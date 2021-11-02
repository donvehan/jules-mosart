#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os
import numpy as np
import xarray as xr
from constants import OUTPUT_VARS 

START = int(os.environ['JULES_START_YEAR'])
END = int(os.environ['JULES_END_YEAR'])
YEARS = np.arange(START, END + 1)
SUITE = str(os.environ['JULES_SUITE'])
ID_STEM = str(os.environ['JULES_ID_STEM'])
JOB_NAME = str(os.environ['JULES_JOB_NAME'])
PROFILE_NAME = str(os.environ['JULES_PROFILE_NAME'])
INPUT_DIRECTORY = str(os.environ['INPUT_DIRECTORY'])
INPUT_FILE_SUFFIX = str(os.environ['INPUT_FILE_SUFFIX'])
OUTPUT_DIRECTORY = str(os.environ['OUTPUT_DIRECTORY'])

def main():    
    for yr in YEARS:
        job_name = JOB_NAME.format(year=yr)
        FN = ID_STEM + '.' + job_name + '.' + PROFILE_NAME + '.' + str(yr) + '.' + INPUT_FILE_SUFFIX + '.nc'
        x = xr.open_dataset(os.path.join(INPUT_DIRECTORY, FN))
        # kg m-2 s-1 -> m d-1
        rate_vars = []
        for var in OUTPUT_VARS['daily_hydrology']:
            try:
                if x[var].units == 'kg m-2 s-1':                
                    x[var] = x[var] * 60 * 60 * 24 / 1000
                    rate_vars.append(var)
            except KeyError:
                pass
        x = x[rate_vars]
        # m d-1 -> m month-1
        MONTH_OUTFN = ID_STEM + '.' + job_name + '.' + PROFILE_NAME + '.' + str(yr) + '.' + INPUT_FILE_SUFFIX + '.month.nc'
        x_month = x.groupby("time.month").sum(dim="time")
        x_month.to_netcdf(os.path.join(OUTPUT_DIRECTORY, MONTH_OUTFN))
        # m d-1 -> m year-1
        YEAR_OUTFN = ID_STEM + '.' + job_name + '.' + PROFILE_NAME + '.' + str(yr) + '.' + INPUT_FILE_SUFFIX + '.year.nc'
        x_year = x.groupby("time.year").sum(dim="time")
        x_year.to_netcdf(os.path.join(OUTPUT_DIRECTORY, YEAR_OUTFN))
        x.close()

if __name__ == '__main__':
    main()
