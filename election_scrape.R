library(rvest) 
library(tidyr)
library(dplyr)
library(data.table)


# Read the HTML content of the website
webpage <- read_html("https://electionresults.sos.mn.gov/Results/Index?ersElectionId=157&scenario=ResultsByPrecinctCrosstab&OfficeInElectionId=33119&QuestionId=0")

# Extract the table content
table_content <- webpage %>%
  html_table(fill = TRUE) %>%
  .[[3]]  # Assuming the table you need is the third one

# Remove the last row
table_content <- table_content[-nrow(table_content), ]

# Clean column names
colnames(table_content) <- gsub("NP", "", colnames(table_content))
colnames(table_content) <- gsub("ISD #709 - ", "", colnames(table_content))

# Convert columns to integers
cols_to_convert <- 2:ncol(table_content)  # Exclude the first column
table_content[cols_to_convert] <- lapply(table_content[cols_to_convert], as.integer)

# Calculate the percentage for each cell based on the "VoteTotal" column
table_content <- table_content %>%
  mutate(across(starts_with("Col"), ~ifelse(is.na(.), 0, .))) %>%
  rowwise() %>%
  mutate(VoteTotal = sum(c_across(starts_with("Col")))) %>%
  ungroup() %>%
  mutate(across(starts_with("Col"), ~(. / VoteTotal) * 100, .names = "Col_{.col}_Percentage"))

# Write the table to a CSV file
write.csv(table_content, "data/table_real.csv", row.names = FALSE)