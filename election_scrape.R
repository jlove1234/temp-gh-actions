library(rvest) 
library(tidyr)
library(dplyr)
library(data.table)



# Read the HTML content of the website 
webpage <- read_html("https://electionresults.sos.mn.gov/Results/Index?ersElectionId=156&scenario=ResultsByPrecinctCrosstab&OfficeInElectionId=33119&QuestionId=0") 

# Select the table using CSS selector 
table_node <- html_nodes(webpage, "table") 

# Extract the table content 
table_content <- html_table(table_node)[[3]] 

table_content[] <- lapply(table_content, function(cell) {
  sub("St. Louis: ", "", cell)
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

# Print the table 
write.csv(table_content, "/workspaces/temp-gh-actions/data/table_real.csv", row.names=FALSE)


