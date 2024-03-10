*** DO-FILE:       Preparation **********************************************
*** PROJECT NAME:  Master's Thesis ******************************************
*** DATE: 		   28.12.2023 ***********************************************
*** AUTHOR: 	   JG + JZ **************************************************

* Note: The purpose of this do-file is to prepare the data for analysis


*****************************************************************************
*** SECTION 2.3.0 - PREPARATION FOR ANALYSIS ********************************

set more off

** RUN SETTINGS **
clear
// cd "/Users/`c(username)'/Dropbox/Research/DFG_FOR576/3. Research/Rice Insurance/2. STATA/do" 
macro drop _all
// do 2.1.settings.do Add 09.11.: Not needed as the settings are in the master.do-file <- Update: No, they're set in this file in the next blocks

global home "//tsclient/C/Users/Julian/Dropbox/Rice Long-term"


global 	rawdata			"$home/0_Original_data" //store original data here
global 	ado 			"$home/2_STATA/ado" //user-written ado's and self-written programs
global 	data 			"$home/2_STATA/data" //whenever you save data, do it here
global 	do 				"$home/2_STATA/do/_Julian neu" //all do-files go here, numbered in logical order

global 	graph 			"$home/2_STATA/graph" //all graphs go here
global 	output			"$home/2_STATA/output" //result tables, log files, etc.

sysdir set PERSONAL 	"$ado"

global cleandata_w1 "$rawdata/wave_1_2007_TH_Stata"
global cleandata_w2 "$rawdata/wave_2_2008_TH_Stata"
global cleandata_w3 "$rawdata/wave_3_2010_TH_Stata"
global cleandata_w5 "$rawdata/wave_5_2013_TH_Stata"
global cleandata_w6 "$rawdata/wave_6_2016_TH_Stata"
global cleandata_w7 "$rawdata/wave_7_2017_TH_Stata"
global cleandata_w8 "$rawdata/wave_8_2019_dataset_V2"

global merge_w1 "$data/merge_w1"
global merge_w2 "$data/merge_w2"
global merge_w3 "$data/merge_w3"
global merge_w5 "$data/merge_w5"
global merge_w6 "$data/merge_w6"
global merge_w7 "$data/merge_w7"
global merge_w8 "$data/merge_w8"

// global dataset_v2 "$home/2_STATA/data/dataset_v2"
*add to merge do:

* varnames cannot be more than 9 characters long

* shares should be denoted as shares by a final "S"

***
*change the bobs variable back to share in merge file

cd "$data"
use dataset_v1, clear

cap drop distr subdistr // cap added for now, because otherwise this do-file can't be run isolated if it was run before and distr and subdistr are deleted already


** SAMPLE **
keep if w2insurcrops==1 //rice farmer
keep if w3reg!=.
keep if T==1
*keep if prov==31
*drop prov




** MVs DUE TO CHANGE IN RICE CULTIVATION STATUS OVER THE YEARS **
foreach var of varlist w1expend w1hiredlab w1ricekgsld w1ricekgtot w1ricekgrai w1riceland w1ricelandS w1ricelando w1sharesold {
replace `var'=0 if `var'==.
}
/*
foreach var of varlist w2expend w2hiredlab w2ricekgsld w2ricekgtot w2ricekgrai w2riceland w2ricelandS w2ricelando w2seedsres w2sharesold {
replace `var'=0 if `var'==.
*/
foreach var of varlist w3expend w3hiredlab w3ricekgsld w3ricekgtot w3ricekgrai w3riceland w3ricelandS w3ricelando w3seedsres w3sharesold {
replace `var'=0 if `var'==.
}
foreach var of varlist w5expend w5hiredlab w5ricekgsld w5ricekgtot w5ricekgrai w5riceland w5ricelandS w5ricelando w5seedsres w5sharesold {
replace `var'=0 if `var'==.
}
foreach var of varlist w6expend w6hiredlab w6ricekgsld w6ricekgtot w6ricekgrai w6riceland w6ricelandS w6ricelando w6seedsres w6sharesold {
replace `var'=0 if `var'==.
}
foreach var of varlist w7expend w7hiredlab w7ricekgsld w7ricekgtot w7ricekgrai w7riceland w7ricelandS w7ricelando w7seedsres w7sharesold {
replace `var'=0 if `var'==.
}
foreach var of varlist w8expend w8hiredlab w8ricekgsld w8ricekgtot w8ricekgrai w8riceland w8ricelandS w8ricelando w8seedsres w8sharesold {
replace `var'=0 if `var'==.
}
*



** OUTLIERS **
cd "$do"
do 2.3.1.outliers.do
//Alternative transformation for skewed variables with neagtive values:
*gen varC= sign(var) * (abs(var))^(1/3)
cd "$data"
save dataset_v2, replace


*neglog transformation (Withaker 2005):
*sign(x) ln(|x| + 1)
*see: http://www.stata.com/statalist/archive/2010-02/msg01283.html

*de-zeroing variables and log them
*lnskew0
*bcskew0




* IMPUTE ** ATTENTION: command impute2 does not exist in web anymore
cd "$do"
do 2.3.0.ylists.do
do 2.3.0.xlists.do




** PRICE **
foreach wave in w2 w3 w5 w6 w7 w8 {
replace `wave'pricekg =. if `wave'ricekgsld==0 //corrects if prices were imputetd or set to zero
replace `wave'ppricekg =. if `wave'paddkgsld==0 //where actually no rice was sold
sum *pricekg *kgsld
}


*winsor2 w2pricekg w3pricekg w5pricekg , replace 
*winsor2 w5pricekg , replace cut(0 97)

** INCOME AGGREGATE **

//generate total income with outlier cleaned income variables
//dont generate w1income as it somewhat differs from other waves
foreach wave in w1 w2 w3 w5 w6 w7 w8 {
	if "`wave'"=="w1" { // Attention: Self-Employment income (10087) is missing for wave 1, because variable doesn't exist/can't be calculated, as the variable that gives amounts of days worked is missing.
		egen `wave'income = rowtotal(`wave'_x10080  `wave'_x10084 `wave'_x10085 `wave'_x10086 `wave'_x10088)
		winsor2 `wave'income, c(0 99) replace
	}
	else {
		egen `wave'income = rowtotal(`wave'_x10080  `wave'_x10084 `wave'_x10085 `wave'_x10086 `wave'_x10087 `wave'_x10088)
		winsor2 `wave'income, c(0 99) replace
	}
}
*`wave'_x10081 `wave'_x10082 `wave'_x10083 `wave'_x10091 `wave'_x10092 `wave'_x10093 `wave'_x10094
*lnskew0 transform?

foreach wave in w1 w2 w3 w5 w6 w7 w8 {
	foreach var in `wave'_x31005a `wave'_x10080 `wave'_x10081 `wave'_x10082 `wave'_x10083 `wave'_x10084 `wave'_x10085 `wave'_x10086 `wave'_x10087 `wave'_x10088 `wave'_x10091 `wave'_x10092 `wave'_x10093 `wave'_x10094 { 

cap confirm variable `var'L 
if !_rc {
}
else {
		cap gen `var'L=`var'
		cap lab var `var'L "LOG `: var lab `var''"		
		cap replace `var'L =`var'L +1 //0.1
		cap replace `var'L =log(`var'L)
}
}	
}	
*		

** RICH POOR DUMMY BASELINE **
sum w2income, d
gen w2richD50 = (w2income>r(p50)) if w2income!=.



** INDICES **
*Bandiera et al 2017: Women`s Empwmnt in Action:
*The index is constructed by converting each component into a z-score, 
*averaging these and taking the z-score of the average. z-scores for each 
*component are computed using means and standard deviations in control 
*communities at baseline (and the z-score averaged by treatment group is imputed 
*for missing values).

//rice production index
foreach wave in w2 w3 w5 w6 w7 w8 w1 {
foreach var in ricekgtotL expendL ricelandL _x91009_aL {
sum w2`var' if w3registered==1
gen z_`wave'`var' = (`wave'`var' - r(mean))/r(sd)
}
egen `wave'temp= rowtotal(z_`wave'*)
replace `wave'temp= `wave'temp/4
sum w2temp if w3registered==1 
gen `wave'rice_index = (`wave'temp - r(mean))/r(sd)
drop z_`wave'*
}
drop *temp

//activity diversification index
foreach wave in w1 w2 w3 w5 w6 w7 w8{
egen `wave'iga_index = rowtotal( `wave'_x43202n `wave'_x44002n `wave'_x50002n `wave'_x60002n )
}
*


do 2.3.2.impute.do //make sure that all outcome vars and pscore vars are imputed. Was changed to this line, because before the imputation the variables income, rice_index and iga_index have to be created.


** FINAL DATA SET **
cd "$do"

gen w6n60borgov=. // The following variables aren't available for waves 6-8.
gen w6n60relfr=.
gen w7n60borgov=.
gen w7n60relfr=.
gen w8n60borgov=.
gen w8n60relfr=.

keep $ylistw5 $ylistw3 $ylistw2 $ylistw6 $ylistw7 $ylistw8 $noimpute_ylistw5 $noimpute_ylistw3 $noimpute_ylistw2 $noimpute_ylistw6 $noimpute_ylistw7 $noimpute_ylistw8 $xlist $xlist_balance $treatment w5whynotreg09 QID T hhid prov vill *_x1008* *_x1009* 


cd "$data"
save dataset_v2, replace



** PREPARE 2.ORDER VARS **
cd "$do"
do 2.3.3.secorder.do
cd "$data"
saveold dataset_v2, replace
