# 13F-Securities-list-in-Excel
## Description
This R code generates an .xlsx file containing the Section 13(f) Securities as published by the SEC in a PDF document [here](https://www.sec.gov/divisions/investment/13flists).

## Usage
Install the packages used in the code:

```
install.packages("pdftools")
install.packages("tidyverse")
install.packages("openxlsx")
```

Modify `"list.pdf"` as needed. This should be the address to the SEC PDF file stored in your machine:
```
txt <- lapply(as.list(pdf_text("list.pdf")), as.character)
```

The code generates one `.xlsx `and one `.csv` file containing the data from the PDF in a tabular format:
```
write.xlsx(df, "13F securities list.xlsx")
write.csv(df, "13F securities list.csv")
```
