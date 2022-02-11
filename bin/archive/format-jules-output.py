#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os
import numpy as np
import netCDF4
import xarray

DATADIR = str(os.environ['DATADIR'])

START = 1980
END = 2018
YEARS = np.arange(START, END + 1)
ID_STEM = 'JULES_vn6.1'
PROFILE = 'daily_hydrology'

# Default fill vals for netCDF 
F8_FILLVAL = netCDF4.default_fillvals['f8']
F4_FILLVAL = netCDF4.default_fillvals['f4']
I4_FILLVAL = netCDF4.default_fillvals['i4']

def main():        
    for yr in YEARS:

        print('Processing output profile ' + PROFILE + ' for year ' + str(yr) + '...')

        # NB I had been doing this in xarray but it was causing
        # issues - using netCF4 directly seems to have solved these

        # 1 - get original JULES output
        fn = ID_STEM + '.S2.' + PROFILE + '.' + str(yr) + '.nc'
        x = netCDF4.Dataset(os.path.join(DATADIR, 'jules-output', fn), 'r')
        lat_vals = x['latitude'][:,0]
        lon_vals = x['longitude'][0,:]

        outfn = ID_STEM + '.S2.' + PROFILE + '.' + str(yr) + '.reformat.nc'            
        # nco = netCDF4.Dataset(outfn, 'w', format='NETCDF4')
        nco = netCDF4.Dataset(os.path.join(DATADIR, 'aux', outfn), 'w', format='NETCDF4')

        nco.createDimension('latitude', len(lat_vals))
        nco.createDimension('longitude', len(lon_vals))
        nco.createDimension('time', None)

        var = nco.createVariable(
            'longitude', 'f8', ('longitude',)
        )
        var.units = 'degrees_east'
        var.standard_name = 'longitude'
        var[:] = lon_vals

        var = nco.createVariable(
            'latitude', 'f8', ('latitude',)
        )
        var.units = 'degrees_north'
        var.standard_name = 'latitude'
        var[:] = lat_vals

        var = nco.createVariable(
            'time', 'f4', ('time',)
        )
        var.units = x['time'].units
        var.standard_name = x['time'].standard_name
        var[:] = x['time'][:]

        for jules_var in ['precip', 'esoil_gb', 'ecan_gb', 'elake', 'surf_roff', 'sub_surf_roff', 'runoff']:            
            var = nco.createVariable(jules_var, 'f4', ('time', 'latitude', 'longitude'), fill_value=F4_FILLVAL)
            var.units = x[jules_var].units
            var.long_name = x[jules_var].long_name
            # var[:] = x[jules_var][:]
            var[:] = np.flip(x[jules_var][:], axis=1)  # TESTING            
        nco.close()
        x.close()
                
if __name__ == '__main__':
    main()

