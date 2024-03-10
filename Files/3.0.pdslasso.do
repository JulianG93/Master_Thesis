*** DO-FILE:       PDSLasso *************************************************
*** PROJECT NAME:  Master's Thesis ******************************************
*** DATE: 		   28.12.2023 ***********************************************
*** AUTHOR: 	   JG *******************************************************

* Note: The purpose of this do-file is to perform the analysis using the PDS Lasso

*****************************************************************************
*** SECTION 3.0 - PDSLASSO **************************************************

global LaTeX			"//ug-uyst-ba-cifs.student.uni-goettingen.de/home/users/julian.grotzfeld/Desktop/Thesis/LaTeX/thesis-template"

// lassopack helpfile: https://statalasso.github.io/docs/pdslasso/ivlasso_help/
// lassopack needs to be installed:
cap which pdslasso
if _rc ssc install pdslasso


// sxpose needs to be installed for transposing (string) matrices
cap which sxpose
if _rc ssc install sxpose

// listtex is needed to save files in .tex format from within stata
cap which listtex
if _rc ssc install listtex


// texdoc needs to be installed to write LaTeX code from within stata
cap which texdoc
if _rc ssc install texdoc

*******************************************************************************

// Running the PDS-Lasso-Regression with the 36 variables from the xlists.do-file without control variables for waves 3 and 5 for comparison of the PDS-Lasso-Regression with the results of Juliane's PSM approach.


// Creating variables that are missing for certain waves, but are needed to run the regression without throwing an error or replacing variables with 0 that otherwise only contain missing values, because this also throws an error otherwise.
cd "$data"
use dataset_v2, clear

// Creating Δyt-1 for the ylist-variables (=outcome variables) by substracting the values of the outcome variables of wave 2 from waves 3 to 8
foreach wave in w3 w5 {
	foreach var in $ylist {
		gen `wave'd`var' = `wave'`var'- w2`var'
	}
}

// Creating varlists for the delta values of the ylist-variables (outcome variables)
foreach wave in w3 w5 {
	unab `wave'_delta: `wave'd*
	dis "``wave'_delta'"
}

keep w3d* w5d* w3registered $xlist_base $xlist_all

gen dollar = "$"

// Creating regression result tables that look comparable to the ones in the original paper coefficient values, p-values and standard deviations of the coefficient values have to be extracted
foreach wave in w3 w5 {
	foreach var in ``wave'_delta' {
		pdslasso `var' w3registered $xlist_base $xlist_all, robust // Performing the PDS-Lasso regression. The robust option leads to heteroskedasticity-consistent standard errors, see help pdslasso, which shows the PDS-Lasso help file.
		matrix `var'values = r(table) // Preparing the needed results to be extracted
		preserve
		gen `var'coeff = `var'values[1,1] // This line extracts the coefficient values
		gen `var'coeffpval = `var'values[4,1] // This line extracts the p-values of the coefficient values
		gen `var'1 = strofreal(`var'coeff,"%5.3f") // Adding p-value stars to the coefficient values
		replace `var'1= dollar + `var'1 + "^{***}" + dollar if `var'coeffpval <= 0.01
		replace `var'1= dollar + `var'1 + "^{**}" + dollar if `var'coeffpval > 0.01 & `var'coeffpval <= 0.05
		replace `var'1= dollar + `var'1 + "^{*}" + dollar if `var'coeffpval > 0.05 & `var'coeffpval <= 0.1
		gen `var'stderr = `var'values[2,1] // This line extracts the standard errors of the coefficient values
		gen `var'2 = strofreal(`var'stderr,"%5.3f") // Putting the standard errors in parentheses
		replace `var'2 = "("+ `var'2 + ")"
		gen name = "`var'" // Creating a variable with the name of the variable (needed for transposing later)
		keep `var'1 `var'2 name
		keep in 1 // The first value is always kept. (Values are always the same, but only needed once)
		rename `var'1 coeff
		rename `var'2 stddev
		order name // Variables are ordered alphabetically which later simplifies the creation of the regression tables
		save `var'.dta, replace // A dataset with the variable name is stored for each variable and contains the coefficent values, p-values and standard errors
		restore
		}
}

drop* // The previously created variables aren't needed anymore, because the `var'-datasets were already saved

foreach wave in w3 w5 { // Appending all single datasets, to have all coefficient values, p-values and standard errors stored in one dataset
	foreach var in ``wave'_delta' {
		append using `var'.dta
	}
}

sxpose, clear firstnames // The datasets need to be transposed

foreach wave in w3 w5 { // The variables are sorted in the way they will be used in the regression tables later
	sort `wave'dexpendL `wave'dricelandL `wave'd_x91009_aL `wave'dricekgtotL `wave'drice_index `wave'dricekgsldL `wave'dricelandS `wave'd_x43202n `wave'd_x44002n `wave'd_x50002n `wave'd_x60002n `wave'diga_index `wave'do14_jobs `wave'd_x10093 `wave'd_x31024 `wave'dagriloanD `wave'd_x10084 `wave'd_x10085 `wave'd_x10086 `wave'd_x10087 `wave'd_x10088 `wave'd_x10080 `wave'dincome
}

save dataset_v3.dta, replace

keep *expendL *ricelandL *x91009_aL *ricekgtotL *rice_index *ricekgsldL
save dataset_v3.1.noQU.dta, replace // Contains variables for the table "Treatment Effects of the PIS on Rice Production of Treated Farmers"

use dataset_v3.dta, clear
keep *ricelandS *x43202n *x44002n *x50002n *x60002n *iga_index *o14_jobs
save dataset_v3.2.noQU.dta, replace // Contains variables for the table "Treatment Effects of the PIS on Treated Farmers. Possible Coupling Mechanisms: Land and Labor Allocation"

use dataset_v3.dta, clear
keep *x10093 *x31024 *agriloanD
save dataset_v3.3.noQU.dta, replace // Contains variables for the table "Treatment Effects of the PIS on Treated Farmers. Possible Coupling Mechanisms: Wealth, Risk Aversion, and Credit Constraints"

use dataset_v3.dta, clear
keep *x10084 *x10085 *x10086 *x10087 *x10088 *x10080 *income
save dataset_v3.4.noQU.dta, replace // Contains variables for the table "Treatment Effects of the PIS on Incomes of Treated Farmers" 


foreach i in 1 2 3 4 { // The regression results are saved in a format that is needed for the creation of the regression results in the next do-file (3.1.tables.do)
	cd "$data"
    use dataset_v3.`i'.noQU.dta
	foreach j in 3 5 {
	    foreach k in 1 2 {
			preserve 
			keep w`j'*
			keep in `k'
			cd "$LaTeX"
			listtex * using dataset_v3.`i'`j'`k'.noQU.tex, replace
			restore
		}
	}
}

cd "$data" // The single `var' datasets are deleted, because they're not needed anymore
foreach wave in w3 w5 {
	foreach var in ``wave'_delta' {
		erase `var'.dta
	}
}

*******************************************************************************

// Now running the PDS-Lasso-Regression including also waves 6, 7 and 8 and the control variables

// Creating variables that are missing for certain waves, but are needed to run the regression without throwing an error or replacing variables with 0 that otherwise only contain missing values, because this also throws an error otherwise.
cd "$data"
use dataset_v2, clear

// Creating Δyt-1 for the ylist-variables (=outcome variables) by substracting the values of the outcome variables of wave 2 from waves 3 to 8.
foreach wave in w3 w5 w6 w7 w8 {
	foreach var in $ylist {
		gen `wave'd`var' = `wave'`var'- w2`var'
	}
}

// Creating varlists for the delta values of the ylist-variables (outcome variables)
foreach wave in w3 w5 w6 w7 w8 {
	unab `wave'_delta: `wave'd*
	dis "``wave'_delta'"
}

keep w3d* w5d* w6d* w7d* w8d* w3registered $xlist_base $xlist_all QU*

gen dollar = "$"

// To create regression result tables that look comparable to the ones in the original paper coefficient values, p-values and standard deviations of the coefficient values have to be extracted
foreach wave in w3 w5 w6 w7 w8 {
	foreach var in ``wave'_delta' {
		pdslasso `var' w3registered ($xlist_base $xlist_all QU*), robust // Performing the PDS-Lasso regression. The robust option leads to heteroskedasticity-consistent standard errors, see help pdslasso, which shows the PDS-Lasso help file.
		matrix `var'values = r(table) // Preparing the needed results to be extracted
		preserve
		gen `var'coeff = `var'values[1,1] // This line extracts the coefficient values
		gen `var'coeffpval = `var'values[4,1] // This line extracts the p-values of the coefficient values
		gen `var'1 = strofreal(`var'coeff,"%5.3f") // Adding p-value stars to the coefficient values
		replace `var'1= dollar + `var'1 + "^{***}" + dollar if `var'coeffpval <= 0.01
		replace `var'1= dollar + `var'1 + "^{**}" + dollar if `var'coeffpval > 0.01 & `var'coeffpval <= 0.05
		replace `var'1= dollar + `var'1 + "^{*}" + dollar if `var'coeffpval > 0.05 & `var'coeffpval <= 0.1
		gen `var'stddev = `var'values[2,1] // This line extracts the standard deviation of the coefficient values
		gen `var'2 = strofreal(`var'stddev,"%5.3f") // Putting the standard errors in parentheses
		replace `var'2 = "("+ `var'2 + ")"
		gen name = "`var'" // Creating a variable with the name of the variable (needed for transposing later)
		keep `var'1 `var'2 name
		keep in 1 // The first values is always kept. (Values are always the same, but only needed once)
		rename `var'1 coeff
		rename `var'2 stddev
		order name // Variables are ordered alphabetically which later simplifies the creation of the regression tables
		save `var'.dta, replace // A dataset with the variable name is stored for each variable and contains the coefficient values, p-values and standard errors
		restore
		}
}

drop* // The previously created variables aren't needed anymore, because the `var'-datasets were already saved

foreach wave in w3 w5 w6 w7 w8 { // Appending all single datasets, to have all coefficient values, p-values and standard errors stored in one dataset
	foreach var in ``wave'_delta' {
		append using `var'.dta
	}
}

sxpose, clear firstnames

foreach wave in w3 w5 w6 w7 w8 {
	sort `wave'dexpendL `wave'dricelandL `wave'd_x91009_aL `wave'dricekgtotL `wave'drice_index `wave'dricekgsldL `wave'dricelandS `wave'd_x43202n `wave'd_x44002n `wave'd_x50002n `wave'd_x60002n `wave'diga_index `wave'do14_jobs `wave'd_x10093 `wave'd_x31024 `wave'dagriloanD `wave'd_x10084 `wave'd_x10085 `wave'd_x10086 `wave'd_x10087 `wave'd_x10088 `wave'd_x10080 `wave'dincome
}

save dataset_v3.dta, replace

keep *expendL *ricelandL *x91009_aL *ricekgtotL *rice_index *ricekgsldL
save dataset_v3.1.dta, replace // Contains variables for the table "Treatment Effects of the PIS on Rice Production of Treated Farmers"

use dataset_v3.dta, clear
keep *ricelandS *x43202n *x44002n *x50002n *x60002n *iga_index *o14_jobs
save dataset_v3.2.dta, replace // Contains variables for the table "Treatment Effects of the PIS on Treated Farmers. Possible Coupling Mechanisms: Land and Labor Allocation"

use dataset_v3.dta, clear
keep *x10093 *x31024 *agriloanD
save dataset_v3.3.dta, replace // Contains variables for the table "Treatment Effects of the PIS on Treated Farmers. Possible Coupling Mechanisms: Wealth, Risk Aversion, and Credit Constraints"

use dataset_v3.dta, clear
keep *x10084 *x10085 *x10086 *x10087 *x10088 *x10080 *income
save dataset_v3.4.dta, replace // Contains variables for the table "Treatment Effects of the PIS on Incomes of Treated Farmers" 

foreach i in 1 2 3 4 { // The regression results are saved in a format that is needed for the creation of the regression results in the next do-file (3.1.tables.do)
	cd "$data"
    use dataset_v3.`i'.dta
	foreach j in 3 5 6 7 8 {
	    foreach k in 1 2 {
			preserve 
			keep w`j'*
			keep in `k'
			cd "$LaTeX"
			listtex * using dataset_v3.`i'`j'`k'.tex, replace
			restore
		}
	}
}

cd "$data" // The single `var' datasets are deleted, because they're not needed anymore
foreach wave in w3 w5 w6 w7 w8 {
	foreach var in ``wave'_delta' {
		erase `var'.dta
	}
}