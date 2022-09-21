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
  geometry = TRUE
)

# pivot to wide format, rename columns, convert polygons to centroids
mke.wide.centroids <- milwaukee.blocks %>%
  pivot_wider(names_from = variable, values_from = value) %>%
  rename(pop = P2_001N, pop_hisp = P2_002N, pop_white = P2_005N,
         pop_black = P2_006N, pop_aian = P2_007N, pop_asian = P2_008N,
         pop_nhpi = P2_009N, pop_other = P2_010N, pop_two = P2_011N) %>%
  mutate(geometry = st_centroid(geometry))

# save output
st_write(mke.wide.centroids, "geo-sources/milwaukee/Census_Blocks_2020_centroids.geojson")
