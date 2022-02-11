#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os
import numpy as np
import xarray

# AUX_DATADIR = str(os.environ['AUX_DATADIR'])

# START = 1980
# END = 2018
# YEARS = np.arange(START, END + 1)
# ID_STEM = 'JULES_vn6.1'
# PROFILE_NAMES = ['daily_hydrology']

prec = xarray.open_dataset("~/projects/rahu/data/WRF_climate/precipitation_bias_corrected.nc")
prec_year = prec.groupby('Time.year').sum(dim="Time")
prec_annual_mean = prec_year.mean(dim="year")
prec_annual_mean.to_netcdf("test1.nc")

prec = xarray.open_dataset("~/projects/rahu/data/WRF_climate_fixed/precip.nc")
prec['precip'] = prec['precip'] * 60 * 60
prec_year = prec.groupby('time.year').sum(dim="time")
prec_annual_mean = prec_year.mean(dim="year")
prec_annual_mean.to_netcdf("test2.nc")

prec = xarray.open_dataset("~/JULES_output/u-cd588/JULES_vn6.1.S2.daily_hydrology.1980.nc")#['precip']
prec = prec * 24 * 60 * 60
prec_year = prec.groupby('time.year').sum(dim='time')
prec_annual_mean = prec_year.mean(dim="year")
prec_annual_mean.to_netcdf("test3.nc")

prec = xarray.open_dataset("~/projects/mosart/data/aux/JULES_vn6.1.S2.daily_hydrology.1980.reformat.nc")['precip']
prec = prec * 24 * 60 * 60
prec_year = prec.groupby('time.year').sum(dim='time')
prec_annual_mean = prec_year.mean(dim="year")
prec_annual_mean.to_netcdf("test4.nc")


# fs = []
# for yr in YEARS:
#     FN = 'JULES_vn6.1.S2.daily_hydrology.' + str(yr) + '.regrid.nc'
#     fs.append(os.path.join(AUX_DATADIR, FN))

# x = xr.open_mfdataset(fs)
# area = xr.open_dataset(os.path.join(AUX_DATADIR, "gridarea.nc"))
# for var in ['surf_roff', 'sub_surf_roff', 'runoff']:
#     # kg m-2 s-1 -> m/d
#     x[var] = x[var] * 60 * 60 * 24 / 1000
#     # # m -> m3
#     # x[var] = x[var] * area['cell_area']
    
# x_year = x.groupby("time.year").sum(dim="time")
# x_annual_mean = x_year.mean(dim="year")
# for jules_var in ['precip', 'esoil_gb', 'ecan_gb', 'elake', 'surf_roff', 'sub_surf_roff', 'runoff']:
#     # m -> m3
#     x_annual_mean[jules_var] = x_annual_mean[jules_var] * area['cell_area']

# x_annual_mean.to_netcdf(os.path.join(AUX_DATADIR, "jules_runoff_1980_2018_anntot.nc"))
# x.close()
