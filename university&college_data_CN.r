# nolint start
#  *----------------------------------------------------------
#  * @Author: TigerNiu
#  * @Date: 2022-04-30 11:40:57
#  * @LastEditors: TigerNiu
#  * @LastEditTime: 2022-05-02 17:00:30
#  * @FilePath: \R\university&college_data_CN.r
#  * @Description: In the polygon layer of OSM data, extract polygons with amenity attributes of University and college. In the following code, you should only change the pathes, which are "op_path" and the path in "read_sf", to the directory in your computer
#  *
#  * ProjectName: Proofreading and digitization of University boundary shape
#  * ToDo: Link the data to geospatial data of provinces or cities
#  *----------------------------------------------------------

rm(list = ls())

library(sf)
library(osmextract)
library(tmap)
library(stringr)
library(readr)
library(utils)

# 只需要更改 op_path 和 read_sf 中的路径
# 设置输出数据路径
op_path <- "D:/Astudy/SAN/sanxia/digital/university&college/"
op_csv_path <- paste0(op_path, "university&college.csv")

# 读取地级市数据
CN_range <- read_sf("D:/Astudy/SAN/sanxia/digital/border/border/China_prefecture.shp")
CN_xml <- as.data.frame(CN_range)

# 获得地级市总数（以下处理，从第二行开始，所以准确来说是地级市总数+1）
number_shi <- nrow(CN_range)

for (i in 2:number_shi) {
   print(paste0("start: number_", i, " ", CN_xml[i, 3]))
   # 获取城市边界数据
   my_bbox_poly <- st_as_sfc(CN_range[i, ])

   # 获取osm数据，上一步已经获得，这里再检查一遍，也可以略过
   oe_get(
      CN_range[i, ],
      provider = "openstreetmap_fr",
      download_only = TRUE,
      skip_vectortranslate = TRUE
   )

   # 从本地osm数据中选取multipolygons图层
   osm_data <- oe_get(
      CN_range[i, ],
      provider = "openstreetmap_fr",
      layer = "multipolygons",
      wkt_filter = st_as_text(my_bbox_poly)
   )

   # 获取university和college数据
   university_college_data <- subset(osm_data, osm_data$amenity == "university" | osm_data$amenity == "college" | osm_data$amenity == "school")

   # 合并两个sf数据，以便后续生成中国高校
   if (i == 2) {
      middle_data <- university_college_data
   } else {
      middle_data <- rbind(middle_data, university_college_data)
   }

   # 设置tmap参数，检查并修改未封闭的multipolygons
   tmap_options(check.and.fix = TRUE)

   # 设置输出路径和名字
   ip_name <- str_sub(CN_xml[i, 3])
   op_name <- paste0(ip_name, "_高校.gpkg")
   output <- file.path(op_path, op_name)
   st_write(university_college_data, output)

   # 高校转为csv，并写入csv文件
   university_college_csv <- as.data.frame(university_college_data)
   university_college_csv <- subset(university_college_csv,select = c(osm_way_id, name, amenity, other_tags))
   if (i == 2) {
      write_csv(university_college_csv, op_csv_path, append = TRUE, col_names = TRUE)
   } else {
      write_csv(university_college_csv, op_csv_path, append = TRUE)
   }

   print(paste0("done: number_", i, " ", CN_xml[i, 3]))
}

# 输出所提取的图层数据
output_main <- file.path(op_path, "中国高校.gpkg")
st_write(middle_data, output_main)

# 设置tmap窗口为view
tmap_mode("view")
# 查看结果（也可以只查看一个城市的）
tmap_options(check.and.fix = TRUE)
tm_shape(CN_range) +
   tm_borders(col = "darkred") +
   tm_shape(middle_data) +
   tm_polygons(lwd = 2)
# nolint end