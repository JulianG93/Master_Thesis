*** DO-FILE:       Impute ***************************************************
*** PROJECT NAME:  Master's Thesis ******************************************
*** DATE: 		   28.12.2023 ***********************************************
*** AUTHOR: 	   JZ *******************************************************

* Note: The purpose of this do-file is to impute missing variable values


*** SECTION 2.3.2 - IMPUTE **************************************************
***********************!!!!!!!!!!!ADJUST!!!!!!!!!!!!*************************

cap which descsave
if _rc ssc install descsave

set trace on
set tracedepth 1
// The following variables that are part of the x- or y-list were deleted for wave 1, as they don't exist for wave 1: 31024 (Person take or avoid risk), 71133c (Travel time to BAAC), 31025 (If you won 100,000 Baht, how much would you invest?), 10087 (Income from wage employment). Variables that are neither part of the xlist or ylist are deleted: 32007 (how many days to get the amount?), 42030 (storing part of agricultural production?), hhavage, genratio, 31006a (Assets loss, based on all AGRI schocks in HH survey), ownlandaS (share of total land area that is owned), ricekgrai (Rice produce in kg/rai on aver/plot), 42032 (stored total crops in kg), 43109a (total value of livestock, end of period), w1hhhethn, w1hhhrel, w1hhhpol

//adjust the following three locals:

//impute input 
#delimit ;
local imputeinput = `"
w1_x12122
w1_x32010
w1hhhage
w1under6
w1_x31002
w1_x31004
w1_x31005a
w1_x41003
w1ricekgtotL
w1expendL
w1ricekgsldL

w1ricelandS
w1_x43202n
w1_x44002n
w1_x50002n
w1_x60002n
w1ricelandL
w1_x91009_aL
w1rice_index
w1_x10093
w1iga_index
w1o14_jobs
w1_x10084
w1_x10085
w1_x10086
w1_x10088
w1_x10080L
w1_x10080
w1income
w1_x32004
w1_x71514
"'
;
#delimit cr


//impute input categorial
#delimit ;
local imputeinput_c = `"

w1hhhgen
w1hhhprim
w1agriloanD
w1_x32003
w1_x32003a
"'
;
#delimit cr




//to be imputed

local tobeimputed = "$ylistw2 $ylistw3 $ylistw5 $ylistw6 $ylistw7 $ylistw8 $xlist"
foreach var of local tobeimputed {
cap confirm variable `var'
if !_rc {
local tobeimputed2 "`tobeimputed2' `var'" // Alle Variablen die in den angegebenen Listen des locals tobeimputed enthalten sind, bekommen den prefix tobeimputed2
}
}


*****************************************************************************

sum vill
scalar N=r(N)

foreach var of varlist `tobeimputed2' {

	quiet tab `var'

	if r(N)<N {
	impute2 `var' `imputeinput', xc(`imputeinput_c') xl(T prov vill) nonegative
	table i`var' if `var'==.
	replace `var'=i`var' if `var'==.
	drop i`var'
	lab var `var' "IMP `: var lab `var''"
	}
}
*

*****************************************************************************
// Impute imputes non-integer values for categorial variables, so they need to be rounded again to integer values:

foreach var in _x43202n _x44002n _x50002n _x60002n agriloanD _x31024 {
foreach wave in w2 w3 w5 w6 w7 w8 {
    replace `wave'`var'=round(`wave'`var')
}
}
*