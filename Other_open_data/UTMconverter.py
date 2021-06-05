# -*- coding: utf-8 -*-
"""
Created on Thu May 27 23:12:47 2021

@author: pgeir
"""

## UTM to WSG84 Decidata Converter ##

################################
## OPTION1 ##### Using Geopandas
################################

import pandas as pd
import geopandas as gpd
from shapely.geometry import Point

ds02 = pd.read_csv("../Input_open_data/ds02_datos-nidos-avispa-asiatica.csv")

# Replace , by . ### this is because Geopandas works with the USA notation
ds02["longitude"] = ds02.longitude.str.replace(",",".").astype(float)
ds02["latitude"] = ds02.latitude.str.replace(",",".").astype(float)


# Convert coordinates from DataFrame to Shapely geometry (Geopandas special data type) 
ds02["geometry"] = [Point(xy) for xy in zip(ds02.longitude, ds02.latitude)]

# And use them to convert our initial Dataframe to a GeoDataframe
ds02_gdf = gpd.GeoDataFrame(ds02, crs="EPSG:25830", geometry=ds02.geometry) # use UTM projection "EPSG:25830"

# Convert projection to WSG84 to get our coordinates in degrees
ds02_gdf = ds02_gdf.to_crs("EPSG:4326")

# Add the new coordinates to the Pandas Datafarme as string type data for manipulations
ds02["geometry"] = ds02_gdf.geometry.astype("string")

# A) Extract coordinates; B) Clean the non-desired characters; C) Strip and convert to float dtype
latitudeWSG84 = ds02.geometry.str.split(" ",n=3, expand=True)[2].str.replace(")","",regex=False).str.strip().astype(float)
longitudeWSG84 = ds02.geometry.str.split(" ",n=3, expand=True)[1].str.replace("(","",regex=False).str.strip().astype(float)

# Add the new coordinates to the dataset
ds02["latitudeWGS84"] = latitudeWSG84
ds02["longitudeWGS84"] = longitudeWSG84

# Filter the columns requested as save as a csv file
ds02_final = ds02.loc[:,["_id","latitudeWGS84","longitudeWGS84"]]
ds02_final.to_csv("ds02_wgs84.csv", index=False)

###########################################################
## OPTION2 ##### 1) Install pyproj / 2) Function & For Loop
###########################################################

import pandas as pd
from pyproj import Proj

ds02 = pd.read_csv("../Input_open_data/ds02_datos-nidos-avispa-asiatica.csv")

# Replace , by . ### this is because Pyproj works with the USA notation
ds02["longitude"] = ds02.longitude.str.replace(",",".").astype(float)
ds02["latitude"] = ds02.latitude.str.replace(",",".").astype(float)

# Instatiate the converter with the desired parameters
coord_converter = Proj(proj="utm", zone="30T", ellps="WGS84", north=True)

# Run a For Loop to convert the coordinates and store them in a new Series
ds02["longitudeWGS84"] = 0.0
ds02["latitudeWGS84"] = 0.0

for i in range(0,ds02.shape[0],1):
    # Convert coordinates for each row
    new_coord = coord_converter(ds02.longitude[i],ds02.latitude[i], inverse=True)
    # Add these new coordinates for each row in the new Lat/Long columns
    ds02.longitudeWGS84[i] = new_coord[0]
    ds02.latitudeWGS84[i] = new_coord[1]

# Filter the columns requested as save as a csv file
ds02_final2 = ds02.loc[:,["_id","latitudeWGS84","longitudeWGS84"]]
ds02_final2.to_csv("ds02_wgs84.csv", index=False)