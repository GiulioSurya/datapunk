library(tidyverse)
library(rvest)
library(googlesheets4)


ualist<-read_sheet("https://docs.google.com/spreadsheets/d/1FduIFZUJcPFzKWm2qxdQw4qZo1nJwnLf9n5ddtR1w5A/edit#gid=0")
page<- read_html("https://www.whosampled.com/Daft-Punk/sampled/?role=1", user_agent = sample(ualist))

tracks_links <- page %>% 
  html_nodes(".trackCover") %>%
  html_attr("href") %>%
  paste0("https://www.whosampled.com", ., "sampled/") 


result <- tibble(
  title = character(),
  artist = character(),
  year = character(),
  genre = character()
)

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
      links <- 1  # Imposta links a 1 se è NULL
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

