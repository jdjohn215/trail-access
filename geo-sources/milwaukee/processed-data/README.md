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

* `cycle_id`  - the osm_id for the intersected cycleway
* `cycle_fclass` - the fclass of the intersected cycleway, always "cycleway"
* `cycle_layer` - the layer of the intersected cycleway, always identical to the layer of the intersected road
* `road_id` - the osm_id for ht intersected road/path
* `road_fclass` - the fclass of the intersected road
* `road_layer` - the layer of the intersected road, always identical to the layer of the intersected cycleway
* `road_name` - the name of the intersected road
* `geometry`  - POINT, WGS84 (crs = 4326)