![alt text](https://github.com/a6b8/rss-merge-docker/blob/master/images/curlai-logo-black--50.png)

## Proof-of-Concept (v.01)

Working Prototyp for longtime user test.
Docker-Hub Repo: https://hub.docker.com/r/a6b8/rss-merger

### Features
- Update Subscribtion List by Google Spreadsheet.
- Single Docker Container > Docker-Compose / Secrets Ready!

![alt text](https://github.com/a6b8/rss-merge-docker/blob/master/images/detail.png)

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
