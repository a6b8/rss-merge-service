![alt text](https://github.com/a6b8/rss-merge-docker/blob/master/images/curlai-logo-black--50.png)

Information on Rails.


## General

*Focus:*
- Show Media in the fastest possible way, no clutter and distraction free.
- Use Open Webstandards for distribution.
- Generate own index.html for media content to fastest loading and features
- A Input is a RSS(XML) or JSON File (only RSS - currently)


*Structure:*
- Every inputsource is in one category.
- Every category has one mode (Morning, Evening...)
- Every category generate a .rss (xml) file
- Every mode generate a .opml (Rss Grouping) file



------



## Prototyp (Test Environment)

*Focus:*
- Get things running
- Reclutter Headlines and Text
- Setup Template Structure
- Generate a Datasets for diffrent user purposes
- Longtime User Testing.


### Dashboard
> Using a Google Spreadsheet as Interface. For Transmitting the Spreadsheet is set public and readable as json.:

*Tasks:*
- Sort Sources by Category 
- Set Names
- Generate URL with Parameters
- Discovering Content Creator ID Number for importxml
<br>

*Overview:*
- 1200 Sources (Videos, Websites)
- 22 Categories (Art, Programming...)
- 3 Modes (Morning, Evening...)

<img src="https://github.com/a6b8/rss-merge-docker/blob/master/images/overview.png" alt="alt text" height="300">



*Detail:*
- Rearrange category by dropdown


<img src="https://github.com/a6b8/rss-merge-docker/blob/master/images/detail.png" alt="alt text" height="300">

### User Interface
> Every RSS Reader with Webview & Opml Import is capable to show the content.
We use [Leaf for Mac](https://apps.apple.com/us/app/leaf-rss-news-reader/id576338668?mt=12)


- Over 600 Inputsources get imported over 2 .opml files. 
- The headline from every inputsources has the same structure

**Headline Structure**

*Headline*:
▫️ LEX FRIDMAN | Most Research In Deep Learning Is A Total Waste Of Time - Jeremy Howard | Ai Podcast Clips


Content-Symbol CHANNEL_NAME | Titleized-Content-Name-Without-Emojis


<img src="https://github.com/a6b8/curlai/blob/master/images/reader.png" alt="alt text" height="300">

### Backend
> All processes run (currently) in one docker container. As container distrubution we use [Rancher 1.6](https://rancher.com)

Features:
- All Environment Variables are docker secrets ready!
- Generating Files is controlled and scheduled over a cron
- Console Log is controllable over environment variables



Docker-Hub Repo: https://hub.docker.com/r/a6b8/rss-merger

**Development**
```yaml
version: "2"
services:
  curlai:
    build: .
    environment:
      AWS_REGION : ${AWS_REGION}
      AWS_ID : ${AWS_ID}
      AWS_SECRET : ${AWS_SECRET}
      AWS_BUCKET_NAME : ${AWS_BUCKET_NAME}
      AWS_VERSION : ${AWS_VERSION}
      SLACK : ${SLACK}
      SPREADSHEET : ${SPREADSHEET}
      CRON_GENERATE : ${CRON_GENERATE}
      CRON_STATUS : ${CRON_STATUS}
      DEBUG : ${DEBUG}
      STAGE : ${STAGE}
```


**Production (with Docker Secrets)**
```yaml
version: '2'
services:
  rss-merger-rss-13plus-com:
    image: a6b8/rss-merger:v8
    environment:
      AWS_BUCKET_NAME_FILE: /run/secrets/curlai--aws-bucket-name
      AWS_ID_FILE: /run/secrets/curlai--aws-id
      AWS_REGION_FILE: /run/secrets/curlai--aws-region
      AWS_SECRET_FILE: /run/secrets/curlai--aws-secret
      AWS_VERSION_FILE: /run/secrets/curlai--aws-version
      CRON_GENERATE_FILE: /run/secrets/curlai--cron-generate
      CRON_STATUS_FILE: /run/secrets/curlai--cron-status
      DEBUG_FILE: /run/secrets/curlai--debug
      SLACK_FILE: /run/secrets/curlai--slack
      SPREADSHEET_FILE: /run/secrets/curlai--spreadsheet
      STAGE_FILE: /run/secrets/curlai--stage
    secrets:
    - curlai--aws-region
    - curlai--aws-id
    - curlai--aws-secret
    - curlai--aws-bucket-name
    - curlai--aws-version
    - curlai--slack
    - curlai--spreadsheet
    - curlai--cron-generate
    - curlai--cron-status
    - curlai--debug
    - curlai--stage
secrets:
  curlai--aws-version:
    external: 'true'
  curlai--stage:
    external: 'true'
  curlai--cron-generate:
    external: 'true'
  curlai--aws-id:
    external: 'true'
  curlai--spreadsheet:
    external: 'true'
  curlai--debug:
    external: 'true'
  curlai--aws-bucket-name:
    external: 'true'
  curlai--aws-secret:
    external: 'true'
  curlai--slack:
    external: 'true'
  curlai--aws-region:
    external: 'true'
  curlai--cron-status:
    external: 'true'
```


## Future

| Website        | Media           | Source  | Link |
| ------------- |:-------------:|:-----:|:-----:|
| Arxiv      | website | RSS | [Link](http://arxiv.org/rss/cs.LG) |
| Craiglist      | website      | RSS | [Link](https://berlin.craigslist.org/search/jjj?format=rss) |
| Wikipedia DE | website      | RSS | [Link](https://de.wikipedia.org/w/api.php?action=featuredfeed&feed=onthisday&feedformat=atom) |
| Wikipedia EN | website      | RSS | [Link](https://tools.wmflabs.org/ifttt-testing/ifttt/v1/triggers/article_of_the_day?lang=en) |
| Discogs | website      | RSS | [Link](https://www.discogs.com/sell/mplistrss?genre=Hip+Hop&q=jay-z&format=Vinyl&output=rss) |
| Ebay DE | website      | RSS | [Link](https://www.ebay.de/sch/Rap-Hip-Hop/1589/i.html?_from=R40&LH_Auction=1&_nkw=hip+hop+vinyl&_sop=1&_rss=1) |
| Epo | website     | RSS | [Link](https://register.epo.org/rssSearch?query=txt+%3D+k%C3%BCnstliche+and+txt+%3D+intelligenz&lng=de) |
| Google Trends | overview      | RSS | [Link](https://trends.google.com/trends/trendingsearches/daily/rss?geo=DE) |
| Instagram | video      | RSS | [Link](https://rsshub.app/instagram/user/nyjah) |
| Kickstarter | video      | JSON | [Link](https://www.kickstarter.com/discover/advanced?category_id=16&sort=newest&format=json&page=2) |
| Medium | website      | RSS | [Link](https://medium.com/feed/topic/artificial-intelligence) |
| Reddit | website      | RSS | [Link](https://www.reddit.com/r/Datasets/.rss) |
| Stackoverflow | website      | RSS | [Link](https://stackoverflow.com/feeds/tag?tagnames=three.js&sort=newest) |
| Vimeo | video |  RSS | ... |
| Thingiverse.com | website      | RSS | [Link](https://www.thingiverse.com/rss/featured) |
| Twitch.com | video      | RSS | [Link](http://twitchrss.appspot.com/vod/ryukahr) |


