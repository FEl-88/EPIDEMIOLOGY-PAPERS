/****************************************************************************
** bamm_simulation_examples.do
** Script to produce examples for the Stata journal article for bamm
**
** Programmer: Will Parish
** Date:	   25apr2023
****************************************************************************/

clear all
set more off
capture log close

sjlog using bamm1, replace
* Setup
sysuse bamm_simulated_data
notes
tabulate x
sjlog close, replace

sjlog using bamm2, replace
* Estimate with multinomial logit and use margins to obtain probabilities
mlogit x
margins
sjlog close, replace 

sjlog using bamm3, replace
* Estimate with default (flat) priors
bamm x, cnum(2) nchains(4) rseed(9)
sjlog close, replace

sjlog using bamm4, replace
* Estimate with default (flat) priors but more MCMC iterations
bamm x, cnum(2) nchains(4) rseed(9) mcmcsize(40000) burnin(10000)
sjlog close, replace

sjlog using bamm5, replace 
* Estimate with informative priors
matrix a = 400, J(1, 5, 320)
matrix b = I(6)*10 + J(6, 6, 2.5)
bamm x, prior_p(a) prior_pi(b) cnum(2) nchains(4) rseed(9)
sjlog close, replace
