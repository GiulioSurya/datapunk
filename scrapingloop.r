library(tidyverse)
library(rvest)

#setwd for useragents, i will upload on web when i will finish
setwd("C:/Users/c_ans/Desktop/bologna lezioni/comunication of statistics")
ualist<-read.table("useragents.txt", sep = "\n")
#create a list of links with all the possible songs
page <- read_html("https://www.whosampled.com/Daft-Punk/sampled/?role=1", user_agent=sample(ualist))
tracks_links <- page %>% html_nodes(".trackCover") %>%
    html_attr("href") %>% paste0("https://www.whosampled.com", .,"sampled/")



#first method
#loop for each link
for (i in length(tracks_links)){
    #read the link and find the number of pages
    page <- read_html(tracks_links[i], user_agent=sample(ualist))
    pages <- page %>% 
  html_elements(".page a") %>% 
  html_text2() %>% 
  last()
  #extract the data from each page
    paste0(tracks_links[i], "?cp=", 1:pages) %>%
        map(~read_html(.,user_agent)) %>% 
        map_dfr(~ html_elements(.x, ".table.tdata tbody tr") %>% 
                    map_dfr(~ tibble(
                        title = html_element(.x, ".trackName.playIcon") %>% 
                            html_text2(),
                        artist = html_element(.x, ".tdata__td3") %>% 
                            html_text2(),
                        year = html_element(.x, ".tdata__td3:nth-child(4)") %>% 
                            html_text2(),
                        genre = html_element(.x, ".tdata__badge") %>% 
                            html_text2()
                    ))) -> tracks
}


#second method
pages_list <- list()
#create a list with all the links and pages
for (i in seq_along(tracks_links)) {
  page<- read_html(tracks_links[1], user_agent = sample(ualist))
  pages <- page %>% 
    html_elements(".page a") %>% 
    html_text2() %>% 
    last()
  pages_list[[i]] <- paste0(tracks_links[i], "?cp=", 1:as.numeric(pages))
}
#extract the data from each page
tracks <- map_df(pages_list, ~read_html(.x) %>%
                    html_elements(".table.tdata tbody tr") %>% 
                    map_dfr(~ tibble(
                      title = html_element(.x, ".trackName.playIcon") %>% 
                        html_text2(),
                      artist = html_element(.x, ".tdata__td3") %>% 
                        html_text2(),
                      year = html_element(.x, ".tdata__td3:nth-child(4)") %>% 
                        html_text2(),
                      genre = html_element(.x, ".tdata__badge") %>% 
                        html_text2()
                    )))


