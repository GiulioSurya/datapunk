
library(tidyverse)
library(googlesheets4)
library(svglite)
library(ggtext)
library(geomtextpath)

# Define color palette (NA values are defined separately)


colorvalues <- c(
  "Other" = "#FF8D06",
  "Soul/Funk/Disco" = "#FF009D",
  "Soul/Disco" = "#891978",
  "Hip-Hop/Rap/R&B" = "#e41e0391",
  "Jazz/Blues/Funk" = "#0cecbf",
  "Jazz/Blues" = "#258df5",
  "Reggae/Dub" = "#f90c0c",
  "Rock/Pop" = "#4419df",
  "Electronic/Dance"= "#913EED"
)


navalue = "#AAAAAA"

#data preparation
donutsmain <- read_sheet('https://docs.google.com/spreadsheets/d/1oDuhgP_xxYq3D4iOBtgrlXfsveCkhkuySVPoKTNYRaA/edit?usp=sharing')

tracklist<- donutsmain %>%
  distinct(track, .keep_all = TRUE) %>%
  select(track,lenght)

samplelist<-donutsmain %>%
  select(,-lenght)

#create donut

# Define dimensions of the album donut
aouter = 6       # Half of a 12" record
aleadin = 5.75   # Start of the recording groove =11.5"
aleadout = 1.88 # End of the recording groove 3.75
ainner = 1.69    # End of spiral 3.375

# Compute percentages and cumulative percentages
tracklist$fraction<-tracklist$lenght/sum(tracklist$lenght)

# ymax is the right (clockwise) edge of each slice
tracklist$ymax = cumsum(tracklist$fraction)
# ymin is the left (clockwise) edge of each slice
# Bump the max array by one position, add a zero up front
tracklist$ymin = c(0, head(tracklist$ymax, n=-1))

# Set up each sprinkle (dots)
latestyear<-max(samplelist$year)
earliestyear = min(samplelist$year)
samplelist$radius = 1 - ((samplelist$year-earliestyear) / (latestyear-earliestyear))
samplelist$groove = aleadout + ((samplelist$radius) * (aleadin - aleadout))

# Create a function to translate years to groove positions (timeline)
vlinecalc <- function(year) {
  vlinegroove <- aleadout + ((1 - ((year - earliestyear) / 
                 (latestyear-earliestyear))) * (aleadin-aleadout))
  return(vlinegroove)
}

# Join datasets to map samples to the Donut tracklist
df1 <- inner_join(tracklist, samplelist, by='track')

# Place sprinkles within their slice, adding randomness to avoid overplotting
set.seed(029)
df1$sprinkle <- df1$ymin + ((df1$ymax - df1$ymin)*(runif(nrow(df1), 0.10, 0.90)))

# Calculate the angle and hjust of the track names
df1$angle <-  90 - (360 * (df1$ymax + df1$ymin)/2) 

# Horizontal justification flips on the left side
df1$hjust <- ifelse(df1$angle < -90, 0, 1)
df1$vjust <- ifelse(df1$angle < -90, 0, 1)

# The angle flips on the left side of the album
df1$angle <- ifelse(df1$angle < -90, df1$angle+180, df1$angle)

# Make a table for year labels
yearlabels <- data.frame(
  label = c('<strong>1968</strong>', '<strong>1975</strong>', '<strong>1982</strong>', 
            '<strong>1990</strong>', '<strong>1996</strong>'),
  x = vlinecalc(c(1968, 1975, 1982, 1990, 1996)),
  y = 1,
  angle = 0)

# Count the genres in dataset
genres = count(df1, genre)

df1outro <- df1 %>% filter(track != 1)
tracklistoutro <- df1outro %>% distinct(trackname, .keep_all = TRUE) 




#create the donut

donutrecord<-ggplot(df1) + 

  # Start with a white circle for the background of the album label
  geom_rect(aes(xmin = 0, xmax = ainner,
                ymax = 1, ymin = 0),
            fill = 'white') +  
  
  # Create two sets of rectangles that will be converted to 4-edged slices
  # First, the rectangles for the  the total record (outer and inner edges) 
  geom_rect(aes(ymax = 1, ymin = 0,
                xmax = aouter, xmin = ainner),
            fill = 'gray11', color = 'gray11', 
            linewidth = 0.6) +

  # Overlay the rectangles for track slices 
  geom_rect(aes(ymax = ymax, ymin = ymin, 
                xmax = aleadin, xmin = aleadout), 
            fill = 'gray22', color = 'gray44', 
            linewidth = 0.4) +
  
  # Add gridlines for certain years (grooves)
  geom_vline(xintercept = vlinecalc(c(1970,1980,1990)), color = 'gray11',
             linewidth = 0.4, linetype = 'solid') +

  # Add dots representing samples in each track (sprinkles)
  geom_point(aes(x = groove, y = sprinkle,
                 fill = genre), 
             shape = 21, color = 'gray88', 
             alpha = 0.60, size = 3.5, stroke = 0.6) +
  
  # Add colors for the sprinkles and remove plot buffers
  scale_fill_manual(values = colorvalues, na.value = navalue) + 

  # Add labels for gridlines (grooves)
  geom_richtext(data = yearlabels,
                mapping = aes(x = x, y = y, 
                              label = label,
                              # hjust = 0.5 means centered horizontally,
                              # vjust = 0 means above the dashed line
                              hjust = 0.5, vjust = 0.5,
                              angle = angle),
                color = 'gray99', fill = NA, 
                label.color = NA,
                size = 4.5,
                label.padding = unit(rep(0, 4), "pt")) +
  
  # Add labels for track names (slices)
  geom_richtext(data = tracklistoutro, 
                mapping = aes(x = (0.99*aleadin), y = (ymin + ymax)/2,
                          label = trackname,
                          # hjust = 0.5 means centered horizontally,
                          # vjust = 0 means above the dashed line
                          hjust = hjust, vjust = 0.5, 
                          angle = angle),
                color = 'gray77', fill = NA, alpha = 0.7,
                label.color = NA,
                size = 3.9,
                label.padding = unit(rep(0, 4), "pt")) +
  
  geom_textvline(aes(xintercept = aouter,
                     label = "Homework >>"), 
                 hjust = 0.025, vjust = 1, linetype = 0,
                 size = 3.4, color = 'gray77') +
  
  geom_textvline(aes(xintercept = aouter,
                     label = "<< Discovery"), 
                 hjust = 0.975, vjust = 1, linetype = 0,
                 size = 3.4, color = 'gray77') +
  
  # Remove any gaps around the plot edge 
  scale_x_continuous(limits = c(0, 7), expand = expansion(0,0)) +
  scale_y_continuous(limits = c(0, 1), expand = expansion(0,0),
                     labels = NULL) +
                    

  # Convert rectangles to radial slices
  coord_polar(theta = 'y') +
  # Remove other plot elements and legend
  theme_void() +
  theme(panel.border = element_blank(),
        axis.ticks = element_blank(),
        axis.text.y = element_blank(),
        panel.grid  = element_blank(),
        plot.margin = unit(rep(-0.82,4), "inches"),
        legend.direction = 'horizontal',
        legend.position = c(0.5, 0.14)   
        ) 

print(donutrecord)

ggsave(file = "donutrecord.svg", plot = donutrecord)


#Bar Graph

sampled<-read_sheet("https://docs.google.com/spreadsheets/d/1D3kZpDH9MnELH3Jt1JY95iL8ALxsXzM2x77FYA9xm4U/edit#gid=0")
sampled<-sampled[,-1]

#remove space in genre column for colorpalette matching
sampled<-sampled %>%
  mutate_at(vars(5), ~gsub(" ", "", .))

#group by genre and part_sampled and count the number of songs sampled
sampled_df<-sampled%>%group_by(genre, part_sampled)%>%summarise(n=n())%>%arrange(desc(n))


#plot the bar graph relative
sampled_bar<-ggplot(sampled_df, aes(x=part_sampled, y=n, fill=genre))+
  geom_col(position="fill", width = 0.4)+
  scale_fill_manual(values = colorvalues)+
  theme_minimal()+
  theme(legend.position = "bottom")+
  labs(title="Genres by Type of Sampled Part", x="Sampled part of the Daft Punk tracks", y="Percentage by Genre Type!")

print(sampled_bar)

ggsave(file = "sampled_bar.svg", plot = sampled_bar)

#graph bare in absolute values
sampled_bar_absolute<-ggplot(sampled_df, aes(x=part_sampled, fill=genre))+
  geom_bar(aes(y=n), stat="identity", position="dodge")+
  scale_fill_manual(values = colorvalues)+
  theme_minimal()+
  theme(legend.position = "bottom")+
  labs(title="Genres by Type of Sampled Part", x="Sampled part of the Daft Punk tracks", y="Count of Samples")

print(sampled_bar_absolute)

ggsave(file = "sampled_bar_absolute.svg", plot = sampled_bar_absolute)

