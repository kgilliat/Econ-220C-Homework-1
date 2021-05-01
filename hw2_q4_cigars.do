drop _all
set mem 300m
set more off

cd "C:/Users/Kurtis/Documents/Classes/Spring 2021/Metrics/Homework 2"
capture log close
log using ps2.log, replace

import excel using "cigar.xls", clear firstrow

*Rename variables
rename (State Year logconsumption lnprice logincome logminimumpriceatneighboring) ///
	(state year lnc lnp lny lnpn)

sort state year
tsset state year

**************************************************************
*      Part (a)                                              *
**************************************************************
reg lnc L1.lnc lnp lny lnpn, r

*Record beta and standard errors
mat coeffs = r(table)
local b1 = coeffs[1,1]
local b2 = coeffs[1,2]
local b3 = coeffs[1,3]
local b4 = coeffs[1,4]

local se1 = coeffs[2,1]
local se2 = coeffs[2,2]
local se3 = coeffs[2,3]
local se4 = coeffs[2,4]

foreach x in b1 b2 b3 b4 se1 se2 se3 se4 {
	local `x' : di %10.2fc ``x''
	}

*Output table of coefficients
cap file close texfile
file open texfile using table1.tex, write replace 
file write texfile "\begin{table}[h]" _n
file write texfile "\centering" _n
file write texfile "\caption{Effects of prices, income, and past consumption on cigarette prices, OLS w/o FEs}" _n
file write texfile "\label{tab:table1}" _n
file write texfile "\begin{tabular}{lcccc}" _n
file write texfile "\toprule" _n
file write texfile " & $ \log(C_{t-1}) $ & $ \log(P_t) $ & $ \log(Y_t) $ & $ \log(Pn_t) $ \tabularnewline" _n
file write texfile "\midrule" _n

file write texfile "$ \hat{\beta} $ & `b1' & `b2' & `b3' & `b4' \tabularnewline" _n
file write texfile "(Standard Error) & (`se1') & (`se2') & (`se3') & (`se4') \tabularnewline" _n

file write texfile "\bottomrule \addlinespace[1ex]" _n
file write texfile "\end{tabular}" _n
file write texfile "\end{table}" _n
file close texfile


**************************************************************
*      Part (b)                                              *
**************************************************************
quiet tabulate year, generate (yeard)  
                              /*generate the year dummies */

reg lnc L1.lnc lnp lny lnpn yeard2-yeard30, r

*Record beta and standard errors
mat coeffs = r(table)
local b1 = coeffs[1,1]
local b2 = coeffs[1,2]
local b3 = coeffs[1,3]
local b4 = coeffs[1,4]

local se1 = coeffs[2,1]
local se2 = coeffs[2,2]
local se3 = coeffs[2,3]
local se4 = coeffs[2,4]

foreach x in b1 b2 b3 b4 se1 se2 se3 se4 {
	local `x' : di %10.2fc ``x''
	}

*Output table of coefficients
cap file close texfile
file open texfile using table2.tex, write replace 
file write texfile "\begin{table}[h]" _n
file write texfile "\centering" _n
file write texfile "\caption{Effects of prices, income, and past consumption on cigarette prices, year FEs}" _n
file write texfile "\label{tab:table2}" _n
file write texfile "\begin{tabular}{lcccc}" _n
file write texfile "\toprule" _n
file write texfile " & $ \log(C_{t-1}) $ & $ \log(P_t) $ & $ \log(Y_t) $ & $ \log(Pn_t) $ \tabularnewline" _n
file write texfile "\midrule" _n

file write texfile "$ \hat{\beta} $ & `b1' & `b2' & `b3' & `b4' \tabularnewline" _n
file write texfile "(Standard Error) & (`se1') & (`se2') & (`se3') & (`se4') \tabularnewline" _n

file write texfile "\bottomrule \addlinespace[1ex]" _n
file write texfile "\end{tabular}" _n
file write texfile "\end{table}" _n
file close texfile

**************************************************************
*      Part (c)                                              *
**************************************************************
by state: gen lnc1=lnc[_n-1]
xtreg lnc lnc1 lnp lny lnpn, fe

*Record beta and standard errors
mat coeffs = r(table)
local b1 = coeffs[1,1]
local b2 = coeffs[1,2]
local b3 = coeffs[1,3]
local b4 = coeffs[1,4]

local se1 = coeffs[2,1]
local se2 = coeffs[2,2]
local se3 = coeffs[2,3]
local se4 = coeffs[2,4]

foreach x in b1 b2 b3 b4 se1 se2 se3 se4 {
	local `x' : di %10.2fc ``x''
	}

*Output table of coefficients
cap file close texfile
file open texfile using table3.tex, write replace 
file write texfile "\begin{table}[h]" _n
file write texfile "\centering" _n
file write texfile "\caption{Effects of prices, income, and past consumption on cigarette prices, state FEs}" _n
file write texfile "\label{tab:table3}" _n
file write texfile "\begin{tabular}{lcccc}" _n
file write texfile "\toprule" _n
file write texfile " & $ \log(C_{t-1}) $ & $ \log(P_t) $ & $ \log(Y_t) $ & $ \log(Pn_t) $ \tabularnewline" _n
file write texfile "\midrule" _n

file write texfile "$ \hat{\beta} $ & `b1' & `b2' & `b3' & `b4' \tabularnewline" _n
file write texfile "(Standard Error) & (`se1') & (`se2') & (`se3') & (`se4') \tabularnewline" _n

file write texfile "\bottomrule \addlinespace[1ex]" _n
file write texfile "\end{tabular}" _n
file write texfile "\end{table}" _n
file close texfile

**************************************************************
*      Part (d)                                              *
**************************************************************

qui xtreg lnc lnc1 lnp lny lnpn yeard2-yeard30, fe 
testparm yeard*

*Record beta and standard errors
xtreg lnc lnc1 lnp lny lnpn yeard2-yeard30, fe 
mat coeffs = r(table)
local b1 = coeffs[1,1]
local b2 = coeffs[1,2]
local b3 = coeffs[1,3]
local b4 = coeffs[1,4]

local se1 = coeffs[2,1]
local se2 = coeffs[2,2]
local se3 = coeffs[2,3]
local se4 = coeffs[2,4]

foreach x in b1 b2 b3 b4 se1 se2 se3 se4 {
	local `x' : di %10.2fc ``x''
	}

*Output table of coefficients
cap file close texfile
file open texfile using table4.tex, write replace 
file write texfile "\begin{table}[h]" _n
file write texfile "\centering" _n
file write texfile "\caption{Effects of prices, income, and past consumption on cigarette prices, state and year FEs}" _n
file write texfile "\label{tab:table4}" _n
file write texfile "\begin{tabular}{lcccc}" _n
file write texfile "\toprule" _n
file write texfile " & $ \log(C_{t-1}) $ & $ \log(P_t) $ & $ \log(Y_t) $ & $ \log(Pn_t) $ \tabularnewline" _n
file write texfile "\midrule" _n

file write texfile "$ \hat{\beta} $ & `b1' & `b2' & `b3' & `b4' \tabularnewline" _n
file write texfile "(Standard Error) & (`se1') & (`se2') & (`se3') & (`se4') \tabularnewline" _n

file write texfile "\bottomrule \addlinespace[1ex]" _n
file write texfile "\end{tabular}" _n
file write texfile "\end{table}" _n
file close texfile


**************************************************************
*      Part (e)                                              *
**************************************************************

gen Dlnc=D.lnc
ivreg D.lnc (L1.Dlnc = L2.lnc) D.lnp D.lny D.lnpn  yeard2-yeard30

*Record beta and standard errors
mat coeffs = r(table)
local b1 = coeffs[1,1]
local b2 = coeffs[1,2]
local b3 = coeffs[1,3]
local b4 = coeffs[1,4]

local se1 = coeffs[2,1]
local se2 = coeffs[2,2]
local se3 = coeffs[2,3]
local se4 = coeffs[2,4]

foreach x in b1 b2 b3 b4 se1 se2 se3 se4 {
	local `x' : di %10.2fc ``x''
	}

*Output table of coefficients
cap file close texfile
file open texfile using table5.tex, write replace 
file write texfile "\begin{table}[h]" _n
file write texfile "\centering" _n
file write texfile "\caption{Effects of prices, income, and past consumption on cigarette prices, AH}" _n
file write texfile "\label{tab:table5}" _n
file write texfile "\begin{tabular}{lcccc}" _n
file write texfile "\toprule" _n
file write texfile " & $ \log(C_{t-1}) $ & $ \log(P_t) $ & $ \log(Y_t) $ & $ \log(Pn_t) $ \tabularnewline" _n
file write texfile "\midrule" _n

file write texfile "$ \hat{\beta} $ & `b1' & `b2' & `b3' & `b4' \tabularnewline" _n
file write texfile "(Standard Error) & (`se1') & (`se2') & (`se3') & (`se4') \tabularnewline" _n

file write texfile "\bottomrule \addlinespace[1ex]" _n
file write texfile "\end{tabular}" _n
file write texfile "\end{table}" _n
file close texfile


**************************************************************
*      Part (g)                                              *
**************************************************************

*******g.i **********
xtabond lnc lnp lny lnpn yeard2-yeard30, lags(1)

*Record beta and standard errors
mat coeffs = r(table)
local b1 = coeffs[1,1]
local b2 = coeffs[1,2]
local b3 = coeffs[1,3]
local b4 = coeffs[1,4]

local se1 = coeffs[2,1]
local se2 = coeffs[2,2]
local se3 = coeffs[2,3]
local se4 = coeffs[2,4]

foreach x in b1 b2 b3 b4 se1 se2 se3 se4 {
	local `x' : di %10.2fc ``x''
	}

*Output table of coefficients
cap file close texfile
file open texfile using table6.tex, write replace 
file write texfile "\begin{table}[h]" _n
file write texfile "\centering" _n
file write texfile "\caption{Effects of prices, income, and past consumption on cigarette prices, AB1}" _n
file write texfile "\label{tab:table6}" _n
file write texfile "\begin{tabular}{lcccc}" _n
file write texfile "\toprule" _n
file write texfile " & $ \log(C_{t-1}) $ & $ \log(P_t) $ & $ \log(Y_t) $ & $ \log(Pn_t) $ \tabularnewline" _n
file write texfile "\midrule" _n

file write texfile "$ \hat{\beta} $ & `b1' & `b2' & `b3' & `b4' \tabularnewline" _n
file write texfile "(Standard Error) & (`se1') & (`se2') & (`se3') & (`se4') \tabularnewline" _n

file write texfile "\bottomrule \addlinespace[1ex]" _n
file write texfile "\end{tabular}" _n
file write texfile "\end{table}" _n
file close texfile



*******g.ii **********
xtabond lnc lnp lny lnpn yeard2-yeard30, lags(1) maxldep(3)

*Record beta and standard errors
mat coeffs = r(table)
local b1 = coeffs[1,1]
local b2 = coeffs[1,2]
local b3 = coeffs[1,3]
local b4 = coeffs[1,4]

local se1 = coeffs[2,1]
local se2 = coeffs[2,2]
local se3 = coeffs[2,3]
local se4 = coeffs[2,4]

foreach x in b1 b2 b3 b4 se1 se2 se3 se4 {
	local `x' : di %10.2fc ``x''
	}

*Output table of coefficients
cap file close texfile
file open texfile using table7.tex, write replace 
file write texfile "\begin{table}[h]" _n
file write texfile "\centering" _n
file write texfile "\caption{Effects of prices, income, and past consumption on cigarette prices, AB 3 lags}" _n
file write texfile "\label{tab:table7}" _n
file write texfile "\begin{tabular}{lcccc}" _n
file write texfile "\toprule" _n
file write texfile " & $ \log(C_{t-1}) $ & $ \log(P_t) $ & $ \log(Y_t) $ & $ \log(Pn_t) $ \tabularnewline" _n
file write texfile "\midrule" _n

file write texfile "$ \hat{\beta} $ & `b1' & `b2' & `b3' & `b4' \tabularnewline" _n
file write texfile "(Standard Error) & (`se1') & (`se2') & (`se3') & (`se4') \tabularnewline" _n

file write texfile "\bottomrule \addlinespace[1ex]" _n
file write texfile "\end{tabular}" _n
file write texfile "\end{table}" _n
file close texfile




*******g.iii **********
xtabond lnc lnp lny lnpn yeard2-yeard30, lags(1) maxldep(1)

*Record beta and standard errors
mat coeffs = r(table)
local b1 = coeffs[1,1]
local b2 = coeffs[1,2]
local b3 = coeffs[1,3]
local b4 = coeffs[1,4]

local se1 = coeffs[2,1]
local se2 = coeffs[2,2]
local se3 = coeffs[2,3]
local se4 = coeffs[2,4]

foreach x in b1 b2 b3 b4 se1 se2 se3 se4 {
	local `x' : di %10.2fc ``x''
	}

*Output table of coefficients
cap file close texfile
file open texfile using table8.tex, write replace 
file write texfile "\begin{table}[h]" _n
file write texfile "\centering" _n
file write texfile "\caption{Effects of prices, income, and past consumption on cigarette prices, AB 1 lag}" _n
file write texfile "\label{tab:table8}" _n
file write texfile "\begin{tabular}{lcccc}" _n
file write texfile "\toprule" _n
file write texfile " & $ \log(C_{t-1}) $ & $ \log(P_t) $ & $ \log(Y_t) $ & $ \log(Pn_t) $ \tabularnewline" _n
file write texfile "\midrule" _n

file write texfile "$ \hat{\beta} $ & `b1' & `b2' & `b3' & `b4' \tabularnewline" _n
file write texfile "(Standard Error) & (`se1') & (`se2') & (`se3') & (`se4') \tabularnewline" _n

file write texfile "\bottomrule \addlinespace[1ex]" _n
file write texfile "\end{tabular}" _n
file write texfile "\end{table}" _n
file close texfile




