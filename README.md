![alt text](https://github.com/a6b8/rss-merge-docker/blob/master/images/curlai-logo-black--50.png)

## Proof-of-Concept (v.01)
Working Prototyp for longtime User Testing.


### General Idea
- Show Media in the fastest possible way, no clutter and distraction free.
- Use Open Webstandards for distribution.
- Generate own index.html for media content to fastest loading and features
- A Input is a RSS(XML) or JSON File (only RSS - currently)


### Structure
- Every inputsource is in one category.
- Every category has one mode (Morning, Evening...)
- Every category generate a .rss (xml) file
- Every mode generate a .opml (Rss Grouping) file


### Prototyp
#### User Interface
Using a Google Spreadsheet as Interface. For Transmitting the Spreadsheet is set public and readable as json.:

The Spreadsheet do:
- Sort Sources by Category 
- Set Names
- Generate URL with Parameters
- Helper: Discovering Content Creator ID Number (importxml)

Overview
<img src="https://github.com/a6b8/rss-merge-docker/blob/master/images/overview.png" alt="alt text" height="400">

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


| website        | Media           | Cool  |
| ------------- |:-------------:| -----:|
| Arxiv.org      | right-aligned | $1600 |
| Craiglist.com      | centered      |   $12 |
| de.Wikipedia.com | are neat      |    $1 |
| en.Wikipedia.com | are neat      |    $1 |
| Discogs.com | are neat      |    $1 |
| Ebay.de | are neat      |    $1 |
| Epo.org | are neat      |    $1 |
| Google Trends | are neat      |    $1 |
| Instagram | are neat      |    $1 |
| Kickstarter | are neat      |    $1 |
| Medium.com | are neat      |    $1 |
| Reddit.com | are neat      |    $1 |
| Stackoverflow.com | are neat      |    $1 |
| Thingiverse.com | are neat      |    $1 |
| Twitch.com | are neat      |    $1 |


