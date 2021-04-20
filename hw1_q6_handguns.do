*-------------------------------------------------------------------------------*
*                     Homework 1 Problem 6 - Handguns                           *
*-------------------------------------------------------------------------------*
*Author: Kurtis Gilliat
*Date: 4/16/2021

clear all
 
set more off 
set matsize 300 
capture log close

cd "C:/Users/Kurtis/Documents/Classes/Spring 2021/Metrics/Homework 1"

log using shall.log, replace
use handguns.dta

desc
summarize
gen log_vio=log(vio)
gen log_mur=log(mur)
gen log_rob=log(rob)

/****************************** Question 1 **********************************/
foreach crime in vio mur rob {
	reg log_`crime' shall, r
	mat coeffs = r(table)
	local `crime'_r2 = `e(r2)'
	local `crime'_b1 = coeffs[1,1]
	local `crime'_b0 = coeffs[1,2]
	local `crime'_se1 = coeffs[2,1]
	local `crime'_se0 = coeffs[2,2]
	foreach x in b0 se0 b1 se1 r2 {
		local `crime'_`x' : di %10.2fc ``crime'_`x''
		}
	}

*Make table
cap file close texfile
file open texfile using regression_table1.tex, write replace 
file write texfile "\begin{table}[h]" _n
file write texfile "\centering" _n
file write texfile "\caption{Effect of Shall laws on crime, no controls}" _n
file write texfile "\label{tab:table1}" _n
file write texfile "\begin{tabular}{lccc}" _n
file write texfile "\toprule" _n
file write texfile "Dep Var $=$ & $ \log(vio) $ & $ \log(mur) $ & $ \log(rob) $ \tabularnewline" _n
file write texfile "\midrule" _n

file write texfile "$ \hat{\beta}_0 $ & `vio_b0' & `mur_b0' & `rob_b0' \tabularnewline" _n
file write texfile " & (`vio_se0') & (`mur_se0') & (`rob_se0') \tabularnewline" _n
file write texfile "$ \hat{\beta}_1 $ & `vio_b1' & `mur_b1' & `rob_b1' \tabularnewline" _n
file write texfile " & (`vio_se1') & (`mur_se1') & (`rob_se1') \tabularnewline" _n
file write texfile "$ R^2 $ & `vio_r2' & `mur_r2' & `rob_r2' \tabularnewline" _n

file write texfile "\bottomrule \addlinespace[1ex]" _n
file write texfile "\end{tabular}" _n
file write texfile "\end{table}" _n
file close texfile

/****************************** Question 2 **********************************/
foreach crime in vio mur rob {
	reg log_`crime' shall incarc_rate density pop pm1029 avginc, r
	mat coeffs = r(table)
	local `crime'_r2 = `e(r2)'
	local `crime'_b1 = coeffs[1,1]
	local `crime'_b0 = coeffs[1,7]
	local `crime'_se1 = coeffs[2,1]
	local `crime'_se0 = coeffs[2,7]
	foreach x in b0 se0 b1 se1 r2 {
		local `crime'_`x' : di %10.2fc ``crime'_`x''
		}
	}

*Make table
cap file close texfile
file open texfile using regression_table2.tex, write replace 
file write texfile "\begin{table}[h]" _n
file write texfile "\centering" _n
file write texfile "\caption{Effect of Shall laws on crime, with controls}" _n
file write texfile "\label{tab:table2}" _n
file write texfile "\begin{tabular}{lccc}" _n
file write texfile "\toprule" _n
file write texfile "Dep Var $=$ & $ \log(vio) $ & $ \log(mur) $ & $ \log(rob) $ \tabularnewline" _n
file write texfile "\midrule" _n

file write texfile "$ \hat{\beta}_0 $ & `vio_b0' & `mur_b0' & `rob_b0' \tabularnewline" _n
file write texfile " & (`vio_se0') & (`mur_se0') & (`rob_se0') \tabularnewline" _n
file write texfile "$ \hat{\beta}_1 $ & `vio_b1' & `mur_b1' & `rob_b1' \tabularnewline" _n
file write texfile " & (`vio_se1') & (`mur_se1') & (`rob_se1') \tabularnewline" _n
file write texfile "$ R^2 $ & `vio_r2' & `mur_r2' & `rob_r2' \tabularnewline" _n

file write texfile "\bottomrule \addlinespace[1ex]" _n
file write texfile "\end{tabular}" _n
file write texfile "\end{table}" _n
file close texfile

/****************************** Question 4 **********************************/
tab state, gen(statedummy)
tab year, gen(yeardummy)

foreach crime in vio mur rob {

/* column 1 in the table */
reg log_`crime' shall incarc_rate density pop pm1029 avginc, r
mat coeffs = r(table)
local `crime'_b1 = coeffs[1,1]
local `crime'_se1 = coeffs[2,1]

/* column 2 in the table */
reg log_`crime' shall incarc_rate density pop pm1029 avginc statedummy*, r
mat coeffs = r(table)
local `crime'_b2 = coeffs[1,1]
local `crime'_se2 = coeffs[2,1]
testparm statedummy*
local `crime'_ps2 = r(p)

/* column 3 in the table */
reg log_`crime' shall incarc_rate density pop pm1029 avginc statedummy* yeardummy*,r
mat coeffs = r(table)
local `crime'_b3 = coeffs[1,1]
local `crime'_se3 = coeffs[2,1]
testparm statedummy*
local `crime'_ps3 = r(p)
testparm yeardummy*
local `crime'_py3 = r(p)

/* Clustered standard errors */
reg log_`crime' shall incarc_rate density pop pm1029 avginc statedummy* yeardummy*, cluster(state) r 
mat coeffs = r(table)
local `crime'_b4 = coeffs[1,1]
local `crime'_se4 = coeffs[2,1]
testparm statedummy*
local `crime'_ps4 = r(p)
testparm yeardummy*
local `crime'_py4 = r(p)

*Format values for table
foreach x in b1 se1 b2 se2 ps2 b3 se3 ps3 py3 b4 se4 ps4 py4 {
	local `crime'_`x' : di %10.2fc ``crime'_`x''
	}

*Make tables
cap file close texfile
file open texfile using regression_table_`crime'.tex, write replace 
file write texfile "\begin{table}[h]" _n
file write texfile "\centering" _n
file write texfile "\caption{Comparing four estimates of Shall laws' effect on $\log$(`crime')}" _n
file write texfile "\label{tab:table_`crime'}" _n
file write texfile "\begin{tabular}{lcccc}" _n
file write texfile "\toprule" _n
file write texfile "Dep Var $=\log(`crime')$ & 1 & 2 & 3 & cluster option  \tabularnewline" _n
file write texfile "\midrule" _n

file write texfile "$\hat{\beta}_1$ (\textit{shall}) & ``crime'_b1' & ``crime'_b2' & ``crime'_b3' & ``crime'_b4'  \tabularnewline" _n
file write texfile "(std. error) & (``crime'_se1') & (``crime'_se2') & (``crime'_se3') & (``crime'_se4')  \tabularnewline" _n
file write texfile "State Fixed Effect & No & Yes & Yes & Yes  \tabularnewline" _n
file write texfile "Year Fixed Effect & No & No & Yes & Yes  \tabularnewline" _n
file write texfile "F test for State Effect & - & ``crime'_ps2' & ``crime'_ps3' & ``crime'_ps4'  \tabularnewline" _n
file write texfile "F test for Year Effect & - & - & ``crime'_py3' & ``crime'_py4'  \tabularnewline" _n


file write texfile "\bottomrule \addlinespace[1ex]" _n
file write texfile "\end{tabular}" _n
file write texfile "\end{table}" _n
file close texfile


}
***eof***
	