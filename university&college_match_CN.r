# nolint start
#  *----------------------------------------------------------
#  * @Author: TigerNiu
#  * @Date: 2022-05-02 19:58:39
#  * @LastEditors: TigerNiu
#  * @LastEditTime: 2022-05-02 19:58:46
#  * @FilePath: \R\university&college_match_CN.r
#  * @Description: Match the extract data with the university and college in the official database
#  *
#  * ProjectName: Proofreading and digitization of University boundary shape
#  *----------------------------------------------------------
rm(list = ls())

library(sf)
library(stringr)
library(readr)
library(xlsx)
library(dplyr)

# 读取数据，sf数据转为dataframe格式
# Read data, translate sf to data.frame
extract_data <- read_sf("D:/Astudy/SAN/sanxia/digital/university&college/中国高校.gpkg")
extract_data_df <- as.data.frame(extract_data)
U_C_data <- read.xlsx("D:/Astudy/SAN/sanxia/digital/match/全国成人高等学校名单.xlsx", 1)

# 选出不含"小学|中学|初中|高中|实验学校|附小|附中|附属|研究"字段的行
extract_data_df <- filter(extract_data_df, !grepl("小学|中学|初中|高中|实验学校|附小|附中|附属|研究", extract_data_df[, 3]))

# 获得数据行数
# Get the row number of University and College data
number <- nrow(U_C_data)

# 条件筛选，思路：分为学校全称，或者学校加"部|区|分校"；前者进行全字段匹配，后者先从数据中筛选出含"部|区|分校"的部分，在筛选出含校名的数据；最后将两部分合并即可
# Idea of screening: it's divided into two parts, the full name of the school, or the school plus "部|区|分校"; We do full field matching to the fommer part, and we do include matching to the latter part; Finally, merge the two parts
count0 <- grep(pattern = ("部|区|分校"), extract_data_df[, 3])
n <- 0
y <- 0

for (i in 1:number) {
    U_C_name <- U_C_data[i, 2]
    count <- grep(pattern = U_C_name, extract_data_df[, 3])
    count <- intersect(count0, count)
    rownumber <- which(extract_data_df$name == U_C_name)
    count <- append(count, rownumber)
    # 如果count为0，即国家数据库内的学校在前面选出的数据中没有匹配的学校时，将此学校加入未匹配的列表
    # If count == 0, add this scholl to the unmatched list
    if (length(count) == 0) {
        n <- n + 1
        if (n == 1) {
            required_U_C <- U_C_data[i, ]
        } else {
            required_U_C <- rbind(required_U_C, U_C_data[i, ])
        }
    } else {
        y <- y + 1
        if (y == 1) {
            match_data_df <- extract_data_df[count, ]
        } else {
            match_data_df <- rbind(match_data_df, extract_data_df[count, ])
        }
    }
}

# 输出数据，只需要更改op_path和ip_name即可
# Write data
op_path = "D:/Astudy/SAN/sanxia/digital/match/"
ip_name = "全国成人高等学校"
match_data_sf <- st_as_sf(match_data_df)
match_data_df <- subset(match_data_df, select = c(osm_way_id, name, amenity, other_tags))

output_required = file.path(op_path, paste0(ip_name, "_required.xlsx"))
write.xlsx(required_U_C, output_required, sheetName = "Sheet1", row.names = FALSE)

output_match_xlsx = file.path(op_path, paste0(ip_name, "_match.xlsx"))
write.xlsx(match_data_df, output_match_xlsx, sheetName = "Sheet1", row.names = FALSE)

output_match_gpkg = file.path(op_path, paste0(ip_name, "_match.gpkg"))
st_write(match_data_sf, output_match_gpkg)


# 处理完上述两个名单后，进行合并：
# chengren = read_sf("D:/Astudy/SAN/sanxia/digital/match/全国成人高等学校_match.gpkg")
# putong = read_sf("D:/Astudy/SAN/sanxia/digital/match/全国普通高等学校_match.gpkg")
# U_C_all = rbind(chengren, putong)
# st_write(U_C_all, file.path(op_path, "全国高校.gpkg"))

# nolint end