drop _all
set mem 300m
set more off

cd "C:/Users/Kurtis/Documents/Classes/Spring 2021/Metrics/Homework 3"
capture log close
log using ps3.log, replace

set obs 100 
drawnorm x 
gen y=x>0
logit y x
