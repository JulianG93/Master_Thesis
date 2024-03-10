*** DO-FILE:       Ylists Ü**************************************************
*** PROJECT NAME:  Master's Thesis ******************************************
*** DATE: 		   28.12.2023 ***********************************************
*** AUTHOR: 	   JG + JZ **************************************************

* Note: The purpose of this do-file is to create the ylist globals (dependent variables) used for the analysis


*****************************************************************************
*** SECTION 2.3.0 - YLISTS **************************************************


/*Die folgenden Variablen wurden aus ylist und ylist`wave' entfernt, da sie im Paper nicht genutzt werden:

`wave'baacloanD
`wave'takloanD

`wave'anymem_pol
`wave'anymem_oc_go
`wave'hhhpol
`wave'n60borgov
`wave'n60relfr

`wave'ricelandp

`wave'mregriskD
`wave'weatriskD
`wave'outpriskD

`wave'hhh_healthy
`wave'hhh_canmanage
`wave'hhh_sick


`wave'_x42018
`wave'_x42019
`wave'_x42020
`wave'_x42021
`wave'_x42022
`wave'_x42023
`wave'_x42024
`wave'_x42025
`wave'_x42026
`wave'_x42027
`wave'_x42028
`wave'_x42029
`wave'_x42036

`wave'hiredlab
*/

** YLIST **

#delimit ;
global ylist `"

expendL
ricelandL
_x91009_aL
ricekgtotL
rice_index
ricekgsldL

_x10093
_x31024
agriloanD

ricelandS
_x43202n
_x44002n
_x50002n
_x60002n
iga_index
o14_jobs


_x10084
_x10085
_x10086
_x10087
_x10088
_x10080L
_x10080
income


"'
;
#delimit cr
dis  "$ylist"


// baacloans 
// polloans 
// takloans  
//
// polloanD 
//
// takloanD 

#delimit ;
global noimpute_ylist `"

pricekg
ppricekg 
pricekgD
ppricekgD 
pricekgsD
pprickgsD
   
"'
;
#delimit cr
dis  "$noimpute_ylist"






** YLIST WAVE **

foreach wave in w2 w3 w5 w6 w7 w8 {
#delimit ;
global ylist`wave' `"

`wave'expendL
`wave'ricelandL
`wave'_x91009_aL
`wave'ricekgtotL 
`wave'rice_index 
`wave'ricekgsldL

`wave'_x10093 
`wave'_x31024
`wave'agriloanD

`wave'ricelandS
`wave'_x43202n 
`wave'_x44002n 
`wave'_x50002n 
`wave'_x60002n 
`wave'iga_index 
`wave'o14_jobs


`wave'_x10084 
`wave'_x10085 
`wave'_x10086
`wave'_x10087
`wave'_x10088 
`wave'_x10080L 
`wave'_x10080
`wave'income        



"'
;
#delimit cr
dis  "$ylist`wave'"
}
*

//
//
// `wave'baacloans 
// `wave'polloans 
// `wave'takloans  
//
// `wave'baacloanD
// `wave'polloanD 
// `wave'takloanD 
// `wave'n60borgov 
// `wave'n60relfr
//
// `wave'anymem_pol
// `wave'anymem_oc_go
// `wave'hhhpol
//
// `wave'pricekg
// `wave'ppricekg 
//
// `wave'ricelandp 
//
// `wave'weatriskD
//


foreach wave in w2 w3 w5 w6 w7 w8 {
#delimit ;
global noimpute_ylist`wave' `"

`wave'pricekg
`wave'ppricekg 
`wave'pricekgD
`wave'ppricekgD
`wave'pricekgsD
`wave'pprickgsD
"'
;
#delimit cr
dis  "$noimpute_ylist`wave'"
}
*

