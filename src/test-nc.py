#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os
import numpy as np
import xarray

LAT = np.array([9.5,8.5,7.5,6.5,5.5]) * -1
LAT = LAT[::-1]
LON = np.array([0.5, 1.5, 2.5, 3.5, 4.5])
VALS = np.array([1,2,3,4,5])[:,None] * np.ones((5,5))

import netCDF4
nco = netCDF4.Dataset("test.nc", "w")
nco.createDimension('lat', len(LAT))
nco.createDimension('lon', len(LON))

var = nco.createVariable(
    'lon', 'f8', ('lon',)
)
var.units = 'degrees_east'
var.standard_name = 'lon'
var.long_name = 'longitude'
var[:] = LON

var = nco.createVariable(
    'lat', 'f8', ('lat',)
)
var.units = 'degrees_north'
var.standard_name = 'lat'
var.long_name = 'latitude'
var[:] = LAT

var = nco.createVariable('runoff', 'f8', ('lat', 'lon'), fill_value=F8_FILLVAL)
var[:] = VALS
nco.close()
