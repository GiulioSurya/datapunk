library(tidyverse)
library(rvest)
library(googlesheets4)

#user agent list
ualist<-read_sheet("https://docs.google.com/spreadsheets/d/1FduIFZUJcPFzKWm2qxdQw4qZo1nJwnLf9n5ddtR1w5A/edit#gid=0")
#first url (i need it to create the list of all URls)
page <- read_html("https://www.whosampled.com/Daft-Punk/sampled/?role=1", user_agent = sample(ualist))

#create the list of urls
tracks_links <- page %>% 
  html_nodes(".trackCover") %>%
  html_attr("href") %>%
  paste0("https://www.whosampled.com", ., "sampled/") 

tracks_links <- tracks_links[-6] #for the moment i delet it because it got me an NA error in the loop

#loop for each url
for (i in 1:length(tracks_links)) {
  link <- tryCatch({                                              #tryCatch is used to handle error 403
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
    
    result <- paste0(tracks_links[i], "?cp=", 1:links) %>%  
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
        } else {
          tibble()  # Restituisce un tibble vuoto se .x è NULL
        }
      })
  }
}


