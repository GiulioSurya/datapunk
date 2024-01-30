library(tidyverse)
library(rvest)
library(googlesheets4)
library(httr)

#create an user agent list
ualist<-read_sheet("https://docs.google.com/spreadsheets/d/1FduIFZUJcPFzKWm2qxdQw4qZo1nJwnLf9n5ddtR1w5A/edit#gid=0")

#select an user agent that works
ua_success <- character()
for(i in 200:499) {
  response <- httr::GET("https://www.whosampled.com/Daft-Punk/sampled/?role=1", 
                        add_headers(`User-Agent` = as.character(ualist[i,])))
  if(response$status_code == 200) {
    ua_success <- c(ua_success, as.character(ualist[i,]))
    break
  }
  Sys.sleep(10)
}


#extract the links of the pages
tracks_links<-c()
for (i in 1:8) {
  pages<-GET(paste0("https://www.whosampled.com/Daft-Punk/sampled/?role=1&sp=",i), user_agent(ua_success)) %>%
  content(type = "text/html") %>% 
     html_nodes(".trackCover") %>%
     html_attr("href") %>%
     paste0("https://www.whosampled.com", ., "sampled/") 
 tracks_links <- c(tracks_links, pages)
 Sys.sleep(60)
}


#inizialized the result
result <- tibble(
  title = character(),
  artist = character(),
  year = character(),
  genre = character()
)

#extract the data
for (i in 1:length(tracks_links)) {
Sys.sleep(10)
links<-GET(tracks_links[i], user_agent(ua_success)) %>%
  content(type = "text/html") %>% 
      html_elements(".page a") %>% 
      html_text2() %>% 
      last()
  if (is.na(links)) {
 extracted<-tracks_links[i]
  }  else {
    extracted<- paste0(tracks_links[i], "?cp=", 1:links)
  }   
    extracted_data<- map(extracted,~GET(.x,user_agent(ua_success))) %>% map(~content(.,type = "text/html")) %>% 
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
      result<- bind_rows(result,extracted_data)
  }






