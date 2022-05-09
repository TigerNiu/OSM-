# nolint start
# /*
#  * @Author: TigerNiu
#  * @Date: 2022-05-02 18:39:37
#  * @LastEditors: TigerNiu
#  * @LastEditTime: 2022-05-02 18:39:41
#  * @FilePath: \R\downloadcheck.r
#  * @Description:
#  *
#  */
rm(list = ls())

library(sf)
library(osmextract)

CN_range = read_sf("D:/Astudy/SAN/sanxia/digital/border/china.shp")

CN_df = as.data.frame(CN_range)
number_province = nrow(CN_df)

for (i in 2:number_province) {
   my_bbox_poly = st_as_sfc(CN_range[i,])
   oe_match(my_bbox_poly, provider = "openstreetmap_fr")
}
my_bbox_poly = st_as_sfc(CN_range)
oe_match(my_bbox_poly, provider = "openstreetmap_fr")

# nolint end