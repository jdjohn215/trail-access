rm(list = ls())

library(tidyverse)
library(sf)

# this script does the following:
#   1.  subsets cycleways meeting a minimum length standard
#   2.  subsets intersections connecting to qualifying cycleways
#   3.  subsets blocks to only those with non-zero population
#   4.  finds the nearest qualified intersection to each block centroid
#   5.  calculates the distance between each block centroid and its nearest access point
#   6.  reformats blocks with access points, and saves the output

all.cycleways <- st_read("geo-sources/milwaukee/processed-data/Cycleways.geojson")
all.access.points <- st_read("geo-sources/milwaukee/processed-data/Cycleway_Access_Points.geojson")
all.blocks <- st_read("geo-sources/milwaukee/Census_Blocks_2020_centroids.geojson")

# cycleways at least 2/3rds of a mile long
valid.cycleways <- all.cycleways %>%
  filter(length_in_miles >= (2/3))

# intersections connecting to valid cycleways
valid.intersections <- all.access.points %>%
  filter(cycle_id %in% valid.cycleways$osm_id) %>%
  mutate(rownum = row_number())

# populated blocks
populated.blocks <- all.blocks %>%
  filter(pop > 0) %>%
  st_transform(crs = st_crs(valid.intersections))

# match blocks to nearest access point
blocks.to.nearest.access.point <- populated.blocks %>%
  select(GEOID) %>%
  # find index of nearest access point
  mutate(closest_access_point = st_nearest_feature(geometry, valid.intersections)) %>%
  # join to nearest access point, keeping both geometry columns
  inner_join(as.data.frame(select(valid.intersections, cycle_id, road_id, rownum)),
             by = c("closest_access_point" = "rownum")) %>%
  # find distance between both geometry columns
  mutate(distance = st_distance(geometry.x, geometry.y, by_element = T),
         distance_in_miles = as.numeric(distance)*0.000621371)

summary(blocks.to.nearest.access.point$distance_in_miles)

# clean up output
block.output <- populated.blocks %>%
  st_drop_geometry() %>%
  tibble() %>%
  inner_join(blocks.to.nearest.access.point) %>%
  rename(geometry_block = geometry.x, geometry_access_point = geometry.y) %>%
  select(block_fips = GEOID, starts_with("pop"), cycle_id, road_id,
         distance_in_miles, geometry_block, geometry_access_point)

saveRDS(block.output, "geo-sources/milwaukee/processed-data/Blocks_Matched_To_Access_Points.rds")
