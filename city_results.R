library(rvest)
library(tidyr)
library(dplyr)
library(data.table)

# Read the HTML content of the website
webpage <- read_html("https://electionresults.sos.mn.gov/results/Index?ErsElectionId=157&scenario=LocalMunicipality&FipsCode=17000&show=Go")
table_node <- html_nodes(webpage, "table")

# Extract the mayor results
mayoral_chart <- html_table(table_node)[[3]]
mayoral_chart$Source <- "Mayor"

# Extract council at large
council_at_large <- html_table(table_node)[[4]]
council_at_large$Source <- "Council At Large"

# Extract district 1
council_district_1 <- html_table(table_node)[[5]]
council_district_1$Source <- "Council District 1"

# Extract district 3
council_district_3 <- html_table(table_node)[[6]]
council_district_3$Source <- "Council District 3"

# Extract district 4
council_district_4 <- html_table(table_node)[[7]]
council_district_4$Source <- "Council District 4"

# Extract district 5
council_district_5 <- html_table(table_node)[[8]]
council_district_5$Source <- "Council District 5"

# Scrape the precincts reporting and assign them to the correct race
target_spans <- html_nodes(webpage, xpath = "//span[@class='hidden-xs hidden-sm']")
span_texts <- html_text(target_spans)

# Extract the number of precincts reporting for each race
mayoral_chart$Precincts_Reported <- span_texts[1]
council_at_large$Precincts_Reported <- span_texts[2]
council_district_1$Precincts_Reported <- span_texts[3]
council_district_3$Precincts_Reported <- span_texts[4]
council_district_4$Precincts_Reported <- span_texts[5]
council_district_5$Precincts_Reported <- span_texts[6]

#remove useless columns
mayoral_chart <- mayoral_chart[, -c(1, 2, 6)]
council_at_large <- council_at_large[, -c(1, 2, 6)]
council_district_1 <- council_district_1[, -c(1, 2, 6)]
council_district_3 <- council_district_3[, -c(1, 2, 6)]
council_district_4 <- council_district_4[, -c(1, 2, 6)]
council_district_5 <- council_district_5[, -c(1, 2, 6)]

# Rename columns
mayoral_chart <- mayoral_chart %>%
  rename("Candidate" = "Totals", "Number of votes" = "Percent", "Percent" = "Graph")

council_at_large <- council_at_large %>%
  rename("Candidate" = "Totals", "Number of votes" = "Percent", "Percent" = "Graph")

council_district_1 <- council_district_1 %>%
  rename("Candidate" = "Totals", "Number of votes" = "Percent", "Percent" = "Graph")

council_district_3 <- council_district_3 %>%
  rename("Candidate" = "Totals", "Number of votes" = "Percent", "Percent" = "Graph")

council_district_4 <- council_district_4 %>%
  rename("Candidate" = "Totals", "Number of votes" = "Percent", "Percent" = "Graph")

council_district_5 <- council_district_5 %>%
  rename("Candidate" = "Totals", "Number of votes" = "Percent", "Percent" = "Graph")


# Remove thousands separators (commas) from the "Number of votes" column
mayoral_chart$`Number of votes` <- gsub(",", "", mayoral_chart$`Number of votes`, fixed = TRUE)
council_at_large$`Number of votes` <- gsub(",", "", council_at_large$`Number of votes`, fixed = TRUE)
council_district_1$`Number of votes` <- gsub(",", "", council_district_1$`Number of votes`, fixed = TRUE)
council_district_3$`Number of votes` <- gsub(",", "", council_district_3$`Number of votes`, fixed = TRUE)
council_district_4$`Number of votes` <- gsub(",", "", council_district_4$`Number of votes`, fixed = TRUE)
council_district_5$`Number of votes` <- gsub(",", "", council_district_5$`Number of votes`, fixed = TRUE)

# Write data to separate CSV files
write.csv(mayoral_chart, "data/mayoral_results.csv", row.names = FALSE)
write.csv(council_at_large, "data/council_at_large_results.csv", row.names = FALSE)
write.csv(council_district_1, "data/council_district_1_results.csv", row.names = FALSE)
write.csv(council_district_3, "data/council_district_3_results.csv", row.names = FALSE)
write.csv(council_district_4, "data/council_district_4_results.csv", row.names = FALSE)
write.csv(council_district_5, "data/council_district_5_results.csv", row.names = FALSE)
