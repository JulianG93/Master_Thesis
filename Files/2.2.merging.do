*** DO-FILE:       Merging **************************************************
*** PROJECT NAME:  Master's Thesis ******************************************
*** DATE: 		   28.12..2023 **********************************************
*** AUTHOR: 	   JG + JZ **************************************************

* Note: The purpose of this do-file is to merge the different waves.


*****************************************************************************
*** SECTION 2.2a - 2013 MERGING  ********************************************

set more off
set trace on
set tracedepth 1
** RUN SETTINGS **
clear
// cd "/Users/`c(username)'/Dropbox/Research/DFG_FOR576/3. Research/Rice Insurance/2. STATA/do" // Old directory
// do 2.1.settings.do Add 09.11.: Not needed as the settings are in the master.do-file                 

sysdir set PLUS "$data" // Changing the package installation path, because I don't have access to the default installation path, when using stata remotely
cap which fre
if _rc ssc install fre
cap which winsor2
if _rc ssc install winsor2

** CREATE MASTER **
	
foreach wave in w1 w2 w3 w5 w6 w7 w8 {

if "`wave'"=="w1"{
	use "${cleandata_w1}/hhclean", replace
	cap gen prov= _x10001 // Using cap for gen-commands from here on, because otherwise partial run-througs of the do-file the error code "Variable already defined" is thrown.
	cap gen distr= _x10002
	cap gen subdistr= _x10003
	cap gen vill= _x10004
	foreach root in 12122 12123 72201 32007 32010 32011a 32011b 32011c 32011d 32011e 42030 {
		replace _x`root'=. if _x`root'==97 // Replacing 97 with missing values as they are used as a label for 'Don't know'.
		replace _x`root'=. if _x`root'==98 // Replacing 98 with missing values as they are used as a label for 'no answer'.
		replace _x`root'=. if _x`root'==99 // Replacing 99 with missing values as they are used as a label for missing values.
	}
	rename (_x31013 _x31014) (_x31013b _x31014b) // The variables 31013 (Are you better off than last year?) and 31014 (Are you better off than 5 years ago?) are called 31013b and 31014b in the following waves
	foreach var of varlist _x31013b _x31014b {
		recode `var' (1 2 =1) (nonmis=0)
		replace `var'=0 if `var'==3 | `var'==4 | `var'==5 | `var'==97 // These values are not used in the following waves for variables 31013b and 31014b (see lines 137-140). So these values are deleted for wave 1.
	}
}
else if "`wave'"=="w2" {
	use "${cleandata_`wave'}/hhclean1", replace // Using hhclean1 dataset for waves 2-7, because several variables were missing in the hhclean dataset and needed to be merged first from the hhraw dataset (see merge_prep.do-file)
	cap gen _x32024=. // Variable 32024 (Do you think the climate (weather) in general has been changing since the time you live in this place?) doesn't exist for wave 2.
}
else if "`wave'"=="w5" {
	use "${cleandata_`wave'}/hhclean1", replace
	cap gen prov= _x10001
	cap gen distr= _x10002
	cap gen subdistr= _x10003
	cap gen vill= _x10004
	replace _x32007=. if _x32007==99 // 99 is used as a label for "not applicable" (10% of observations)
	replace _x32010=. if _x32010==99 // 99 is used as a label for "not applicable" (20% of observations)
	tostring QID, replace
}
else if "`wave'"=="w3" {
	use "${cleandata_`wave'}/hhclean1", replace
	cap gen prov= _x10001
	cap gen distr= _x10002
	cap gen subdistr= _x10003
	cap gen vill= _x10004
	cap gen _x32024=. // Variable 32024 (Do you think the climate (weather) in general has been changing since the time you live in this place?) doesn't exist for wave 2.
	replace _x32007=. if _x32007==999 // 999 is used as a label for "if never able to get the amount".
	replace _x32010=. if _x32010==999 // 999 is used as a label for "if never able to get the amount".
}
else if "`wave'"=="w6" {
    use "${cleandata_`wave'}/hhclean1", replace
	cap gen prov= _x10001
	cap gen distr= _x10002
	cap gen subdistr= _x10003
	cap gen vill= _x10004
	cap gen _x12122 =.
	cap gen _x12123 =.
}
else if "`wave'"=="w8" {
	use "${cleandata_`wave'}/TVSEP20191", replace // Using TVSEP20191, because the T-Dummies were added to it (see 2.1.merge_prep.do) and other variables that were needed + renamed.
	cap gen prov= v10001
	cap gen distr= v10002
	cap gen subdistr= v10003
	cap gen vill= v10004
}
else {
	use "${cleandata_`wave'}/hhclean1", replace
	cap gen prov= _x10001
	cap gen distr= _x10002
	cap gen subdistr= _x10003
	cap gen vill= _x10004
	cap gen _x12122 =.
	cap gen _x12123 =.
}

if "`wave'"=="w2" | "`wave'"=="w3" | "`wave'"=="w5" { // Variable 31025 asks how much a person would invest in a risky business if he just won 100000 THB in a lottery. In waves 2, 3 and 5 the variable is denominated in USD and some observations are higher than the equivalent of 100000 THB (~$5500 PPP), so these observations are deleted.
	replace _x31025=. if _x31025>5500
}

if "`wave'"=="w6" | "`wave'"=="w7" | "`wave'"=="w8" { // Variable 31025 asks how much a person would invest in a risky business if he just won 100000 THB in a lottery. In waves 6, 7 and 8 the variable is denominated in USD and some observations are higher than 100000 THB, so these observations are deleted.
	replace _x31025=. if _x31025>100000
}

drop if T!=1

//tostring QID, replace force

if "`wave'"=="w1" | "`wave'"=="w2" | "`wave'"=="w3" | "`wave'"=="w5" {
	cap gen n60relfr= 0 if _x32011a!=.
	foreach var of varlist _x32011a _x32011b _x32011c _x32011d _x32011e {
		replace n60relfr=1 if `var'== 7 | `var'== 9 | `var'== 17 | `var'== 18 | `var'== 30 | `var'== 31
	}
	cap gen n60borgov= 0 if _x32011a!=.
	foreach var of varlist _x32011a _x32011b _x32011c _x32011d _x32011e {
		replace n60borgov=1 if `var'== 21 | `var'== 23 | `var'== 24 | `var'== 25 | `var'== 28
	}
	label var n60relfr "If would suddenly need 60000 THB would send children to relatives/friends / adult migrate to live with friends/relatives / borrow from relatives / borrow from friends/neighbours / help from relatives / help from friends/neighbours"
	label var n60borgov "If would suddenly need 60000 THB would borrow from village funds / borrow from BAAC/Coop. Bank / borrow from government savings bank / borrow from village bank / help from government"
}

recode _x72201 (1=1) (2=0) 

if "`wave'"!="w1"{
	foreach var of varlist _x31013a _x31013b _x31014a _x31014b _x31019a _x31019b _x31020a _x31020b {
		recode `var' (1 2 =1) (nonmis=0)
	}
}

cd "${cleandata_`wave'}"
save hh_temp.dta, replace


if "`wave'"=="w5"{ // Variables set as comments in the following lines don't exist for the respective waves
	keep QID hhid prov distr subdistr  vill T   _x12122 _x12123 _x42030 _x32007 _x32010 _x32024 _x31013a 	_x31013b _x31014a _x31014b _x31019a _x31019b _x31020a _x31020b _x72201 n60borgov n60relfr _x31024
}
if "`wave'"=="w2"{
	keep QID hhid prov distr subdistr  vill T   _x12122 _x12123 _x42030 _x32007 _x32010 _x32024 _x31013a 	_x31013b _x31014a _x31014b _x31019a _x31019b _x31020a _x31020b _x72201 n60borgov n60relfr
}
if "`wave'"=="w3"{
	keep QID hhid prov distr subdistr  vill T   _x12122 _x12123 _x42030 _x32007 _x32010 _x32024 _x31013a 	_x31013b _x31014a _x31014b _x31019a _x31019b _x31020a _x31020b _x72201 n60borgov n60relfr
}
if "`wave'"=="w1"{
	keep QID hhid prov distr subdistr  vill T _x12122 _x12123 _x42030 _x32007 _x32010 /*_x32024 _x31013a */ _x31013b /*_x31014a*/ _x31014b /*_x31019a _x31019b _x31020a _x31020b*/ _x72201 n60borgov n60relfr
}
if "`wave'"=="w6"{
	keep QID hhid prov distr subdistr  vill T _x12122 _x12123 _x42030 /*_x32007 _x32010*/ _x32024 _x31013a 	   _x31013b _x31014a _x31014b _x31019a _x31019b _x31020a _x31020b _x72201 /*n60borgov n60relfr*/
}
if "`wave'"=="w7"{
	keep QID hhid prov distr subdistr  vill T   _x12122 _x12123 /*_x42030 _x32007 _x32010 _x32024*/_x31013a _x31013b _x31014a _x31014b _x31019a _x31019b _x31020a _x31020b _x72201 /*n60borgov n60relfr*/
}
if "`wave'"=="w8"{
	keep QID /*hhid*/ prov distr subdistr  vill T /*_x12122*/ _x12123 /*_x42030 _x32007 _x32010 		 _x32024*/ _x31013a _x31013b _x31014a _x31014b _x31019a _x31019b _x31020a _x31020b _x72201 //n60borgov 	n60relfr // Variables set as comments don't exist
}

cd "$data"
save merge_`wave', replace

if "`wave'"=="w3" | "`wave'"=="w5" | "`wave'"=="w6" | "`wave'"=="w7" {

	merge 1:1 QID using "${cleandata_`wave'}/hh_temp.dta", keepusing(_x62013 _x62001 _x62022 _x62024 _x62027 _x62020 _x62021 _x62023 _x62025 _x62026 ) nogen //not in 2007 and 2008. Variables that are set as a comment in the following blocks don't exist for the respective waves.
	foreach var in _x62013 _x62001 _x62022 _x62024 _x62027 _x62020 _x62021 _x62023 _x62025 _x62026{
		cap replace `var'=0 if `var'!=1 & `var'!=.
	}
}

if "`wave'"=="w8" {

	merge 1:1 QID using "${cleandata_`wave'}/hh_temp.dta", keepusing(_x62013 _x62001 _x62022 _x62024 /* _x62027*/ _x62020 _x62021 _x62023 _x62025 /*_x62026*/ ) nogen //not in 2007 and 2008. Variables that are set as a comment aren't available in the respective waves.
	foreach var in _x62013 _x62001 _x62022 _x62024 /*_x62027*/ _x62020 _x62021 _x62023 _x62025 /*_x62026*/{
		cap replace `var'=0 if `var'!=1 & `var'!=. // Creating an extra loop for wave 8, because variables 62026 (What do you plan in regard of the time used for agricultural production?) and 62027 (What do you plan in regard of the labor hired in?) don't exist for wave 8.
	}
	label var _x62013 "Divestments last 5 years"
	label var _x62001 "Investment last 5 years"
}

if "`wave'"=="w1" {

	merge 1:1 QID using "${cleandata_`wave'}/hh_temp.dta", keepusing(_x12122 _x12123 /*_x10024 _x31024 _x31025 _x71133b _x71133c _x31013a*/ _x31013b /*_x31014a*/ _x31014b /*_x31019a _x31019b _x31020a _x31020b*/ _x72201 n60borgov n60relfr _x32010 _x42030 _x32007 /*_x32024*/) nogen //not in 2007.
}

if "`wave'"=="w2" | "`wave'"=="w3" | "`wave'"=="w5" {

	merge 1:1 QID using "${cleandata_`wave'}/hh_temp.dta", keepusing(_x12122 _x12123 _x10024 _x31024 _x31025 _x71133b _x71133c _x31013a _x31013b _x31014a _x31014b _x31019a _x31019b _x31020a _x31020b _x72201 n60borgov n60relfr _x32010 _x42030 _x32007 _x32024) nogen //not in 2007
	label var _x32024 "Do you think the climate changed over time?"
}

if "`wave'"=="w6" {
	merge 1:1 QID using "${cleandata_`wave'}/hh_temp.dta", keepusing(/*_x12122 _x12123*/ _x10024 _x31024 _x31025 _x71133b _x71133c _x31013a _x31013b _x31014a _x31014b _x31019a _x31019b _x31020a _x31020b _x72201 /*n60borgov n60relfr _x32010*/ _x42030 /*_x32007*/ _x32024) nogen //not in 2007
	label var _x32024 "Do you think the climate changed over time?"
}



if "`wave'"=="w7" {
	merge 1:1 QID using "${cleandata_`wave'}/hh_temp.dta", keepusing(/*_x12122 _x12123*/ _x10024 _x31024 _x31025 _x71133b _x71133c _x31013a _x31013b _x31014a _x31014b _x31019a _x31019b _x31020a _x31020b _x72201 /*n60borgov n60relfr _x32010 _x42030 _x32007 32024*/) nogen //not in 2007.
}

if "`wave'"=="w8" {
	merge 1:1 QID using "${cleandata_`wave'}/hh_temp.dta", keepusing(/*_x12122*/ _x12123 /*_x10024*/ _x31024 _x31025 _x71133b _x71133c _x31013a _x31013b _x31014a _x31014b _x31019a _x31019b _x31020a _x31020b _x72201 /*n60borgov n60relfr _x32010*/) nogen
	label var _x31025 "won in lottery how much would invest?"
}

cd "$data"
save merge_`wave', replace

erase "${cleandata_`wave'}/hh_temp.dta"
}
erase "$cleandata_w8/TVSEP20191.dta"
foreach wave in w2 w3 w5 w6 w7 {
	erase "${cleandata_`wave'}/hhclean1.dta"
}

*


*****************************************************************************

** MERGE MEM DATA**

foreach wave in w1 w2 w3 w5 w6 w7 w8 {

if "`wave'"=="w1"{
	use "${cleandata_w1}/memclean1", replace // Using the memclean1 dataset for w1, because variable 22007 (Highest education level) has been corrected.
	drop _x21020 // Dropping _x21020, because _x21020n will be renamed to _x21020 and _x21020 has a label "99" if questioned farmers gave no answers, which would impair the statistical results
	cap rename _x21020n _x21020
	foreach root in 21004 21005 21003 21011 21012 21013 21014 21018 21020 22003 22006 22005 22007 23003 23004 23005 {
		replace _x`root'=. if _x`root'==97 // Replacing 97 with missing values as they are used as a label for 'Don't know'.
		replace _x`root'=. if _x`root'==98 // Replacing 98 with missing values as they are used as a label for 'no answer'.
		replace _x`root'=. if _x`root'==99 // Replacing 99 with missing values as they are used as a label for missing values.
	}
}
else if "`wave'"=="w8"{
	use "${cleandata_`wave'}/members1", replace // Using members1, because the T-Dummy was added and other variables were corrected (see 2.1.merge_prep.do).
	foreach root in 21004 21005 21003 21018 21020 21014 22006 22007 22005 22003 22014 21011 21012 21013 23004 23005 {
		cap rename  v`root' _x`root'
	}
	rename v23002 _x23003 // Variable number is 23002 in w8 instead of 23003 as in previous waves.
}
else {
	use "${cleandata_`wave'}/memclean1", replace // Using the memclean1 dataset, because variable 22007 needed to be corrected (see merge_prep.do-file).
}

//hh age structure and children below 6
gen under6= _x21004<6 if _x21004 < .

gen over14= _x21004>14 if _x21004 < .

gen hhavage= _x21004

gen hhhage= _x21004 if _x21005==1


//agegroups
gen btw020=  (_x21004>=0  & _x21004<20) if _x21004!=.
gen btw2040= (_x21004>=20 & _x21004<40) if _x21004!=.
gen btw4060= (_x21004>=40 & _x21004<60) if _x21004!=.
gen btw60up= (_x21004>=60)              if _x21004!=.

gen btw1016=  (_x21004>=10 & _x21004<=16) if _x21004!=.
gen btw1115=  (_x21004>=11 & _x21004<=15) if _x21004!=.
gen btw1214=  (_x21004>=12 & _x21004<=14) if _x21004!=.

gen btw1564f= (_x21004>=15 & _x21004<=64) & _x21003==2 if _x21004!=.
gen btw1564m= (_x21004>=15 & _x21004<=64) & _x21003==1 if _x21004!=.

//occupation
gen jobsear = (_x21018==4 | _x21018==5) if _x21018!=.

gen remittjsD = (_x21020> 0 & jobsear==1) if jobsear!=. & _x21020!=.

tab _x21014, gen(oc)

egen oc_ag  = rowtotal(oc1 oc4 oc6)
if "`wave'"=="w8" {
	egen oc_ue = rowtotal(oc13 oc14 oc15) // In wave 8 being unemployed has the values oc17, oc18 and oc19 instead of oc12 as in previous waves.
	egen oc_na = rowtotal(oc3 oc5 oc7 oc8 oc11) // In wave 8 'monk' equals oc12, which is oc15 in previous waves. In wave 8 'joining the army' equals oc14, which is oc15 in the previous waves. There's no observation in wave 8 though, so it was set as a comment.
	egen oc_ot = rowtotal(oc2 oc9 oc11 oc12) // In wave 8 'performing only occasional work' equals oc11, which is oc13 in the previous waves and 'monk' equals oc13, which is oc14 in the previous waves. It's only oc12 and following that differs between wave 8 and the previous waves, because label 12 (unemployed) just doesn't exist anymore in wave 8 and then all the following oc's in wave 8 are one number less than in the subsequent waves.
}
else {
	egen oc_ue = rowtotal(oc12)
	egen oc_na = rowtotal(oc3 oc5 oc7 oc8 oc15)
	egen oc_ot = rowtotal(oc2 oc9 oc13 oc14)
}
egen oc_st = rowtotal(oc10)

egen anymem_oc_go = rowtotal(oc8) 

 
//hh gender structure
gen _x21004_malegrownup=1 if _x21004 >12 & _x21003==1
replace  _x21004_malegrownup=0 if _x21004_malegrownup==.

gen _x21004_grownup= _x21004 >12 if _x21004<.

gen hhhgen= _x21003 if _x21005==1


//eduction of hh
if "`wave'"=="w1" | "`wave'"=="w2" | "`wave'"=="w3" | "`wave'"=="w5" | "`wave'"=="w6" | "`wave'"=="w7" {
	gen edhhh_repair= 0 			if _x22006==2 & _x22007==. & (_x21005==1 | _x21005==2)
	replace edhhh_repair=_x22005 	if _x22005!=. & _x22007==. & (_x21005==1 | _x21005==2)
	replace _x22007=edhhh_repair 	if _x22007==.

	gen hhhprim=	(_x22007 <5 & _x21005==1) 
	gen hhhprim7=	(_x22007 <8 & _x21005==1)
	gen hhhsec= 	(_x22007 >=5 & _x21005==1)
}
*gen eduhhh=_x22007 if _x21005==1
*gen edhhhpa=_x22007 if _x21005==2
else {
	//education of hh: repair for w8
	gen edhhh_repair=0				if _x22006==2 & _x22007==. & (_x21005==1 | _x21005==2)
	replace edhhh_repair=_x22005	if _x22005!=. & _x22007==.  & (_x21005==1 | _x21005==2)
	replace _x22014=edhhh_repair	if _x22007==.
	
	gen hhhprim=	(_x22014<5 & _x21005==1) // For wave 8 variable 22007 (Members highest educational attainment) can't be used as in other waves, but variable 22014 (How many years did member go to school) is a perfect substitute, as both variables count the number of years HH members went to school.
	gen hhhprim7=	(_x22014<8 & _x21005==1)
	gen hhhsec=		(_x22014>4 & _x21005==1)
}

replace hhhprim=. if _x21005!=1
replace hhhprim7=. if _x21005!=1
replace hhhsec=. if _x21005!=1

if "`wave'"=="w8" { // The definition of hhid in wave 8 has changed compared to the previous waves (It isn't a unique identifier of a household anymore), so here it can't be used. Instead QID can be used.
	bys QID: egen hheduhi = max(_x22014) if T==1
	bys QID: gen temp=_n
}
else {
	bys hhid: egen hheduhi = max(_x22007) if T==1
	bys hhid: gen temp=_n
}
replace hheduhi=. if temp!=1
label value hheduhi _x22007
fre hheduhi if T==1
drop temp

gen hhedupr = (hheduhi<=7) if hheduhi!=. & T==1
gen hheduls = (hheduhi<=10) if hheduhi!=. & T==1

//can read write
recode _x22003 (1=1) (2=0), gen(hhhread)
replace hhhread=. if _x21005!=1

//subjective health assessment
recode _x23003 (1=1) (nonmis=0), gen(hhh_healthy)
recode _x23003 (2=1) (nonmis=0), gen(hhh_canmanage)
recode _x23003 (3=1) (nonmis=0), gen(hhh_sick)
replace hhh_healthy=. if _x21005!=1
replace hhh_canmanage=. if _x21005!=1
replace hhh_sick=. if _x21005!=1

//adding: health assessment compared to one year ago
recode _x23004 (1=1) (nonmis=0), gen(hhh1_worse)
recode _x23004 (2=1) (nonmis=0), gen(hhh1_same)
recode _x23004 (3=1) (nonmis=0), gen(hhh1_better)
replace hhh1_worse=. if _x21005!=1
replace hhh1_same=. if _x21005!=1
replace hhh1_better=. if _x21005!=1

//adding: health assessment compared to five years ago
recode _x23005 (1=1) (nonmis=0), gen(hhh5_worse)
recode _x23005 (2=1) (nonmis=0), gen(hhh5_same)
recode _x23005 (3=1) (nonmis=0), gen(hhh5_better)
replace hhh5_worse=. if _x21005!=1
replace hhh5_same=. if _x21005!=1
replace hhh5_better=. if _x21005!=1

//hhh missing
gen hhhnomis=1 if _x21005==1

//ethnicity and political membership
gen hhhethn= _x21011 if _x21005==1
replace hhhethn=0 if hhhethn!=. & hhhethn!=3
replace hhhethn=1 if hhhethn==3

gen hhhrel= _x21012 if _x21005==1

gen hhhpol= _x21013 if _x21005==1 // Changed if "_x21013==1" to "_x21005==1", because hhhpol is supposed to be a dummy variable indicating whether the hh-head is member of a political party or not. Before the change the dummy variable would not have referred exclusively to the hh-head, if _x21005==1 is missing.


gen anymem_pol= _x21013
recode anymem_pol (2=0) (1=1)

collapse (max) anymem_pol anymem_oc_go (mean) hhhethn hhhrel hhhpol hhhgen hhhage hhavage hheduhi hhedupr hheduls (sum) btw* hhhnomis hhhprim hhhprim7 hhhsec hhhread hhh_healthy hhh_canmanage hhh_sick hhh1_worse hhh1_same hhh1_better hhh5_worse hhh5_same hhh5_better under6 _x21004_malegrownup _x21004_grownup (sum) over14 jobsear remittjsD oc_*, by(QID)

gen genratio=_x21004_malegrownup/_x21004_grownup
drop _x21004_malegrownup _x21004_grownup

gen o14_jobs = jobsear/over14
gen o14_oc_ag =oc_ag/over14
gen o14_oc_na =oc_na/over14
gen o14_oc_ue =oc_ue/over14
gen o14_oc_st =oc_st/over14
gen o14_oc_ot =oc_ot/over14

replace o14_jobs = 1 if o14_jobs>1 & o14_jobs!=.

gen o14_jobsD = (jobsear>0) if jobsear!=.

replace remittjsD = (remittjsD>0) if remittjsD!=.

drop jobsear  over14 oc_*


*recode eduhhh (0=0) (1/7=1) (8/15=2) (16/22=3) (nonm =4), generate(edhhh_c)

replace hhhpol=0 if hhhpol==.
replace hhhpol=0 if hhhpol==2

replace hhhgen=0 if hhhgen==2

replace hhh_healthy=1 if hhh_healthy>1 // If there is more than one household head given per HH and they're healthy hhh_healthy will become bigger than 1, but it should be 1 as it is a Dummy variable and not 2,3,4... etc.
replace hhhnomis=1 if hhhnomis>1 // If there is more than one household head given per HH hhhnomis will become bigger than 1, but it should be 1 as it is a Dummy variable and not 2,3,4... etc.
replace hhhpol=1 if hhhpol>1 // If there is more than one household head given per HH that is member of a political party hhhpol will become bigger than 1, but it should be 1 as it is a Dummy variable and not 2,3,4... etc.
replace hhh_canmanage=1 if hhh_canmanage>1 // If there is more than one household head given per HH and their health status is "can manage" the variable hhh_canmanage will become bigger than 1, but it should be 1 as it is a Dummy variable and not 2,3,4... etc.
replace hhhprim=1 if hhhprim>1 // If there is more than one HH-head with no or primary education up to grade 4 the variable will become bigger than 1, but as it is a Dummy variable these values need to be replaced by 1.
replace hhhprim7=1 if hhhprim7>1 // If there is more than one HH-head with no or primary education up to grade 7 the variable will become bigger than 1, but as it is a Dummy variable these values need to be replaced by 1.
replace hhhsec=1 if hhhsec>1 // If there is more than one HH-head with secondary education the variable will become bigger than 1, but as it is a Dummy variable these values need to be replaced by 1.
replace hhhgen=1 if hhhgen >1 & hhhgen <=1.5 // If there is more than one HH-head per household and if they have different genders, hhhgen can become bigger than one. If the majority of the HH-heads is male, hhhgen will be below 1.5 (or at 1.5 if the number of male HH-heads equals the number of female HH-heads), so these HH will be considered as male-headed.
replace hhhgen=0 if hhhgen>1.5 // On the opposite, if there are several household heads and the majority is female, hhhgen will be above 1.5 and these households will not be considered male-headed.
replace hhhread=1 if hhhread>1 // If there is more than one HH-head that can read the variable will become bigger than 1, but as it is a Dummy variable these values need to be replaced by 1.
replace hhh1_worse=1 if hhh1_worse>1 // If there is more than one household head given per HH and they're worse than 1 year ago hhh1_worse will become bigger than 1, but it should be 1 as it is a Dummy variable and not 2,3,4... etc.
replace hhh1_same=1 if hhh1_same>1 // See previous explanations
replace hhh1_better=1 if hhh1_better>1 // See previous explanations
replace hhh5_worse=1 if hhh5_worse>1 // See previous explanations
replace hhh5_same=1 if hhh5_same>1 // See previous explanations
replace hhh5_better=1 if hhh5_better>1 // See previous explanations


cd "${cleandata_`wave'}"
save mem_temp, replace

cd "$data"
use merge_`wave', clear
merge 1:1 QID using "${cleandata_`wave'}/mem_temp.dta"
drop if _merge==2 
drop _merge
erase "${cleandata_`wave'}/mem_temp.dta"

label var hhh_healthy "Is 1 if household head is healthy"
label var hhh_canmanage "Is 1 if household head's health status is 'can manage'"
label var hhh_sick "Is 1 if household head is sick"
label var hhhnomis "Is 1 if hh head isn't missing in the dataset"
label var hhhethn  "Ethnicity of hh head"
label var hhhrel  "Religion of hh head"
label var hhhpol  "Is 1 if hh head has political membership"
label var anymem_pol  "Is 1 if any mem has political membership"
label var anymem_oc_go  "Is 1 if any mem is government official"

label var hhhgen  "Gender of hh head"
label var hhhage  "Age of hh head"
*label var eduhhh  "Highest edu attainment of hh head"
*label var edhhhpa  "Highest edu attainment of hh head partner"
*label var edhhh_c  "Category of highest edu attainment of hh head"
label var hhhprim  "HH has no or primary edu up to 4th grade"
label var hhhprim7  "HH has no or primary edu up to 7th grade"
label var hhhsec   "HH has more than 4th grade edu up to university degree (rare)"
label var hhhread  "HH can read and write"

label var hheduhi "Edu attainment of HH member with highest edu attainment of the HH"
label var hhedupr  "HH has no member with edu higher than primary 7"
label var hheduls  "HH has no member with edu higher than lower secondary grade 9"

label var genratio  "Ratio of male grownups (>12) on total grownups in HH"
label var under6  "Number of kids in HH below age 6"
label var o14_jobs "Share of over 14 left HH searching or having job" 
label var o14_jobsD "Dummy if at least 1 HH member left perm for job or jobsearch"
label var hhavage  "HH average age"

label var btw020   "Number of HH mem below 20"
label var btw1016   "Number of HH mem between 10 and inkl 16"
label var btw1115   "Number of HH mem between 11 and inkl 15"
label var btw1214   "Number of HH mem between 12 and inkl 14"
label var btw2040  "Number of HH mem between 20 and 40"
label var btw4060  "Number of HH mem between 40 and 60"
label var btw60up  "Number of HH mem between 60 and up"
label var btw1564f  "Number of woking age HH mem female"
label var btw1564m  "Number of woking age HH mem male"

label var remittjsD "Amount of money/value of gifts a person that moved away for a job opportunity/job search sent home to his/her HH"
label var o14_oc_ag "Share of HH mem over 14 working in agriculture"
label var o14_oc_na "Share of HH mem over 14 working in non-agricultural jobs/as government officials/in the army"
label var o14_oc_ue "Share of HH members over 14 that are unemployed"
label var o14_oc_st "Share of HH members over 14 that are students/pupils"
label var o14_oc_ot "Share of HH members over 14 that are fishing/housewives/occasional workers/monks"

label var hhh1_worse "Is 1 if household head's health status is worse than 1 year ago"
label var hhh1_same "Is 1 if household head's health status is the same as 1 year ago"
label var hhh1_better "Is 1 if household head's health status is better than 1 year ago"

label var hhh5_worse "Is 1 if household head's health status is worse than 5 years ago"
label var hhh5_same "Is 1 if household head's health status is the same as 5 years ago"
label var hhh5_better "Is 1 if household head's health status is better than 5 years ago"



cd "$data"
save merge_`wave', replace


if "`wave'"=="w8" {
    cd "${cleandata_`wave'}"
	erase members1.dta
}
else {
	cd "${cleandata_`wave'}"
	erase memclean1.dta
}
}

*
*****************************************************************************

** MERGE SHOCKS **

foreach wave in w1 w2 w3 w5 w6 w7 w8 {

if "`wave'"=="w1"{
	use "${cleandata_w1}/shocksclean", replace
	foreach root in 31001 31002 31004 31005 31006 {
		replace _x`root'=. if _x`root'==97 // Replacing 97 with missing values as they are used as a label for 'Don't know'.
		replace _x`root'=. if _x`root'==98 // Replacing 98 with missing values as they are used as a label for 'no answer'.
		replace _x`root'=. if _x`root'==99 // Replacing 99 with missing values as they are used as a label for missing values.
	}
}
else if "`wave'"=="w8" {
	use "${cleandata_`wave'}/shocks1", replace // Using the shocks1 dataset, because QID has been added to it.
	rename v31104 _x31004
	rename shocks__id _x31002 // shocks__id has the definition of variable 31002 (Shocks: Type of event) in other waves.
	rename v31105a _x31005a
	rename v31105b _x31005b
	rename v31106a _x31006a
}
else {
    use "${cleandata_`wave'}/shocksclean", replace
}


if "`wave'"=="w1" {
	cap gen _x31005a=_x31005 // In wave 1 variable 31005 has the definition of variable 31005a (Estimated loss of income due to the event in the year of occurence?) in other waves.
	cap gen _x31005b=. // Wave 1 doesn't contain variable 31005b, so the variable needs to be created containing missing values, but only for wave 1 and not for the other waves.
	cap gen _x31006a=_x31006 // In wave 1 variable 31006 has the definition of variable 31006a (Estimated loss of assets due to the event in the year of occurence?) in other waves.
}

recode _x31004  (1=3) (2=2) (3=1) (4=0)
label define _x31004 0 "No Impact" 1 "Low Impact" 2 "Medium Impact" 3 "High Impact", replace // replace option was added. Otherwise code yields an error message "label _x31004 already defined" for partial run-throughs of the do-file.
label values _x31004 _x31004

if "`wave'"=="w1" | "`wave'"=="w2" | "`wave'"=="w3" {
	recode _x31002 (10/13=1) (16=2) (21=3), generate(agrishock)
}
else {
	recode _x31002 (10/63=1) (16=2) (21=3), generate(agrishock) // Value 13 (crop pests) of variable 31002 isn't available anymore for wave 5 and following. But instead value 63 (Pests and Livestock diseases) is used as a replacement.
}
keep if agrishock <= 3

recode _x31002 (10=1) (nonmiss=0) (miss=.), generate(flood)
recode _x31002 (10=1) (12=1) (16=1) (55=1) (nonmiss=0) (miss=.), generate(flood_2)

collapse (count) _x31002 (mean) _x31004 (sum) _x31005a _x31005b _x31006a (max) flood flood_2, by(QID)
cd "${cleandata_`wave'}"
save shocks_temp, replace

cd "$data"
use merge_`wave', clear
merge 1:1 QID using "${cleandata_`wave'}/shocks_temp.dta", keepusing(_x31002 _x31004 _x31005a _x31005b _x31006a flood flood_2)
drop if _merge==2 //keep only hh which were existent in master data before merge
drop _merge

erase "${cleandata_`wave'}/shocks_temp.dta"

replace _x31002=0 if _x31002==.
replace _x31004=0 if _x31002==0 & _x31004==.
replace _x31005a=0 if _x31005a==. & _x31002==0
replace _x31005b=0 if _x31005b==. & _x31002==0
replace _x31006a=0 if _x31006a==. & _x31002==0
replace flood=0 if flood==. & _x31002==0
replace flood_2=0 if flood==. & _x31002==0

gen flood_5a1 = _x31005a if flood==1
replace flood_5a1=0 if flood==0
replace flood_5a1 =. if flood==.
gen flood_5b1 = _x31005b if flood==1
replace flood_5b1=0 if flood==0
replace flood_5b1 =. if flood==.
gen flood_6a1 = _x31006a if flood==1
replace flood_6a1=0 if flood==0
replace flood_6a1 =. if flood==.

gen flood_5a2 = _x31005a if flood_2==1
replace flood_5a2=0 if flood_2==0
replace flood_5a2 =. if flood_2==.
gen flood_5b2 = _x31005b if flood_2==1
replace flood_5b2=0 if flood_2==0
replace flood_5b2 =. if flood_2==.
gen flood_6a2 = _x31006a if flood_2==1
replace flood_6a2=0 if flood_2==0
replace flood_6a2 =. if flood_2==.

label var _x31002 "Number of AGRI shocks in reference period"
label var _x31004 "Average severity of shocks, based on all AGRI shocks in HH survey"
label var _x31005a "Income loss, based on all AGRI shocks in HH survey"
label var _x31005b "Extra expenditure, based on all AGRI shocks in HH survey"
label var _x31006a "Assets loss, based on all AGRI shocks in HH survey"
label var flood "Household reported flooding shock"
label var flood_2 "Household reported flooding, rain, storm, ersosion shock"
label var flood_5a1 "Income loss of Household reported flooding shock"
label var flood_5b1 "Addit. expend. of Household reported flooding shock"
label var flood_6a1 "Asset loss of Household reported flooding shock"
label var flood_5a2 "Income loss of Household reported flooding rel. shock"
label var flood_5b2 "Addit. expend. of Household reported flooding rel. shock"
label var flood_6a2 "Asset loss of Household reported flooding rel. shock"


cd "$data"
save merge_`wave', replace

if "`wave'"=="w8" {
	cd "${cleandata_`wave'}"
	erase shocks1.dta
}
}
*


** MERGE AGRI RISKS **

foreach wave in w1 w2 w3 w5 w6 w7 w8 {

if "`wave'"=="w8"{ // Using the risks1 dataset, because QID has been added to it.
	cd "${cleandata_`wave'}"
	use risks1.dta, clear
	foreach root in 32003 32003a 32004 32013 {
		cap rename  v`root' _x`root'
	}
	cap gen _x32002=1 // Variable 32002 (do you think this type of event will occur in the next 5 		years?) doesn't exist anymore. But according to the questionair for wave 8 each observation in this dataset is a risk type that is expected within the next 5 years. Therefore the variable can be created as a Dummy variable and filled with 1, because this means in the original definition of 32002, that the risk is expected within the next 5 years by the household.
	rename risks__id _x32001 // risks__id in w8 has the definition of variable 32001 (Type of event (risk)) in other waves.
}
else if "`wave'"=="w1"{ // Also using wave 1 because even if variables are missing, 32002, 32003 and 32004 are still available.
	cd "${cleandata_`wave'}"
	use risksclean.dta, clear
	cap gen _x32003a=. // Variable doesn't exist for wave 1, so it get's created with missing values.
	cap gen _x32013=. // Variable doesn't exist for wave 1, so it get's created with missing values.
	label drop _x32003
	foreach root in 32001 32002 32003 32004 32013 {
		replace _x`root'=. if _x`root'==97 // Replacing 97 with missing values as they are used as a label for 'Don't know'.
		replace _x`root'=. if _x`root'==98 // Replacing 98 with missing values as they are used as a label for 'no answer'.
		replace _x`root'=. if _x`root'==99 // Replacing 99 with missing values as they are used as a label for missing values.
	}
}
else {
	cd "${cleandata_`wave'}"
	use risksclean.dta, clear
	label drop _x32003 _x32003a // Labels will get redefined later
}

recode _x32003 _x32003a  (1=3) (2=2) (3=1) (4=0)
label define _x32003 0 "No Impact" 1 "Low Impact" 2 "Medium Impact" 3 "High Impact"
label define _x32003a 0 "No Impact" 1 "Low Impact" 2 "Medium Impact" 3 "High Impact"
label values _x32003 _x32003
label values _x32003a _x32003a

replace _x32002=0 if _x32002==2
replace _x32013=0 if _x32013==2

recode _x32001 (10/16=1) (20/23=2), generate(agririsk)
keep if agririsk <= 1


collapse (sum) _x32002 _x32004 _x32013 (mean) _x32003 _x32003a, by(QID)
save risks_temp, replace

cd "$data"
use merge_`wave', clear
merge 1:1 QID using "${cleandata_`wave'}/risks_temp.dta", keepusing(_x32002 _x32003 _x32003a _x32004 _x32013)
drop if _merge==2 //keep only hh which were existent in master data before merge
drop _merge
erase "${cleandata_`wave'}/risks_temp.dta"

replace _x32002=0 if _x32002==.
replace _x32003=0 if _x32003==.
replace _x32003a=0 if _x32003a==.
replace _x32004=0 if _x32004==.
replace _x32013=0 if _x32013==.


rename _x32002  _x32002 
rename _x32003  _x32003 
rename _x32003a  _x32003a
rename _x32004  _x32004
rename _x32013  _x32013


label var _x32002 "Number of AGRI risk categories in future 5 years"
label var _x32004 "Number of total AGRI risks in future 5 years"
label var _x32013 "Number of total AGRI risks categories where preventive action undertaken"
label var _x32003 "Average severity of risk on income, based on all AGRI risks"
label var _x32003a "Average severity of risk on assets, based on all AGRI risks"


cd "$data"
save merge_`wave', replace
}
*



** MERGE WEATHER, REGULATION AND PRICE RISKS **

foreach wave in w1 w2 w3 w5 w6 w7 w8{

if "`wave'"=="w8"{ // Using the risks1 dataset, because QID has been added to it.
	cd "${cleandata_`wave'}"
	use risks1.dta, clear
	cap gen _x32002=1 // Variable 32002 (do you think this type of event will occur in the next 5 		years?) doesn't exist anymore. But each observation in this dataset is a risk type that is expected in the next 5 years. Therefore the variable can be created and filled with 1s, because this means in the original definition of 32002, that the risk is expected in the next 5 years by the household.
	rename risks__id _x32001 // 32001 (Type of event (risk)) is called risks__id in w8.
}
else if "`wave'"=="w1"{
	cd "${cleandata_`wave'}"
	use risksclean.dta, clear
	foreach root in 32001 32002 {
		replace _x`root'=. if _x`root'==97 // Replacing 97 with missing values as they are used as a label for 'Don't know'.
		replace _x`root'=. if _x`root'==98 // Replacing 98 with missing values as they are used as a label for 'no answer'.
		replace _x`root'=. if _x`root'==99 // Replacing 99 with missing values as they are used as a label for missing values.
	}
}
else {
	cd "${cleandata_`wave'}"
	use risksclean.dta, clear
}

replace _x32002=0 if _x32002==2

recode _x32001 (10/12 16 55 =100), generate(weatrisk) //100=making up a number that does not already exist in the risk list
recode _x32001 (23=100), generate(mregrisk) //100=making up a number that does not already exist in the risk list
recode _x32001 (21=100), generate(outprisk) //100=making up a number that does not already exist in the risk list

gen weatriskD = 1 if _x32002==1 & weatrisk==100
gen mregriskD = 1 if _x32002==1 & mregrisk==100
gen outpriskD = 1 if _x32002==1 & outprisk==100

collapse (sum) weatriskD mregriskD outpriskD, by(QID)
save risks2_temp, replace


cd "$data"
use merge_`wave', clear
merge 1:1 QID using "${cleandata_`wave'}/risks2_temp.dta", keepusing(weatriskD mregriskD outpriskD)
drop if _merge==2 //keep only hh which were existent in master data before merge
drop _merge
erase "${cleandata_`wave'}/risks2_temp.dta"

replace weatriskD=0 if weatriskD==.
replace weatriskD=1 if weatriskD!=. & weatriskD!=0 // WeatriskD can be bigger than 1, if more than one of the values 10/12 16 55 apply for a household, so these cases were replaced with a 1. 
replace mregriskD=0 if mregriskD==.
replace outpriskD=0 if outpriskD==.

label var weatriskD "HH anticipates severe weather events risk next 5 years"
label var mregriskD "HH anticipates change market regulations risk, next 5 years"
label var outpriskD "HH anticipates strong decrease output price risk, next 5 years"

cd "$data"
save merge_`wave', replace

if "`wave'"=="w8" {
    cd "${cleandata_`wave'}"
	erase risks1.dta
}
}
*



*****************************************************************************

** MERGE LAND DATA **

foreach wave in w1 w2 w3 w5 w6 w7 w8{

if "`wave'"=="w1"{
	use "${cleandata_w1}/landclean1", replace // Using the landclean1 dataset, because variable 41003 (land area) has been corrected (see 2.1.merge_prep.do-file)
	rename _x41009 _x41009a // w1 only has variable 41009 that states the land value at the point of acquisition, but not the current land value (41009a), but this is the best alternative that's available.
	foreach root in 41003 41005 41009a {
		replace _x`root'=. if _x`root'==97 // Replacing 97 with missing values as they are used as a label for 'Don't know'.
		replace _x`root'=. if _x`root'==98 // Replacing 98 with missing values as they are used as a label for 'no answer'.
		replace _x`root'=. if _x`root'==99 // Replacing 99 with missing values as they are used as a label for missing values.
	}
}
else if "`wave'"=="w8" {
    use "${cleandata_`wave'}/land_used1", replace // Using the land__used1 dataset, because QID and T were added to it (see 2.1.merge_prep.do-file).
	rename v41006a _x41009a // Variable 41006a in wave 8 has the definition of variable 41009a in other waves.
	foreach root in 41003 41005 {
		cap rename  v`root' _x`root'
	}
}
else {
    use "${cleandata_`wave'}/landclean1", replace // Using the landclean1 dataset, because T has been added to some waves and variable 41003 (land area) has been corrected for some waves.
}



drop if T!=1 //there was a problem merging w5 land data for some provinces apparently, but buriram seems ok
cap drop __000000 __000001
cap tostring QID, force replace

recode _x41005 (11/12=1) (1/3=2), gen(owned)
*recode _x41005 (11/12=1) (1=2), gen(owned)

gen ownlanda =_x41003 if owned<=2
gen ownlandv =_x41009a if owned<=2

if  "`wave'"=="w6" | "`wave'"=="w7" { // For waves 6 and 7 var 41009a asks for the land value at the point of acquisition and not for the current value as in other waves. There's no substitute available, so the current ownlandv can't be estimated for waves 6 and 7.
	replace ownlandv=.
}

collapse  (sum) _x41003 _x41009a ownlanda ownlandv, by(QID)

replace _x41003=0 if _x41003==.
replace _x41009a=0 if _x41009a==.

gen ownlandaS = ownlanda/_x41003

cd "${cleandata_`wave'}"
save land_temp, replace

cd "$data"
if "`wave'"=="w8" {
	use merge_`wave', clear
	cap tostring QID, force replace // QID needs to be a string for wave 8.
}
else {
	use merge_`wave', clear
}

merge 1:1 QID using "${cleandata_`wave'}/land_temp.dta"
drop if _merge==2 
drop _merge
erase "${cleandata_`wave'}/land_temp.dta"

label var _x41003  "Total land area"
label var _x41009a  "Total land value"
label var ownlanda  "Total owned land area"
label var ownlandv  "Total owned land value"
label var ownlandaS "Share of total land area that is owned"


cd "$data"
save merge_`wave', replace
}
*

** MERGE MORE LAND DATA **


foreach wave in w1 w2 w3 w5 w6 w7 w8{
	
if "`wave'"=="w1"{
	use "${cleandata_w1}/landclean1", replace // Using the landclean1 dataset, because variable 41003 (land area) has been corrected (see 2.1.merge_prep.do-file)
	rename _x41009 _x41009a // w1 only has variable 41009 that states the land value at the point of acquisition, but not the current land value (41009a), but this is the best alternative that's available.
	foreach root in 41003 41004 41009a {
		replace _x`root'=. if _x`root'==97 // Replacing 97 with missing values as they are used as a label for 'Don't know'.
		replace _x`root'=. if _x`root'==98 // Replacing 98 with missing values as they are used as a label for 'no answer'.
		replace _x`root'=. if _x`root'==99 // Replacing 99 with missing values as they are used as a label for missing values.
	}
}
else if "`wave'"=="w8" {
    use "${cleandata_`wave'}/land_used1", replace // Using the land__used1 dataset, because QID and T were added to it (see 2.1.merge_prep.do-file).
	rename v41006a _x41009a // Variable 41006a in wave 8 has the definition of variable 41009a in other waves.
	foreach root in 41003 41004 {
		cap rename  v`root' _x`root'
	}
}
else {
    use "${cleandata_`wave'}/landclean1", replace // Using the landclean1 dataset, because T has been added to some waves and variable 41003 (land area) has been corrected for some waves.
}


drop if T!=1 //there was a problem merging w5 land data for some provinces apparently, but buriram seems ok
cap drop __000000 __000001
cap tostring QID, force replace

gen ricelanda =_x41003 if _x41004==3
gen ricelandv =_x41009a if _x41004==3

if "`wave'"=="w6" | "`wave'"=="w7" { // For waves 6 and 7 var 41009a asks for the land value at the point of acquisition and not for the current value as in other waves. There's no substitute available, so the current ricelandv can't be estimated for waves 6 and 7.
	replace ricelandv=.
}

collapse  (sum) ricelanda ricelandv, by(QID)

gen ricelandp =ricelandv/ricelanda 
winsor2 ricelandp , cut(1 97) replace

cd "${cleandata_`wave'}"
save land2_temp, replace 

cd "$data"
use merge_`wave', clear
merge 1:1 QID using "${cleandata_`wave'}/land2_temp.dta"
drop if _merge==2 
drop _merge
erase "${cleandata_`wave'}/land2_temp.dta"

label var ricelandp  "Rice or field crop land, average price per rai"
label var ricelanda "Total land area used for rice and field crop cultivation"
label var ricelandv "Total land value of land used for rice and field crop cultivation"

cd "$data"
save merge_`wave', replace
}
*



** Generate Sample Var: MERGE CROPS; LAND DATA **

foreach wave in w1 w2 w3 w5 w6 w7 w8 {

if "`wave'"=="w1"{
	use "${cleandata_w1}/cropsclean", replace
	replace _x42016=. if _x42016==99 // Replacing 99 with missing values as they are used as a label for missing values.
	foreach root in 42002 42004 42005 42006 42008 42009 42010 42011 42014 42016 {
		replace _x`root'=. if _x`root'==97 // Replacing 97 with missing values as they are used as a label for 'Don't know'.
		replace _x`root'=. if _x`root'==98 // Replacing 98 with missing values as they are used as a label for 'no answer'.
		replace _x`root'=. if _x`root'==99 // Replacing 99 with missing values as they are used as a label for missing values.
	}
	drop _x42002
	cap rename _x42003a _x42002 // In wave 1 the variable 42003a has the definition of variable 42002 in the following waves.
	replace _x42002=101 if _x42002==11 // In wave 1 there's only 'fragrant rice' (11) instead of 101 as in the following waves. While it's not a perfect substitute, 'fragrant rice' almost always equals 'jasmine rice' in the following waves.
	replace _x42002=103 if _x42002==13 // In wave 1 'glutinous rice' is 13 instead of 103 as in the following waves.
	replace _x42002=104 if _x42002==12 // In wave 1 'non-glutionous rice' is 12 instead of 104 as in the following waves.
	// 102 ('other fragrant rice') doesn't exist for wave 1
}
else if "`wave'"=="w6" | "`wave'"=="w7" {
	 use "${cleandata_`wave'}/cropsclean1", replace // Using cropsclean1, because T has been added.
}
else if "`wave'"=="w8" {
	 use "${cleandata_`wave'}/crops_plots1", replace // Using the crops_plots1 dataset, because T and QID have been added and variables 42003a, 42006 and 42008 needed to be corrected.
	 rename v42003a _x42002 // The definition of v42003a in wave 8 has the definition of 42002 of previous waves.
	foreach root in 42005 42006 42008 42009 42010 42011 42014 42016 {
		cap rename  v`root' _x`root'
	}
	rename land_used__id _x42004
	cap tostring QID, replace
}
else {
	use "${cleandata_`wave'}/cropsclean", replace
}

cap drop __000000
*cap tostring QID, force replace
drop if T!=1 //there was a problem merging w5 land data for some provinces apparently, but buriram seems ok

keep _x42002 _x42004 _x42005 _x42006 _x42008 _x42009 _x42010 _x42011 _x42014 _x42016 QID

if "`wave'"=="w1" | "`wave'"=="w2" {
	replace _x42005=_x42005*6.25
}
*

rename _x42004 parcelid 

cd "${cleandata_`wave'}"
save crops_temp, replace


if "`wave'"=="w1"{
	use "${cleandata_w1}/landclean1", replace // Using landclean1, because variable 41003 was corrected (see merge_prep.do-file)
	foreach root in 41002 41003 41005 41008 {
		replace _x`root'=. if _x`root'==97 // Replacing 97 with missing values as they are used as a label for 'Don't know'.
		replace _x`root'=. if _x`root'==98 // Replacing 98 with missing values as they are used as a label for 'no answer'.
		replace _x`root'=. if _x`root'==99 // Replacing 99 with missing values as they are used as a label for missing values.
	}
}
else if  "`wave'"=="w2" | "`wave'"=="w3" | "`wave'"=="w5" | "`wave'"=="w6" | "`wave'"=="w7" {
	 use "${cleandata_`wave'}/landclean1", replace // Using the landclean1 dataset, because T has been added to some wave and the plot size has been corrected for some waves and variable 41002 (land parcel number) was added to some waves.
}
else {
	 use "${cleandata_`wave'}/land_used1", replace // Using land_used1 because variable 41008 has been corrected (see merge_prep.do-file)
	 rename (v41002 v41003 v41005) (_x41002 _x41003 _x41005)
	 rename v41008a _x41008 // 'When did you purchase the land? -Year' is called 41008a in wave 8 instead of 41008 as in other waves
		 rename v41006a _x41009a // 'What is the current value of the land if you wanted to sell/buy it' is 41006a in wave 8 instead of 41009a as in other waves.
}

cap drop __000000
*cap tostring QID, force replace
drop if T!=1 //there was a problem merging w5 land data for some provinces apparently, but buriram seems ok

cap gen _x41009a=. // This is not a problem here, because the empty variable isn't used to create a new variable or used for merging later.

if "`wave'"=="w5" {
	rename ID parcelid //w5 problem: parcel IDs are SQLIDs 
}
else {
	rename _x41002 parcelid
}

keep _x41003 _x41005 _x41008 _x41009a parcelid QID
cap tostring QID, replace

drop if QID =="3410020302" & _x41003==.
drop if QID =="3415160206" & _x41003==.
duplicates drop // The following merge-command yielded an error code "variables QID parcelid do not uniquely identify observations in the master dataset". The reason was a duplicate row in the dataset which is deleted. This doesn't solve the problem for wave 6 + wave 7, which needs additional cleansing in the following rows.
if "`wave'"=="w3" | "`wave'"=="w6" | "`wave'"=="w7" {
	duplicates drop QID parcelid, force // If there are duplicates of the same QID and parcelid they will be dropped.
}

//merge crop information to the parcels
merge 1:m QID parcelid using "${cleandata_`wave'}/crops_temp.dta", nogen
save land_temp, replace
erase crops_temp.dta

//drop if not rice cassava corn crops
recode _x42002 (101/104=1), gen(insurcrops)
keep if insurcrops==1 


//unit transformation
gen unit=.
replace unit = 1000 if _x42009==1
replace unit = 1 if _x42009==2
replace unit = 12 if _x42009==7
replace unit = 2.2 if _x42009==11

//output in kg per crop
gen ricekgtot = _x42010*unit
gen ricekgav = _x42010*unit 
gen riceland = _x42005
gen ricelando= _x42005 if _x41005==1 | _x41005==2 | _x41005==3

//add: agri_cons (=Quantity of consumed agricultural production)
gen agri_cons = _x42011

collapse (mean) insurcrops riceland ricelando ricekgav (sum) ricekgtot agri_cons, by(QID parcelid)

collapse (mean) insurcrops (sum) riceland ricelando ricekgav ricekgtot agri_cons, by(QID) // works

replace ricelando =0 if ricelando==.
replace ricekgtot =0 if ricekgtot==.
replace ricekgav =0 if ricekgav==.

gen ricekgrai=ricekgav / riceland
drop ricekgav

save land_temp, replace

cd "$data"
use merge_`wave', clear
merge 1:1 QID using "${cleandata_`wave'}/land_temp.dta"
drop if _merge==2 
drop _merge
erase "${cleandata_`wave'}/land_temp.dta"

replace riceland=0 if riceland==.

label var ricekgrai  "Rice produce in kg/rai on aver/plot (sev harvests possbl)"
label var ricekgtot  "Rice produce in in total per year"
label var riceland  "Total area planted with rice"
label var ricelando  "Total area planted with rice and owned"
label var insurcrops "Does HH plant RICE crops"
label var agri_cons "Quantity of consumed agricultural production"


cd "$data"
save merge_`wave', replace
}
*

** AGAIN MERGE CROPS DATA FOR TAPIOCA AND MAIZE**

foreach wave in w1 w2 w3 w5 w6 w7 w8 {

if "`wave'"=="w1"{
	use "${cleandata_w1}/cropsclean", replace
	replace _x42016=. if _x42016==99 //Replacing 99 with missing values as they are used as a label for missing values.
	foreach root in 42002 42004 42005 42006 42008 42009 42010 42014 42016 {
		replace _x`root'=. if _x`root'==97 // Replacing 97 with missing values as they are used as a label for 'Don't know'.
		replace _x`root'=. if _x`root'==98 // Replacing 98 with missing values as they are used as a label for 'no answer'.
		replace _x`root'=. if _x`root'==99 // Replacing 99 with missing values as they are used as a label for missing values.
	}
}
else if "`wave'"=="w6" | "`wave'"=="w7" {
	use "${cleandata_`wave'}/cropsclean1", replace // Using the cropsclean1 dataset, because T has been added and variable 42002 (crop type) was corrected (see 2.1.merge_prep.do-file)
}
else if "`wave'"=="w8"{
	use "${cleandata_`wave'}/crops_plots1", replace // Using the crops_plots1 dataset, because T and QID have been added and variables 42003a, 42006 and 42008 needed to be corrected.
	foreach root in 42005 42006 42008 42009 42010 42014 42016 {
		cap rename  v`root' _x`root'
	}
	rename v42003a _x42002
	rename land_used__id _x42004
	cap tostring QID, replace
}
else {
    use "${cleandata_`wave'}/cropsclean", replace
}

cap drop __000000
*cap tostring QID, force replace
drop if T!=1 //there was a problem merging w5 land data for some provinces apparently, but buriram seems ok

keep _x42002 _x42004 _x42005 _x42006 _x42008 _x42009 _x42010 _x42014 _x42016 QID

if "`wave'"=="w1" | "`wave'"=="w2" {
	replace _x42005=_x42005*6.25
}

rename _x42004 parcelid 
cd "${cleandata_`wave'}"
save crops2_temp, replace


if "`wave'"=="w1"{
	use "${cleandata_w1}/landclean1", replace // Using landclean1, because variable 41003 was corrected (see merge_prep.do-file)
	foreach root in 41002 41003 41005 41008 {
		replace _x`root'=. if _x`root'==97 // Replacing 97 with missing values as they are used as a label for 'Don't know'.
		replace _x`root'=. if _x`root'==98 // Replacing 98 with missing values as they are used as a label for 'no answer'.
		replace _x`root'=. if _x`root'==99 // Replacing 99 with missing values as they are used as a label for missing values.
	}
}
else if "`wave'"=="w2" | "`wave'"=="w3" | "`wave'"=="w5" | "`wave'"=="w6" | "`wave'"=="w7" {
	use "${cleandata_`wave'}/landclean1", replace // Using landclean 1, because for waves 1, 2, 3 and 5 variable 41003 has been corrected. For waves 6 and wave 7 T has been added (see merge_prep.do-file)
}
else if "`wave'"=="w8" {
	use "${cleandata_`wave'}/land_used1", replace // Using land_used1 because variable 41008 has been corrected (see merge_prep.do-file)
	foreach root in 41002 41003 41005 {
		cap rename  v`root' _x`root'
	}
	rename v41008a _x41008 // 41008 (When did you purchase the land? - Year) is 41008a in wave 8.
	rename v41006a _x41009a // 'What is the current value of the land if you wanted to sell/buy it' is 41006a in wave 8 instead of 41009a as in other waves.
}

cap drop __000000
*cap tostring QID, force replace
drop if T!=1 //there was a problem merging w5 land data for some provinces apparently, but buriram seems ok


cap gen _x41009a=. // This is not a problem here, because the empty variable isn't used to create a new variable or used for merging later.


if "`wave'"=="w5" {
	rename ID parcelid //w5 problem: parcel IDs are SQLIDs 
}
else {
	rename _x41002 parcelid
}

keep _x41003 _x41005 _x41008 _x41009a parcelid QID
cap tostring QID, replace

drop if QID =="3410020302" & _x41003==.
drop if QID =="3415160206" & _x41003==.
duplicates drop // The following merge-command yielded an error code "variables QID parcelid do not uniquely identify observations in the master dataset". The reason was a duplicate row in the dataset which is deleted. This doesn't solve the problem for wave 6 + wave 7, which needs additional cleansing in the following rows.
if "`wave'"=="w3" | "`wave'"=="w6" | "`wave'"=="w7" {
	duplicates drop QID parcelid, force // If there are duplicates of the same QID and parcelid they will be dropped.
}


//merge crop information to the parcels
merge 1:m QID parcelid using "${cleandata_`wave'}/crops2_temp.dta", nogen
save land2_temp, replace
erase crops2_temp.dta

//do our rice farmers also grow corn, cassava
if "`wave'"=="w1"{ // For wave 1 'corn' is 2 instead of 201/202. (Contains also glutinous corn, but it never actually shows up in the dataset.)
    recode _x42002 (6 2 =1) (nonmis=0), gen(temp)
	bysort QID: egen corncass = max(temp)
	drop temp

	recode _x42002 (6  =1) (nonmis=0), gen(temp)
	bysort QID: egen cass = max(temp)
	drop temp

	recode _x42002 (2 =1) (nonmis=0), gen(temp)
	bysort QID: egen corn = max(temp)
	drop temp
}
else if "`wave'"=="w6" | "`wave'"=="w7" | "`wave'"=="w8" { // For wave 6-8 'fodder maize' is 21 instead of 201 and 'Sweet corn' is 22 instead of 202.
	recode _x42002 (6 21/22 =1) (nonmis=0), gen(temp)
	bysort QID: egen corncass = max(temp)
	drop temp

	recode _x42002 (6  =1) (nonmis=0), gen(temp)
	bysort QID: egen cass = max(temp)
	drop temp

	recode _x42002 (21/22 =1) (nonmis=0), gen(temp)
	bysort QID: egen corn = max(temp)
	drop temp
}
else {
	recode _x42002 (6 201/202 =1) (nonmis=0), gen(temp)
	bysort QID: egen corncass = max(temp)
	drop temp

	recode _x42002 (6  =1) (nonmis=0), gen(temp)
	bysort QID: egen cass = max(temp)
	drop temp

	recode _x42002 (201/202 =1) (nonmis=0), gen(temp)
	bysort QID: egen corn = max(temp)
	drop temp


	tab _x42009 if _x42002==6
	tab _x42009 if _x42002==201 | _x42002==202

	tab _x42010 if _x42002==6 & _x42009==2
	tab _x42010 if _x42002==6 & _x42009==16
	tab _x42010 if _x42002==6 & _x42009==17

	tab _x42010 if (_x42002==201 | _x42002==202) & _x42009==2 //total 19, and only 6 farmers in the raw sample grow 1 ton or more corn, the rest grows below or equal to 120 kg
}

//unit transformation
gen unit=.
replace unit = 1000 if _x42009==1
replace unit = 1 if _x42009==2
replace unit = 12 if _x42009==7
replace unit = 2.2 if _x42009==11
replace unit = 5000 if _x42009==17
replace unit = 2 if _x42009==16

//output cassva corn in kg per crop
gen temp   = _x42010*unit if  _x42002==6
bysort QID: egen casskgtot = total(temp)
drop temp
if "`wave'"=="w1"{
	gen temp   = _x42010*unit if  _x42002==2
}
else if "`wave'"=="w6" | "`wave'"=="w7" | "`wave'"=="w8" {
	gen temp   = _x42010*unit if  _x42002==21 | _x42002==22
}
else {
	gen temp   = _x42010*unit if  _x42002==201 | _x42002==202
}
bysort QID: egen cornkgtot = total(temp)
drop temp


collapse (mean) corncass corn cass casskgtot cornkgtot, by(QID parcelid) // Casskgtot and cornkgtot don't show the total amount of production per parcelid, but by QID due to the definition (total(temp)) used in the previous lines. But is not a problem anyways, as it is overwritten by the next collapse-command.

collapse (mean) corncass corn cass casskgtot cornkgtot, by(QID)

replace casskgtot   =0 if casskgtot==.
replace cornkgtot   =0 if cornkgtot==.

save land2_temp, replace

cd "$data"
use merge_`wave', clear
merge 1:1 QID using "${cleandata_`wave'}/land2_temp.dta"
drop if _merge==2 
drop _merge
erase "${cleandata_`wave'}/land2_temp.dta"

label var corncass "Does HH plant corn, cassava"
label var corn "Does HH plant corn"
label var cass "Does HH plant cassava"
label var casskgtot  "Cassava produce in in total per year"
label var cornkgtot  "Corn produce in in total per year"



cd "$data"
save merge_`wave', replace

if "`wave'"=="w2" | "`wave'"=="w3" | "`wave'"=="w5" | "`wave'"=="w6" | "`wave'"=="w7" {
	erase "${cleandata_`wave'}/landclean1.dta"
}
if "`wave'"=="w1" {
    cd "${cleandata_`wave'}"
	erase landclean1.dta
}
if "`wave'"=="w8" {
	cd "${cleandata_`wave'}"
	erase land_used1.dta
}
}
*



** MERGE MORE CROP DATA **

foreach wave in w1 w2 w3 w5 w6 w7 w8 {

if "`wave'"=="w1"{
	use "${cleandata_w1}/cropsclean", replace
	drop _x42002
	cap rename _x42003a _x42002 // In wave 1 the variable 42003a has the definition of variable 42002 in the following waves.
	replace _x42002=101 if _x42002==11 // In wave 1 there's only 'fragrant rice' (11) instead of 101 as in the following waves. While it's not a perfect substitute, 'fragrant rice' almost always equals 'jasmine rice' in the following waves.
	replace _x42002=103 if _x42002==13 // In wave 1 'glutinous rice' is 13 instead of 103 as in the following waves.
	replace _x42002=104 if _x42002==12 // In wave 1 'non-glutionous rice' is 12 instead of 104 as in the following waves.
	foreach root in 42014 42016 42018 42019 42020 42021 42022 42023 42024 42025 42026 42027 42028 42029 42029a {
		replace _x`root'=. if _x`root'==97 // Replacing 97 with missing values as they are used as a label for 'Don't know'.
		replace _x`root'=. if _x`root'==98 // Replacing 98 with missing values as they are used as a label for 'no answer'.
		replace _x`root'=. if _x`root'==99 // Replacing 99 with missing values as they are used as a label for missing values.
	}
}
else if "`wave'"=="w8"{
	use "${cleandata_`wave'}/crops_plots1", replace // Using the crops_plots1 dataset, because T and QID have been added.
	gen v42029a=. // 42029a doesn't exist for wave 8.
	rename v42003a _x42002 // In wave 8 variable 42003a is the same as variable 42002 in previous waves.
	egen _x42023 = rowtotal(v42023 v42023a) // In other waves variable 42023 (Fertilizer application: Expenditures materials) equals the sum of variables 42023 and 42024 in wave 8 (42023: Fertilizer application: Expenditures mineral fertilizers, 42024: Fertilizer application: Expenditures Organic fertilizers)
	foreach root in 42009 42010 42013a 42014 42014b 42016 42016b 42018 42019 42020 42021 42022 42023 42024 42025a 42025b 42025c 42026 42027 42028 42029 42029a 42036{
		cap rename  v`root' _x`root' 
}
	cap tostring QID, replace
}
else if "`wave'"=="w6" | "`wave'"=="w7" {
	use "${cleandata_`wave'}/cropsclean1", replace // Using cropsclean1, because T has been added.
	}
else {
    use "${cleandata_`wave'}/cropsclean", replace
}



if "`wave'"=="w1" | "`wave'"=="w2" {
	replace _x42005=_x42005*6.25
}

if "`wave'"=="w1" {
	cap gen _x42013a=.
	cap gen _x42029a=.
	cap gen _x42036=.
	cap gen _x42014b=.
	cap gen _x42016b=.
} // These variables are only missing in w1 and don't need to be created for the other waves.

//equalize
if "`wave'"=="w1" | "`wave'"=="w2" | "`wave'"=="w3" { // waves 1, 2 and 3 only have variable 42025, which equals the sum of 42025a + 42025b and 42025c in the following waves.
}
else {
	cap egen _x42025= rowtotal (_x42025a _x42025b _x42025c) // Using egen rowtotal, so that missing values of single variables don't lead to missing values in _x42025, even if other variables have non-zero values.
}
cap drop _x42025a _x42025b _x42025c

//reduce vars
keep _x42002 _x42009 _x42010 _x42013a  _x42014 _x42014b _x42016 _x42016b _x42018 _x42019 _x42020 _x42021 _x42022 _x42023 _x42024 _x42025 _x42026 _x42027 _x42028 _x42029 _x42029a _x42036 QID // Maybe _x42018 (land preparation expenditures variable machine cost) was forgotten here, because it was still used in the "renaming" code line. It was added here again.

//drop if not rice crops
recode _x42002 (101/104=1), gen(insurcrops)
keep if insurcrops==1

//expenditure
egen expend= rowtotal (_x42018 _x42019 _x42020 _x42021 _x42022 _x42023 _x42024 _x42025 _x42026 _x42027 _x42028 _x42029 _x42036) // Using egen rowtotal, so that missing values of single variables don't lead to missing values in expend, even if other variables have non-zero values. Additionally, _x42018 (land preparation expenditures variable machine cost) was added again.
replace expend=_x42029a if expend==.

egen hiredlab= rowtotal (_x42019 _x42021 _x42022 _x42024 _x42026 _x42028) // Using egen rowtotal, so that missing values of single variables don't lead to missing values in hiredlab, even if other variables have non-zero values.


//units
gen unit=.
replace unit = 1000 if _x42009==1
replace unit = 1 if _x42009==2
replace unit = 12 if _x42009==7
replace unit = 2.2 if _x42009==11

//seeds reserved
gen seedsres= _x42013a*unit 


//share sold
egen ricekgsld = rowtotal(_x42014 _x42014b)
replace ricekgsld= ricekgsld*unit 
replace ricekgsld=. if _x42014 ==. & _x42014b==.
//winsorize
winsor2 ricekgsld, c(0 97) replace // Removing outliers


replace _x42016b=0 if _x42016b==.

mvencode _x42014 _x42016 _x42014b _x42016b, mv(0) override // Replacing missing values in _x42014, _x42016, _x42014b and _x42016b with zeros, because otherwise if there is a missing value in one or more of the four variables, the variable ricerev that's created in the next line will become zero too. The option override needs to be used, because there are already zeros in these variables and Stata otherwise would stop as soon as it realizes. 
gen ricerev= _x42014*_x42016 + _x42014b*_x42016b
sum  _x42014 _x42016 _x42014b _x42016b
sum ricerev, d
winsor2 ricerev, c(0 97) replace // Removing outliers

gen ricekg= _x42010*unit 

gen pricekgs = ricerev/ricekgsld


if "`wave'"=="w1" {
	gen pricekgsD = . // pledging didn't exist back in wave 1.
}
if "`wave'"=="w2" {
	gen pricekgsD = (pricekgs>=0.7) if pricekgs!=.  //pledging price 14000 * conversion rate 0.0582 / 1000
}
if "`wave'"=="w3" {
	gen pricekgsD = (pricekgs>=0.7) if pricekgs!=.  //pledging price 14000 * conversion rate 0.0552 / 1000
}
if "`wave'"=="w5" {
	gen pricekgsD = (pricekgs>=0.7) if pricekgs!=.  //pledging price 15000 * conversion rate 0.0496 / 1000
}
if "`wave'"=="w6" {
	gen pricekgsD = (pricekgs>=0.7) if pricekgs!=.  //pledging price 15000 * conversion rate 0.0485 / 1000
}
if "`wave'"=="w7" {
	gen pricekgsD = (pricekgs>=0.7) if pricekgs!=.  //pledging price 15000 * conversion rate 0.0478 / 1000
}
if "`wave'"=="w8" {
	gen pricekgsD = (pricekgs>=0.7) if pricekgs!=.  //pledging price 15000 * conversion rate 0.0475 / 1000
}

collapse (sum) expend hiredlab seedsres ricekgsld ricekg ricerev (max) pricekgsD, by(QID)

replace seedsres=0 if seedsres==.
replace expend=0 if expend==.
replace hiredlab=0 if hiredlab==.
replace ricekgsld=0 if ricekgsld==.
replace ricekg=0 if ricekg==.
replace ricerev=0 if ricerev==.

gen sharesold= ricekgsld/ricekg  
drop ricekg 

gen pricekg = ricerev/ricekgsld
sum pricekg, d

if "`wave'"=="w1" {
	gen pricekgD = . //pledging didn't exist back in wave 1
}
if "`wave'"=="w2" {
	gen pricekgD = (pricekg>=0.7) if pricekg!=.  //pledging price 14000 * conversion rate 0.0582 / 1000
}
if "`wave'"=="w3" {
	gen pricekgD = (pricekg>=0.7) if pricekg!=.  //pledging price 14000 * conversion rate 0.0552 / 1000
}
if "`wave'"=="w5" {
	gen pricekgD = (pricekg>=0.7) if pricekg!=.  //pledging price 15000 * conversion rate 0.0496 / 1000
}
if "`wave'"=="w6" {
	gen pricekgD = (pricekg>=0.7) if pricekg!=.  //pledging price 15000 * conversion rate 0.0485 / 1000
}
if "`wave'"=="w7" {
	gen pricekgD = (pricekg>=0.7) if pricekg!=.  //pledging price 15000 * conversion rate 0.0478 / 1000
}
if "`wave'"=="w8" {
	gen pricekgD = (pricekg>=0.7) if pricekg!=.  //pledging price 15000 * conversion rate 0.0475 / 1000
}

label var hiredlab  "Rice crop cultivation hired labour expenditure"
label var expend  "Rice crop cultivation expenditure"
label var seedsres  "Rice crop seeds resrved"
label var sharesold  "Share of produced rice that was sold"
label var ricekgsld  "Kg produced rice that was sold"
label var pricekg  "Average price for kg sold rice, all"
label var pricekgD  "Pledging - Avergae price is higher 14000 or 15000 per ton"
label var pricekgsD  "Pledging - Any seperate price is higher 14000 or 15000 per ton"
label var ricerev "Revenue from rice sales"

cd "${cleandata_`wave'}"
save crops2_temp, replace

cd "$data"
use merge_`wave', clear
merge 1:1 QID using "${cleandata_`wave'}/crops2_temp.dta"
drop if _merge==2 
drop _merge
erase "${cleandata_`wave'}/crops2_temp.dta"

cd "$data"
save merge_`wave', replace

}
*



***#######################THIS MIGHT BE FLAWED################################################
** MERGE MORE CROP DATA **

foreach wave in w1 w2 w3 w5 w6 w7 w8 {

if "`wave'"=="w1"{
	use "${cleandata_w1}/cropsclean", replace
	drop _x42002
	rename _x42003a _x42002 // In wave 1 the variable 42003a has the definition of variable 42002 in the following waves.
	replace _x42002=101 if _x42002==11 // In wave 1 there's only 'fragrant rice' (11) instead of 101 as in the following waves. While it's not a perfect substitute, 'fragrant rice' almost always equals 'jasmine rice' in the following waves.
	replace _x42002=103 if _x42002==13 // In wave 1 'glutinous rice' is 13 instead of 103 as in the following waves.
	replace _x42002=104 if _x42002==12 // In wave 1 'non-glutionous rice' is 12 instead of 104 as in the following waves.
	foreach root in 42014 42016 42018 42019 42020 42021 42022 42023 42024 42025 42026 42027 42028 42029 42029a  {
		replace _x`root'=. if _x`root'==97 // Replacing 97 with missing values as they are used as a label for 'Don't know'.
		replace _x`root'=. if _x`root'==98 // Replacing 98 with missing values as they are used as a label for 'no answer'.
		replace _x`root'=. if _x`root'==99 // Replacing 99 with missing values as they are used as a label for missing values/not applicable.
	}
}
else if "`wave'"=="w6" | "`wave'"=="w7" {
	use "${cleandata_`wave'}/cropsclean1", replace // Using the cropsclean1 dataset, because T has been added and variable 42002 was corrected (see 2.1.merge_prep.do-file)
}
else if "`wave'"=="w8" {
	use "${cleandata_`wave'}/crops_plots1", replace // Using the crops_plots1 dataset, because T and QID have been added and the months have been corrected in variable 42006 (Start of planting period) so that they fit the other waves as well.
	gen v42029a=. // 42029a doesn't exist for wave 8.
	rename v42003a _x42002 // In wave 8 the variable 42003a is the same as variable 42002 in previous waves.
	egen _x42023 = rowtotal(v42023 v42023a) // In other waves variable 42023 (Fertilizer application: Expenditures materials) equals the sum of variables 42023 and 42024 in wave 8 (42023: Fertilizer application: Expenditures mineral fertilizers, 42024: Fertilizer application: Expenditures Organic fertilizers)
	foreach root in 42009 42010 42013a 42014 42014b 42015a 42016 42016b 42018 42019 42020 42021 42022 42024 42025a 42025b 42025c 42026 42027 42028 42029 42029a 42036 {
		cap rename  v`root' _x`root'
	}
	cap tostring QID, replace
}
else {
    use "${cleandata_`wave'}/cropsclean", replace
}



if "`wave'"=="w1" | "`wave'"=="w2" {
	replace _x42005=_x42005*6.25
}

/* if "`wave'"=="w1" {
	cap gen _x42015a=.
} _x42015a is actually available for w1 and seems to be not corrupted, so I'm using it. */

if "`wave'"=="w1" {
	cap gen _x42013a=.
	cap gen _x42029a=.
	cap gen _x42036=.
	cap gen _x42014b=.
	cap gen _x42016b=.
} // These variables are only missing in w1 and don't need to be created also for the other waves.

//equalize
if "`wave'"=="w1" | "`wave'"=="w2" | "`wave'"=="w3" { // waves 1, 2 and 3 have only 42025, which equals the sum of 42025a + 42025b and 42025c in the following waves.
}
else {
	cap egen _x42025= rowtotal (_x42025a _x42025b _x42025c) // Using egen rowtotal, so that missing values of single variables don't lead to missing values in _x42025, even if other variables have non-zero values.
}
cap drop _x42025a _x42025b _x42025c

//reduce vars
keep T _x42002 _x42009 _x42010 _x42013a _x42014 _x42014b _x42015a _x42016 _x42016b _x42018 _x42019 _x42020 _x42021 _x42022 _x42023 _x42024 _x42025 _x42026 _x42027 _x42028 _x42029 _x42029a _x42036 QID

//drop if not rice crops
recode _x42002 (101/104=1), gen(insurcrops)
keep if insurcrops==1

egen e_lndprep= rowtotal (_x42018 _x42019)
egen e_seeds= rowtotal (_x42020 _x42021)
egen e_fertil= rowtotal (_x42023 _x42024)
egen e_pestiz= rowtotal (_x42025 _x42026)
egen e_harvest= rowtotal (_x42027 _x42028)
gen e_irrig= _x42029 // Using egen rowtotal to generate the previous variables, so that missing values of single variables don't lead to missing values in the generated variables, even if other variables have non-zero values.

//units
gen unit=.
replace unit = 1000 if _x42009==1
replace unit = 1 if _x42009==2
replace unit = 12 if _x42009==7
replace unit = 2.2 if _x42009==11

//winsorize
winsor2 _x42014, replace

//share sold
egen paddkgsld = rowtotal(_x42014 _x42014b) if _x42015a==1
replace paddkgsld= paddkgsld*unit 
replace paddkgsld=. if  _x42014 ==.  & _x42014b==.
sum paddkgsld, d
winsor2 paddkgsld, cut(0 99) replace // removing outliers
replace _x42016b=0 if _x42016b==.

mvencode _x42014 _x42016 _x42014b _x42016b, mv(0) override // Replacing missing values in _x42014, _x42016, _x42014b and _x42016b with zeros, because otherwise if there is a missing value in one or more of the four variables, the variable paddrev that's created in the next line will become zero too. The option override needs to be used, because there are already zeros in these variables and Stata otherwise would stop as soon as it realizes. 
gen paddrev= _x42014*_x42016 + _x42014b*_x42016b if _x42015a==1
sum  _x42014 _x42016 _x42014b _x42016b
sum paddrev, d
winsor2 paddrev, cut(0 97) replace // removing outliers

gen ppricekgs = paddrev/paddkgsld

if "`wave'"=="w1" {
	gen pprickgsD = . // pledging didn't exist back in wave 1.
}
if "`wave'"=="w2" {
	gen pprickgsD = (ppricekgs>=0.7) if ppricekgs!=.  //pledging price 14000 * conversion rate 0.0582 / 1000
}
if "`wave'"=="w3" {
	gen pprickgsD = (ppricekgs>=0.7) if ppricekgs!=.  //pledging price 14000 * conversion rate 0.0552 / 1000
}
if "`wave'"=="w5" {
	gen pprickgsD = (ppricekgs>=0.7) if ppricekgs!=.  //pledging price 15000 * conversion rate 0.0496 / 1000
}
if "`wave'"=="w6" {
	gen pprickgsD = (ppricekgs>=0.7) if ppricekgs!=.  //pledging price 15000 * conversion rate 0.0485 / 1000
}
if "`wave'"=="w7" {
	gen pprickgsD = (ppricekgs>=0.7) if ppricekgs!=.  //pledging price 15000 * conversion rate 0.0478 / 1000
}
if "`wave'"=="w8" {
	gen pprickgsD = (ppricekgs>=0.7) if ppricekgs!=.  //pledging price 15000 * conversion rate 0.0475 / 1000
}

collapse  (sum) paddrev paddkgsld _x42018 _x42019 _x4202* _x42036 e_* (max) pprickgsD, by(QID)   

drop _x42029a

foreach var of varlist e_* {
	replace `var'=0 if `var'==.
	winsor2 `var' , cut(0 97) replace
	label var `var' "Rice crop cultivation partly expenditures "
}

gen ppricekg = paddrev/paddkgsld
sum ppricekg, d

if "`wave'"=="w1" {
	gen ppricekgD = . // Pledging didn't exist back in wave 1.
}
if "`wave'"=="w2" {
	gen ppricekgD = (ppricekg>=0.7) if ppricekg!=.  //pledging price 14000 * conversion rate 0.0582 / 1000
}
if "`wave'"=="w3" {
	gen ppricekgD = (ppricekg>=0.7) if ppricekg!=.  //pledging price 14000 * conversion rate 0.0552 / 1000
}
if "`wave'"=="w5" {
	gen ppricekgD = (ppricekg>=0.7) if ppricekg!=.  //pledging price 15000 * conversion rate 0.0496 / 1000
}
if "`wave'"=="w6" {
	gen ppricekgD = (ppricekg>=0.7) if ppricekg!=.  //pledging price 15000 * conversion rate 0.0485 / 1000
}
if "`wave'"=="w7" {
	gen ppricekgD = (ppricekg>=0.7) if ppricekg!=.  //pledging price 15000 * conversion rate 0.0478 / 1000
}
if "`wave'"=="w8" {
	gen ppricekgD = (ppricekg>=0.7) if ppricekg!=.  //pledging price 15000 * conversion rate 0.0475 / 1000
}


label var ppricekg  "Average price for kg sold paddy rice"
label var ppricekgD  "Pledging - Average price is higher 14000 or 15000 per ton"
label var pprickgsD  "Pledging - Any seperate price is higher 14000 or 15000 per ton"
label var paddrev "Revenue from paddy rice sales"
label var paddkgsld "Amount of paddy rice sold"
label var _x42018 "Expenditures for land preparation: variable machine cost"
label var _x42019 "Expenditures for land preparation: hired labor incl. food, drinks"
label var _x42020 "Expenditures for seeds and seedlings and planting: seeds and seedlings"
label var _x42021 "Expenditures for seeds and seedlings and planting: hired labor incl. food, drinks"
label var _x42022 "Expenditures for hand weeding (hired labor)"
label var _x42023 "Expenditures for fertilizer application: materials"
label var _x42024 "Expenditures for fertilizer appliaction: hired labor incl. food, drinks"
label var _x42025 "Expenditures for pesticides: materials"
label var _x42026 "Expenditures for pesticides: hired labor incl. food, drinks"
label var _x42027 "Expenditures for harvesting including threshing: machinery cost"
label var _x42028 "Expenditures for harvesting including threshing: hired labor incl. food, drinks"
label var _x42029 "Irrigation expenditures"
label var _x42036 "Other expenditures (including processing)"

cd "${cleandata_`wave'}"
save crops3_temp, replace


cd "$data"
use merge_`wave', clear
merge 1:1 QID using "${cleandata_`wave'}/crops3_temp.dta"
drop if _merge==2 
drop _merge
erase "${cleandata_`wave'}/crops3_temp.dta"

cd "$data"
save merge_`wave', replace

if "`wave'"=="w6" | "`wave'"=="w7" {
	cd "${cleandata_`wave'}"
	erase cropsclean1.dta
}
}
*
***#######################THIS MIGHT BE FLAWED################################################




** MERGE TOTAL LAND PLANTED FROM CROP DATA **

foreach wave in w1 w2 w3 w5 w6 w7 w8{

if "`wave'"=="w1"{
	use "${cleandata_w1}/cropsclean", replace
	foreach root in 42004 42005 {
		replace _x`root'=. if _x`root'==97 // Replacing 97 with missing values as they are used as a label for 'Don't know'.
		replace _x`root'=. if _x`root'==98 // Replacing 98 with missing values as they are used as a label for 'no answer'.
		replace _x`root'=. if _x`root'==99 // Replacing 99 with missing values as they are used as a label for missing values/not applicable.
	}
}
else if "`wave'"=="w8"{
	use "${cleandata_`wave'}/crops_plots1", replace // Using the crops_plots1 dataset, because QID has been added.
	rename v42005 _x42005
	rename land_used__id _x42004 // 42004 (Planted on parcel number) ist hier land_used__id
	cap tostring QID, replace
}
else {
    use "${cleandata_`wave'}/cropsclean", replace
}

if "`wave'"=="w1" | "`wave'"=="w2" {
	replace _x42005=_x42005*6.25
}

rename _x42004 parcelid
rename _x42005 plantland


//reduce vars
keep plantland parcelid QID


// collapse (mean) plantland , by(QID parcelid) // Needs to be set as a comment, otherwise the next collapse line will somehow not always create the correct sum, if there are QIDs with small values in their plantland variables.

collapse (sum) plantland, by(QID)

replace plantland=0 if plantland==.

cd "${cleandata_`wave'}"
save crops_temp, replace

cd "$data"
use merge_`wave', clear
merge 1:1 QID using "${cleandata_`wave'}/crops_temp.dta"
drop if _merge==2 
drop _merge
erase "${cleandata_`wave'}/crops_temp.dta"


gen ricelandS = riceland/plantland
gen otherland = plantland- riceland

label var plantland  "Total area planted"
label var ricelandS  "Share of rice land of total area planted"
label var otherland  "Total area planted that is not planted with rice"

cd "$data"
save merge_`wave', replace

if "`wave'"=="w8" {
    cd "${cleandata_`wave'}"
	erase crops_plots1.dta
}
}
*



*****************************************************************************

** MERGE CROP STORAGE DATA **

foreach wave in w1 w2 w3 w5 w6 {

if "`wave'"=="w2" | "`wave'"=="w3" | "`wave'"=="w5" {
	use "${cleandata_`wave'}/storclean1", replace // Using the storclean1 dataset, because variable 42032 (Stored total crops in kg (all not just insured crops)) needed to be merged from the raw dataset (see merge_prep.do-file).
}

else {
	use "${cleandata_`wave'}/storclean", replace
	if "`wave'"=="w1" {
		foreach root in 42032 {
			replace _x`root'=. if _x`root'==97 // Replacing 97 with missing values as they are used as a label for 'Don't know'.
			replace _x`root'=. if _x`root'==98 // Replacing 98 with missing values as they are used as a label for 'no answer'.
			replace _x`root'=. if _x`root'==99 // Replacing 99 with missing values as they are used as a label for missing values/not applicable.
	}
}
}

collapse (sum) _x42032, by(QID)

cd "${cleandata_`wave'}"
save stor_temp, replace

cd "$data"
use merge_`wave', clear
merge 1:1 QID using "${cleandata_`wave'}/stor_temp.dta"
drop if _merge==2 
drop _merge
erase "${cleandata_`wave'}/stor_temp.dta"

replace _x42032=0 if _x42032==.

label var _x42032 "Stored total crops in kg  (all not just insured crops)"

cd "$data"
save merge_`wave', replace


if "`wave'"=="w2" | "`wave'"=="w3" | "`wave'"=="w5" {
    cd "${cleandata_`wave'}"
	erase storclean1.dta
}
}

*



** MERGE LIVE STOCK DATA **

cd "${cleandata_w5}"
copy livstclean.dta livestclean.dta, replace // Instead of 'livestclean' as in other waves, in wave 5 the dataset is called 'livstclean', so I'm creating a copy of the dataset with the usual name.

foreach wave in w1 w2 w3 w5 w6 w7 w8{

if "`wave'"=="w1"{
	use "${cleandata_w1}/livestclean"
	rename _x43110 _x43109a // In wave 1 variable 43110 has the definition of variable 43109a (value of livestock stocked) in other waves
	gen _x43103a = _x43109a / _x43109 * _x43103 // In wave 1 variable 43103a (value of livestock stocked at the beginning) isn't available, but can be created by dividing the variable (which was just rename to) 43109a (sales value of livestock stocked) with variable 43109 (stock at the end of the year) to get the value per one unit of the livestock stocked and multiplicating with variable 43103 (stock at the beginning of the year) to get a substitute for 43103a.
	gen _x43107a=. // Variable 43107a (Value of livestock and aquaculture home consumption)
	foreach root in 43103 43103a 43109 43109a {
		replace _x`root'=. if _x`root'==97 // Replacing 97 with missing values as they are used as a label for 'Don't know'.
		replace _x`root'=. if _x`root'==98 // Replacing 98 with missing values as they are used as a label for 'no answer'.
		replace _x`root'=. if _x`root'==99 // Replacing 99 with missing values as they are used as a label for missing values/not applicable.
	}
}
else if "`wave'"=="w8"{
    use "${cleandata_`wave'}/livest1", replace // Using the livest1 dataset, because the QID has been added to it.
	rename (v43103a v43107a v43109a) (_x43103a _x43107a _x43109a)
	cap tostring QID, replace
}
else {
    use "${cleandata_`wave'}/livestclean", replace
}

//lifestock indicator
gen _x43100_D=1

collapse (mean) _x43100_D (sum) _x43103a _x43107a _x43109a, by(QID)
cd "${cleandata_`wave'}"
save livest_temp, replace

cd "$data"
use merge_`wave', clear
merge 1:1 QID using "${cleandata_`wave'}/livest_temp.dta"
drop if _merge==2 
erase "${cleandata_`wave'}/livest_temp.dta"

replace _x43103a=0 if _merge==1
replace _x43109a=0 if _merge==1
replace _x43100_D=0 if _merge==1 // Otherwise these cases would be missing values and they get replaced with zeros here.

*gen _x43109_3= _x43109a - _x43103a

label var _x43103a  "Total value of livestock, beginning of period"
label var _x43107a "Total value of livestock and aquaculture home consumption"
label var _x43109a  "Total value of livestock, end of period"
label var _x43100_D "HH has lifestock"

*label var _x43109_3  "Change in value of livestock, over period (positive=increase)"

drop _merge
cd "$data"
save merge_`wave', replace

if "`wave'"=="w8" {
    cd "${cleandata_`wave'}"
	erase livest1.dta
}
}
*


** MERGE LIVESTOCK PRODUCTS  DATA **

foreach wave in w1 w2 w3 w5 w6 w7 w8{

if "`wave'"=="w1"{
	use "${cleandata_w1}/lstprodclean", replace
	gen _x43205a=. // Variable 43205a (Total value of livestock products home consumption) isn't available for wave 1.
}
else if "`wave'"=="w8"{
	use "${cleandata_`wave'}/livestock_product1", replace // Using the livestock_product1 dataset, because QID has been added.
	cap tostring QID, replace
	rename v43205a _x43205a
}
else {
    use "${cleandata_`wave'}/lstprodclean", replace
}

//livest prod indicator
gen _x43200_D=1

//no livest prod activities
gen _x43202n =1

collapse (mean) _x43200_D (sum) _x43202n _x43205a, by(QID)
cd "${cleandata_`wave'}"
save lstprod_temp, replace

cd "$data"
use merge_`wave', clear
merge 1:1 QID using "${cleandata_`wave'}/lstprod_temp.dta"
drop if _merge==2 
drop _merge
erase "${cleandata_`wave'}/lstprod_temp.dta"

replace _x43200_D=0 if _x43200_D==.
replace _x43202n=0 if _x43202n==.

label var _x43200_D  "HH has livestock products "
label var _x43202n  "Number of livestock product activities"
label var _x43205a "Total value of livestock products home consumption"

cd "$data"
save merge_`wave', replace

if "`wave'"=="w8" {
    cd "${cleandata_`wave'}"
	erase livestock_product1.dta
}
}
*


** MERGE HUNTING/COLLECTING/LOGGING  DATA **

foreach wave in w1 w2 w3 w5 w6 w7 w8{

if "`wave'"=="w8"{
	use "${cleandata_`wave'}/natres1", replace // The hunting dataset has a different name in wave 8 ('natres'). Using the natres1 dataset, because QID has been added.
	cap tostring QID, replace
}
else {
    use "${cleandata_`wave'}/huntingclean", replace
}

//hunting indicator
gen _x44000_D=1

//no of hunting activities
gen _x44002n =1

collapse (mean) _x44000_D (sum) _x44002n, by(QID)
cd "${cleandata_`wave'}"
save hunting_temp, replace

cd "$data"
use merge_`wave', clear
merge 1:1 QID using "${cleandata_`wave'}/hunting_temp.dta"
drop if _merge==2 
drop _merge
erase "${cleandata_`wave'}/hunting_temp.dta"

replace _x44000_D=0 if _x44000_D==.
replace _x44002n=0 if _x44002n==.

label var _x44000_D  "HH was Fishing/hunting/collecting/logging "
label var _x44002n  "Number of fishing/hunting/collecting/logging activities"

cd "$data"
save merge_`wave', replace

if "`wave'"=="w8" {
    cd "${cleandata_`wave'}"
	erase natres1.dta
}
}
*


** MERGE OFF-FARM EMPLOYMENT DATA **

foreach wave in w1 w2 w3 w5 w6 w7 w8{
    
if "`wave'"=="w6" | "`wave'"=="w7" {
    use "${cleandata_`wave'}/offemplclean", replace
	gen _x50027c=. // 50027c (Irregular bonuses) is now included in 50022 (Cash income (inc. regular + irregular bonuses)) in waves 6 and 7.
	gen _x50027b=. // 50027b (Free meals value) isn't included anymore in waves 6 and 7.
}
else if "`wave'"=="w8" {
    use "${cleandata_`wave'}/offempl1", replace // Using the offempl1 dataset, because QID has been added.
	rename (v51003 v51022 v51023 v51028 v51028a v51029) (_x50003 _x50022 _x50023 _x50028 _x50028a _x50029)
	gen _x50027c=. // 50027c (Irregular bonuses) is now included in 50022 (Cash income (inc. regular + irregular bonuses))
	gen _x50027b=. // 50027b (Free meals value) isn't included anymore in wave 8.
	cap tostring QID, replace
}
else {
    use "${cleandata_`wave'}/offemplclean", replace
	if "`wave'"=="w1"{
		foreach root in 50028 50029 50022 50023 50003 {
		replace _x`root'=. if _x`root'==97 // Replacing 97 with missing values as they are used as a label for 'Don't know'.
		replace _x`root'=. if _x`root'==98 // Replacing 98 with missing values as they are used as a label for 'no answer'.
		replace _x`root'=. if _x`root'==99 // Replacing 99 with missing values as they are used as a label for missing values/not applicable.
		}
	}

}

//offfarm indicator
gen _x50000_D=1

//no of off farm activities
gen _x50002n =1

//total hours
if "`wave'"=="w1"{
	gen _x50028hrsm=. 
	// rename __50003 _x50003 <- Not needed as the _x-prefix is already there
}
else{
	gen _x50028hrsm = (_x50028 * _x50028a * _x50029)/12
}

//income
if "`wave'"=="w1"{
	gen _x10087new=.
}
else{
	gen _x10087new = _x50022 if _x50023 ==5 | _x50023 ==6
	replace _x10087new = _x50022 * _x50029 if _x50023 ==4
	replace _x10087new = _x50022 * _x50029 * _x50028a if _x50023 ==2
	winsor2 _x50027c, c(0 99) replace
	mvencode _x10087new _x50027b _x50029 _x50028a, mv(0) override // Replacing missing values in _x10087new, _x50027b, _x50029 and _x50028a with zeros, because otherwise if there is a missing value in one or more of the four variables, the variable _x10087new that's created in the next line will become zero too. The option override needs to be used, because there are already zeros in these variables and Stata otherwise would stop as soon as it realizes.
	replace _x10087new = _x10087new + (_x50027b * _x50029 * _x50028a) + _x50027c if _x50027c!=.
*gen temp = (_x50011a * _x50029 * _x50028a) if _x50008a ==1
*winsor2 temp , c(0 97) replace
*replace _x10087new = _x10087new - temp if temp!=.
*drop temp
}
*

collapse (mean) _x50000_D (sum) _x50002n _x50028hrsm _x10087new, by(QID _x50003)

collapse (mean) _x50000_D (sum) _x50002n _x50028hrsm _x10087new (count) _x50003, by(QID) // works


cd "${cleandata_`wave'}"
save offempl_temp, replace

cd "$data"
use merge_`wave', clear
merge 1:1 QID using "${cleandata_`wave'}/offempl_temp.dta"
drop if _merge==2 
drop _merge
erase "${cleandata_`wave'}/offempl_temp.dta"

replace _x50000_D=0 if _x50000_D==.
replace _x50003=0 if _x50003==.
replace _x50002n=0 if _x50002n==.
replace _x50028hrsm=0 if _x50028hrsm==.
replace _x10087new=0 if _x10087new==.

label var _x50000_D  "HH has off-farm employment"
label var _x50003  "No of HH mem in off-farm employment"
label var _x50002n  "No of off-farm employment activities"
label var _x50028hrsm  "Total hours HH spend on off-farm employment activities"
label var _x10087new  "Total off-farm income"

if "`wave'"=="w1"{
	drop _x50028hrsm  _x10087new
}

cd "$data"
save merge_`wave', replace

if "`wave'"=="w8" {
    cd "${cleandata_`wave'}"
	erase offempl1.dta
}
}
*



** MERGE SELF-EMPLOYMENT DATA **

foreach wave in  w1 w2 w3 w5 w6 w7 w8{
    
if "`wave'"=="w1" {
	use "${cleandata_`wave'}/selfemplclean", replace
	foreach root in 60038 60039 { 
		replace _x`root'=. if _x`root'==97 // Replacing 97 with missing values as they are used as a label for 'Don't know'.
		replace _x`root'=. if _x`root'==98 // Replacing 98 with missing values as they are used as a label for 'no answer'.
		replace _x`root'=. if _x`root'==99 // Replacing 99 with missing values as they are used as a label for missing values/not applicable.
	}
}
else if "`wave'"=="w8" {
    use "${cleandata_`wave'}/selfempl1", replace // Using selfempl1, because QID has been added to it.
	rename (v61040b v61040a v61039) (_x60040b _x60040a _x60039)
	rename v61003__0 _x60003
	// 60038 (Average monthly cash profit/loss) will be created out of the variables v61029 (volume of sales per month) - v61021 (monthly payroll) - v61033 (costs for input purchases) as described on page 55 of the Questionair of wave 5. Missing values will be treated as zeros, because otherwise if one or more of the three variables used have missing values 60038 will also have a missing value.
	foreach x of varlist v61029 v61021 v61033 {
	    replace `x'=0 if missing(`x')
	}
	cap tostring QID, replace
	cap gen _x60038 = v61029 - v61021 - v61033
}
else {
    use "${cleandata_`wave'}/selfemplclean", replace
}

//self-empl indicator
gen _x60000_D=1

//no of  self-empl activities
gen _x60002n =1

//total hours
if "`wave'"=="w1"{
	gen _x60040hrsm=.
	// rename __60003 _x60003
}
else{
	gen _x60040hrsm = (_x60040b * _x60040a * _x60039)/12
}

//income
gen _x10088new =_x60038 * _x60039 

*


collapse (mean) _x60000_D (sum) _x60002n _x60040hrsm _x10088new, by(QID _x60003)

collapse (mean) _x60000_D (sum) _x60002n _x60040hrsm _x10088new (count) _x60003, by(QID) // works


cd "${cleandata_`wave'}"
save selfempl_temp, replace

cd "$data"
use merge_`wave', clear
merge 1:1 QID using "${cleandata_`wave'}/selfempl_temp.dta"
drop if _merge==2 
drop _merge
erase "${cleandata_`wave'}/selfempl_temp.dta"

replace _x60000_D=0 if _x60000_D==.
replace _x60003=0 if _x60003==.
replace _x60002n=0 if _x60002n==.
replace _x60040hrsm=0 if _x60040hrsm==.
replace _x10088new=0 if _x10088new==.

label var _x60000_D  "HH has self-employment"
label var _x60003  "No of HH mem in non-farm self-employment"
label var _x60002n  "No of self-farm employment activities"
label var _x60040hrsm  "Total hours HH spend on self-farm employment activities"
label var _x10088new  "Total self-employ income"

if "`wave'"=="w1"{
drop _x60040hrsm // _x10088new The variables for 10088 are available for wave 1 and have the same definition so I don't see a reason, why the variable should be deleted. Only the variables for _x60040hrsm are correctly stated as missing.
}

cd "$data"
save merge_`wave', replace

if "`wave'"=="w8" {
    cd "${cleandata_`wave'}"
	erase selfempl1.dta
}
}
*






*****************************************************************************


** MERGE ASSETS DATA **

foreach wave in w1 w2 w3 w5 w6 w7 w8 {

if "`wave'"=="w8" {
	cd "${cleandata_`wave'}"
	use asset_detail1.dta, replace // Using the asset_detail1.dta dataset, because QID and prov have been added as well as asset_detail__id (How many items does the HH own) has been corrected (see merge_prep.do-file).
	rename (v91009 v91008a assets__id asset_detail__id v10001) (_x91009 _x91008a _x91001 _x91002 prov)
	cap tostring QID, replace
}
else if "`wave'"=="w1" {
	cd "${cleandata_`wave'}"
	use assetsclean1.dta, replace // Using the assetsclean1 dataset, because a subtitute for variable 91009 (How much would you get if you sold all items today?) was built.
	rename _x10001 prov
	recode _x91008 (1=1) (.5=2) (0=3), gen(_x91008a) // The values of variable 91008 (Asset is used for productive purposes (share)) get changed so that they equal the definition of variable 91008a in the following waves. 1 stays 1 (mostly business use), .5 gets replace by 2 (business and private use) and 0 gets replaced by 3 (mostly private use).
	foreach root in 91009  { 
		replace _x`root'=. if _x`root'==97 // Replacing 97 with missing values as they are used as a label for 'Don't know'.
		replace _x`root'=. if _x`root'==98 // Replacing 98 with missing values as they are used as a label for 'no answer'.
		replace _x`root'=. if _x`root'==99 // Replacing 99 with missing values as they are used as a label for missing values/not applicable.
	}
}
else {
    cd "${cleandata_`wave'}"
	use assetsclean.dta, replace
}


gen _x91009_p = _x91009 if _x91008a <3
gen _x91009_a = _x91009 if _x91001 <=11 &_x91001!=5

gen _x91009_1 = _x91002 if _x91001==1
replace _x91009_1 =. if _x91009_1> 40000 // There are some outliers that will get deleted like this
gen _x91009_2 = _x91002 if _x91001==2
gen _x91009_3 = _x91002 if _x91001==3
gen _x91009_4 = _x91002 if _x91001==4
gen _x91009_6 = _x91002 if _x91001==6
gen _x91009_7 = _x91002 if _x91001==7
gen _x91009_8 = _x91002 if _x91001==8
gen _x91009_9 = _x91002 if _x91001==9
gen _x91009_10 = _x91002 if _x91001==10
gen _x91009_11 = _x91002 if _x91001==11


gen tv=(_x91001==26)

collapse (max) tv (sum) _x91009*, by(QID prov) // works



gen _x91009aS = _x91009_a/_x91009

drop prov

save asset_temp, replace

cd "$data"
use merge_`wave', clear
merge 1:1 QID using "${cleandata_`wave'}/asset_temp.dta"
drop if _merge==2 
drop _merge
erase "${cleandata_`wave'}/asset_temp.dta"


label var _x91009_1  "Number of Traktors 2 wheel"
label var _x91009_2  "Number of Traktors 4 wheel"
label var _x91009_3  "Number of Knapsackspray"
label var _x91009_4  "Number of Engine Spray"
label var _x91009_6  "Number of Water pump"
label var _x91009_7  "Number of Water tanks (field)"
label var _x91009_8  "Number of Pipes"
label var _x91009_9  "Number of Other farm tools"
label var _x91009_10 "Number of Rice Mill"
label var _x91009_11 "Number of Threshing Machine"

label var _x91009 "Total value of HH assets"
label var _x91009_p "Total value of productive HH assets (business or bus/private use)"
label var _x91009_a "Total value of agri HH assets"
label var _x91009aS "Share of agri HH assets value of total assets"
label var tv "Is 1 if household owns a TV"


cd "$data"
save merge_`wave', replace

if "`wave'"=="w1" {
    cd "${cleandata_`wave'}"
	erase assetsclean1.dta
}
if "`wave'"=="w8" {
    cd "${cleandata_`wave'}"
	erase asset_detail1.dta
}
}
*



** MERGE INVESTMENT DATA **

//investment

foreach wave in w3 w5 w6 w7 w8 {

if "`wave'"=="w6" | "`wave'"=="w7" {
	cd "${cleandata_`wave'}"
	use investclean1.dta, replace // Using investclean1, because T was added (see merge_prep.do-file).
}
else if "`wave'"=="w8" {
    cd "${cleandata_`wave'}"
	use invdetail1.dta, replace // Using invdetail1, because T has been added and variable 62006a (year) has been corrected.
	rename invest__id _x62003a
	foreach root in 62006a 62007 {
		cap rename  v`root' _x`root'
	}
}
else {
	cd "${cleandata_`wave'}"
	use investclean.dta, replace 
}
drop if T!=1

recode _x62003a (1=1) (14/23=1) (5/7=2) (40/48=2), gen(agriinvest)

if "`wave'"=="w3"{ 
	drop if _x62006a<2009
	drop if _x62006a==2009 & _x62006<10
}
else if "`wave'"=="w5"{
	drop if _x62006a<2012
	drop if _x62006a==2012 & _x62006<10
} 
else if "`wave'"=="w6"{
	drop if _x62006a<2015
	drop if _x62006a==2015 & _x62006<10
} 
else if "`wave'"=="w7"{
	drop if _x62006a<2016
	drop if _x62006a==2016 & _x62006<10
} 
else if "`wave'"=="w8"{
	drop if _x62006a<2018
	drop if _x62006a==2018 & _x62006<10
} 



gen _x62007_c= _x62007 if agriinvest==1
gen _x62007_a= _x62007 if agriinvest==2


collapse (sum) _x62007 _x62007_a _x62007_c, by(QID)   
label var _x62007  "Total value of HH investment last 7 months"
label var _x62007_c  "Total value of HH crop related investment last 7 months"
label var _x62007_a  "Total value of HH livestock related investment last 7 months"

tostring QID, replace
save invest_temp, replace


cd "$data"
use merge_`wave', replace
merge 1:1 QID using "${cleandata_`wave'}/invest_temp.dta"
drop if _merge==2 
drop _merge
erase "${cleandata_`wave'}/invest_temp.dta"


replace _x62007=0 if _x62007==.
replace _x62007_a=0 if _x62007_a==.
replace _x62007_c=0 if _x62007_c==.


cd "$data"
save merge_`wave', replace

if "`wave'"=="w6" | "`wave'"=="w7" {
	cd "${cleandata_`wave'}"
	erase investclean1.dta
}
if "`wave'"=="w8" {
	cd "${cleandata_`wave'}"
	erase invdetail1.dta
}
}


//disinvestment
foreach wave in w3 w5 w6 w7 w8{

if "`wave'"=="w8" {
    cd "${cleandata_`wave'}"
	use disinvdetail1.dta, replace // Using the disinvdetail dataset, because QID has been added.
	rename divest__id _x62016
	foreach root in 62017 {
		cap rename  v`root' _x`root'
	}
	cap tostring QID, replace
}
else if "`wave'"=="w3" {
    cd "${cleandata_`wave'}"
	use disinvestclean1.dta, replace // Using the disinvcestclean1 dataset, because the variables 62016 (divestment type) and 62017 (amount divestment) have been added (see merge_prep.do-file)
}
else {
	cd "${cleandata_`wave'}"
	use disinvestclean.dta, replace
}

recode _x62016 (1=1) (14/23=2) (5/7=2) (40/48=2), gen(agrdenvest) // Values 5/7 and 40/48 were added, because they're included in all waves and were also used in the investment part above.

gen _x62017_a= _x62017 if agrdenvest<=2

collapse (sum) _x62017_a, by(QID)

label var _x62017_a  "Total value of HH agri devestment"

save disinvest_temp, replace

cd "$data"
use merge_`wave', clear
merge 1:1 QID using "${cleandata_`wave'}/disinvest_temp.dta"
drop if _merge==2 
drop _merge
erase "${cleandata_`wave'}/disinvest_temp.dta"

replace _x62017_a=0 if _x62017_a==.

cd "$data"
save merge_`wave', replace

if "`wave'"=="w3" {
    cd "${cleandata_`wave'}"
	erase disinvestclean1.dta
}

if "`wave'"=="w8" {
    cd "${cleandata_`wave'}"
	erase disinvdetail1.dta
}
}
*





*****************************************************************************


** MERGE BORROWING DATA **

foreach wave in w1 w2 w3 w5 w6 w7 w8 {

if "`wave'"=="w8" {
    cd "${cleandata_`wave'}"
	use borr1.dta, replace // Using the borr1 dataset, because QID and prov have been added.
	gen _x71106a=2 if v71106__2==1 // In w8 v71106__2==1 equals _x71106a=2 in previous waves.
	replace _x71106a=4 if v71106__4==1 // In w8 v71106__4==1 equals _x71106a=4 in previous waves.
	gen _x71106b=. // There's no secondary loan usage (71106) that can be used in w8 (only specify_v71106, but the answers there are all in Thai.)
	rename v10001 prov
	foreach root in 71107 71119b {
		cap rename  v`root' _x`root'
	}
	cap tostring QID, replace
}
else if "`wave'"=="w1" {
    cd "${cleandata_`wave'}"
	use borrclean1.dta, replace // Using the borrclean1 dataset, because variable 71119 (remaining debt) was repaired (see 2.1.merging.do-file).
	gen _x71106b=. // Variable 71106b (secondary loan usage) doesn't exist for wave 1.
	rename _x10001 prov
	rename _x71106 _x71106a // Variables 71106a (For what did the household actually use the loan (most important usage)) and 71106b (For what did the household actually use the loan (second most important usage)) aren't available in wave 1, but 71106 (For what purpose did you borrow) is used as a substitute. Only one of the two variables needs to be replaced (in this case variable 71106a gets replaced) to create the variable 'agriloans'.
	foreach root in 71119b {
		replace _x`root'=. if _x`root'==97 // Replacing 97 with missing values as they are used as a label for 'Don't know'.
		replace _x`root'=. if _x`root'==98 // Replacing 98 with missing values as they are used as a label for 'no answer'.
		replace _x`root'=. if _x`root'==99 // Replacing 99 with missing values as they are used as a label for missing values/not applicable.
	}
}
else {
	cd "${cleandata_`wave'}"
	use borrclean.dta, replace
}

replace _x71107=. if _x71107==97 | _x71107==98 | _x71107==99 | _x71107==2 // Values 97, 98 and 99 are labels for "don't know" "no answer" and "not applicable" and 2 means "no".
gen loan_bc_shock =1 if _x71107==1

gen agriloans= 0
replace agriloans = _x71119b if _x71106a == 2 | _x71106b == 2 | _x71106a == 4 | _x71106b == 4


collapse (sum) _x71119b agriloans (min) loan_bc_shock, by(QID prov)

drop prov
save borr_temp, replace

cd "$data"
use merge_`wave', clear
merge 1:1 QID using "${cleandata_`wave'}/borr_temp.dta"
drop if _merge==2 
drop _merge
erase "${cleandata_`wave'}/borr_temp.dta"

replace _x71119b=0 if _x71119b==.
replace agriloans=0 if agriloans==.


cap gen agriloanD =(agriloans>0)


label var _x71119b "Total value of HH debt"
label var agriloans "Total value of HH debt related to agricultural expenses or investment"
label var agriloanD "HH has loan related to agricultural expenses or investment"
label var loan_bc_shock "Is 1 if HH took a loan because of a shock affecting the household"


cd "$data"
save merge_`wave', replace

if "`wave'"=="w1" {
    cd "${cleandata_`wave'}"
	erase borrclean1.dta
}
}
*
****************************************************************************

** MERGE MORE BORROWING DATA **

foreach wave in w2 w3 w5 w6 w7 w8 {

if "`wave'"=="w8" {
    cd "${cleandata_`wave'}"
	use borr1.dta, replace // Using the borr1 dataset, because QID and prov have been added.
	rename v10001 prov
	rename (v71109 v71119b) (_x71109 _x71119b)
	cap tostring QID, replace
}
else {
	cd "${cleandata_`wave'}"
	use borrclean.dta, replace
}

gen baacloans= 0
replace baacloans = _x71119b if _x71109 == 52 

gen polloans= 0
replace polloans = _x71119b if _x71109 == 51 | _x71109 == 53 | _x71109 == 54 | _x71109 == 55 | _x71109 == 56 | _x71109 == 57 | _x71109 == 58 

gen takloans= 0
replace takloans = _x71119b if _x71109 == 60 

/* if "`wave'"=="w5"{
replace baacloans=.
replace polloans=.
replace takloans=.
} */ // This was set as a comment. Wave 5 and the following waves can be used, because variables 71109 and 71119b are available for them and have the same definitions as for the previous waves.

collapse (sum) baacloans polloans takloans, by(QID prov)

drop prov
save borr2_temp, replace

cd "$data"
use merge_`wave', clear
merge 1:1 QID using "${cleandata_`wave'}/borr2_temp.dta"
drop if _merge==2 
drop _merge
erase "${cleandata_`wave'}/borr2_temp.dta"

replace baacloans=0 if baacloans==.
replace polloans=0 if polloans==.
replace takloans=0 if takloans==.

gen baacloanD =(baacloans>0)
gen polloanD =(polloans>0)
gen takloanD =(takloans>0)


label var baacloans "Total value of HH debt borrowed from BAAC"
label var polloans "Total value of HH debt borrowed from any socio-political organiztaion"
label var takloans "Total value of HH debt borrowed from Taksin Village Fund"
label var baacloanD "HH has loan borrowed from BAAC"
label var polloanD "HH has loan borrowed from any socio-political organiztaion"
label var takloanD "HH has loan borrowed from Taksin Village Fund"

cd "$data"
save merge_`wave', replace

if "`wave'"=="w8" {
    cd "${cleandata_`wave'}"
	erase borr1.dta
}
}
*


****************************************************************************

** MERGE SAVINGS DATA **

foreach wave in w1 w2 w3 w5 w6 w7 w8 {

if "`wave'"=="w8" {
	cd "${cleandata_`wave'}"
	use savings1.dta, replace // Using the savings1 dataset, because QID was added.
	gen _x71513=1 // wave 8 doesn't contain variable 71513 (Do HH members have any of the following kind of savings?). Therefore I create it by using variable 71414 (How much is the value of this kind of saving?) and setting 71513 = 1 if 71414 has a positive value and 0 if 71414 is 0 or has missing values.
	replace _x71513=0 if v71414==0 | v71414==.
	rename (v71414) (_x71514)
	cap tostring QID, replace
}
else {
	cd "${cleandata_`wave'}"
	use savclean.dta, replace
	if "`wave'"=="w1" {
		rename _x71501 _x71513 // Variable 71513 (Do HH members have any of the following kinds of savings?) doesn't exist for wave 1, but is replaced by variable 71501 (Do you have any savings).
		foreach root in 71514 { 
			replace _x`root'=. if _x`root'==97 // Replacing 97 with missing values as they are used as a label for 'Don't know'.
			replace _x`root'=. if _x`root'==98 // Replacing 98 with missing values as they are used as a label for 'no answer'.
			replace _x`root'=. if _x`root'==99 // Replacing 99 with missing values as they are used as a label for missing values/not applicable.
			}
	}
}

collapse (max) _x71513 (sum) _x71514, by(QID) // The mean of _x71513 was used but this wouldn't work. Instead the max get's used and if it's 1 the household has savings and if it's unequal 1, the household doesn't have savings, because 71513=1 means, that the houshold has savings and 71513=0 means, that the household doesn't have savings.
save sav_temp, replace


cd "$data"
use merge_`wave', clear
merge 1:1 QID using "${cleandata_`wave'}/sav_temp.dta"
drop if _merge==2 
drop _merge
erase "${cleandata_`wave'}/sav_temp.dta"

replace _x71513=0 if _x71513!=1 // This line and the next one were changed (See explanation in the "collapse" line above.)
replace _x71513=0 if _x71513==.
replace _x71514=0 if _x71514==.

label var _x71513  "Does HH have any kind of savings listed in the Qnr?"
label var _x71514  "Total value of HH savings"

if "`wave'"=="w2" {
    replace _x71119b=_x71119b/18.1013 // W2 PPP CONVERSION for 71119 needs to be done here already, otherwise the created variable wealth will be corrupted.
}

//gen wealth vars
replace _x91009=0 if _x91009==. // Setting missing values of variable 91009 to zero, because otherwise if there's a missing value in variable 91009, the variable wealth will have a missing value too.
replace _x71119b=0 if _x71119b==. // Setting missing values of variable 71119b to zero, because otherwise if there's a missing value in variable 71119b, the variable wealth will have a missing value too.
gen _wealth=  _x71514+ _x91009 - _x71119b
label var _wealth "Total savings  + total assets -total debt in HH"


cd "$data"
save merge_`wave', replace

if "`wave'"=="w8" {
    cd "${cleandata_`wave'}"
	erase savings1.dta
}
}
*




*****************************************************************************



** MERGE FARMER INCOME GUARANTEE TRANSFER DATA **

foreach wave in w3 {

if  "`wave'"=="w3" {
	cd "${cleandata_`wave'}"
	use transfraw.dta, replace // Using transfraw, because the transf dataset doesn't exist.
	rename __72103 _x72103
}

//rice insurance BURIRAM
gen riceisB_t =.
replace riceisB_t = 1 if __72102t== "agricultural products insurance project (rice, fruit)"
replace riceisB_t = 1 if __72102t== "income from agricultural products insurance project"
replace riceisB_t = 1 if __72102t== "insurance of income from agricultural products"
replace riceisB_t = 1 if __72102t== "rice insurance"
replace riceisB_t = 1 if __72102t== "insurance of rice's price"

gen riceisB_a = _x72103 if riceisB_t==1



//rice insurance WHOLE THAILAND (UPPER BOUND OF INDIVIDUALS receiving transfer) 
gen riceisT_t =riceisB_t 	//includes all rice transfers from Buriram
							//in other provs: rice transfer recorded under "other gov program"
							//so below I include all of these although half of them are probably "study for free" and "elictricity" program transfers
							//I try to exclude some of those below
replace riceisT_t = 1 if __72102t== "Other commune program"
replace riceisT_t = 1 if __72102t== "Other government program"
replace riceisT_t = 1 if __72102t== "other payments"
replace riceisT_t = 1 if __72102t== "other social assistence"
replace riceisT_t = 1 if __72102t== "other social security"

replace riceisT_t = . if _x72103 < 60 & prov!=31  	//we know from Buriram that rice insurance transfers are usually bigger than 60
													//so i exclude those here. this will take out probably most of the cases from the
													//"study for free" and 40% of the "electricity" programs
gen riceisT_a = _x72103 if riceisT_t==1
													
													
//rice insurance WHOLE THAILAND (LOWER BOUND OF INDIVIDUALS receiving transfer) 													
gen riceisTe_t =riceisT_t 							//to exclude all of the latter i increase the lower transf limit to 200
replace riceisTe_t = . if _x72103 < 200 & prov!=31

gen riceisTe_a = _x72103 if riceisTe_t==1


//disaster relief 
gen disarel_t =.
replace disarel_t = 1 if __72102t== "Social relief for natural disasters"
replace disarel_t = 1 if __72102t== "damage from flooding"
replace disarel_t = 1 if __72102t== "drought"
replace disarel_t = 1 if __72102t== "grant of flood insurance"
replace disarel_t = 1 if __72102t== "disaster relief package"

gen disarel_a = _x72103 if disarel_t==1

replace riceisB_t=0 if riceisB_t==. & prov==31
replace riceisB_a=0 if riceisB_a==. & prov==31


collapse (mean) riceisB_t disarel_t riceisT_t riceisTe_t (sum) riceisB_a disarel_a riceisT_a riceisTe_a, by(QID) // Seems to work except riceisB_t and riceisB_a, which only works for w3, because the values don't exist in other datasets and neither in the questionairs.

save transf_temp, replace

cd "$data"
use merge_`wave', clear
merge 1:1 QID using "${cleandata_`wave'}/transf_temp.dta"
drop if _merge==2 
drop _merge
erase "${cleandata_`wave'}/transf_temp.dta"


replace riceisT_t=0 if riceisT_t==.
replace riceisT_a=0 if riceisT_a==.
replace riceisTe_t=0 if riceisTe_t==.
replace riceisTe_a=0 if riceisTe_a==.
replace disarel_t=0 if disarel_t==.
replace disarel_a=0 if disarel_a==.

label var riceisB_t "Buriram..Indicator whether received rice insurance transfer"
label var riceisB_a "Buriram..Amount received rice insurance transfer"
label var riceisT_t "Thailand-upper bound of ind..Indicator whether received rice insurance transfer"
label var riceisT_a "Thailand-upper bound of ind..Amount received rice insurance transfer"
label var riceisTe_t "Thailand-lower bound of ind..Indicator whether received rice insurance transfer"
label var riceisTe_a "Thailand-lower bound of ind..Amount received rice insurance transfer"
label var disarel_t "Indicator whether received disaster relief transfer"
label var disarel_a "Amount received disaster relief transfer"



cd "$data"
save merge_`wave', replace

}

****************************************************************************

** MERGE CREDIT DEFAULT DATA **

foreach wave in w1 w2 w3 w5 w6 w7 w8 {

if "`wave'"=="w8" {
    cd "${cleandata_`wave'}"
	use default_ros1.dta, replace
	rename (v71214 v71215) (_x71414 _x71415)
	}
	
else if "`wave'"=="w2" {
	cd "${cleandata_`wave'}"
	use defhistclean1.dta, replace // Using the defhistclean1 dataset, because variable 71415 (Paid late/defaulted as a consequence of a shock) was added to it.
}

else {
	cd "${cleandata_`wave'}"
	use defhistclean.dta, replace
}


replace _x71415=0 if _x71415==2 // 71415==2 means the HH didn't default on a loan because of a shock and needs to be set zero, otherwise it would interfere with the variable default_sh that is created in the next block.

gen default=1 if _x71414==1
gen paylate=1 if _x71414==2
gen default_sh=1 if _x71415==1

collapse (max) default_sh (min) default paylate, by(QID)

save defhist_temp, replace

cd "$data"
use merge_`wave', clear
merge 1:1 QID using "${cleandata_`wave'}/defhist_temp.dta"
drop if _merge==2
drop _merge
erase "${cleandata_`wave'}/defhist_temp.dta"

label var default "Is 1 if HH defaulted on a loan"
label var paylate "Is 2 if HH paid late on a loan"
label var default_sh "Is 1 if HH defaulted on a loan because of a shock that affected the HH"

cd "$data"
save merge_`wave', replace
// I added these variables to the dataset, because they might be interesting to analyse.

if "`wave'"=="w2" {
    cd "${cleandata_`wave'}"
	erase defhistclean1.dta
}

if "`wave'"=="w8" {
    cd "${cleandata_`wave'}"
	erase default_ros1.dta
}
}

****************************************************************************

** MERGE FARMER INCOME GUARANTEE REGISTRATION DATA **

// No other waves can be integrated as this dataset only exists in wave 5 and doesn't apply to any other waves.

// cd "/Users/`c(username)'/Dropbox/Research/DFG_FOR576/2. Original Data/Thai HH Survey 2013/4. Data clean/w5_v2/" <- This filepath doesn't work
cd "$cleandata_w5"
use rinsur_withmissing.dta, replace

*cd "$cleandata_w5"
*use rinsur.dta, clear

replace _x72110 = 2010 if 3109070406 & _x72112==.
replace _x72110=2009 if _x72110==2010 & prov==48
drop if QID =="4801100802" | QID =="4805110503"

gen received_min= _x72113

replace _x72113=0 if _x72113==2 // For creating received_sum 72113==2 (Meaning the household didn't receive a compensation by the program) must be replaced by 0. Otherwise received_sum could in the end have values 3 and 4 and lead to confusion.

gen received_sum= _x72113

gen registered=1 if _x72112!=.

sort QID ID
bysort QID: gen year= _n
// gen registered09=1 if _x72112!=. & year==1 // <- There's no real difference to registered except that always the first observation of any given QID is used is now. But this doesn't mean that the year is 2009 then, because the first observation can also be 2010. So like this the variable doesn't actually tell if HH registered in 2009 as the name suggests? Correction follows in the next line
gen registered09=1 if _x72112!=. & _x72110==2009

cap rename yearnr year // Why this line? There is no variable called "yearnr"?
//gen whynotreg09=_x72111 if year==1 //<- This line needs to be corrected too
gen whynotreg09=_x72111 if _x72110==2009

//did farmer recieve compensation in 2009/10 period
//all
recode _x72110 (1 52  2552 5253 25552= 2009) (nonm=.), gen(year09) // x-prefix für 72210 hinzugefügt, da sonst Fehlermeldung erhalten.
tab year09
tab _x72113 if year09==2009
drop year09
//Buriram, where years are mostly in tact
recode _x72110 (1 52  2552 5253 25552= 2009) (nonm=.), gen(yearb) // x-prefix für 72210 hinzugefügt, da sonst Fehlermeldung erhalten.
replace yearb =. if prov!=31
tab  _x72113 if yearb==2009
drop yearb

collapse (sum) received_sum registered registered09 (min) received_min (firstnm) whynotreg09, by(QID prov) // works
replace registered=1 if registered>0 & registered!=.
replace registered09=1 if registered09>0 & registered09!=.
tab registered

replace received_min=0 if received_min >1


label define __72111 1 "did not know about it", modify
label define __72111 2 "forgot to do it", modify
label define __72111 3 "it was to much effort to go and register", modify
label define __72111 4 "do not trust the government", modify
label define __72111 5 "not satisfied in previous year", modify

label define __72111 10 "no farming/ rice farming", modify
label define __72111 11 "no land titel/person with land title registered", modify
label define __72111 12 "land is not enough/only ate rice but did not sell it", modify
label define __72111 13 "too complicated", modify
label define __72111 14 "The yield is not damaged/no drought", modify
label define __72111 15 "change of government", modify
label define __72111 16 "not willing to", modify
label var received_sum "Is 2 if the household received compensation from the PIS in both periods (05/2009-04/2010 and 05/2010-04/2011), is 1 if the household received compensation from the PIS in one of the two periods and is 0 if the household didn't receive compensation in any of the periods."
label var received_min "Is 1 if HH received compensation payments from the PIS between 2009 and 2011 and 0 if HH didn't receive it."
label var registered09 "Is 1 if HH registered for PIS"
label var whynotreg09 "Reason why HH didn't register for PIS"

label values whynotreg09 __72111
		

cd "$cleandata_w5"
save rinsur_temp, replace

cd "$data"
use merge_w5, clear
merge 1:1 QID using "$cleandata_w5/rinsur_temp.dta", force
drop if _merge==2 
drop _merge
erase "$cleandata_w5/rinsur_temp.dta"

*replace registered=0 if registered==.

cd "$data"
save merge_w5, replace



*****************************************************************************
*** SECTION 2.2d - CREATE PANEL  ********************************************

foreach wave in w1 w2 w3 w5 w6 w7 w8{

cd "$data"
use merge_`wave'

** CORRECT VAR NAMES **
foreach var of varlist * {
	rename  `var' `wave'`var'
}

rename `wave'T T
rename `wave'QID QID
if  "`wave'"=="w8" { // wave 8 doesn't contain the hhid, so the following renaming command needs to be skipped for wave 8.
}
else {
	rename `wave'hhid hhid
}
rename `wave'prov prov
rename `wave'vill vill
rename `wave'distr distr
rename `wave'subdistr subdistr

cap destring prov, replace
label values prov prov

cd "$data"
save merge_`wave', replace
}
*



** MERGE WAVES **
foreach wave in w3 w5 w6 {

cd "$data"
use merge_`wave'
cap tostring distr subdistr vill, force replace
save merge_`wave', replace
}

cd "$data"
use merge_w2, clear
//label values distr distr
merge 1:1 QID hhid using "merge_w3", nogen
merge 1:1 QID hhid using "merge_w5", nogen
merge 1:1 QID hhid using "merge_w6", nogen
merge 1:1 QID hhid using "merge_w7", nogen
merge 1:1 QID      using "merge_w8", keep (match master) nogen // w8 doesn't contain the hhid variable, so I'm not using it. QID alone is enough though, because it's a unique identifier. Has unmatched observations from merge_w8 (using dataset) which need to be dropped (keep (match master)). Otherwise there will be an error message following when trying to merge merge_w1 stating that hhid doesn't uniquely identify observations.
merge 1:1 QID hhid using "merge_w1"

drop if _merge==2 //drop obs that only exist for using dataset
drop _merge


** MERGE EXPENDITURES **

// merge 1:1 hhid  using "$cleandata_w5/cons_agg.dta",  nogen force keepusing(*total *cap_total) // <- cons_agg dataset is missing!

** MERGE INCOME DATA**
//w1
merge 1:1 QID using "$cleandata_w1/hhInc2clean1.dta", keepusing(_x10080 _x10081 _x10082 _x10083  _x10084 _x10085 _x10086 _x10087 _x10088 _x10091 _x10092 _x10093 _x10094 _x10100 _x10101) // Using hhInc2clean1, because , because variables had values 97, 98 and 99 as labels for "Don't know", "no answer", "and missing values/not applicable". Also variable 10093 (Value of transfer payments received) needed to be repaired.
drop if _merge==2 //keep only hh which were existent in master data before merge
drop _merge
drop if T!=1
erase "$cleandata_w1/hhInc2clean1.dta"

foreach root in 10080 10081 10082 10083 10084 10085 10086 10087 10088 10091 10092 10093 10094 10100 10101 {
	cap rename _x`root' w1_x`root'
} // The variables dont need the _x-prefix anymore as the clean dataset was used, but they still need the w1_-prefix which is added in this loop.
*

drop if QID=="41113090314"
drop if QID=="41117150209"

//w2 w3
merge 1:1 QID using "$cleandata_w3/hhinc_w3_w2clean1.dta", keepusing(w2_x10080 w2_x10081 w2_x10082 w2_x10083 w2_x10084 w2_x10085 w2_x10086 w2_x10087 w2_x10088 w2_x10091 w2_x10092 w2_x10093 w2_x10094 w2_x10100 w2_x10101 _x10080 _x10081 _x10082 _x10083 _x10084 _x10085 _x10086 _x10087 _x10088 _x10091 _x10092 _x10093 _x10094 _x10100 _x10101)
drop if _merge==2 //keep only householdss which were existent in master data before merge
drop _merge
drop if T!=1
erase "$cleandata_w3/hhinc_w3_w2clean1.dta"

foreach root in 10080 10081 10082 10083 10084 10085 10086 10087 10088 10091 10092 10093 10094 10100 10101 {
	cap rename  _x`root' w3_x`root'
}

//w6: 10091 isn't available
merge 1:1 QID using "$cleandata_w6/hhincclean1.dta", keepusing(_x10080 _x10081 _x10082 _x10083 _x10084 _x10085 _x10086 _x10087 _x10088 /*_x10091*/ _x10092 _x10093 _x10094 _x10100 _x10101)
drop if _merge==2
drop _merge
drop if T!=1
erase "$cleandata_w6/hhincclean1.dta"

foreach root in 10080 10081 10082 10083 10084 10085 10086 10087 10088 /*10091*/ 10092 10093 10094 10100 10101 {
	cap rename  _x`root' w6_x`root'
}

//w7: 10091 isn't available
merge 1:1 QID using "$cleandata_w7/hhincclean1.dta", keepusing(_x10080 _x10081 _x10082 _x10083 _x10084 _x10085 _x10086 _x10087 _x10088 /*_x10091*/ _x10092 _x10093 _x10094 _x10100 _x10101)
drop if _merge==2
drop _merge
drop if T!=1
erase "$cleandata_w7/hhincclean1.dta"

foreach root in 10080 10081 10082 10083 10084 10085 10086 10087 10088 /*10091*/ 10092 10093 10094 10100 10101 {
	cap rename  _x`root' w7_x`root'
}

//w8: 10101 isn't available
merge 1:1 QID using "$cleandata_w8/hhincclean.dta", keepusing(_x10080 _x10081 _x10082 _x10083 _x10084 _x10085 _x10086 _x10087 _x10088 _x10091 _x10092 _x10093 _x10094 _x10100 /*__10101*/)
drop if _merge==2
drop _merge
drop if T!=1
erase "$cleandata_w8/hhincclean.dta"

foreach root in 10080 10081 10082 10083 10084 10085 10086 10087 10088 10091 10092 10093 10094 10100 /*10101*/ {
	cap rename  _x`root' w8_x`root'
}

*
cd "$data"
saveold dataset_v1, replace //$ sign before 'dataset_v1' threw an error 'invalid file specification'. According to the Stata helpfile after saveold the name under which the dataset will be saved should follow. This means the dollar sign can't be used there as it is a reference to a macro, which can't be part of a filename.

//w5
cd "$cleandata_w5"
use hhincclean1.dta, clear // Using hhInc2clean1, because variable 10094 (Compensation payments received from insur. in reference period in PPP$) was corrected.
tostring QID, replace force
drop if T!=1
save hhinc_temp.dta, replace
erase "$cleandata_w5/hhincclean1.dta"

cd "$data"
use dataset_v1, clear // $ sign before 'dataset_v1' needed to be removed
merge 1:1 QID using "$cleandata_w5/hhinc_temp.dta", keepusing(_x10080 _x10081 _x10082 _x10083 _x10084 _x10085 _x10086 _x10087 _x10088 _x10091 _x10092 _x10093 _x10094 _x10100 _x10101)
drop if _merge==2 //keep only hh which were existent in master data before merge
drop _merge
drop if T!=1

foreach root in 10080 10081 10082 10083 10084 10085 10086 10087 10088 10091 10092 10093 10094 10100 10101 {
	cap rename  _x`root' w5_x`root'
}

cd "$cleandata_w5"
erase hhinc_temp.dta
*



** ALTERNATIVE INCOME **
drop *10088 *10087
rename *10088new *10088
rename *10087new *10087

//creat income occurance dummies
foreach var of varlist  w1_x1008* w2_x1008* w3_x1008* w5_x1008* w6_x1008* w7_x1008* w8_x1008*  *_x10093 {
	gen `var'_D = (`var'!=0) if `var'!=.
}

foreach wave in w1 w2 w3 w5 w6 w7 w8 {
	label var `wave'_x10080_D "Dummy variable for 'Remittances received (from absent or non-nucleus hh members)'"
	label var `wave'_x10081_D "Dummy variable for 'Remittances received from friends/relatives'"
	label var `wave'_x10082_D "Dummy variable for 'Income from house and homestead (imputed rental value)'"
	label var `wave'_x10083_D "Dummy variable for 'Income from land rent'"
	label var `wave'_x10084_D "Dummy variable for 'Income from crop production'"
	label var `wave'_x10085_D "Dummy variable for 'Income from livestock'"
	label var `wave'_x10086_D "Dummy variable for 'Income from hunting'"
	label var `wave'_x10093_D "Dummy variable for 'Compensation payments received in reference period'"
}
foreach wave in w2 w3 w5 w6 w7 w8 {
	label var `wave'_x10087_D "Dummy variable for 'Income from nat. resource extraction'"
	label var `wave'_x10088_D "Dummy variable for 'Income from off-farm (self)-employment"
}
foreach wave in w6 w7 {
	label var `wave'_x10101 "Total annual household income per nucleus member"
}

** REPAIRE **
drop  w1_x31005b w1_x41009a  w1ownlandv w1_x43103a w1seedsres w1ricelandv // w1_31005b: Variable doesn't exist for wave 1; w1_41009a, w1ownlandv (made from w1_41009a): Only 41009 exists as an alternative, but it states the land value at the acquisition point, but not the current value; w1_x43103a: Variable doesn't exist for this wave, but a relatively good alternative could be calculated; w1seedsres: Variable needed doesn't exist for wave 1. w1ricelandv was added to be dropped for the same reasons as for variables 41009a and ownlandv.
drop if hhid==4578
drop if hhid==4577
rename w5registered w3registered //name is changed, because registration actually took place in wave 3 and not wave 5
// rename w1_x43109a w1_x43109 // Wave 1 was integrated in MERGE LIVE STOCK DATA and 43109a exists therefore for w1
destring vill, replace
label values vill vill


** W1 PPP CONVERSION **
foreach var in  w1_x31005 w1_x31006 w1_x10080 w1_x10081 w1_x10082 w1_x10083 w1_x10084 w1_x10085 w1_x10086 w1_x10087 w1_x10088 w1_x10091 w1_x10092 w1_x10093 w1_x10094 w1_x10100 w1_x10101 w1_x42018 w1_x42019 w1_x42020 w1_x42021 w1_x42022 w1_x42023 w1_x42024 w1_x42025 w1_x42026 w1_x42027 w1_x42028 w1_x42029 w1_x43109a w1_x71119b w1_x91009 w1_x91009_a w1_x91009_p w1e_fertil w1e_harvest w1e_irrig w1e_lndprep w1e_pestiz w1e_seeds w1expend w1flood_5a1 w1flood_5a2 w1hiredlab w1_wealth w1agriloans w1paddrev w1ricerev w1pricekg w1ppricekg w6riceisT_a {
	cap confirm variable `var'
	if !_rc {
		replace `var'=`var'/17.17
	}
}

** W2 PPP CONVERSION **
foreach var in w2agriloans w2polloans w2takloans w2baacloans {
	cap confirm variable `var'
	if !_rc {
		replace `var'=`var'/18.1013
	}
}

** W5 PPP CONVERSION **
foreach var in  w5ownlandv w5ricelandp w5ricelandv w5_x41009a {
	cap confirm variable `var'
	if !_rc {
		replace `var'=`var'/20.6143
	}
}

** W6 PPP CONVERSION **
foreach var in  w6_x31005a w6_x31005b w6_x31006a w6_x31025 w6flood_5a1 w6flood_5b1 w6flood_6a1 w6flood_5a2 w6flood_5b2 w6flood_6a2 /*w6_x41009a*/ w6ownlandv w6ricelandv w6ricelandp w6expend w6hiredlab w6ricerev w6pricekg w6paddrev w6_x42018 w6_x42019 w6_x42020 w6_x42021 w6_x42022 w6_x42023 w6_x42024 w6_x42025 w6_x42026 w6_x42027 w6_x42028 w6_x42029 w6_x42036 w6e_lndprep w6e_seeds w6e_fertil w6e_pestiz w6e_harvest w6e_irrig w6ppricekg w6_x43103a w6_x43109a w6_x10087 w6_x10088 w6_x91009 w6_x91009_p w6_x91009_a w6_x62007 w6_x62007_a w6_x62007_c w6_x62017_a w6_x71119b w6agriloans w6baacloans w6polloans w6takloans w6_x71514 w6_wealth w6disarel_a w6riceisT_a w6riceisTe_a w6_x10080 w6_x10081 w6_x10082 w6_x10083 w6_x10084 w6_x10085 w6_x10086 /*w6_x10091*/ w6_x10092 w6_x10093 w6_x10094 w6_x10100 w6_x10101 w6_x43107a w6_x43205a {
	cap confirm variable `var'
	if !_rc {
		replace `var'=`var'/20.8993
	}
}

** W7 PPP CONVERSION **
foreach var in  w7_x31005a w7_x31005b w7_x31006a w7_x31025 w7flood_5a1 w7flood_5b1 w7flood_6a1 w7flood_5a2 w7flood_5b2 w7flood_6a2 /*w7_x41009a*/ w7ownlandv w7ricelandv w7ricelandp w7expend w7hiredlab w7ricerev w7pricekg w7paddrev w7_x42018 w7_x42019 w7_x42020 w7_x42021 w7_x42022 w7_x42023 w7_x42024 w7_x42025 w7_x42026 w7_x42027 w7_x42028 w7_x42029 w7_x42036 w7e_lndprep w7e_seeds w7e_fertil w7e_pestiz w7e_harvest w7e_irrig w7ppricekg w7_x43103a w7_x43109a w7_x10087 w7_x10088 w7_x91009 w7_x91009_p w7_x91009_a w7_x62007 w7_x62007_a w7_x62007_c w7_x62017_a w7_x71119b w7agriloans w7baacloans w7polloans w7takloans w7_x71514 w7_wealth w7disarel_a w7riceisT_a w7riceisTe_a w7_x10080 w7_x10081 w7_x10082 w7_x10083 w7_x10084 w7_x10085 w7_x10086 /*w6_x10091*/ w7_x10092 w7_x10093 w7_x10094 w7_x10100 w7_x10101 w7_x43107a w7_x43205a {
	cap confirm variable `var'
	if !_rc {
		replace `var'=`var'/21.0573
}
}

** W8 PPP CONVERSION **
foreach var in  w8_x31005a w8_x31005b w8_x31006a w8_x31025 w8flood_5a1 w8flood_5b1 w8flood_6a1 w8flood_5a2 w8flood_5b2 w8flood_6a2 w8_x41009a w8ownlandv w8ricelandv w8ricelandp w8expend w8hiredlab w8ricerev w8pricekg w8paddrev w8_x42018 w8_x42019 w8_x42020 w8_x42021 w8_x42022 w8_x42023 w8_x42024 w8_x42025 w8_x42026 w8_x42027 w8_x42028 w8_x42029 w8_x42036 w8e_lndprep w8e_seeds w8e_fertil w8e_pestiz w8e_harvest w8e_irrig w8ppricekg w8_x43103a w8_x43109a w8_x10087 w8_x10088 w8_x91009 w8_x91009_p w8_x91009_a w8_x62007 w8_x62007_a w8_x62007_c w8_x62017_a w8_x71119b w8agriloans w8baacloans w8polloans w8takloans w8_x71514 w8_wealth w8disarel_a w8riceisT_a w8riceisTe_a w8_x10080 w8_x10081 w8_x10082 w8_x10083 w8_x10084 w8_x10085 w8_x10086 w8_x10091 w8_x10092 w8_x10093 w8_x10094 w8_x10100 /*w8_x10101*/ w8_x43107a w8_x43205a {
	cap confirm variable `var'
	if !_rc {
		replace `var'=`var'/21.6067
	}
}

*
*****************************************************************************

note: "JZ: v1: completed data set, ready for analysis. cleaned and megred with hh data variables. merged with village level data. all village level var names are indicated with v_..."

destring subdistr, replace
label values subdistr subdistr


cd "$data"
saveold dataset_v1, replace

erase merge_w1.dta
erase merge_w2.dta
erase merge_w3.dta
erase merge_w5.dta
erase merge_w6.dta
erase merge_w7.dta
erase merge_w8.dta

// Deleting leftover temporary files that aren't needed anymore


* to do: write protect data  

* smth wrong with w5_x10093 and w1expend

*NOTE: var names cannot have more than 9 digits!


