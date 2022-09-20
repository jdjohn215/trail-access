rm(list = ls())

library(tidyverse)
library(sf)
library(leaflet)
options(warn=0)

roads <- st_read("geo-sources/milwaukee/OSM_Roads_and_Paths.geojson") %>%
  mutate(label = paste(name, "<br>",
                       "id:", osm_id, "<br>",
                       fclass, "<br>",
                       "layer:", layer, "<br>"))
trails <- st_read("geo-sources/milwaukee/Milwaukee_County_Trails.geojson")
  
bike.trails <- trails %>%
  filter(
    TypeGen == "HT", # hard trail
    Type == "ST" # separated trail
  )

leaflet(bike.trails) %>%
  addTiles() %>%
  addPolylines(label = ~TrailName) %>%
  addPolylines(data = filter(bike.trails, Access == "Y"), label = ~TrailName,
               color = "red")

not.at.grade <- roads %>% 
  filter(layer != 0)
cycleways <- roads %>%
  filter(fclass == "cycleway")

leaflet(not.at.grade) %>%
  addTiles() %>%
  addPolylines(label = ~lapply(label, htmltools::HTML))

leaflet(cycleways) %>%
  addTiles() %>%
  addPolylines(label = ~lapply(label, htmltools::HTML),
               popup = ~lapply(label, htmltools::HTML))

leaflet(roads %>% filter(fclass == "steps")) %>%
  addTiles() %>%
  addPolylines(label = ~lapply(label, htmltools::HTML))


cycleways2 <- cycleways %>%
  select(cycle_id = osm_id, cycle_fclass = fclass, cycle_layer = layer) %>%
  st_make_valid() %>%
  st_transform(crs = 32054) %>%
  st_buffer(dist = 3)

roads2 <- roads %>%
  filter(! fclass %in% c("motorway", "cycleway", "steps")) %>%
  select(road_id = osm_id, road_fclass = fclass, road_layer = layer, road_name = name) %>%
  filter(st_geometry_type(geometry) %in% c("LINESTRING", "MULTILINESTRING")) %>%
  st_make_valid() %>%
  st_transform(crs = 32054) %>%
  st_buffer(dist = 3)

road.cycleway.intersections <- st_intersection(cycleways2, roads2)

road.cycleway.intersections.2 <- road.cycleway.intersections %>%
  mutate(geometry = st_centroid(geometry)) %>%
  st_transform(crs = 4326)

leaflet(cycleways) %>%
  addTiles() %>%
  addPolylines(label = ~lapply(label, htmltools::HTML),
               popup = ~lapply(label, htmltools::HTML)) %>%
  addCircleMarkers(data = road.cycleway.intersections.2 %>% 
                     filter(road_layer == cycle_layer),
                   color = "green", radius = 1.2, opacity = 1) %>%
  addCircleMarkers(data = road.cycleway.intersections.2 %>% 
                     filter(road_layer != cycle_layer),
                   color = "red", radius = 1.2, opacity = 1)

