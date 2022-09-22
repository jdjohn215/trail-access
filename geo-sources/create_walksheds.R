library(sf)
library(openrouteservice)
library(dplyr)
library(tmap)


# API limit: 40 requests per minute; 2500 per day
# function returns walkshed polygon sf object
create_iso <- function(location, profile_1 = "e-bike", range_1){
  iso <- try(ors_isochrones(locations = st_coordinates(location), 
                        profile = ors_profile(mode = profile_1),
                        range = range_1,
                        output = "sf"))
  Sys.sleep(1.5) #delay to not exceed per-minute API restriction
  ifelse(class(iso) != "try-error", iso$geometry, NA) #check if iso is not error; return NA if TRUE, geometry if false
}

# add walkshed as geometry column for centroids
walksheds <- mke.wide.centroids[1:2500,] |> 
  rowwise() |> 
  mutate(walkshed = create_iso(geometry, "walk", 3))

tmap_mode("view")
tm_shape(walksheds) +
  tm_polygons()