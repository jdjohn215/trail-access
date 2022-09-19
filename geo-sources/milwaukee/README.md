## README

* `Trails_in_Milwaukee_County.geojson` was downloaded from [Milwaukee County GIS and Land Information](https://gis-mclio.opendata.arcgis.com/datasets/MCLIO::trails-in-milwaukee-county-1/about) on 9/19/2022.
* `Street_Centerlines.geojson` was downloaded from [a Milwaukee County ESRI server](https://lio.milwaukeecountywi.gov/arcgis/rest/services/Parks/Milwaukee_Co_Trails/FeatureServer/0) on 9/19/2022 using this code:

  ```
  st_write(
    st_read("https://lio.milwaukeecountywi.gov/arcgis/rest/services//Parks/Milwaukee_Co_Trails/FeatureServer/0/query?outFields=%2A&returnGeometry=true&f=geojson"),
    "geo-sources/milwaukee/Trails_in_Milwaukee_County.geojson",
    delete_dsn = T
  )
  ```