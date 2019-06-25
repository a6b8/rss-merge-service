#!/usr/bin/env ruby

require 'rufus-scheduler'
require 'rubygems'
require 'zip'
require 'uri'
require 'open-uri'
require 'nokogiri'
require 'cgi'
require 'date'
require "rss"
require 'aws-sdk'
require 'slack/incoming/webhooks'
require 'opml-parser'
include OpmlParser


def helper_remove_html( html, debug )
  result = ""
  Nokogiri::HTML( CGI.unescapeHTML( html ) ).traverse do |e|
    result << e.text if e.text?
  end
  result = result.strip.split(" ").map{ | word | word.capitalize}.join(" ")
  return result
end


def helper_youtube_opml_to_tsv( obj, debug )

  file = File.open( obj[:path][:from] )
  content = file.readlines.join("")

  outlines = OpmlParser.import(content)

  items = []
  for i in 1..outlines.length-1
    index = i
    item = {
      :title => outlines[ index ].attributes[:text],
      :url => outlines[ index ].attributes[:xmlUrl]
    }
    items.push( item )
  end

  tsv = []
  tsv.push( "TITLE" )
  tsv.push( "URL")
  tsv.push( "\n")

  for i in 0..items.length-1
    tsv.push( items[i][:title] )
    tsv.push( items[i][:url] + "")
    tsv.push( "\n")
  end

  str = tsv.join("\t")


  File.open( obj[:path][:to], 'w') { |file| file.write( str ) }
end


def s3_uploadFile( obj, debug )
  aws_s3 = Aws::S3::Resource.new(region: obj[:request][:region])

  name = ""
  if obj[:request][:bucketSubFolder] != ""
    name = obj[:request][:bucketSubFolder]
  end
  
  if obj[:request][:filename] != ""
      name = name + obj[:request][:filename]
  else
    name = name + File.basename(obj[:request][:localPathFull])
  end

  obj[:request][:filename_with_subfolder] = name

  s3_ = aws_s3.bucket(obj[:request][:bucketName]).object(obj[:request][:filename_with_subfolder] )    
  s3_.upload_file obj[:request][:localPathFull], {acl: obj[:request][:access_acl] }

  result = {
    :request => obj[:request],
    :response => {
      :s3_content_response => s3_.content_type,
      :s3_bucketName_response => s3_.bucket.name,
      :s3_fileSize_response => s3_.size,
      :s3_fileHash_response => s3_.hash,
      :s3_lastModified_response => s3_.last_modified,
      :s3_fileKey_response => s3_.key,
      :s3_aclGrant_response => s3_.last_modified,
      :s3_publicUrl_response => s3_.public_url 
    }
  }

  if debug
    puts "   └── " + result[:response][:s3_publicUrl_response]
  end
  
  return result
end


def ga_upload_youtube_html( obj, debug )
  payload = {
    :s3 => {
      :request => {
        :region => obj[:meta][:aws][:region],
        :localPathFull => nil,
        :bucketName => obj[:meta][:aws][:bucket_name],
        :bucketSubFolder => obj[:meta][:aws][:version], ## with "/" default = ""
        :filename => obj[:params][:youtube_html_name], ## default = localpathfull name
        :access_acl => 'public-read'
      },
      :response => {}
    }
  }
  payload[:s3][:request][:localPathFull] = obj[:meta][:files_folder] + obj[:params][:youtube_html_name]
  
  result = s3_uploadFile( payload[:s3], debug )
  return result
end


def ga_entries_rss_to_hash_google( xml, debug )
  doc = Nokogiri::XML xml
  feed = {
      :meta => {
        :title => doc.at("feed").search('title')[0].text.gsub('"',"'"),
        :url => doc.at("feed").search('link')[0].attribute("href").text
      },
      :items => []
  }

  a = doc.at("feed").search('entry')
  for i in 0..a.length-1
    result = ""
    item = {
      :title => nil,
      :description => helper_remove_html( a[i].at("content").text, debug ),
      :time => {
        :stamp => Time.parse( a[i].at("published") ).to_i,
        :utc => a[i].at("published").text
      },
      :url => nil,
      :domain => nil
    }

    url_rss = a[i].at("link").attribute("href")
    item[:url] = CGI.parse(URI.parse( url_rss ).query)["url"][0]
    item[:domain] = URI( item[:url] ).host.split(".")[-2,2].join(".")
    
    item[:title] = feed[:meta][:title].split("-")[1].upcase
    item[:title] += " | "
    item[:title] += item[:domain].upcase
    item[:title] += " | "
    item[:title] += helper_remove_html( a[i].at("title").text, debug )
    
    feed[:items].push( item )
  end

  result = feed
  return result
end


def ga_entries_rss_to_hash_youtube_url( obj, s3, channel, debug )
  item = {
    :url => nil,
    :query => {
      :v => 123,
      :video_id => CGI::parse( obj[:url].split("?")[1])["v"][0],
      :channel_id => CGI.parse(channel.split("?")[1])["channel_id"][0],
      :title => obj[:title]
    }
  }

  item[:url] = 'https://'
  item[:url] += s3[:bucketName]
  item[:url] += '.s3.'
  item[:url] += s3[:region]
  item[:url] += '.amazonaws.com/'
  item[:url] += s3[:bucketSubFolder]
  item[:url] += s3[:youtube_html_name]

  result = item[:url] + "?"
  result += URI.encode_www_form(item[:query])
  return result
end


def ga_entries_rss_to_hash_youtube( xml, s3, debug )
  doc = Nokogiri::XML xml

  feed = {
      :meta => {
        :title => doc.at("feed").search('title')[0].text.gsub('"',"'"),
        :url => doc.at("feed").search('link')[0].attribute("href").text
      },
      :items => []
  }
  
  a = doc.at("feed").search('entry')

  for i in 0..a.length-1
    result = ""
    item = {
      :title => "",
      :description => helper_remove_html( a[i].xpath("//media:description").text, debug ),
      :time => {
        :stamp => Time.parse( a[i].at("published") ).to_i,
        :utc => a[i].at("published").text
      },
      :url => nil,
      :domain => nil
    }
    
    item[:title] = "▫️ " + feed[:meta][:title].upcase + " | " + helper_remove_html( a[i].at("title").text, debug )
    
    threshold = 70
    if item[:description].length >= threshold
      item[:description] = item[:description][0, threshold]
    end

    item[:url] = a[i].at("link").attribute("href").text
    item[:url] = ga_entries_rss_to_hash_youtube_url( item, s3, feed[:meta][:url], debug )
    
    item[:domain] = URI( item[:url] ).host.split(".")[-2,2].join(".")
    feed[:items].push( item )
  end

  result = feed
  return result
end


def ga_entries_merge( feeds, debug )
  list_unsorted = {}

  for i in 0..feeds.length-1
    for j in 0..feeds[i][:items].length-1
      if !list_unsorted.key? feeds[i][:items][j][:time][:stamp]
        list_unsorted[ feeds[i][:items][j][:time][:stamp] ] = []
      end
      list_unsorted[ feeds[i][:items][j][:time][:stamp] ].push( feeds[i][:items][j] )
    end
  end

  list_sorted = []
  a = list_unsorted.keys.sort!
  for i in 0..a.length-1
    for j in 0..list_unsorted[ a[i] ].length-1
      list_sorted.push( list_unsorted[ a[i] ][j] )
    end
  end

  result = list_sorted
  return result
end

def ga_entries_hash_to_rss( obj, debug )
  result = ""
  rss = RSS::Maker.make("atom") do |maker|
    maker.channel.author = obj[:rss][:author]
    maker.channel.updated = Time.now.to_s
    maker.channel.about = obj[:rss][:about]
    maker.channel.title = obj[:rss][:title]

    for i in 0..obj[:rss][:merge].length-1

      index = i
      obj[:rss][:merge][ index ][:url]

      maker.items.new_item do |item|
        item.link = obj[:rss][:merge][ index ][:url]
        item.title = obj[:rss][:merge][ index ][:title]
        item.description = obj[:rss][:merge][ index ][:description]
        item.updated = obj[:rss][:merge][ index ][:time][:utc]
      end
    end
  end

  result = rss.to_s.gsub('<link href="', '<link rel="alternate" href="')
  
  return result
end


def ga_feed_create( obj, debug )
  status = ""
  
  obj[:rss][:about] = "https://"
  obj[:rss][:about] += obj[:s3][:request][:bucketName]
  obj[:rss][:about] += ".s3.eu-central-1.amazonaws.com/"
  obj[:rss][:about] += obj[:s3][:request][:bucketSubFolder]
  obj[:rss][:about] += obj[:s3][:request][:filename]

  obj[:s3][:request][:localPathFull] = obj[:meta][:local]



  for i in 0..obj[:rss][:paths].length-1    
    if debug
      puts "  [" + i.to_s + "]  " + obj[:rss][:paths][i].to_s
    end
    begin
      if obj[:rss][:paths][i][ obj[:rss][:paths][i].length-1, obj[:rss][:paths][i].length ] == "?"
        obj[:rss][:paths][i] = obj[:rss][:paths][i][ 0, obj[:rss][:paths][i].length-1 ]
      end
      response = open( obj[:rss][:paths][i] ).read
    rescue Exception => e
      status += " " + obj[:rss][:paths][i].to_s + "  "
      status += "caught exception #{e}! ohnoes!"
    else
      str = URI( obj[:rss][:paths][i] ).host.split(".")[-2,2].join(".")
      case str
        when "google.com"
          feed = ga_entries_rss_to_hash_google( response, debug )
        when "youtube.com"
          feed = ga_entries_rss_to_hash_youtube( response, obj[:s3][:request], debug )
      end

      obj[:rss][:feeds].push( feed )
    end
  end

  obj[:rss][:merge] = ga_entries_merge( obj[:rss][:feeds], debug)
  obj[:rss][:xml] = ga_entries_hash_to_rss( obj, debug )

  File.open( obj[:meta][:local], "w" ) do |f|
    f.write( obj[:rss][:xml] )
  end
  
  s3_uploadFile( obj[:s3], debug )
  return status
end


def ga_feed_start( pre, debug )
  item = {
    :meta => {
      :local => pre[:temp_folder] + "temp.rss"
    },
    :rss => {
      :paths => pre[:paths],
      :title => pre[:title],
      :about => nil,
      :author => "me",
      :feeds => [],
      :merge => [],
      :xml => "",    
    },
    :s3 => {
      :request => {
        :region => pre[:aws_region],
        :localPathFull => nil,
        :bucketName => pre[:aws_bucket_name],
        :bucketSubFolder => pre[:aws_version], ## with "/" default = ""
        :filename => pre[:filename], ## default = localpathfull name
        :access_acl => 'public-read',
        :youtube_html_name => pre[:youtube_html_name]
      },
      :response => {}
    }
  }
  status = ga_feed_create( item, debug )
  return status
end


def ga_spreadsheet_merge( spreadsheets, debug )

  k = spreadsheets[ 0 ].keys.sort
  cmds = []

  for i in 1..spreadsheets.length-1
    l = spreadsheets[i].keys
    for j in 0..l.length-1
      if !k.include? l[j]
        cmd = {
          :phrase => l[j],
          :index => i
        }
        cmds.push( cmd )
      else  
      end
    end
  end


  for i in 0..cmds.length-1
    if !spreadsheets[0].key? cmds[i][:phrase]
      spreadsheets[0][ cmds[i][:phrase] ] = spreadsheets[ cmds[i][:index] ][ cmds[i][:phrase] ]
    else
      spreadsheets[0][ cmds[i][:phrase] ] = (
        spreadsheets[0][ cmds[i][:phrase] ] + 
        spreadsheets[ cmds[i][:index] ][ cmds[i][:phrase] ]
      ).uniq
    end
  end

  result = spreadsheets[0]
  return result
end


def ga_spreadsheet_get_urls( obj, debug )
  url = "https://spreadsheets.google.com/feeds/cells/"
  url += obj[:id]
  url += "/"
  url += obj[:tab].to_s
  url += "/public/full?alt=json"

  response = open( url.strip ).read
  json = JSON.parse(response)
  all = json["feed"]["entry"]
  groups = {}
  for i in 0..all.length-1
    index = i
    row = json["feed"]["entry"][ index ]["gs$cell"]["row"].to_i
    column = json["feed"]["entry"][ index ]["gs$cell"]["col"].to_i
    if row > obj[:row] and column == obj[:column]
      if obj[:tab] >= 2
        a = URI( URI.decode( json["feed"]["entry"][ index ]["gs$cell"]["$t"] ) )
      else
        a = json["feed"]["entry"][ index ]["gs$cell"]["$t"]
      end
      
      if a.to_s.length > 0
        case obj[:tab]
          when 1
            query = json["feed"]["entry"][ index ]["gs$cell"]["$t"].split("?")
            value = query[0].split("=")[1]
            category = query[1].split("=")[1]
          when 2..10
            b = CGI::parse( URI(json["feed"]["entry"][ index ]["gs$cell"]["$t"]).query )
            category = b["category"].join("")
            b.delete("category")
            value = a.scheme + "://" + a.host + a.path + "?" + URI.encode_www_form(b)
        end

        if !groups.key? category
          groups[ category ] = []
        end

        groups[ category ].push( value )
      end
    end
  end
  result = groups
  return result
end


def ga_spreadsheet_start( obj, debug )
  
  spreadsheets = []
  for i in 0..obj[:meta][:feeds].length-1
    index = i
    spreadsheets[ index ] = ga_spreadsheet_get_urls( obj[:meta][:feeds][ index ], debug )
  end
  
  a = ga_spreadsheet_merge( spreadsheets, debug )
  keys = a.keys.sort!
  keys.delete( obj[:params][:delete] )
  status = ""
  status += "*RSS*\n"
  
  feeds = []
  for i in 0..keys.length-1
    if debug
      puts " " + keys[i]
    end
    status += "  [" + i.to_s + "] "
    pre = {
      :filename => ( keys[i] + ".xml" ).gsub( " ", "-" ).downcase,
      :paths => a[ keys[i] ],
      :title => keys[i].gsub( "_", " " ).split(" ").map{ | word | word.capitalize}.join(" "),
      :aws_region => obj[:meta][:aws][:region],
      :aws_bucket_name => obj[:meta][:aws][:bucket_name],
      :aws_version => obj[:meta][:aws][:version],
      :temp_folder => obj[:meta][:temp_folder],
      :youtube_html_name => obj[:params][:youtube_html_name]
    }
    status += pre[:title]
    pre[:paths] = pre[:paths].to_set.to_a
    
    feed = "https://"
    feed += obj[:meta][:aws][:bucket_name]
    feed += ".s3."
    feed += obj[:meta][:aws][:region]
    feed += ".amazonaws.com/"
    feed += obj[:meta][:aws][:version]
    feed += pre[:filename].to_s
    
    #puts ">>"
    #puts feed
    #puts pre[:filename]
    #puts "<<"
    
    status += ga_feed_start( pre, debug )  
    status += " >> OPML | "
    #status += "\n       "
    status += feed
    status += "\n"
    
    opml = {
      :title => pre[:title],
      :url => feed,
    }
    
    feeds.push( opml )
  end
  
  if debug
    puts
  end

  # status += "https://docs.google.com/spreadsheets/d/"
  # status += obj[:meta][:feed][:id]
  # status += "/edit#gid=0"
  # status += "\n"

  result = {
    :feeds => feeds,
    :status => status
  }
  
  return result
end


def ga_opml_generate( obj, index, debug )
  item = {
    :path => obj[:meta][:temp_folder] + "temp.opml",
    :title => obj[:opml][:tasks][ index ][:title],
    :filter => obj[:opml][:tasks][ index ][:filter],
    :feeds => obj[:opml][:feeds][:feeds],
    :s3 => {
      :request => {
        :region => obj[:meta][:aws][:region],
        :localPathFull => nil,
        :bucketName => obj[:meta][:aws][:bucket_name],
        :bucketSubFolder => obj[:meta][:aws][:version], ## with "/" default = ""
        :filename => nil, ## default = localpathfull name
        :access_acl => 'public-read'
      },
      :response => {}
    }  
  }
  
  item[:s3][:request][:localPathFull] = item[:path]
  item[:s3][:request][:filename] = item[:title].gsub(" ", "-").downcase + ".opml"

  outlines = []
  for i in 0..item[:feeds].length-1
    index = i
    for j in 0..item[:filter].length-1
      str = item[:feeds][ index ][:title].downcase.gsub(" ", "-")

      if str.eql? item[:filter][j]
        feed = {
          :text => "", 
          :title => item[:feeds][ index ][:title], 
          :type => "rss",
          :xmlUrl => item[:feeds][ index ][:url],
          :htmlUrl => item[:feeds][ index ][:url]
        }

        outline = OpmlParser::Outline.new( feed )
        outlines.push( outline )
      end
    end
  end

  opml = OpmlParser.export( outlines, item[:title] )
  output = File.new( item[:path], "w")
  output.puts( opml )
  output.close

  status = s3_uploadFile( item[:s3], debug )
  return status[:response][:s3_publicUrl_response]
end


def ga_opml_start( obj, debug )
  from = ga_spreadsheet_get_urls( obj[:meta][:opml], debug )
  from.keys.each { | a |
    task = {
      :title => a,
      :filter => from[a]
    }
    obj[:opml][:tasks].push( task ) 
  }
  
  if debug
    puts "OPML"
    puts " Single"
  end

  status = ""
  for i in 0..obj[:opml][:tasks].length-1
    index = i
    status += ga_opml_generate( obj, index, debug )
    status += "\n"
  end
  
  result = status
  return result
end


def ga_slack_start( cmd, debug )
  slack_url = "https://hooks.slack.com/services/"
  slack_url += cmd[:id]

  slack = Slack::Incoming::Webhooks.new slack_url
  slack.post cmd[:message]
  return true
end

def ga_zip_start( obj, debug )
  item = {
    :path => {
      :root => obj[:meta][:temp_folder],
      :download => {
          :to => "",
          :from => ""
      },
      :zip => {
          :to => "",
          :filename => obj[:params][:opml_zip_name]
      }
    },
    :opmls => {
      :local => [],
      :web => obj[:opml][:status]
    },
    :s3 => {
      :request => {
        :region => obj[:meta][:aws][:region],
        :localPathFull => nil,
        :bucketName => obj[:meta][:aws][:bucket_name],
        :bucketSubFolder => obj[:meta][:aws][:version], ## with "/" default = ""
        :filename => obj[:params][:opml_zip_name], ## default = localpathfull name
        :access_acl => 'public-read'
      },
      :response => {}
    }
  }

  item[:path][:zip][:to] = item[:path][:root] + item[:path][:zip][:filename]
  item[:s3][:request][:localPathFull] = item[:path][:zip][:to]

  for i in 0..item[:opmls][:web].length-1
    index = i
    item[:path][:download][:from] = item[:opmls][:web][ index ].strip
    item[:path][:download][:to] = item[:path][:root] + File.basename( item[:path][:download][:from] )

    File.open( item[:path][:download][:to], "wb") do | saved_file |
      open( item[:path][:download][:from], "rb" ) do | read_file |
        saved_file.write( read_file.read )
      end
    end
    item[:opmls][:local].push( item[:path][:download][:to] )
  end

  FileUtils.rm_f item[:path][:zip][:to]

  Zip::File.open( item[:path][:zip][:to], Zip::File::CREATE) do | zipfile |
    item[:opmls][:local].each do | filename |
      filename = File.basename( filename )
      zipfile.add(
        filename, 
        File.join(
          item[:path][:root], 
          "" + filename
        )
      )
    end
  end
  item[:opmls][:local].each { | file |
    FileUtils.rm file
  }
  
  if debug
    puts " Zip"
  end
  
  item[:s3] = s3_uploadFile( item[:s3], debug )
  
  status = "\n"
  status += "   >"
  status += item[:s3][:response][:s3_publicUrl_response]
  
  return status
end

def ga_environment_variables()
  params = {
    :data => {
      :aws => {
        :region => nil,
        :id => nil,
        :secret => nil,
        :bucket_name => nil,
        :version => nil
      },
      :slack => nil,
      :spreadsheet => nil,
      :cron_generate => nil,
      :cron_status => nil,
      :debug => nil,
      :stage => nil
    }
  }

  for i in 0 ... ARGV.length
    key = ARGV[i].split("=")[0]
    value = ARGV[i].split("=")[1].gsub('"','')

    if key.include? "_FILE"
      value = File.open( "" + value, "r") do |f|
        f.each_line do |line|
        end
      end
      key = key[ 0, key.length-5 ]
    end

    case key
      when "AWS_REGION"
        params[:data][:aws][:region] = value
      when "AWS_ID"
        params[:data][:aws][:id] = value
      when "AWS_SECRET"
        params[:data][:aws][:secret] = value
      when "AWS_BUCKET_NAME"
        params[:data][:aws][:bucket_name] = value
      when "AWS_VERSION"
        params[:data][:aws][:version] = value
      when "SLACK"
        params[:data][:slack] = value
      when "SPREADSHEET"
        params[:data][:spreadsheet] = value 
      when "CRON_GENERATE"
        params[:data][:cron_generate] = value
      when "CRON_STATUS"
        params[:data][:cron_status] = value
      when "DEBUG"
        params[:data][:debug] = JSON.parse( value )
      when "STAGE"
        params[:data][:stage] = value.downcase
    else
    end
  end
  return params
end

def ga_start( params )
  hash = {
    :meta => {
      :feeds => [
        {
          :ident => "Youtube",
          :id => params[:data][:spreadsheet],
          :tab => 2,
          :row => 5,
          :column => 1
        },
        {
          :ident => "Google Alerts",
          :id => params[:data][:spreadsheet],
          :tab => 3,
          :row => 5,
          :column => 1
        }
      ],
      :opml => {
        :id => params[:data][:spreadsheet],
        :tab => 1,
        :row => 13,
        :column => 1
      },
      :slack => params[:data][:slack],
      :aws => {
        :id => params[:data][:aws][:id],
        :secret => params[:data][:aws][:secret],
        :region => params[:data][:aws][:region],
        :bucket_name => params[:data][:aws][:bucket_name],
        :version => params[:data][:aws][:version]
      },
      :temp_folder => "./temp/",
      :files_folder => "./files/"
    },
    :params => {
      :delete => "Other",
      :opml_zip_name => "opml.zip",
      :youtube_html_name => "index.html"
    },
    :opml => {
      :tasks => [],
      :feeds => nil,
      :status => []
    }
  }

  Aws.config.update({
    credentials: Aws::Credentials.new(
      hash[:meta][:aws][:id], 
      hash[:meta][:aws][:secret]
    )
  })

  debug = params[:data][:debug]

  hash[:opml][:feeds] = ga_spreadsheet_start( hash, debug )
  ga_upload_youtube_html( hash, debug )
  hash[:opml][:feeds][:status] += "\n"
  hash[:opml][:feeds][:status] += "*OPML*\n"
  hash[:opml][:status] = ga_opml_start( hash, debug ).split("\n")
  hash[:opml][:feeds][:status] += hash[:opml][:status].join("\n")
  hash[:opml][:feeds][:status] += "\n"
  hash[:opml][:feeds][:status] += ga_zip_start( hash, debug )

  if debug
    cmd = {
      :id=> hash[:meta][:slack],
      :message => hash[:opml][:feeds][:status]
    }
    ga_slack_start( cmd, debug )
  end
end 

scheduler = Rufus::Scheduler.new
params = ga_environment_variables()

stats = {
  :success => 0,
  :error => 0
}

if params[:data][:stage] == "production"

  if params[:data][:debug]
    puts "Initialize"
  end

  scheduler.cron params[:data][:cron_status] do
    cmd = {
      :id => params[:data][:slack],
      :message => "*STATUS: * Success " + stats[:success].to_s + " | Error " + stats[:error].to_s
    }
    ga_slack_start( cmd, params[:data][:debug] )
    stats = {
      :success => 0,
      :error => 0
    }
  end

  scheduler.cron params[:data][:cron_generate] do
    begin
      ga_start( params )
      stats[:success] = stats[:success] + 1
    rescue
      stats[:error] = stats[:error] + 1
    end
  end
else
  ga_start( params )
end



scheduler.join