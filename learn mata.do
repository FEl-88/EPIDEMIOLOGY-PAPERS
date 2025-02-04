clear 
set obs 3
gen str7 rownames = ""
gen str7 colnames = "" 
mata:
mata set matastrict on 
b1 = ("orange", "lemons", "banana")', ("kales", "spinach", "carrots")'
b1
rownames = b1[1..., 1]
rownames
colnames = b1[1..., 2]  
colnames 
st_sstore(., "rowname", rownames) 
st_sstore(., "colname", colnames)
end 
mat J = J(3,3, .3)
local colnames 
local rownames 
forval j = 1/ `= colsof(J)' {
	local colnames "`colnames' `=colnames[`j']'"
	local rownames "`rownames' `=rownames[`j']'" 
	
}
mat colnames J = `colnames' 
mat rownames J = `rownames'
mat l  J 
