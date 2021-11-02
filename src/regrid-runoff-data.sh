#!/bin/bash

# TODO: need a reliable way to specify this grid

# echo "gridtype=lonlat
# xsize=40
# ysize=40
# xfirst=-73.95
# xinc=0.1
# yfirst=-11.95
# yinc=-0.1" > /tmp/gridfile.txt

for YEAR in {1980..2018}
do
    echo $YEAR
    FN=$DATADIR/JULES_vn6.1.S2.daily_hydrology.$YEAR.reformat.nc
    # FN=JULES_vn6.1.S2.daily_hydrology.${YEAR}.reformat.nc
    OUTFN1=tmp.nc
    cdo remapbil,/tmp/gridfile.txt $FN $OUTFN1
    # # 3-convert datatype
    OUTFN2=$DATADIR/JULES_vn6.1.S2.daily_hydrology.$YEAR.regrid.nc
    cdo -b F64 copy $OUTFN1 $OUTFN2
    # tidy up
    rm -f tmp.nc
done

# We also need a grid area file, so make that here
cdo gridarea $DATADIR/JULES_vn6.1.S2.daily_hydrology.1980.regrid.nc $AUX_DATADIR/gridarea.nc

# NOT USED:

# ERA-Land: [NB this is so terrible over the Vilcanota that we do not use here]
# for VAR in runoff sub_surface_runoff surface_runoff
# do    
#     echo $YEAR
#     FN=$DATADIR/${VAR}_1981_2020.nc
#     OUTFN1=/tmp/tmp.nc
#     # 1-regrid
#     cdo remapbil,/tmp/gridfile.txt $FN $OUTFN1
#     OUTFN2=$AUX_DATADIR/${VAR}_1981_2020_regrid.nc
#     # 2-convert datatype
#     cdo -b F64 copy $OUTFN1 $OUTFN2
# done

