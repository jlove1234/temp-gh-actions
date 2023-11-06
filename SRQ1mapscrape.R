library(rvest) 
library(tidyr)
library(dplyr)
library(data.table)



# Read the HTML content of the website 
webpage <- read_html("https://electionresults.sos.mn.gov/Results/Index?ersElectionId=157&scenario=ResultsByPrecinctCrosstab&QuestionId=1593")
table_node <- html_nodes(webpage, "table") 

# Extract the table content 
table_content <- html_table(table_node)[[3]] 

# Remove last row
table_content <- table_content %>% filter(row_number() <= n()-1)

table_content[] <- lapply(table_content, function(cell) {
  sub("St. Louis: ", "", cell)
})

table_content[] <- lapply(table_content, function(cell) {
  sub("ISD #709 - ", "", cell)
})

colnames(table_content) <- gsub("NP", "", colnames(table_content))

# Assuming your data frame is named "table_content"

# Identify the columns you want to convert to integers
cols_to_convert <- 2:ncol(table_content)  # Exclude the first column

# Convert the selected columns to integers
table_content[cols_to_convert] <- lapply(table_content[cols_to_convert], as.integer)

table_content$VoteTotal <- rowSums(table_content[, -1])  # Exclude the first column

# Calculate the percentage for each cell based on the "VoteTotal" column
for (col in 2:(ncol(table_content) - 1)) {
  new_col_name <- paste0(names(table_content)[col], "_Percentage")
  table_content[, new_col_name] <- (table_content[, col] / table_content$VoteTotal) * 100
}

table_content <- table_content %>%
  mutate(across(everything(), ~ifelse(. == "NaN", 0, .), .names = "{.col}_New"))

# Write the table to the CSV file
write.csv(table_content, "data/SD_Q1_map.csv", row.names = FALSE)