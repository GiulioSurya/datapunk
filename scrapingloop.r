library(tidyverse)
library(rvest)


setwd("C:/Users/c_ans/Desktop/bologna lezioni/comunication of statistics")
ualist<-read.table("useragents.txt", sep = "\n")

page <- read_html("https://www.whosampled.com/Daft-Punk/sampled/?role=1", user_agent=sample(ualist))
tracks_links <- page %>% html_nodes(".trackCover") %>%
    html_attr("href") %>% paste0("https://www.whosampled.com", .,"sampled/")
    
for (i in length(tracks_links)){
    page <- read_html(tracks_links[i], user_agent=sample(ualist))
    pages <- page %>% 
  html_elements(".page a") %>% 
  html_text2() %>% 
  last()
    paste0(tracks_links[i], "?cp=", 1:pages) %>%
    #i need to add an user agent
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


str_c("https://www.whosampled.com/Daft-Punk/Harder,-Better,-Faster,-Stronger/sampled/?cp=", 1:pages) %>% 
  map(read_html) %>% 
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
            )))


for (i in length(tracks_links)){
    page <- read_html(tracks_links[i], user_agent=sample(ualist))
    pages <- page %>% 
  html_elements(".page a") %>% 
  html_text2() %>% 
  last()
    str_c(tracks_links[i], "?cp=", 1:pages) %>%
    #i need to add an user agent
        map(read_html) %>% 
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
