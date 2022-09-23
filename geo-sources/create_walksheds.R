library(sf)
library(openrouteservice)
library(dplyr)
library(tmap)


# API limit: 20 requests per minute; 2500 per day
# function returns walkshed polygon sf object
create_iso <- function(location, profile_1 = "e-bike", range_1){
  iso <- try(ors_isochrones(locations = st_coordinates(location), 
                        profile = ors_profile(mode = profile_1),
                        range = range_1,
                        output = "sf"))
  Sys.sleep(3) #delay to not exceed per-minute API restriction
  ifelse(class(iso) != "try-error", return(iso$geometry), return(NULL)) #check if iso is not error; return NA if TRUE, geometry if false
}


mke.wide.centroids.with.pop <- mke.wide.centroids |> 
  filter(pop > 0)
# add walkshed as geometry column for centroids
walksheds <- mke.wide.centroids.with.pop[1:2450,] |> 
  rowwise() |> 
  mutate(walkshed = create_iso(geometry, "walk", 3))




#saveRDS(walksheds, file = "geo-sources/milwaukee/processed-data/walksheds_mke_1_2450.RDS")
