## README

* `OSM_Roads_and_Paths.geojson` is derived from the Wisconsin statewide shapefile downloaded from [GEOFABRIK](http://download.geofabrik.de/north-america/us/wisconsin.html) on 9/20/2022. It was last updated on 9/20/2022.
* `OSM_Roads_and_Paths_Codebook.pdf` was extracted from the full codebook [available here](http://download.geofabrik.de/osm-data-in-gis-formats-free.pdf).
* `ProcessCyclesways.R` creates `processed-data/Cycleways.geojson` and `processed-data/Cycleway_Access_Points.geojson`.
* `Fetch2020CensusBlocks.R` uses {{tidycensus}} to retrieve 2020 census data.
* `Census_Blocks_2020_centroids.geojson` contains population counts (total and by race/ethnicity) for Milwaukee County census blocks, along with their centroids.
* `MatchBlocksToAccessPoints.R` creates `processed-data/Blocks_Matched_To_Access_Points.rds`