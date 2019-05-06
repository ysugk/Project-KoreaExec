library(tidyverse)
library(readxl)

raw.kospi <- read_excel("build/input/TS2000/임원_KOSPI.xlsx", col_types = rep("text", 18))
raw.kosdaq <- read_excel("build/input/TS2000/임원_KOSDAQ.xlsx", col_types = rep("text", 18))

raw.data <- bind_rows(raw.kospi, raw.kosdaq) %>%
  distinct()

cleaned.data <- read_csv("build/input/TS2000/exec_KOREA_1998_2017_cleaned.csv",
                         col_types = rep("c", 21) %>% paste0(collapse = ""))

position.code <- cleaned.data %>%
  distinct(직명코드, 직명) %>%
  arrange(직명코드)

write_rds(position.code, path = "build/temp/PositionCode.rds")

ceo.code <- position.code %>%
  filter(str_detect(직명, "대표이사"))

ceo.data <- cleaned.data %>%
  semi_join(ceo.code, by = "직명코드")

multiple.ceo <- ceo.data %>%
  group_by(거래소코드, 회계년도) %>%
  tally(sort = TRUE) %>%
  filter(n >= 5)

ceo.data %>%
  semi_join(multiple.ceo, by = c("거래소코드", "회계년도")) %>%
  View()
