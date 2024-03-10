*** DO-FILE:       Outliers *************************************************
*** PROJECT NAME:  Master's Thesis ******************************************
*** DATE: 		   28.12.2023 ***********************************************
*** AUTHOR: 	   JZ *******************************************************

* Note: The purpose of this do-file is to deal with outlier values


*** SECTION 2.3.1 - OUTLIERS ************************************************
***********************!!!!!!!!!!!ADJUST!!!!!!!!!!!!*************************

//adjust local to the variables that you wish to log and check for outliers
unab varlist: w*
unab Svars: *S
local shares " `Svars' w3o14_oc_ag  w3o14_oc_na   w3o14_oc_ue  w3o14_oc_st  w3o14_oc_ot w3o14_jobs w2o14_oc_ag  w2o14_oc_na      w2o14_oc_ue  w2o14_oc_st  w2o14_oc_ot w2o14_jobs w1o14_oc_ag  w1o14_oc_na      w1o14_oc_ue  w1o14_oc_st  w1o14_oc_ot w1o14_jobs w5o14_oc_ag  w5o14_oc_na      w5o14_oc_ue  w5o14_oc_st  w5o14_oc_ot w5o14_jobs w6o14_oc_ag  w6o14_oc_na   w6o14_oc_ue  w6o14_oc_st  w6o14_oc_ot w6o14_jobs w7o14_oc_ag  w7o14_oc_na   w7o14_oc_ue  w7o14_oc_st  w7o14_oc_ot w7o14_jobs w8o14_oc_ag  w8o14_oc_na   w8o14_oc_ue  w8o14_oc_st  w8o14_oc_ot w8o14_jobs"
*shares should not be logged or winsorized, of course other variables that should be ignored by the transformations below could be added to local

local varlist2 : list varlist -  shares
dis in red "`shares'"
*****************************************************************************
//destring w1_x10002 w1_x10003 w1_x10004, replace
//destring w2_x10002 w2_x10003 w2_x10004, replace


//identify vars with outliers
foreach var of varlist `varlist2' { 
	
	quiet sum `var' , d
	
	if r(max)>(3*r(sd)) | r(min)<(3*r(sd)) | r(skewness)> 0.5 | r(skewness)< -0.5 {
		
		local outlier_vars "`outlier_vars' `var'"
	}
}
dis "`outlier_vars'"

//remove outliers and generating ln vars for skewed variables 
foreach var of varlist  `outlier_vars' {

	dis "start of loop"

	//if var is a dummi: continue	
	 summarize `var', d
	
	if (r(max)==1 & r(min)==0)  {
		dis "dummy: `var' "
		continue
	}	

	//if var is categorial: check later and continue
	qui tab `var'
		
	if r(r)<=12 {
		
		local checkvars "`checkvars' `var'"
		dis "category: `checkvars'"
		continue
	}

/*	
	//replace highest and lowest percentile with "." if these values are beyond 4 SD 
	dis "Attention: outliers dropped:"
	quiet summarize `var', d
	replace `var' =. if `var' > (r(mean)+(4*r(sd)))
	replace `var' =. if `var' < (r(mean)-(4*r(sd)))	
	
	quiet summarize `var', d
	if r(max) > (r(mean)+(3*r(sd))) {
	winsor2 `var' , replace  cuts(0 97) 
	lab var `var' "TR `: var lab `var''"		
	}
	quiet summarize `var', d
	if r(min) < (r(mean)-(3*r(sd))) {
	winsor2 `var' , replace  cuts(3 100) 
	lab var `var' "TL `: var lab `var''"		
	}
*/
	//replace highest and lowest percentile with "." if these values are beyond 4 SD 
	dis "Attention: outliers dropped:"
	quiet summarize `var', d
	replace `var' =. if `var' > (r(p50)+(3*r(sd))) // Changed . to 0, because otherwise building the log further down will not work, as Stata can't perform this operation on an empty local macro.
	replace `var' =. if `var' < (r(p50)-(3*r(sd))) // Changed . to 0, because otherwise building the log further down will not work, as Stata can't perform this operation on an empty local macro.
	
	
	//logarithm
	summarize `var', d

	if (r(skewness) > 0.5 | r(skewness)< -0.5) & r(p1)>=0 {
		
		
		
		*GRAPH
		/*
		//before transformation graph
		cap drop `var'f-`var'pmean
		quiet summarize `var', d
		gen `var'f=0.3
		gen `var'sd3max=r(mean)+(3*r(sd))
		gen `var'sd3min=r(mean)-(3*r(sd))
		gen `var'pmin=r(min)
		gen `var'p25=r(p25)
		gen `var'p50=r(p50)
		gen `var'p75=r(p75)
		gen `var'pmax=r(max)
		gen `var'pmean=r(mean)
		
		//kdensity and boxplot on same axes 
		two (kdensity `var') ///
			(rscatter `var' `var' `var'f, hor mcol(mint) msize(tiny)) ///
			(rbar `var'sd3min `var'sd3max `var'f, hor fc(cyan) fi(inten20) lc(dknavy) lw(vvthin) barwidth(0.02)) ///  
			(rbar `var'p25 `var'p75 `var'f, hor fc(mint) fi(inten20) lc(dknavy) lw(vvthin) barwidth(0.1)) ///      
			(rcap `var'p50 `var'p50 `var'f, hor bcolor(white)), ///
			xtitle("`var'") ytitle("Frequency") 
		
		//save before transf graph
		cd "$graph"
		graph save Graph `var', replace asis
    
		//clean up
		drop `var'f-`var'pmean
		*/


		
		
		

		*LOG



		//replace var with log var
		cap gen `var'L=`var' // Cap was added, because otherwise partial runthrougs lead to error messages, that variables are already defined
		lab var `var'L "LOG `: var lab `var''"		
		replace `var'L =`var'L +1 //0.1
		replace `var'L =log(`var'L)
		
		//include in checkvars vector to graph again later
		local checkvars "`checkvars' `var'L "
		
		
	}
	
}
*


//prepare graphs
/**

cd "$graph"
graph drop  _all //drops graphs in memory
 
foreach var of varlist `checkvars' {
	cap drop `var'f-`var'pmean
	quiet summarize `var', d
	gen `var'f=0.3
	gen `var'sd3max=r(mean)+(3*r(sd))
	gen `var'sd3min=r(mean)-(3*r(sd))
	gen `var'pmin=r(min)
	gen `var'p25=r(p25)
	gen `var'p50=r(p50)
	gen `var'p75=r(p75)
	gen `var'pmax=r(max)
	gen `var'pmean=r(mean)
	
	//graph kdensity and boxplot on same axes 
	two (kdensity `var') ///
		(rscatter `var' `var' `var'f, hor mcol(mint) msize(tiny)) ///
		(rbar `var'sd3min `var'sd3max `var'f, hor fc(cyan) fi(inten20) lc(dknavy) lw(vvthin) barwidth(0.02)) ///  
		(rbar `var'p25 `var'p75 `var'f, hor fc(mint) fi(inten20) lc(dknavy) lw(vvthin) barwidth(0.1)) ///      
		(rcap `var'p50 `var'p50 `var'f, hor bcolor(white)), ///
		xtitle("`var'") ytitle("Frequency") 

	graph save Graph `var'_check, replace asis

	// clean up
	drop `var'f-`var'pmean
}

*/
