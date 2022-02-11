#!/bin/bash

export GRASS_MESSAGE_FORMAT=plain

r.in.gdal \
    input=${AUX_DATADIR}/merit_elv_utm19s.tif \
    output=merit_elv \
    --overwrite

g.region raster=merit_elv
g.region -p

r.slope.aspect \
    elevation=merit_elv \
    slope=merit_slope \
    format=degrees \
    --overwrite    

# r.mapcalc "merit_slope_pct = merit_slope / 360." --overwrite
# r.stats -c merit_slope_pct
