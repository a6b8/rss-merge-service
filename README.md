![alt text](https://github.com/a6b8/rss-merge-docker/blob/master/images/curlai-logo-black--50.png)

## Proof-of-Concept (v.01)
Working Prototyp for longtime User Testing.


### General Idea
- Show Media in the fastest possible way, no clutter and distraction free.
- Use Open Webstandards for distribution.
- Generate own index.html for media content to fastest loading and features
- A Input is a RSS(XML) or JSON File (only RSS - currently)


### Structure
- Every Inputsource gets one Category.
- Every Category in one Mode (Morning, Evening...)
- Every Category generate a RSS (XML) File
- Every Mode generate a OPML (RSS Grouping) File


### Prototyp
**User Interface**
Using a Google Spreadsheet as Interface. For Transmitting the Spreadsheet is set public and readable as json.:

The Spreadsheet do:
- Sort Sources by Category 
- Set Names
- Generate URL with Parameters
- Helper: Discovering Content Creator ID Number (importxml)

Overview

Detail (Video)




**Backend**
Docker-Hub Repo: https://hub.docker.com/r/a6b8/rss-merger

- Single Docker Container > Docker-Compose / Secrets Ready!



```yaml
version: "3.1"
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

![alt text](https://github.com/a6b8/rss-merge-docker/blob/master/images/detail.png)


Video
- Youtube

Web
- Google Alert 


Checked:
- Arxiv.org
- Craiglist.com
- de.Wikipedia.com
- Discogs.com
- Ebay.de
- en.Wikipedia.com
- Epo.org
- Google Trends
- Instagram
- Kickstarter
- Medium.com
- Reddit.com
- Stackoverflow.com
- Thingiverse.com
- Twitch.com
