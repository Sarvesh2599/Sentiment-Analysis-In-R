install.packages('rvest')
install.packages('corpus')
install.packages('ggplot2')
install.packages('tidytext')
install.packages('textdata')
install.packages('tidyverse')


#Load Packages

library(rvest)
library(corpus)
library(ggplot2)
library(tidytext)
library(textdata)
library(tidyverse)



#Import Speech Text from Webpage 

#Create the URL variable for webpage to be scraped
url <- 'https://www.huffpost.com/entry/i-have-a-dream-speech-text_n_809993'
#Read in the webpage HTML code and specific node wanted from the webpage
webpage <- read_html(url)
speech_text <- html_nodes(webpage,'blockquote')
#Convert nodes to text
speech_text <- html_text(speech_text)
print(speech_text)




# Create Corpus 

text <- as_corpus_text(speech_text)
data <- as_corpus_frame(speech_text)


# Clean Corpus

# Remove punctuation and stop words form corpus:
words <- term_stats(data, drop_punct = TRUE, drop = stopwords_en)
# Drop Column 3 
words <- words[,1:2]
# Rename column names
colnames(words) <- c("word", "count")


# Plot Top 10 Words Used

ggplot(data=words[1:10,], aes(x=reorder(word, -count), y=count)) + 
  geom_bar(stat="identity") + 
  ggtitle("MLK Speech: Top 10 Words Used") + 
  labs(y = "Count", x = "Word") + 
  theme(axis.text.x  = element_text(angle=60, vjust=0.5, size=8)) + 
  theme(axis.title.y = element_text(size=10)) 




#Create Dataframes Joining Words from Speech with Bing and NRC Sentiments

speech_bing <- words %>%
  inner_join(get_sentiments("bing"), by="word")
speech_nrc <- words %>%
  inner_join(get_sentiments("nrc"), by="word")


# Order Bing Sentiment by Word Count and Plot

speech_bing_plot <- speech_bing %>%
  group_by(sentiment) %>% #group words by sentiment
  summarise(word_count = n()) %>% #find count of words by sentiment group
  ungroup() %>% #separate words
  mutate(sentiment = reorder(sentiment, word_count)) %>% #add column sentiment with sentiment ordered by word count
  ggplot(aes(sentiment, word_count, fill = sentiment)) +
  geom_col() +
  labs(x = NULL, y = "Word Count") +
  scale_y_continuous(limits = c(0, 80)) + 
  ggtitle("MLK Speech: Number of Words with Positive vs. Negative Sentiment") +
  coord_flip()
plot(speech_bing_plot)



# Plot showing Positive or Negative Sentiment of Top words used

TopWords_Bing_Plot <- speech_bing[1:25,] %>%
  ggplot(aes(x = reorder(word, -count), y = count, fill = sentiment)) + 
  geom_bar(stat = "identity") + labs(x = "Word", y = "Word Count") + 
  ggtitle("MLK Jr. Speech: Positive or Negative Sentiment of the Most Used Words") + 
  theme(axis.text.x  = element_text(angle=60, vjust=0.5, size=8)) + 
  theme(axis.title.y = element_text(size=10)) 
plot(TopWords_Bing_Plot)


# Order NRC Sentiment by Word Count and Plot

speech_nrc_plot <- speech_nrc %>%
  group_by(sentiment) %>% #group words by sentiment
  summarise(word_count = n()) %>% #find count of words by sentiment group
  ungroup() %>% # separate words
  mutate(sentiment = reorder(sentiment, word_count)) %>% #add column sentiment with sentiment ordered by word count 
  ggplot(aes(sentiment, word_count, fill = sentiment)) + 
  geom_col() + 
  labs(x = NULL, y = "Word Count") + 
  scale_y_continuous(limits = c(0, 80)) + #Hard code the axis limit
  ggtitle("MLK Speech: Number of Words per Emotion Sentiment") + 
  coord_flip()
plot(speech_nrc_plot)


# Plot NRC Sentiment of Top words used

TopWords_NRC_Plot <- speech_nrc[1:22,] %>%
  ggplot(aes(x = reorder(word, -count), y = count, fill = sentiment)) + 
  geom_bar(stat = "identity") + 
  facet_grid(sentiment ~ .) +
  labs(x = "Word", y = "Word Count") + 
  ggtitle("MLK  Speech: Sentiments of the Top 10 Words Used") + 
  theme(axis.text.x  = element_text(angle=60, vjust=0.5, size=8)) + 
  theme(axis.title.y = element_text(size=10))
plot(TopWords_NRC_Plot)
