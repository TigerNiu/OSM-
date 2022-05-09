# nolint start
#  *----------------------------------------------------------
#  * @Author: TigerNiu
#  * @Date: 2022-04-30 17:12:03
#  * @LastEditors: TigerNiu
#  * @LastEditTime: 2022-05-02 16:57:31
#  * @FilePath: \R\download_osmdata.r
#  * @Description: Get the data from openstreetmap and do the vectortranslation.
#  *               
#  * ProjectName: Proofreading and digitization of University boundary shape
#  * ToDo: Check the data, skip current data when provider responses for too long
#  *----------------------------------------------------------

rm(list = ls())

library(osmextract)
library(sf)

# 读取数据列表
# Read the data
CN_range <- read_sf("D:/Astudy/SAN/sanxia/digital/border/border/China_prefecture.shp")

# 获得数据列数（数据有多少条）
# Get the number of the data-list
number_shi <- nrow(CN_range)

# 建议先进行供应商处数据量大小查询，选择数据量最小的供应商# 建议先进行供应商处数据量大小查询，选择数据量最小的供应商，一般为"openstreetmap_fr"
# It's recommended to query the data size at the supplier first,
# It's recommended to choose supplier that gives the minimum size of the data.
# for (i in 2:number_province) {
#    my_bbox_poly = st_as_sfc(CN_range[i,])
#    oe_match(my_bbox_poly, provider = "openstreetmap_fr")
# }
# providers: openstreetmap_fr, bbbike, geofabrik

# 从第二列开始为各市，供应商选择合适的
# Start from the second col, choose the propriate provider
for (i in 2:number_shi) {
    oe_get(
        CN_range[i, ],
        provider = "openstreetmap_fr",
        download_only = TRUE,
        skip_vectortranslate = FALSE
    )

    print(i)
}

# nolint end