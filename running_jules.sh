#!/bin/bash

# Instructions on running JULES for VU model using rose-suites
# Clara Gimeno Jesus, June 2022

# Navigate to rose suites folder
cd roses
#for Clara's rose suite
cd u-cj531
# for Simon's rose suite
cd u-cd588

### Changes in the configuration file
cd rose-suite.conf

# Change the variables CHAUKHAMBA_ANCIL_PATH and CHAUKHAMBA_DRIVE_PATH to the
# location of rahu_data/netcdf and rahu_data/WRF_climate_fixed, respectively,
# and CHAUKHAMBA_OUTPUT_FILE to somewhere on your home directory

# Change LSPINUP to "true", so that JULES will run the spinup routine. 
# This only needs to be done once (unless you change something else in the
# model config), as JULES will subsequently restart from one of the dump files
# from the initial spinup

# Change output folders to relevant folders in your directory

# The rahu data can be copied from /mnt/scratch/scratch/data/rahu_data

### RUNNING THE ROSE-SUITE

# Always cache your mosrs password before running a rose-suite
mosrs-cache-password

# For the first time you should also:
source .bashrc
mosrs-setup-gpg-agent

# Make sure the same username is used for mosrs login details,
# ~/.metome/rose.conf and ~/.subversion/servers

# Check this has worked by running the following command
rosie hello

conda activate jules

# Two ways of running the rose suite
# Through the terminal
cd roses/u-cj531
rose-suite-run

# Through the GUI interface
rosie go
# select relevant rose-suite
# click on Run



