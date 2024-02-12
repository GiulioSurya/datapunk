## **Data Punk**

 Data visualization project on Daft Punk, focusing on the exploration of genres that influenced the duo and how this influence shaped their music. The ultimate goal is to create a static page with the analysis results accompanied by a scrolling narrative.

 
The idea originated within the context of a data visualization project at the University of Bologna. The aim is to leverage both libraries like ggplot in R and data visualization tools to create an enjoyable narrative on the musical evolution of the duo. The inspiration comes from [samplingdonuts.com](https://samplingdonuts.com/), while the data has been collected from whosampled.com.



https://github.com/GiulioSurya/datapunk/assets/153427674/64cf2fb7-1acf-44b5-a2b6-15736bafe106

The work is divided into two sections, the first one involves scraping data from [WhoSampled](https://www.whosampled.com/Daft-Punk/sampled/?role=1), while the second one involves creating ggplot graphs and the static page that will host the analysis and data scrolling.

## Scraping
The first issue with this scraping arises from the need for a user agent to ensure that the server accepts the request. I used a list generated through [this website](https://user-agent-generator-220418.netlify.app/#/random). The first loop draws from a list of 500 possible user agents and selects the first one that grants access to the site, saving it in the "ua_success" object.

The second loop is necessary to recreate the URLs of all the tracks by Daft Punk. Since there are 8 pages to scrape, the loop runs from 1 to 8, reconstructing the URLs of the tracks present on each page. Each of the 74 generated links (representing the Daft Punk tracks that have been sampled) can have multiple pages depending on how many artists/tracks have used that Daft Punk track as a sample. Therefore, for each Daft Punk track, there can be multiple tracks, necessitating the reconstruction of the link for each of these. The "title", "artist", "year", and "part sampled" information is all within these URLs, and this task is handled by the third loop.

The last piece of information, the "genre", unfortunately, is not on the same pages as the others. Hence, it is necessary to recreate the link for each track. This part was the most complex, requiring the recreation of hundreds of links. In the end, I found a somewhat "fancy" method that utilizes the "title" and "artist" variables to recreate the links. However, some data cleaning work is required beforehand.

Once the data is ready, it's possible to generate the graphs. A more detailed explanation is provided within the code. Below is a brief idea of how the page will be structured. This won't be its final structure but simply serves to give an idea.

To reproduce the code, it's simply necessary to run the individual code parts. Remember to authenticate through the terminal when the "read_sheet" function is launched; this is necessary to read the data. In the scraping process, a Sys.sleep has been set. The time can be arbitrarily changed considering that some loops consist of hundreds of elements (especially the fourth one). Avoid running the code block all at once; I recommend doing it in parts and waiting for feedback. this also applies to donut code.

## Let's Have Some Donut!

The Daft Punk were a celebrated French musical duo formed by musicians Thomas Bangalter and Guy-Manuel de Homem-Christo. Active from 1993 until 2021, they gained international fame for their contributions to electronic music and influenced numerous artists and musical genres.

They, too, were influenced by modern music, especially the most active musical currents between the 1960s and 1990s. Many famous pieces were sampled to create some of the duo's most successful singles. The albums "Homework" and "Discovery" are the ones that most prominently featured the use of samples in their production.

This donut chart, reminiscent of an LP (special thanks to Sampling Donut for the idea), represents the Daft Punk tracks that used samples during their production.

![donutrecord](https://github.com/GiulioSurya/datapunk/assets/153427674/8f751c66-a35c-496d-bb45-2b1ffd456e2c)

## **The Legacy**

The duo was likely one of the most influential groups of the last few decades, but how influential were they, and especially in what genre was this influence felt? And which elements of their tracks were most widely used?

![sampled_bar_absolute](https://github.com/GiulioSurya/datapunk/assets/153427674/58792dd9-f047-4b90-88d6-1f5e20658557)

From the graph, it's evident that their influence in electronic music was significant. However, based on the individual elements of their tracks that have been sampled and used across various genres examined, it's even more apparent how the duo influenced not only electronic music but beyond.

![sampled_bar](https://github.com/GiulioSurya/datapunk/assets/153427674/64b4d6d4-1d50-45b6-8299-7fb6b662e659)








