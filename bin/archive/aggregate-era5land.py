#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os
import numpy as np
import xarray as xr

AUX_DATADIR = str(os.environ['AUX_DATADIR'])
DATADIR = str(os.environ['DATADIR'])

FN = 'runoff_1981_2020_regrid.nc'

# Open runoff file, get mean annual runoff [m3 s-1]

x = xr.open_dataset(os.path.join(AUX_DATADIR, FN))
# days_in_month = x.time.dt.days_in_month
area = xr.open_dataset(os.path.join(AUX_DATADIR, "gridarea.nc"))
x['ro'] = x['ro'] * area['cell_area']
x_year = x.groupby("time.year").sum(dim="time")
x_annual_mean = x_year.mean(dim="year")
x_annual_mean.to_netcdf(os.path.join(AUX_DATADIR, "runoff_1981_2020_annmean.nc"))

# x['ro'] = (x['ro'] / days_in_month / 86400) * area['cell_area']
# x_year = x.groupby("time.year").mean(dim="time")
# x_annual_mean = x_year.mean(dim="year")
# x_annual_mean.to_netcdf(os.path.join(AUX_DATADIR, "runoff_1981_2020_annmean.nc"))
