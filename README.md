![alt text](https://github.com/a6b8/rss-merge-docker/blob/master/images/curlai-logo-black--50.png)

Information on Rails.

*Table of Contents*

- [Overview](#overview)
- [Prototype](#prototype)
  - [Dashboard](#dashboard)
  - [User Interface](#user-interface)
  - [Browser Extension](#browser-extension)
  - [Backend](#backend)
- [Future](#future)


## Overview

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



## Prototyp (Version Ashby)
Getting things running. 

*Focus:*
- [x] Reclutter Headlines and Text
- [x] Setup Template Structure
- [x] Generate a Datasets for diffrent user purposes
- [x] Longtime User Testing.


### Dashboard
> Using a Google Spreadsheet as Interface. The Spreadsheet is set to public and consumable in json format.:

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


- With 2 .opml files the Reader imports more then 20 Categories.
- The headline from every inputsources has the same structure
- Default View is set to Webview.

*Headlines:*

- Every Source merges into the same headline structure. 
- Content gets mixable, and easier to read.


*Example:*

▫️ LEX FRIDMAN | Most Research In Deep Learning Is A Total Waste Of Time - Jeremy Howard | Ai Podcast Clips

1. Content-Symbol 
2. CHANNEL_NAME 
3. Split " | " 
4. Titleized-Content-Name-Without-Emojis


<img src="https://github.com/a6b8/curlai/blob/master/images/reader.png" alt="alt text" height="300">

### Browser Extension


### Backend
> All processes run (currently) in one docker container. As container distrubution we use [Rancher 1.6](https://rancher.com)


*Features:*
- All Environment Variables are docker secrets ready!
- Generating Files is controlled and scheduled over a cron
- Console Log is controllable over environment variables


*Environment Variables:*

- Aws S3: Write rss, opml and templates, access to public.
```yaml
AWS_REGION= # -string
AWS_ID= #-string
AWS_SECRET= # -string
AWS_BUCKET_NAME= # -string
AWS_VERSION= # -string must end with "/"
```

- Slack Channel: Send Status Logs
```yaml
SLACK= # -string
CRON_STATUS= # -cron string
```

<img src="https://github.com/a6b8/curlai/blob/master/images/slack.png" alt="alt text" height="300">



- Google Spreadsheet: First Tab needs to be a overview site. next two detail sites. Its configable in `index.rb`
```yaml
SPREADSHEET= # -string
```

- Cron: Sets the schedule times.
```yaml
CRON_GENERATE= # -cron string

```

- Console Logs: Enable Logs.
```yaml
DEBUG= # -boolean
STAGE= # -string production or development
```


*Local:*
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


*With Docker Secrets:*
```yaml
version: '2'
services:
  curlai:
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

*Docker Hub:* 
- https://hub.docker.com/r/a6b8/rss-merger



## Future

| Website        | Media           | Source  | Link |
| ------------- |:-------------:|:-----:|:-----:|
| Arxiv      | Website | xml | [Link](http://arxiv.org/rss/cs.LG) |
| Craiglist      | Website      | xml | [Link](https://berlin.craigslist.org/search/jjj?format=rss) |
| Wikipedia DE | Website      | xml | [Link](https://de.wikipedia.org/w/api.php?action=featuredfeed&feed=onthisday&feedformat=atom) |
| Wikipedia EN | Website      | xml | [Link](https://tools.wmflabs.org/ifttt-testing/ifttt/v1/triggers/article_of_the_day?lang=en) |
| Discogs | Website      | xml | [Link](https://www.discogs.com/sell/mplistrss?genre=Hip+Hop&q=jay-z&format=Vinyl&output=rss) |
| Ebay DE | Website      | xml | [Link](https://www.ebay.de/sch/Rap-Hip-Hop/1589/i.html?_from=R40&LH_Auction=1&_nkw=hip+hop+vinyl&_sop=1&_rss=1) |
| Epo | Website     | xml | [Link](https://register.epo.org/rssSearch?query=txt+%3D+k%C3%BCnstliche+and+txt+%3D+intelligenz&lng=de) |
| Google Trends | overview      | xml | [Link](https://trends.google.com/trends/trendingsearches/daily/rss?geo=DE) |
| Instagram | video      | xml | [Link](https://rsshub.app/instagram/user/nyjah) |
| Kickstarter | video      | json | [Link](https://www.kickstarter.com/discover/advanced?category_id=16&sort=newest&format=json&page=2) |
| Medium | Website      | xml | [Link](https://medium.com/feed/topic/artificial-intelligence) |
| Reddit | Website      | xml | [Link](https://www.reddit.com/r/Datasets/.rss) |
| Stackoverflow | Website      | xml | [Link](https://stackoverflow.com/feeds/tag?tagnames=three.js&sort=newest) |
| Vimeo | video |  xml | ... |
| Thingiverse.com | Website      | xml | [Link](https://www.thingiverse.com/rss/featured) |
| Twitch.com | video      | xml | [Link](http://twitchrss.appspot.com/vod/ryukahr) |


