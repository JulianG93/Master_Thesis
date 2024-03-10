*** DO-FILE:       SECORDER *************************************************
*** PROJECT NAME:  Master's Thesis ******************************************
*** DATE: 		   28.12.2023 ***********************************************
*** AUTHOR: 	   JG + JZ **************************************************

* Note: The purpose of this do-file is to generate second order terms used for the analysis


*** SECTION 2.3.3 - SECORDER ************************************************
***********************!!!!!!!!!!!ADJUST!!!!!!!!!!!!*************************

//adjust local to the variables that you wish to create 2.order terms from
global dataset_v2 "$home/2_STATA/data/dataset_v2" // Still needs to be adjusted

unab varlist: $xlist_base $xlist_all // wave 2 is used, but only the 36 variables used to build the control variables
//adjust which dataset the variables come from and should be stored in
local dataset "$dataset_v2"


cap which descsave
if _rc ssc install descsave
*****************************************************************************

//count relevant first order variables
keep `varlist'
quiet describe
local varnum `r(k)' // contains numbers of variables
local varnum2 "`r(k)'/2-1"
dis `varnum'
dis `varnum2'


//create all second order terms of relevant variables 
cd "$data"
use "`dataset'", clear

cap drop QU*
foreach var of varlist `varlist' {
foreach var2 of varlist `varlist' {
	gen QU`var'`var2'=`var'*`var2' // All variables will be multiplicated by each other
}
}
*
cd "$data"
save "`dataset'", replace

//drop one of the second order vars that where created double (either a*b or b*a)
keep QU*
quiet describe 

descsave *, saving("$data/QUvarnames.dta", replace) //export second order varlist ...
use "$data/QUvarnames.dta", clear //...and open it as .dta file
keep name order 


gen group =round(_n+`varnum2',`varnum') //create groups (a*a, a*b, a*c ... is a group; b*a, b*b, b*c ... is a group; etc.) 
sort group order
by group: gen ID=_n //create another id within each group
replace group=group/`varnum'

drop order
reshape wide name, i(group) j(ID) //reshape to a matrix of (total group number) x (total group number) 

foreach num of numlist 1/`varnum' {
replace name`num'="." if group>=`num' //erase diagonal and everything below (only varnames are kept in the matrix which will be dropped later)
}

reshape long name, i(group) j(ID) //reshape back to long (all varnames stored in one variable)...
drop if name=="." //... and drop the erased fields

forvalues i = 1/`=_N' {
local name`i'=name[`i']
local varnames = "`varnames'  `name`i''" //store all remaining varnames in a local... (these are the to-be-dropped second order terms)
}
dis "`varnames'"

cd "$data"
erase "$data/QUvarnames.dta"

cd "$data"
use "`dataset'", clear //... go back to the dataset which includes the full set of second order terms...
quiet describe
dis `r(k)'
drop `varnames' //... and delete the ones stored in the local
quiet describe
dis `r(k)'
dis (((`varnum')^2)+(`varnum'))/2

*window stopbox rusure "Check the number of QU-vars in the dataset, please. If x is the number of first order terms which served as input in the secorder.do dofile then there should now be:  y=(x^2 + x)/2  QU-vars in the dataset. This condition holds if the last two numbers displayed in the results window differ only by the amount of non QU vars in the dataset."



*