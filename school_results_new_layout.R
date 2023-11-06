library(rvest)
library(tidyr)
library(dplyr)
library(data.table)

# Read the HTML content of the website
webpage <- read_html("https://electionresults.sos.mn.gov/results/Index?ErsElectionId=157&scenario=LocalSchoolDistrict&DistrictId=281&show=Go")
table_node <- html_nodes(webpage, "table")

# Extract the mayor results
school_at_large <- html_table(table_node)[[3]]
school_at_large$Source <- "School Board At Large"

# Extract council at large
school_district_2 <- html_table(table_node)[[4]]
school_district_2$Source <- "School Board District 2"

# Extract district 1
school_district_3 <- html_table(table_node)[[5]]
school_district_3$Source <- "School Board District 3"

# Extract district 3
question_1 <- html_table(table_node)[[6]]
question_1$Source <- "School Referendum Question 1"

# Extract district 4
question_2 <- html_table(table_node)[[8]]
question_2$Source <- "School Referendum Question 2"

######## stopped updating here.

# Scrape the precincts reporting and assign them to the correct race
target_spans <- html_nodes(webpage, xpath = "//span[@class='hidden-xs hidden-sm']")
span_texts <- html_text(target_spans)

# Extract the number of precincts reporting for each race
school_at_large$Precincts_Reported <- span_texts[1]
school_district_2$Precincts_Reported <- span_texts[2]
school_district_3$Precincts_Reported <- span_texts[3]
question_1$Precincts_Reported <- span_texts[4]
question_2$Precincts_Reported <- span_texts[5]

#remove useless columns
school_at_large <- school_at_large[, -c(1, 2, 6)]
school_district_2 <- school_district_2[, -c(1, 2, 6)]
school_district_3<- school_district_3[, -c(1, 2, 6)]
question_1 <- question_1[, -c(1, 2, 6)]
question_2 <- question_2 [, -c(1, 2, 6)]


# Rename columns
school_at_large <- school_at_large %>%
  rename("Candidate" = "Totals", "Number of votes" = "Percent", "Percent" = "Graph")

school_district_2 <- school_district_2 %>%
  rename("Candidate" = "Totals", "Number of votes" = "Percent", "Percent" = "Graph")

school_district_3 <- school_district_3 %>%
  rename("Candidate" = "Totals", "Number of votes" = "Percent", "Percent" = "Graph")

question_1 <- question_1 %>%
  rename("Candidate" = "Totals", "Number of votes" = "Percent", "Percent" = "Graph")

question_2 <- question_2 %>%
  rename("Candidate" = "Totals", "Number of votes" = "Percent", "Percent" = "Graph")

# Remove thousands separators (commas) from the "Number of votes" column
school_at_large$`Number of votes` <- gsub(",", "", school_at_large$`Number of votes`, fixed = TRUE)
school_district_2$`Number of votes` <- gsub(",", "", school_district_2$`Number of votes`, fixed = TRUE)
school_district_3$`Number of votes` <- gsub(",", "", school_district_3$`Number of votes`, fixed = TRUE)
question_1$`Number of votes` <- gsub(",", "", question_1$`Number of votes`, fixed = TRUE)
question_2$`Number of votes` <- gsub(",", "", question_2$`Number of votes`, fixed = TRUE)

# Write data to separate CSV files
write.csv(school_at_large, "data/sb_atlarge_results.csv", row.names = FALSE)
write.csv(school_district_2, "data/sb_district2_results.csv", row.names = FALSE)
write.csv(school_district_3, "data/sb_district3_results.csv", row.names = FALSE)
write.csv(question_1, "data/sd_q1_results.csv", row.names = FALSE)
write.csv(question_2, "data/sd_q2_results.csv", row.names = FALSE)