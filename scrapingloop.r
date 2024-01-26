library(tidyverse)
library(rvest)
library(googlesheets4)

#create a user agent list to avoid error 403 when a request is made to the server
ualist<-read_sheet("https://docs.google.com/spreadsheets/d/1kS6VkrUu7txADr-4xs1M2SREv1YD9HoWEbUOr_8RdG0/edit#gid=0")

#create a list of links with all the possible daft punk songs
tracks_links<-c()
for (i in 1:8) {
   page<- read_html(paste0("https://www.whosampled.com/Daft-Punk/sampled/?role=1&sp=",i),user_agent = sample(ualist))
   pages<- page %>% 
     html_nodes(".trackCover") %>%
     html_attr("href") %>%
     paste0("https://www.whosampled.com", ., "sampled/") 
 tracks_links <- c(tracks_links, pages)
}


#create a tibble to store the data
result <- tibble(
  title = character(),
  artist = character(),
  year = character(),
  genre = character()
)

#loop for each url tracks_links
for (i in 1:length(tracks_links)) {
  link <- tryCatch({
    read_html(tracks_links[i], user_agent = sample(ualist))
  }, error = function(e) {
    cat("Error occurred, retrying...\n")
    Sys.sleep(5)
    NULL
  })
  if (!is.null(link)) {
    links <- link %>% 
      html_elements(".page a") %>% 
      html_text2() %>% 
      last() 
    if (is.null(links)) {
      links <- 0
    }
    extracted<- paste0(tracks_links[i], "?cp=", 1:links) %>%  
      map(function(url) {
        tryCatch({
          read_html(url, user_agent = sample(ualist))
        }, error = function(e) {
          cat("Error occurred in nested read_html, retrying...\n")
          Sys.sleep(5)
          NULL
        })
      }) %>%
      map_dfr(~ {
        if (!is.null(.x)) {
          html_elements(.x, ".table.tdata tbody tr") %>% 
            map_dfr(~ tibble(
              title = html_element(.x, ".trackName.playIcon") %>% 
                html_text2(),
              artist = html_element(.x, ".tdata__td3") %>% 
                html_text2(),
              year = html_element(.x, ".tdata__td3:nth-child(4)") %>% 
                html_text2(),
              genre = html_element(.x, ".tdata__badge") %>% 
                html_text2() 
            ))
        } 
      })
      result <- bind_rows(result, extracted)
  }
}
