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
<b>Overview</b><br>
More then 20 Categories in 3 Modes from 596 Sources<br>
<img src="https://github.com/a6b8/rss-merge-docker/blob/master/images/overview.png" alt="alt text" height="300"><br><br>
<b>Detail (Video)</b><br>
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


