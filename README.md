![alt text](https://github.com/a6b8/rss-merge-docker/blob/master/images/curlai-logo-black--50.png)

Information on Rails.
Working Prototyp for Longtime User Testing.


## General Idea
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



## Prototyp
### User Interface
> Using a Google Spreadsheet as Interface. For Transmitting the Spreadsheet is set public and readable as json.:

Tasks:
- Sort Sources by Category 
- Set Names
- Generate URL with Parameters
- Helper: Discovering Content Creator ID Number (importxml)
<br>
**Overview**<br>
More then 20 Categories in 3 Modes from 596 Sources<br>
<img src="https://github.com/a6b8/rss-merge-docker/blob/master/images/overview.png" alt="alt text" height="300"><br><br>
**Detail (Video)**<br>
<img src="https://github.com/a6b8/rss-merge-docker/blob/master/images/detail.png" alt="alt text" height="300">

### Backend
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






## Future

| Website        | Media           | Source  |
| ------------- |:-------------:| -----:|
| Arxiv      | website | RSS |
| Craiglist      | website      | RSS |
| Wikipedia DE | website      | RSS |
| Wikipedia EN | website      | RSS |
| Discogs | website      | RSS |
| Ebay DE | website      | RSS |
| Epo | website     | RSS |
| Google Trends | overview      | RSS |
| Instagram | video      | RSS |
| Kickstarter | video      | JSON |
| Medium | website      | RSS |
| Reddit | website      | RSS |
| Stackoverflow | website      | RSS |
| Vimeo | video |  RSS |
| Thingiverse.com | website      | RSS |
| Twitch.com | video      | RSS |


