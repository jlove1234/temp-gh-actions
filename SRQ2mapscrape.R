library(rvest) 
library(tidyr)
library(dplyr)
library(data.table)



# Read the HTML content of the website 
webpage <- read_html("https://electionresults.sos.mn.gov/Results/Index?ersElectionId=157&scenario=ResultsByPrecinctCrosstab&QuestionId=1594")
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

columns_to_clean <- colnames(table_content)[-1]  # Exclude the first column

# Loop through each column and apply data cleaning and conversion
for (col_name in columns_to_clean) {
  table_content[[col_name]] <- as.numeric(gsub("[^0-9.]", "", table_content[[col_name]]))
}

#Get rid of NP at the beginning of every name
colnames(table_content) <- gsub("NP", "", colnames(table_content))

table_content$VoteTotal <- rowSums(table_content[, -1])  # Exclude the first column

# Calculate the percentage for each cell based on the "VoteTotal" column
for (col in 2:(ncol(table_content) - 1)) {
  new_col_name <- paste0(names(table_content)[col], "_Percentage")
  table_content[, new_col_name] <- (table_content[, col] / table_content$VoteTotal) * 100
}

table_content <- table_content %>%
  mutate(across(everything(), ~ifelse(. == "NaN", 0, .), .names = "{.col}_New"))

# Write the table to the CSV file
write.csv(table_content, "data/SD_Q2_map.csv", row.names = FALSE)