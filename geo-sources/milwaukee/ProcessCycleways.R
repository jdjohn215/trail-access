library(tidyverse)
library(sf)
library(leaflet)
#options(warn=0)

################################################################
# This script does the following:
#   1. extract OSM cycleways
#   2. identify contiguous cycleways from constituent segments
#   3. measure contiguous cycleway lengths
#   4. find intersections between roads/paths and cycleways
#   5. save cycleway output (with contiguous lengths)
#   6. save intersection output

roads <- st_read("geo-sources/milwaukee/OSM_Roads_and_Paths.geojson") %>%
  mutate(label = paste(name, "<br>",
                       "id:", osm_id, "<br>",
                       fclass, "<br>",
                       "layer:", layer, "<br>"))

# see: https://wiki.openstreetmap.org/wiki/Key:cycleway
cycleways <- roads %>%
  filter(fclass == "cycleway")

# view cycleways
leaflet(cycleways) %>%
  addTiles() %>%
  addPolylines(label = ~lapply(label, htmltools::HTML),
               popup = ~lapply(label, htmltools::HTML))

# convert the cycleway lines to 3-ft wide polygons
cycleways.polygons <- cycleways %>%
  select(cycle_id = osm_id, cycle_fclass = fclass, cycle_layer = layer) %>%
  st_make_valid() %>%
  # convery to a CRS measured in feet
  st_transform(crs = 32054) %>%
  st_buffer(dist = 3)

# combine touching cycleway polygon segments
contiguous.cycleway.polygons <- st_sf(st_cast(st_union(cycleways.polygons), "POLYGON")) %>%
  rename(geometry = 1) %>%
  mutate(contiguous_id = row_number())

# make crosswalk between individual segments and their continuous_id
contiguous.identifiers <- cycleways.polygons %>%
  st_intersection(contiguous.cycleway.polygons) %>%
  st_set_geometry(NULL) %>%
  tibble() %>%
  select(cycle_id, contiguous_id)

# sum up contiguous segment length
contiguous.segment.length <- cycleways %>%
  mutate(length = st_length(geometry)) %>%
  st_set_geometry(NULL) %>%
  inner_join(contiguous.identifiers, by = c("osm_id" = "cycle_id")) %>%
  group_by(contiguous_id) %>%
  mutate(length = sum(length)) %>%
  group_by(osm_id) %>%
  slice_max(length, n = 1, with_ties = FALSE) %>%
  ungroup() %>%
  select(osm_id, contiguous_id, contiguous_length = length) %>%
  mutate(length_in_miles = round(as.numeric(contiguous_length)*0.000621371, 2))

# view contiguous lengths
cycleways %>%
  inner_join(contiguous.segment.length) %>%
  leaflet() %>%
  addTiles() %>%
  addPolylines(label = ~length_in_miles,
               popup = ~length_in_miles)


# convert the road lines to 3-ft wide polygons
roads.polygons <- roads %>%
  # remove freeways and cycleways
  filter(! fclass %in% c("motorway", "cycleway")) %>%
  select(road_id = osm_id, road_fclass = fclass, road_layer = layer, road_name = name) %>%
  filter(st_geometry_type(geometry) %in% c("LINESTRING", "MULTILINESTRING")) %>%
  st_make_valid() %>%
  # convery to a CRS measured in feet
  st_transform(crs = 32054) %>%
  st_buffer(dist = 3)

# find the intersections between cycleways and roads
road.cycleway.intersections <- st_intersection(cycleways.polygons, roads.polygons) %>%
  # remove when layers are different (i.e. a bridge or tunnel)
  filter(cycle_layer == road_layer) %>%
  # convert to centroids
  mutate(geometry = st_centroid(geometry)) %>%
  # convert back to lat/lon
  st_transform(crs = 4326)

# view cycleways with intersections
leaflet(cycleways) %>%
  addTiles() %>%
  addPolylines(label = ~lapply(label, htmltools::HTML),
               popup = ~lapply(label, htmltools::HTML)) %>%
  addCircleMarkers(data = road.cycleway.intersections,
                   color = "green", radius = 1.5, opacity = 1)

# save output
cycleways.output <- cycleways %>%
  select(osm_id, fclass, name, layer, bridge, tunnel) %>%
  inner_join(contiguous.segment.length)
st_write(cycleways.output, "geo-sources/milwaukee/processed-data/Cycleways.geojson")

st_write(road.cycleway.intersections, "geo-sources/milwaukee/processed-data/Cycleway_Access_Points.geojson")

