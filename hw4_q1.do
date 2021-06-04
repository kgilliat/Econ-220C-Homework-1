*-------------------------------------------------------------------------------*
*                       Homework 4 Problem 1 - Probit                           *
*-------------------------------------------------------------------------------*
*Author: Kurtis Gilliat
*Date: 5/28/2021

clear
set more off

cd "C:/Users/Kurtis/Documents/Classes/Spring 2021/Metrics/Homework 4"

capture postclose tempid
postfile tempid beta1 beta2 beta3 se1 se2 se3 ape1 ape2 ape3 ape4 using mydata.dta,replace

forvalues i = 1(1)100 {
	drop _all
	quietly set obs 1000
	/************* DGP ********************/
	gen e1 = rnormal()
	gen e2 = rnormal()
	gen z = rnormal()
	gen u = rnormal()
	
	gen x1 = z + e1
	gen x2 = u + e2
	gen x = x1 + x2
	
	gen y_latent = 1*x + u
	
	qui sum x
	local meanx = r(mean)
	
	gen y = 0
	qui replace y= 1 if y_latent>0

	/********** the first probit regression ************/
	quietly probit y x,r
	scalar beta1 = _b[x]
	scalar se1 = _se[x]
	qui margins, dydx(x) at(x = `meanx')
	scalar ape1 = el(r(b),1,1)
	
	/********** the second probit regression ***********/
	quietly reg x z
	predict e, resid
	quietly probit y x e
	scalar beta2 = _b[x]
	scalar se2 = _se[x]
	qui margins, dydx(x) at(x=`meanx')
	scalar ape2 = el(r(b),1,1)
	qui margins, dydx(x) at(x=`meanx' e=0)
	scalar ape3 = el(r(b),1,1)
	
	/********** the third probit regression ***********/
	quietly reg x z
	predict x_hat, xb
	quietly probit y x_hat
	scalar beta3 = _b[x_hat]
	scalar se3 = _se[x_hat]
	qui margins, dydx(x_hat) at(x_hat =`meanx')
	scalar ape4 = el(r(b),1,1)
	
	post tempid (beta1) (beta2) (beta3) (se1) (se2) (se3) (ape1) (ape2) (ape3) (ape4)
	}
	postclose tempid
	use mydata.dta, clear
	sum,d
	
	* end of the program
