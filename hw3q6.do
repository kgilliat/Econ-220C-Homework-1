clear
cd "C:/Users/Kurtis/Documents/Classes/Spring 2021/Metrics/Homework 3"
local beta -0.5 
/* try different beta's by changing this line -0.5,0.5and 0 */
set more off
set trace off

cap postclose temp
postfile temp beta_2sls beta_iv se_2sls se_iv reject_2sls reject_iv /// 
	using iv_estimate,replace

/* declares the variable names and the filename of a (new) Stata datasetwhereresults are to be stored.  */
forvalues i = 1(1)1000 { /* perform the experiment 1000 times */
	drop _all /* drop all the variables in memory */
	quietly set obs 1000
	gen z = rnormal(0,1)
	gen u = rnormal(0,1)
	
	gen xc = ln(2)*z
	gen xd = 0.5*u + rnormal(0,1)
	gen x = xc + xd
	gen y = 1 + `beta'*x + u
	
	qui reg x z
	qui predict x_hat, xb
	
	qui reg y x_hat
	scalar beta_hat_2sls = _b[x_hat]
	scalar se_hat_2sls = _se[x_hat]
	
	qui test x_hat = `beta'
	sca reject_2sls = (r(p)<0.10)
	
	qui ivreg y (x=z)
	scalar beta_hat_iv = _b[x]
	scalar se_hat_iv = _se[x]
	
	qui test x = `beta'
	sca reject_iv = (r(p)<0.10)
	
	post temp (beta_hat_2sls) (beta_hat_iv) (se_hat_2sls) (se_hat_iv) (reject_2sls) (reject_iv)
	}
	
	postclose temp
	
	use iv_estimate, clear
	
	sum
