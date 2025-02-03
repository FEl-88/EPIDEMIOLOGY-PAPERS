clear all
set scheme sj

sjlog using glasso2, replace
import delimited protain, clear
summarize
sjlog close, replace


// Standardize data
quietly ds
local varlist `r(varlist)'
foreach var in `varlist' {
	egen sd`var' = std(`var')
}

//standardize praf-pjnk
//matrix X = r(X)

numlist "0.01 0.1  0.25 0.5 0.75"



foreach lbd in `r(numlist)'{
	import delimited protain, clear
	quietly ds
	local varlist `r(varlist)'
	foreach var in `varlist' {
		egen sd`var' = std(`var')
	}
	graphiclasso sdpraf-sdpjnk, lam(`lbd')
	local filename = "lambda" + "`lbd'"
	graphiclassoplot e(Omega), type(graph) layout(circle) 	///
	newlabs("Raf" "Mek"  "Plcg"  "PIP2"  "PIP3"  "Erk"  	///
	"Akt"  "PKA"  "PKC"  "P38"  "Jnk") lab 			///
	title("{&lambda}  = `lbd'") saving("`filename'", replace)
}


graph combine "lambda.5" "lambda.25" "lambda.1"  "lambda.01"  

graph export "glasso3.pdf", replace


sjlog using glasso3, replace
import delimited protain, clear
quietly ds
local varlist `r(varlist)'
foreach var in `varlist' {
	egen sd`var' = std(`var')
}
// Run graphiclassocv with eBIC
graphiclassocv  sdpraf-sdpjnk,  gamma(0.5) nlam(20) crit(eBIC) 
matrix eBICOmega = e(Omega) 
local bic = round(e(lambda), 0.0001)
// Run graphiclassocv with CV
graphiclassocv sdpraf-sdpjnk,  nlam(20) crit(loglik)
matrix cvOmega = e(Omega) 
local cv = round(e(lambda), 0.0001)
matrix lambda = `cv',`bic'
// Plot the results 
graphiclassoplot cvOmega, type(graph) saving(cvprotaingraph,replace)	///
	layout(circle) newlabs("Raf" "Mek"  "Plcg"  "PIP2"  "PIP3"  ///
	"Erk"  "Akt"  "PKA"  "PKC"  "P38"  "Jnk") 		///
	lab title("CV, {&lambda} = `cv'") 
graphiclassoplot eBICOmega, type(graph) saving(bicprotaingraph,replace)  /// 
	layout(circle) newlabs("Raf" "Mek"  "Plcg"  "PIP2"  "PIP3" ///
	"Erk"  "Akt"  "PKA"  "PKC"  "P38"  "Jnk") 	           ///
	lab title("eBIC, {&lambda} = `bic'")
graphiclassoplot cvOmega, type(matrix) saving(cvprotainmat,replace)
graphiclassoplot eBICOmega, type(matrix) saving(bicprotainmat,replace)
graph combine "cvprotaingraph" "bicprotaingraph" "cvprotainmat"  "bicprotainmat"  
sjlog close, replace


graph export "glasso4.pdf", replace


//gr combine "bicprotain" "cvprotain"
