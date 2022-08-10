library(pdftools)
library(tidyverse)
library(openxlsx)

#get data from the PDF document
#returns a list of character vectors
txt <- lapply(as.list(pdf_text("list.pdf")), as.character)

#insert line breaks where the text string has "\n"
chr <- lapply(txt, function(.x){ 
  unlist(strsplit(.x, "\n"))
})

#Entries to the ISSUER DESCRIPTION column which contains the word NOTE
#are followed by 2 space characters; this makes strsplit() work in a unintended way
#so this section replaces spaces after NOTE with @ so they can be easily replaced later
chr <- lapply(chr, function(.x){ 
  gsub("(?:\\G(?!^)|NOTE)\\K\\s", "@", .x, perl=TRUE)
                                })

#the same happens to DBCV, DEBT, EXPN
chr <- lapply(chr, function(.x){ 
  gsub("(?:\\G(?!^)|DBCV)\\K\\s", "@", .x, perl=TRUE)
})

chr <- lapply(chr, function(.x){ 
  gsub("(?:\\G(?!^)|DEBT)\\K\\s", "@", .x, perl=TRUE)
})

chr <- lapply(chr, function(.x){ 
  gsub("(?:\\G(?!^)|EXPN)\\K\\s", "@", .x, perl=TRUE)
})

#split text to columns; 
#delimiter is set with the regular expression "\\s{2,}",
#which means two or more spaces
chr <- lapply(chr, function(.x){ 
                      data.frame(do.call("rbind", strsplit(.x, "\\s{2,}")))
                                })

chr <- lapply(chr, function(.x){ 
                       tail(.x,-3)
                     })

#actual security list starts at page 3
chr <- chr[3:length(chr)]

#combine all dfs into one
df <- bind_rows(chr, .id = "column_label")

#remove unwanted columns & rows
last_col <- ncol(df)
df <- df[,(2:last_col)]
df <- head(df,-1)

#change column names to match those of the PDF file
colnames(df) <- c("CUSIP NO","ISSUER NAME","ISSUER DESCRIPTION","STATUS")

df$STATUS[!(df$STATUS %in% c("ADDED", "DELETED"))] <- ""

#remove "@"
df$`ISSUER DESCRIPTION` <- gsub("@", " ", df$`ISSUER DESCRIPTION`)
df$`ISSUER NAME` <- gsub("@", " ", df$`ISSUER NAME`)

#save to XLS & csv
write.xlsx(df, "13F securities list.xlsx")
write.csv(df, "13F securities list.csv")