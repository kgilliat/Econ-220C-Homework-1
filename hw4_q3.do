*-------------------------------------------------------------------------------*
*                     Homework 4 Problem 3 - CA Heating                         *
*-------------------------------------------------------------------------------*
*Author: Kurtis Gilliat
*Date: 6/4/2021

clear
set more off

cd "C:/Users/Kurtis/Documents/Classes/Spring 2021/Metrics/Homework 4"

import delimited "ca_heating.csv"


*--------------------------------- part a --------------------------------------*

forval i = 1/5 {
	gen d`i' = (depvar == `i')
}

*Reshape to panel data where each observation is an id-alternative pair
reshape long d ic oc, i(idcase) j(alterntv)

*Conditional multinomial logit
clogit d ic oc, group(idcase)
mat coeffs = e(b)

*--------------------------------- part b --------------------------------------*
predict phat if e(sample)

sort alterntv
by alterntv: sum phat
tab depvar


*--------------------------------- part c --------------------------------------*

di coeffs[1,2]/coeffs[1,1]

*--------------------------------- part e --------------------------------------*

tab alterntv, gen(alt_dummy) 

clogit d ic oc alt_dummy2-alt_dummy5, group(idcase)
mat coeffs = e(b)
predict phat1 if e(sample)
sort alterntv
by alterntv: sum phat1
tab depvar

*--------------------------------- part f --------------------------------------*
di coeffs[1,2]/coeffs[1,1]


*--------------------------------- part h --------------------------------------*

clogit d ic oc alt_dummy2-alt_dummy5, group(idcase)
preserve
replace ic = ic*0.9 if alterntv==5
predict phat2 if e(sample)
sort alterntv
by alterntv: sum phat2
tab depvar
restore

*--------------------------------- part i --------------------------------------*


sca beta1 = _b[ic]
sca beta2 = _b[oc]
sca gamma1 =0
sca gamma2 =_b[alt_dummy2]
sca gamma3 =_b[alt_dummy3]
sca gamma4 =_b[alt_dummy4]
sca gamma5 =_b[alt_dummy5]
sca gamma6 =_b[alt_dummy3]

* create alternative 6
expand 2 if alterntv==3
sort idcase alterntv
by idcase:  replace alterntv = 6 if _n==4

* Compute the predicted probability manually

gen expo = exp(beta1*ic+beta2*oc+gamma1) if alterntv==1  
replace expo = exp(beta1*ic+beta2*oc+gamma2) if alterntv==2
replace expo = exp(beta1*ic+beta2*oc+gamma3) if alterntv==3
replace expo = exp(beta1*ic+beta2*oc+gamma4) if alterntv==4
replace expo = exp(beta1*ic+beta2*oc+gamma5) if alterntv==5
replace expo = exp(beta1*(ic+200)+beta2*oc*0.75+gamma6) if alterntv==6


by idcase: egen expo_mean = mean(expo)
gen phat3 = expo/(6*expo_mean)

sort alterntv
by alterntv: sum phat3
tab depvar

***eof***
