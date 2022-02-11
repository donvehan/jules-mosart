#!/bin/bash

export GDAL_DATA=$(gdal-config --datadir)

# =================================================================== #
# 1 - Deactivate Anaconda environment
# =================================================================== #

CONDA_BASE=$(conda info --base)
source $CONDA_BASE/etc/profile.d/conda.sh
conda deactivate

# =================================================================== #
# 2 - Mosaic MERIT Hydro maps for current study area
# =================================================================== #

# Set some directories
export MERIT_DATADIR=$HOME/data/MERIT/hydro
export GEOMORPHO_DATADIR=$HOME/data/geomorpho90m
export AUX_DATADIR=$(pwd)/../data/aux

if [[ ! -d $AUX_DATADIR ]]
then
    mkdir $AUX_DATADIR
fi

# Vilcanota [TODO: make command line args]
export N=-12
export S=-16
export E=-70
export W=-74
export OUTLET_X=-72.6271
export OUTLET_Y=-13.0045
export OUTDIR='.'

for VAR in elv dir wth upa
do
    ptn="*_${VAR}.tif"
    find $MERIT_DATADIR -type f -iname "${ptn}" > /tmp/merit_${VAR}_filenames.txt
    # if [[ ! -f ${AUX_DATADIR}/merit_${VAR}.tif ]]
    # then	
    gdalbuildvrt \
	-overwrite \
	-te $W $S $E $N \
	-tr 0.0008333333333 0.0008333333333 \
	-input_file_list /tmp/merit_${VAR}_filenames.txt \
	${AUX_DATADIR}/merit_${VAR}.vrt
    gdal_translate ${AUX_DATADIR}/merit_${VAR}.vrt ${AUX_DATADIR}/merit_${VAR}.tif
    # fi    
done

# =================================================================== #
# 3 - Mosaic Geomorpho90m [slope] data
# =================================================================== #

# It would be possible to calculate slope in GIS, but this is a bit
# tricky when dealing with lat/long format because the horizontal units
# (i.e. degrees) are different to the vertical units (m). As a result
# either a correction factor needs to be applied, or the map needs to
# be converted to a different projection. Both are difficult to
# generalise. Instead we use the precomputed maps from geomorpho90m.

VAR=slope
ptn="${VAR}_90M_*.tif"
find $GEOMORPHO_DATADIR -type f -iname "${ptn}" > /tmp/geomorpho90m_${VAR}_filenames.txt
# if [[ ! -f ${AUX_DATADIR}/geomorpho90m_${VAR}.tif ]]
# then
gdalbuildvrt \
    -overwrite \
    -te $W $S $E $N \
    -tr 0.0008333333333 0.0008333333333 \
    -input_file_list /tmp/geomorpho90m_${VAR}_filenames.txt \
    ${AUX_DATADIR}/geomorpho90m_${VAR}.vrt
gdal_translate ${AUX_DATADIR}/geomorpho90m_${VAR}.vrt ${AUX_DATADIR}/geomorpho90m_${VAR}.tif
# fi

# =================================================================== #
# 2 - Run Python script to extract basins
# =================================================================== #

# NB We use `pyflwdir` to be consistent with the upscaling routines.

conda activate mosart
python src/make-river-basins.py
conda deactivate 

# =================================================================== #
# 3 - Run grass scripts to process MERIT Hydro data
# =================================================================== #

# Now we process the remaining maps in lat/lon location.
LATLON_LOCATION=$HOME/grassdata/latlong
LATLON_MAPSET=$HOME/grassdata/latlong/jules
if [[ ! -d $LATLON_LOCATION ]]
then
    grass -c -e epsg:4326 $LATLON_LOCATION
fi

if [[ ! -d $LATLON_MAPSET ]]
then
    grass -c -e $LATLON_MAPSET
fi
    
SRCDIR=$(pwd)/src
chmod u+x $SRCDIR/grass_process_merit.sh
export GRASS_BATCH_JOB=$SRCDIR/grass_process_merit.sh
grass76 $LATLON_MAPSET
unset GRASS_BATCH_JOB










# NOT USED:

# # First, we estimate topographic slope in a projected location (UTM)

# # Reproject elevation to UTM19S (to compute slope)
# gdalwarp \
#     -overwrite \
#     -t_srs EPSG:32719 \
#     -r bilinear \
#     ${AUX_DATADIR}/merit_elv.tif \
#     ${AUX_DATADIR}/merit_elv_utm19s.tif

# UTM_LOCATION=$HOME/grassdata/utm19s
# UTM_MAPSET=$UTM_LOCATION/jules
# if [[ ! -d $UTM_LOCATION ]]
# then
#     grass -c -e epsg:32719 $UTM_LOCATION
# fi

# if [[ ! -d $UTM_MAPSET ]]
# then
#     grass -c -e $UTM_MAPSET
# fi

# SRCDIR=$(pwd)/src
# chmod u+x $SRCDIR/grass_make_slope.sh
# export GRASS_BATCH_JOB=$SRCDIR/grass_make_slope.sh
# grass76 $UTM_MAPSET
# unset GRASS_BATCH_JOB
