![alt text](https://github.com/a6b8/rss-merge-docker/blob/master/images/curlai-logo-black--50.png)

## Proof-of-Concept (v.01)
Working Prototyp for Longtime User Testing.


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



------



### Prototyp
#### User Interface
> Using a Google Spreadsheet as Interface. For Transmitting the Spreadsheet is set public and readable as json.:

The Spreadsheet do:
- Sort Sources by Category 
- Set Names
- Generate URL with Parameters
- Helper: Discovering Content Creator ID Number (importxml)

**Overview**<br>
More then 20 Categories in 3 Modes from 596 Sources<br>
<img src="https://github.com/a6b8/rss-merge-docker/blob/master/images/overview.png" alt="alt text" height="300">
**Detail (Video)**
<img src="https://github.com/a6b8/rss-merge-docker/blob/master/images/detail.png" alt="alt text" height="300">



#### Backend
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






### Future

| website        | Media           | Source  |
| ------------- |:-------------:| -----:|
| Arxiv      | website | $1600 |
| Craiglist      | website      |   $12 |
| Wikipedia DE | website      |    $1 |
| Wikipedia EN | website      |    $1 |
| Discogs | website      |    $1 |
| Ebay DE | website      |    $1 |
| Epo | website     |    $1 |
| Google Trends | overview      |    $1 |
| Instagram | video      |    $1 |
| Kickstarter | video      |    $1 |
| Medium | website      |    $1 |
| Reddit | website      |    $1 |
| Stackoverflow | website      |    $1 |
| Vimeo | video | 
| Thingiverse.com | website      |    $1 |
| Twitch.com | video      |    $1 |


