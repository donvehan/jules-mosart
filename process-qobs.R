## Author : Simon Moulds
## Date   : September 2021

library(readxl)
library(magrittr)
library(dplyr)
library(tidyr)
library(stringr)
library(zoo)

datadir = "../data-raw"

list.files(datadir)

## Daily discharge data 1958-2015 for the main (and most reliable!)
## gauge in the VUB. This one is situated in the lower basin, close
## to Machu Pichu hydropower plant.

## Latitude  : -13.183103
## Longitude : -72.533592
## Elevation : 2153 masl

months = data.frame(
    Month = c("Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio", "Julio", "Agosto", "Setiembre", "Octubre", "Noviembre", "Diciembre"),
    Month_numeric = as.integer(c(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12))
)

x =
    read_excel(file.path(datadir, "km105_1958_2015_d.xlsx"), skip=2) %>%
    setNames(c("Day", names(.)[2:ncol(.)])) %>%
    separate("Day", into=c("Day", "Month"), sep="--|-") %>%
    mutate_if(is.character, str_trim) %>%
    mutate(Day=as.integer(Day)) %>% 
    left_join(months) %>%
    dplyr::select(-Month) %>%
    rename(Month=Month_numeric) %>%
    gather(Year, Discharge, -Day, -Month) %>%
    mutate(Year=as.integer(Year))

start_time = as.Date("1958-01-01")
end_time = as.Date("2015-12-31")
times = seq(start_time, end_time, by="1 day") %>% as.POSIXlt
yearmon = as.yearmon(times)
full_ts = data.frame(
    Day = times$mday,
    Month = times$mon + 1,
    Year = times$year + 1900,
    yearmon = yearmon
)
Qobs_daily = full_ts %>% left_join(x)

Qobs_month =
    Qobs_daily %>%
    group_by(yearmon) %>% 
    summarise(obs = mean(Discharge, na.rm=TRUE))

## Compare with modelled data
Qsim_month =
    read.csv("../mosart-output/rahu/output_pt.csv") %>%
    dplyr::select(time, channel_inflow) %>%
    mutate(yearmon = as.yearmon(time)) %>%
    dplyr::select(-time) %>%
    group_by(yearmon) %>%
    summarise(sim = mean(channel_inflow, na.rm=TRUE))

Q = left_join(Qsim_month, Qobs_month)
Q = Q[complete.cases(Q),]

library(hydroGOF)
obs = Q$obs
sim = Q$sim
nse = NSE(sim, obs) # 0.78 (not bad!)

## Cumulative discharge

Qobs_year =
    Qobs_month %>%
    mutate(year=format(yearmon, "%Y")) %>%
    dplyr::select(-yearmon) %>%
    group_by(year) %>%
    summarise(obs = mean(obs, na.rm=TRUE))

Qsim_year =
    Qsim_month %>%
    mutate(year=format(yearmon, "%Y")) %>%
    dplyr::select(-yearmon) %>%
    group_by(year) %>%
    summarise(sim = mean(sim, na.rm=TRUE))

Qann = left_join(Qsim_year, Qobs_year)
Qann = Qann[complete.cases(Qann),]
obs = Qann$obs
sim = Qann$sim
Qann_avg_obs = mean(obs) # 128.95 m3/s
## Qann_avg_sim = mean(sim) # 139.18 m3/s [OLD, routing @ 0.1deg]
Qann_avg_sim = mean(sim) # 124.04 m3/s

## x =
##     read_excel(file.path(datadir, "km105_2016_2021_proins_REFORMATTED.xlsx"), skip=1)

## x =
##     read_excel(file.path(datadir, "km105_1985_2021_pro1d_REFORMATTED.xlsx"), skip=1)

## Now take monthly average etc.

