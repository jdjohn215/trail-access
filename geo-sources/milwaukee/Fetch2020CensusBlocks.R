library(tidyverse)
library(tidycensus)
library(sf)

# 2020 census variables
dec.vars <- load_variables(2020, "pl", T)

# retrieve 2020 demographics for Milwaukee County census blocks
milwaukee.blocks <- get_decennial(
  geography = "block",
  variables = c("P2_001N", "P2_002N", "P2_005N", "P2_006N", "P2_007N",
                "P2_008N", "P2_009N", "P2_010N", "P2_011N"),
  state = "WI",
  county = "MILWAUKEE",
  year = 2020,
  geometry = TRUE,
  output = "wide"
)

# pivot to wide format, rename columns, convert polygons to centroids
mke.wide.centroids <- milwaukee.blocks %>%
  rename(pop = P2_001N, pop_hisp = P2_002N, pop_white = P2_005N,
         pop_black = P2_006N, pop_aian = P2_007N, pop_asian = P2_008N,
         pop_nhpi = P2_009N, pop_other = P2_010N, pop_two = P2_011N) %>%
  mutate(geometry = st_centroid(geometry))

# save output
st_write(mke.wide.centroids, "geo-sources/milwaukee/Census_Blocks_2020_centroids.geojson")

### Madison
# get blocks for Dane County
dane_blocks <- blocks(55, county = "025")


# get file for all blocks within Madison https://www2.census.gov/geo/maps/DC2020/DC20BLK/st55_wi/place/p5548000_madison/DC20BLK_P5548000_BLK2MS.txt
madison_blocks <- read_delim("https://www2.census.gov/geo/maps/DC2020/DC20BLK/st55_wi/place/p5548000_madison/DC20BLK_P5548000_BLK2MS.txt", delim = ";")

madison_blocks <- madison_blocks |> 
  mutate(GEOID = as.character(FULLCODE))

madison_blocks <- dane_blocks |> 
  inner_join(madison_blocks, by = c("GEOID20" = "GEOID"))

#remove blocks with 0 population
madison_centroids <- madison_blocks |> 
  filter(POP20 > 0) |> 
  st_centroid()

saveRDS(madison_centroids, "geo-sources/milwaukee/processed-data/madison_centroids.RDS")

