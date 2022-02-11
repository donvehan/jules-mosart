#!/bin/bash

# ===================================== #
# 1 - Aactivate Anaconda environment
# ===================================== #

CONDA_BASE=$(conda info --base)
source $CONDA_BASE/etc/profile.d/conda.sh
conda deactivate

# REMOVE:
export DATADIR=$(pwd)/../data
export AUX_DATADIR=$(pwd)/../data/aux
export OUTLET_X=-72.6271
export OUTLET_Y=-13.0045
export OUTDIR=$AUX_DATADIR

conda activate mosart
python src/upscale-routing-params.py
conda deactivate 
