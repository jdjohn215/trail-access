## Cycleways.geojson

This file is a subset of the original OSM "road" shapefile.

* `osm_id`  - the osm feature ID
* `fclass`  - "cycleway"
* `name`    - name of the osm feature
* `layer`   - osm feature layer
* `bridge`  - logical
* `tunnel`  - logical
* `contiguous_id` - a unique id matching all the individual osm features which form a contiguous trail
* `contiguous_length` - length of the contiguous trail in meters, includes stubs
* `length_in_miles`   - length of the contiguous trail in miles
* `geometry`          - LINESTRING, WGS84 (crs = 4326)

##  Cycleway_Access_Points.geojson

This file contains the intersections between roads (and paths) with cycleways.

* `cycle_id`  - the osm_id of the intersected cycleway
* `cycle_fclass` - the fclass of the intersected cycleway, always "cycleway"
* `cycle_layer` - the layer of the intersected cycleway, always identical to the layer of the intersected road
* `road_id` - the osm_id of the intersected road/path
* `road_fclass` - the fclass of the intersected road
* `road_layer` - the layer of the intersected road, always identical to the layer of the intersected cycleway
* `road_name` - the name of the intersected road
* `geometry`  - POINT, WGS84 (crs = 4326)

## Blocks_Matched_To_Access_Points.rds

This file contains populated block centroids, block demographics, and each block's nearest trail access point. The file is in RDS format to accomodate the inclusion of both the block centroid geometry and the access point geometry.

* `block_fips` - FIPS code for the 2020 census block
* `pop` - total population, 2020 census
* `pop_hisp` - Hispanic or Latino population
* `pop_white` - White (not Hispanic or Latino)
* `pop_black` - Black or African American (not Hispanic or Latino)
* `pop_aian`  - American Indian or Alaska Native (not Hispanic or Latino)
* `pop_asian` - Asian (not Hispanic or Latino)
* `pop_nhpi`  - Native Hawaiin or Pacific Islander (not Hispanic or Latino)
* `pop_other` - any other single race (not Hispanic or Latino)
* `pop_two`   - two or more races (not Hispanic or Latino)
* `cycle_id`  - the osm_id of the cycleway with the nearest access point
* `road_id`   - the osm_id of the road/path with the nearest trail access point
* `distance_in_miles` - distance between the block centroid and the access point
* `geometry_block`  - the centroid of the block, POINT WGS84 (CRS = 4326)
* `geometry_access_point` - the trail access point, POINT WGS84 (CRS = 4326)