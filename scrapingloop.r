library(tidyverse)
library(rvest)
library(googlesheets4)
library(httr)


ualist<-read_sheet("https://docs.google.com/spreadsheets/d/1FduIFZUJcPFzKWm2qxdQw4qZo1nJwnLf9n5ddtR1w5A/edit#gid=0")

ua_success <- character()

for(i in 200:499) {
  response <- GET("https://www.whosampled.com/Daft-Punk/sampled/?role=1", 
                        add_headers(`User-Agent` = as.character(ualist[i,])))
  if(response$status_code == 200) {
    ua_success <- c(ua_success, as.character(ualist[i,]))
    break
  }
sys.sleep(5)
}

tracks_links<-c()
for (i in 1:8) {
  pages<-GET(paste0("https://www.whosampled.com/Daft-Punk/sampled/?role=1&sp=",i), user_agent(ua_success)) %>%
  content(type = "text/html") %>% 
     html_nodes(".trackCover") %>%
     html_attr("href") %>%
     paste0("https://www.whosampled.com", ., "sampled/") 
 tracks_links <- c(tracks_links, pages)
 Sys.sleep(5)
}


result <- tibble(
  title = character(),
  artist = character(),
  year = character(),
  part_sampled = character()
)


for (i in 1:length(tracks_links)) {
Sys.sleep(5)
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
              part_sampled = html_element(.x, ".tdata__badge") %>% 
                html_text2()
            )))  
      result<- bind_rows(result,extracted_data)
  }


#use the value of column artist and title to get the genre of the song, but first we need to clean the data
result_test<-result
result_test <- result_test %>%
  mutate_at(vars(1:2), ~gsub(" /", "", .)) %>%  
  mutate_at(vars(1:2), ~gsub(" feat\\..*$", "", .))  %>%  
  mutate_at(vars(1:2), ~gsub(" ", "-", .)) 
 

genre <- tibble(
  genre = character()
)

#extract the genre of the song
for (i in 1:dim(result_test)[1]) {
  type <- GET(paste0("https://www.whosampled.com/", result_test$artist[i], "/", result_test$title[i], "/"), user_agent("ua_success")) %>%
    content(type = "text/html") %>% 
    html_elements("a span") %>% 
    html_text2()%>% .[2]   
  genre <- bind_rows(genre, tibble(genre = type))

} 

#merge the two dataframes
sampled_dataframe<-bind_cols(result_test, genre)
