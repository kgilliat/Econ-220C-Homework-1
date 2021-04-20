*-------------------------------------------------------------------------------*
*                     Homework 1 Problem 5 - Simulation                         *
*-------------------------------------------------------------------------------*
*Author: Kurtis Gilliat
*Date: 4/17/2021

clear all
 
set more off 
set matsize 300 
capture log close

cd "C:/Users/Kurtis/Documents/Classes/Spring 2021/Metrics/Homework 1"

program panel_sim, rclass
clear

*Set panel data structure
local N = `1'
local T = `2'
set obs `N'

*Generate data
gen i = _n
forval t = 1/`T' {
	gen x_`t' = rnormal(0,1) 
	gen u_`t' = rnormal(0,abs(x_`t'))
	gen y_`t' = x_`t' + u_`t'
	}
	
egen x_bar = rowmean(x_1 - x_`T') // x bar	
egen u_bar = rowmean(u_1 - u_`T') // u bar

*Estimate numerator and denominator of beta hat
gen x_var = 0 // var(x)
gen xu_covar = 0 // cov(x,u)
forval t = 1/`T' {
	replace x_var = x_var + (x_`t' - x_bar)^2
	replace xu_covar = xu_covar + (x_`t' - x_bar)*(u_`t' - u_bar)
	}
*sum over individuals	
egen x_var_sum = total(x_var)	
egen xu_covar_sum = total(xu_covar)

gen beta_hat = 1 + 	xu_covar_sum/x_var_sum // Estimate beta hat

*Estimate residuals
forval t = 1/`T' {
	gen u_hat_`t' = y_`t' - beta_hat*x_`t'
	}
egen u_hat_bar = rowmean(u_hat_1 - u_hat_`T') // u hat bar

*Estimate sigma_hat and sigma_tilde
gen xu_hat_covar = 0 // cov(x,u_hat)
gen x_var_u_var = 0 // var(x)*var(u_hat)
forval t = 1/`T' {
	replace xu_hat_covar = xu_hat_covar + (x_`t' - x_bar)*(u_hat_`t' - u_hat_bar)
	replace x_var_u_var = x_var_u_var + (x_`t' - x_bar)^2*(u_hat_`t' - u_hat_bar)^2
	}
gen xu_covar_sq = xu_hat_covar^2 // (cov(x,u_hat))^2

egen xu_covar_sq_sum = total(xu_covar_sq) // sum across individuals
egen x_var_u_var_sum = total(x_var_u_var)
gen sigma_hat = sqrt(xu_covar_sq_sum/(x_var_sum^2))
gen sigma_tilde = sqrt(x_var_u_var_sum/(x_var_sum^2))

keep if i == 1
keep beta_hat sigma_hat sigma_tilde

return scalar beta_hat = beta_hat[1]
return scalar sigma_hat = sigma_hat[1]
return scalar sigma_tilde = sigma_tilde[1]
end	

*Simulate with T=5
simulate beta_hat sigma_hat sigma_tilde, seed(12345) reps(1000) saving(panel_sim_T5.dta, replace every(10)): panel_sim 500 5
*T=10
simulate beta_hat sigma_hat sigma_tilde, seed(12345) reps(1000) saving(panel_sim_T10.dta, replace every(10)): panel_sim 500 10
*T=20
simulate beta_hat sigma_hat sigma_tilde, seed(12345) reps(1000) saving(panel_sim_T20.dta, replace every(10)): panel_sim 500 20

*-------------------------- Create tables ------------------------------*
foreach t in 5 10 20 {
	use panel_sim_T`t'.dta, clear
	
	sum _sim_1
	local se_beta_hat_`t' = `r(sd)'
	sum _sim_2
	local std_sigma_hat_`t' = `r(sd)'
	local bias_sigma_hat_`t' = `r(mean)' - `se_beta_hat_`t''
	sum _sim_3
	local std_sigma_tilde_`t' = `r(sd)'
	local bias_sigma_tilde_`t' = `r(mean)' - `se_beta_hat_`t''
	local rmse_sigma_hat_`t' sqrt((`bias_sigma_hat_`t'')^2 + (`std_sigma_hat_`t'')^2)
	local rmse_sigma_tilde_`t' sqrt((`bias_sigma_tilde_`t'')^2 + (`std_sigma_tilde_`t'')^2)
	local ratio_`t' = `rmse_sigma_tilde_`t''/`rmse_sigma_hat_`t''
	foreach x in se_beta_hat_`t' std_sigma_hat_`t' bias_sigma_hat_`t' std_sigma_tilde_`t' ///
		bias_sigma_tilde_`t' rmse_sigma_hat_`t' rmse_sigma_tilde_`t' ratio_`t' {
		local `x' : di %10.4fc ``x''
		}	
	}
	
cap file close texfile
file open texfile using simulation_results.tex, write replace 
file write texfile "\begin{table}[h]" _n
file write texfile "\centering" _n
file write texfile "\caption{Results of FE simulations}" _n
file write texfile "\label{tab:sim_results}" _n
file write texfile "\begin{tabular}{lccc}" _n
file write texfile "\toprule" _n
file write texfile " & $ T=5 $ & $ T=10 $ & $ T=20 $ \tabularnewline" _n
file write texfile "\midrule" _n

file write texfile "std($ \hat{\beta} $) & `se_beta_hat_5' & `se_beta_hat_10' & `se_beta_hat_20' \tabularnewline" _n
file write texfile "bias($\hat{\sigma}$) & `bias_sigma_hat_5' & `bias_sigma_hat_10' & `bias_sigma_hat_20' \tabularnewline" _n
file write texfile "bias($\tilde{\sigma}$) & `bias_sigma_tilde_5' & `bias_sigma_tilde_10' & `bias_sigma_tilde_20' \tabularnewline" _n
file write texfile "std($\hat{\sigma}$) & `std_sigma_hat_5' & `std_sigma_hat_10' & `std_sigma_hat_20' \tabularnewline" _n
file write texfile "std($\tilde{\sigma}$) & `std_sigma_tilde_5' & `std_sigma_tilde_10' & `std_sigma_tilde_20' \tabularnewline" _n
file write texfile "rmse($\hat{\sigma}$) & `rmse_sigma_hat_5' & `rmse_sigma_hat_10' & `rmse_sigma_hat_20' \tabularnewline" _n
file write texfile "rmse($\tilde{\sigma}$) & `rmse_sigma_tilde_5' & `rmse_sigma_tilde_10' & `rmse_sigma_tilde_20' \tabularnewline" _n
file write texfile "rmse($\tilde{\sigma}$)\/rmse($\hat{\sigma}$) & `ratio_5' & `ratio_10' & `ratio_20' \tabularnewline" _n

file write texfile "\bottomrule \addlinespace[1ex]" _n
file write texfile "\end{tabular}" _n
file write texfile "\end{table}" _n
file close texfile	
