*** DO-FILE:       Merge_prep ***********************************************
*** PROJECT NAME:  Master's Thesis ******************************************
*** DATE: 	       28.12.2023 ***********************************************
*** AUTHOR:        JG *******************************************************

* NOTE: The purpose of this do-file is to align the different waves, so that they are prepared to be merged.


*****************************************************************************
*** SECTION 2.2a - 2013 MERGING  ********************************************

** CREATE MASTER**

//// waves 2,3,5,6,7
// Adding several variable to the hhclean datasets from the hhraw datasets which are somehow missing in the hhclean datasets. Adding T to waves 6 + 7 and 72201 (Does member own a free health card?) to wave 8.

cd "${cleandata_w2}"
use hhclean.dta, clear
merge 1:1 QID using hhraw.dta, keepusing (__10001 __10002 __10003 __10004 __10024 __12122 __12123 __31013a __31013b __31014a __31014b __31019a __31019b __31020a __31020b __31024 __31025 __32007 __32010 __32011a __32011b __32011c __32011d __32011e __42030 __71133b __71133c __72201)
foreach root in 10024 12122 12123 31013a 31013b 31014a 31014b 31019a 31019b 31020a 31020b 31024 31025 32007 32010 32011a 32011b 32011c 32011d 32011e 42030 71133b 71133c 72201 {
	cap rename  __`root' _x`root'
}
rename (__10001 __10002 __10003 __10004) (prov distr subdistr vill)
save hhclean1, replace

cd "${cleandata_w3}"
use hhclean.dta, clear
merge 1:1 QID using hhraw.dta, keepusing (__42030 __72201 __10024) keep (match master)
rename (__42030 __72201 __10024) (_x42030 _x72201 _x10024)
cap tostring prov distr subdistr vill, force replace
save hhclean1, replace

cd "${cleandata_w5}"
use hhclean.dta, clear
merge 1:1 QID using hhraw.dta, keepusing (__10024 __42030) keep (match master)
foreach root in 10024 42030 {
	cap rename  __`root' _x`root'
}
cap tostring prov distr subdistr vill, force replace
save hhclean1, replace

cd "${cleandata_w6}"
use hhclean.dta, clear
merge 1:1 QID using "${cleandata_w2}/hhclean.dta", keepusing (T) keep (match master) nogen
cap tostring _x10001 _x10002 _x10003 _x10004, force replace
save hhclean1, replace

cd "${cleandata_w7}"
use memclean.dta, clear
by QID (_x23002a), sort: gen diff1 = _x23002a[1] == _x23002a[_N] // If not all members of the HH have a free health card, the HH will be considered as not having a free health card. In that case diff1 will be zero and _x23002a will be set as 0.
replace _x23002a=1 if diff1==1 & _x23002a==1
replace _x23002a=0 if diff1==0
collapse (mean) _x23002a, by(QID)
save mem_temp.dta, replace
use hhclean.dta, clear
merge 1:1 QID using "${cleandata_w2}/hhclean.dta", keepusing (T) keep (match master) nogen
merge 1:1 QID using mem_temp.dta, keepusing (_x23002a) keep (match master) nogen
rename _x23002a _x72201
label variable _x72201 "Do the members of the HH own a free health card?"
cap tostring prov distr subdistr vill, force replace
save hhclean1, replace

//// wave 8
// Merging variables from different datasets that are needed in the HH dataset and renaming variables so that they fit the names of other waves.

// Adding variable 62001 (Did your HH buy any durable goods between 5/17 - 4/19 for a price of 5000 THB or higher (investment))?
cd "${cleandata_w8}"
use invdetail, clear
bysort interview__key: egen v62007D= sum(v62007)
drop if v62007D<5000 // Shows that all households have investments over 5000THB.
gen v62007D1=1 // This variable can (and will later in this file) be used as a substitute for 62001 (Did your HH buy any durable goods for a purchase price of 5000 THB or higher (investment)?
bys interview__key: gen temp=_n // Dropping duplicate interview__keys, because this allows for a m:1-merge instead of a m:m-merge and each interview__key has the same value for v62007D1 anyways.
drop if temp!=1
save invdetailforHHmerging.dta, replace

// Adding variable 62013 (Did your HH sell any durable goods between 5/17 - 4/19 for a price of 5000 THB or higher (disinvestment))?
use disinvdetail, clear
bysort interview__key: egen v62017D= sum(v62017)
drop if v62017D<5000 // Shows that all households have disinvestments over 5000THB.
gen v62017D1=1 // This variable can (and will later in this file) be used as a substitute for 62013 (Did your HH buy sell durable goods for a purchase price of 5000 THB or higher (disinvestment)?
bys interview__key: gen temp=_n // Dropping duplicate interview__keys, because this allows for a m:1-merge instead of a m:m-merge and each interview__key has the same value for v62007D1 anyways.
drop if temp!=1
save disinvdetailforHHmerging.dta, replace

// Merging variable v23002a (Does mem have a free health card?) to the TVSEP-dataset.
use members.dta, clear
by interview__key (v23002a), sort: gen diff = v23002a[1] == v23002a[_N] // If not all members of the HH have a free health card, the HH will be considered as not having a free health card. In that case diff will be zero and v23002a will be dropped.
replace v23002a=1 if diff==1 & v23002a==1
replace v23002a=0 if diff==0
bys interview__key: gen temp=_n // Dropping duplicate interview__keys, because this allows for a m:1-merge instead of a m:m-merge and each interview__key has the same value for v23002a anyways.
drop if temp!=1
save membersforHHmerging.dta, replace

// merging 71101b + 71101c to the TVSEP-dataset.
use financialinstitutions.dta, clear
drop if fin_instTH__id!=33 // 33 equals BAAC. Only the BAAC should be included. Like this these variables have the definition of 71133b (BAAC Location) and 71113c (BAAC Travel Time) in the other waves.
save financialinstitutionsforHHmerging.dta, replace

// The actual merging will be at the bottom of the following block (MERGE MEM DATA)

*****************************************************************************


** MERGE MEM DATA**
//// wave 1
// Replacing values 31 (not graduate), value 32 (non-formal education), value 33 (diploma of vocational certificate) of variable 22007 (Highest educational attainment), because they differ from other waves and aren't useful to create the variable hhheduhi (Highest educational attainment of HH-head) later on. Also deleting values between 51 and 70, because they're supposed to be used for the Vietnamese survey only according to the questionnaires. 71 (PhD) equals 29 in other waves.
cd "$cleandata_w1"
use memclean.dta, clear
replace _x22007=. if _x22007==31 | _x22007==32 | _x22007==33 | _x22007>50 & _x22007<71
replace _x22007=29 if _x22007==71
save memclean1.dta, replace

//// wave 2
// Replacing values 31 (not graduate), value 32 (non-formal education), value 33 (dipoloma of vocational certificate) of variable 22007 (Highest educational attainment), because they differ from other waves and aren't useful to create the variable hhheduhi (Highest educational attainment of HH-head) later on. Also deleting values between 51 and 70, because they're supposed to be used for the Vietnamese survey only according to the questionnaires. 71 (PhD) equals 29 in other waves.
cd "$cleandata_w2"
use memclean.dta, clear
replace _x22007=. if _x22007==31 | _x22007==32 | _x22007==33 | _x22007>50 & _x22007<71
replace _x22007=29 if _x22007==71
save memclean1.dta, replace

//// wave 3
// Replacing values 31 (not graduate), value 32 (non-formal education), value 33 (dipoloma of vocational certificate) and 90 (other, specify) of variable 22007 (Highest educational attainment), because they differ from other waves and aren't useful to create the variable hhheduhi (Highest educational attainment of HH-head) later on. Also deleting values between 51 and 70, because they're supposed to be used for the Vietnamese survey only according to the questionnaires. 71 (PhD) equals 29 in other waves.
cd "$cleandata_w3"
use memclean.dta, clear
replace _x22007=. if _x22007==31 | _x22007==32 | _x22007==33 | _x22007==90 | _x22007>50 & _x22007<71
replace _x22007=29 if _x22007==71
save memclean1.dta, replace

//// wave 5
// Replacing values 31 (not graduate), value 32 (non-formal education), value 33 (dipoloma of vocational certificate) and values over 60 (happens in 4 cases) of variable 22007 (Highest educational attainment), because they differ from other waves and aren't useful to create the variable hhheduhi (Highest educational attainment of HH-head) later on. Also deleting values between 51 and 70, because they're supposed to be used for the Vietnamese survey only according to the questionnaires. 71 (PhD) equals 29 in other waves.
cd "$cleandata_w5"
use memclean.dta, clear
replace _x22007=. if _x22007==31 | _x22007==32 | _x22007==33 | _x22007>=60 | _x22007>50 & _x22007<71
replace _x22007=29 if _x22007==71
save memclean1.dta, replace

//// wave 6 
// Adding T to memclean. Also replacing values 30 (adult education, specify) of variable 22007 (Highest educational attainment), because they differ from other waves and aren't useful to create the variable hhheduhi (Highest educational attainment of HH-head) later on. Also deleting values between 51 and 70, because they're supposed to be used for the Vietnamese survey only according to the questionnaires. 71 (PhD) equals 29 in other waves.
cd "$cleandata_w6"
use memclean.dta, clear
replace _x22007=. if _x22007==30 | _x22007>50 & _x22007<71
replace _x22007=29 if _x22007==71
cap gen T= _x21011
replace T=0 if _x21011!=. & _x21011!=3
replace T=1 if _x21011==3
save memclean1.dta, replace

//// wave 7
// Adding T to memclean. Also replacing values 30 (adult education, specify) of variable 22007 (Highest educational attainment), because they differ from other waves and aren't useful to create the variable hhheduhi (Highest educational attainment of HH-head) later on.
cd "$cleandata_w7"
use memclean.dta, clear
replace _x22007=. if _x22007==30
cap gen T= _x21011
replace T=0 if _x21011!=. & _x21011!=3
replace T=1 if _x21011==3
save memclean1.dta, replace

//// wave 8
// Correcting v21004 (age) <- If a child is below 6 years it gets the label 0. Can be corrected by replacing these cases with v21004a/12 and rounding it down to a full integer, as v21004a gives the age in months of children below 6 years.
cd "$cleandata_w8"
use members.dta, clear
replace v21004 = floor(v21004a/12) if v21004a< .
label drop v21004 // For children between 0 and 11 months there was the label remaining, but it should just be zero (years), so I dropped the label.
rename v21004 _x21004

replace v21013=. if v21013==98 // 98 is used as a label for 'No answer' and needs to be replaced

// Adding Thai Dummy Variable for all members (Later a Thai Dummy for the HH/hh-heads will be created)
cap gen T= v21011
replace T=0 if v21011!=. & v21011!=3
replace T=1 if v21011==3

// Variable 22007 (Highest educational attainment) doesn't exist, but 22014 (How many years did you go to school?) can be used as an alternative. Up until 12 both variables are the same, but for values above variable 22014 needs to be adapted.
replace v22014=26 if v22014==16 // A bachelors degree (equals 26 in variable 22007) and needs 16 years of schooling (4 years after finishing secondary class)
replace v22014=28 if v22014==17 | v22014==18 // A masters degree (equals 28 in variable 22007) and needs 17/18 years of schooling (5/6 years after finishing secondary class)
replace v22014=29 if v22014>20 // A PhD (equals 29 in variable 22007) and needs at least 20 years after schooling (At least 8 years after finishing secondary class)

// v21018 needs to be replaced by v21018a, because v21018 has been redefined in wave 8 and v21018a has the definition of variable 21018 in previous waves.
label drop v21018 // The newly defined value labels of v21018 need to be dropped.
replace v21018 = v21018a
label values v21018 v21018a // Applying the value labels v21018a (which have the definition of 21018 of older waves) to variable v21018.

// v21014 needs to be replaced by v21014a, because v21014 has been redefined in wave 8 and v21014a has the definition of variable 21014 in previous waves.
label drop v21014 // The newly defined value labels of v21014 need to be dropped
replace v21014 = v21014a // // v21014 needs to be replaced by v21014a, because v21014 has been redefined in wave 8 and v21014a has the definition of variable 21014 in previous waves.
label values v21014 v21014a // Applying the value labels v21014a (which have the definition of 21014 of older waves) to variable v21014.

// QID still has to be added by merging with TVSEP2019.dta
merge m:1 interview__key using TVSEP2019.dta, keepusing (QID) keep (match master) nogen
save members1.dta, replace

// T is added to TVSEP2019 by merging with hhclean from wave 2.
cd "${cleandata_w8}"
use TVSEP2019.dta, clear
tostring QID, replace // Just to be able to merge in the next line
merge 1:1 QID using "${cleandata_w2}/hhclean.dta", keepusing (T) keep (match master) nogen
destring QID, replace // Reversing QID again to old form
rename (v31313a v31313b v31314a v31314b v31319a v31319b v31320a v31320b v62020 v62021 v62022 v62023 v62024 v62025 v31324 v31325) (_x31013a _x31013b _x31014a _x31014b _x31019a _x31019b _x31020a _x31020b _x62020 _x62021 _x62022 _x62023 _x62024 _x62025 _x31024 _x31025)
merge m:1 interview__key using membersforHHmerging.dta, keepusing (v23002a) keep (match master) nogen
merge m:1 interview__key using invdetailforHHmerging.dta, keepusing (v62007D1) keep (match master) nogen
merge m:1 interview__key using disinvdetailforHHmerging.dta, keepusing (v62017D1) keep (match master) nogen
merge m:1 interview__key using financialinstitutionsforHHmerging.dta, keepusing (v71101b v71101c)
rename v23002a _x72201 // Variable v23002a has the definition of variable 72201 (Are members of this household entitled to use the free health card?) in the other waves.
rename v62007D1 _x62001 // Variable 62007D1 has the definition of variable 62001 (Did your HH buy any durable goods for a purchase price of 5000 THB or higher (investment)) in the other waves.
rename v62017D1 _x62013 // Variable v62017D1 has the definition of variable 62013 (Did your HH buy sell durable goods for a purchase price of 5000 THB or higher (disinvestment)?) in the other waves.
rename (v71101b v71101c) (_x71133b _x71133c) // Variables 71101b and 71101c have the definition of variables 71133b (BAAC Location) and 71133c (BAAC Travel Time) of the other waves
erase membersforHHmerging.dta
erase invdetailforHHmerging.dta
erase disinvdetailforHHmerging.dta
erase financialinstitutionsforHHmerging.dta
cap tostring v10001 v10002 v10003 v10004, force replace
save TVSEP20191.dta, replace

*****************************************************************************


** MERGE SHOCKS **

//// wave 8
// QID still has to be added by merging with TVSEP2019.dta
cd "${cleandata_w8}"
use shocks.dta, clear
merge m:1 interview__key using TVSEP2019.dta, keepusing (QID) keep (match master) nogen
save shocks1.dta, replace

*****************************************************************************


** MERGE AGRI RISKS **

//// wave 8
// QID still has to be added by merging with TVSEP2019.dta
cd "${cleandata_w8}"
use risks.dta, clear
merge m:1 interview__key using TVSEP2019.dta, keepusing (QID) keep (match master) nogen
save risks1.dta, replace

*****************************************************************************


** MERGE WEATHER, REGULATION AND PRICE RISKS **

// No changes needed and for wave 8 the risks1 dataset from the previous block can be used.

*****************************************************************************


** MERGE LAND DATA **

//// wave 1 + 2 + 3 + 5
// Multiplying variable 41003 (land area) with 6.25 for waves 3-5. This was already done for variable 42005 (area planted) in the crops datasets (for waves 3-8), but not yet for variable 41003 in the land datasets. Also adding 41002 (Land parcel number) to the landclean dataset of wave 3, because it's only available in the raw dataset.
cd "${cleandata_w1}"
use landclean.dta, clear
replace _x41003=_x41003*6.25
save landclean1.dta, replace

cd "${cleandata_w2}"
use landclean.dta, clear
replace _x41003=_x41003*6.25
save landclean1.dta, replace

// wave 3: Adding 41002 (land parcel nr.) from the raw dataset.
cd "${cleandata_w3}"
use landclean.dta, clear
replace _x41003=_x41003*6.25
merge 1:1 ID using landraw.dta, keepusing (__41002) keep (match master) 
rename __41002 _x41002
save landclean1.dta, replace

cd "${cleandata_w5}"
use landclean.dta, clear
replace _x41003=_x41003*6.25
save landclean1.dta, replace

//// wave 6 + 7
// adding T to landclean by using hhclean which has T included.
foreach wave in w6 w7 {
cd "${cleandata_`wave'}"
use landclean.dta, clear
merge m:1 QID using "${cleandata_w2}/hhclean.dta", keepusing (T) keep (match master) nogen
save landclean1, replace
}

//// wave 8
// QID still has to be added by merging with TVSEP2019.dta and T-Dummy by merging with hhclean.dta from wave 2.
cd "${cleandata_w8}"
use land_used.dta, clear
merge m:1 interview__key using "${cleandata_w8}/TVSEP2019.dta", keepusing (QID) keep (match master) nogen
tostring QID, replace // Just to be able to merge in the next line
merge m:1 QID using "${cleandata_w2}/hhclean.dta", keepusing (T) keep (match master) nogen
save land_used1, replace

****************************************************************************

** MERGE MORE LAND DATA **

// No changes needed as for all waves that needed to be integrated the datasets that were prepared in the previous block can be used.

*****************************************************************************

** Generate Sample Var: MERGE CROPS; LAND DATA **

//// wave 8
// Correcting variable 41008 (year of land purchase)
cd "${cleandata_w8}"
use land_used1.dta
foreach root in 41008a {
	replace v`root'=. if v`root'<51 | v`root'==9999 // Incorrect variable values between 9 and 50 deleted
	replace v`root'= v`root'-543 if v`root'>2400 // Converting from buddhist to christian calendar
	save land_used1.dta, replace
} 

//// wave 6, 7
// adding T to cropsclean
foreach wave in w6 w7 {
cd "${cleandata_`wave'}"
use cropsclean.dta, clear
merge m:1 QID using "${cleandata_w2}/hhclean.dta", keepusing (T) keep (match master) nogen
// The variable 42002 ('crop') of waves 1-5 is variable 42003a (variety) in waves 6-8. Glutinous rice is 13 instead of 103.
replace _x42003a=103 if _x42003a==13
label define _x42003a 103 "glutinous rice", add
// Non-glutinous rice is 12 instead of 104.
replace _x42003a=104 if _x42003a==12 
label define _x42003a 104 "non-glutinous rice", add
label value _x42003a _x42003a
// The in wave 6 + 7 newly defined _x42002 isn't needed anymore, so it will be dropped. Then 42003a can be renamed to 42002 so that it has the name as in the other waves again.
drop _x42002
rename _x42003a _x42002
save cropsclean1, replace
}

//// wave 8
// QID still has to be added by merging with TVSEP2019.dta and T-Dummy by merging with members1.dta. Correcting the labels for variables 42006 and 42008, because the months were not correctly set as in the other waves. Correcting variable 42003a. Non-glutinous rice has become 12 instead of 104.
cd "${cleandata_w8}"
use crops_plots.dta, clear
merge m:1 interview__key using TVSEP20191.dta, keepusing (QID T) keep (match master) nogen
replace v42003a=103 if v42003a==13 // The definition for 'glutinous rice' has changed in w8 and is 13 instead of 103 now, so it needs to be reversed back.
label define v42003a 103 "glutinous rice", add
replace v42003a=104 if v42003a==12 // The definition for 'non-glutinous rice' has changed in w8 and is 12 instead of 104 now, so it needs to be reversed back.
label define v42003a 104 "non-glutinous rice", add
label value v42003a v42003a

replace v42006=1 if v42006==9
replace v42006=2 if v42006==10
replace v42006=3 if v42006==11
replace v42006=4 if v42006==12
replace v42006=5 if v42006==1
replace v42006=6 if v42006==2
replace v42006=7 if v42006==3
replace v42006=8 if v42006==4
replace v42006=9 if v42006==5
replace v42006=10 if v42006==6
replace v42006=11 if v42006==7
replace v42006=12 if v42006==8
replace v42006=. if v42006==-99

label define v42006 1 "January" 2 "February" 3 "March" 4 "April" 5 "Mai" 6 "June" 7 "July" 8 "August" 9 "Septemnber" 10 "October" 11 "November" 12 "December", modify

replace v42008=1 if v42008==9
replace v42008=2 if v42008==10
replace v42008=3 if v42008==11
replace v42008=4 if v42008==12
replace v42008=5 if v42008==1
replace v42008=6 if v42008==2
replace v42008=7 if v42008==3
replace v42008=8 if v42008==4
replace v42008=9 if v42008==5
replace v42008=10 if v42008==6
replace v42008=11 if v42008==7
replace v42008=12 if v42008==8
replace v42006=. if v42006==-99

label define v42008 1 "January" 2 "February" 3 "March" 4 "April" 5 "Mai" 6 "June" 7 "July" 8 "August" 9 "Septemnber" 10 "October" 11 "November" 12 "December", modify

save crops_plots1.dta, replace

// Using land_used1 from the previous blocks, because it has already the T-Dummy and QID merged.

*****************************************************************************

** AGAIN MERGE CROPS DATA FOR TAPIOCA AND MAIZE **

// No changes needed as for all waves that needed to be integrated the datasets that were prepared in the previous block can be used.

*****************************************************************************

** MERGE MORE CROP DATA **

// No changes needed as for all waves that needed to be integrated the datasets that were prepared in the previous block can be used.

*****************************************************************************

** MERGE MORE CROP DATA **

// No changes needed as for all waves that needed to be integrated the datasets that were prepared in the previous block can be used.

*****************************************************************************

** MERGE TOTAL LAND PLANTED FROM CROP DATA**

// No changes needed as for all waves that needed to be integrated the datasets that were prepared in the previous block can be used.

*****************************************************************************

** MERGE CROP STORAGE DATA **

//// wave 2
// Variable 42032 (Stored total crops in kg (all not just insured crops)) gets added.
cd "${cleandata_w2}"
use storclean.dta, clear
merge 1:1 ID using storraw.dta, keepusing (__42032) keep (match master) nogen
rename __42032 _x42032
save storclean1.dta, replace

//// wave 3
// Variable 42032 (Stored total crops in kg  (all not just insured crops)) gets added.
cd "${cleandata_w3}"
use storclean.dta, clear
merge 1:1 ID using storraw.dta, keepusing (__42032) keep (match master) nogen
rename __42032 _x42032
save storclean1.dta, replace


//// wave 5
// Variable 42032 (Stored total crops in kg  (all not just insured crops)) gets added.
cd "${cleandata_w5}"
use storclean.dta, clear
merge 1:1 ID using storraw.dta, keepusing (__42032) keep (match master) nogen
rename __42032 _x42032
save storclean1.dta, replace


*****************************************************************************

** MERGE LIVE STOCK DATA **

//// wave 8
// QID still has to be added by merging with TVSEP2019.dta.
cd "${cleandata_w8}"
use livest.dta, clear
merge m:1 interview__key using TVSEP2019.dta, keepusing (QID) keep (match master) nogen
save livest1.dta, replace

*****************************************************************************

** MERGE LIVE STOCK PRODUCT DATA **

//// wave 8
// QID still has to be added by merging with TVSEP2019.dta.
cd "${cleandata_w8}"
use livestock_product.dta, clear
merge m:1 interview__key using TVSEP2019.dta, keepusing (QID) keep (match master) nogen
save livestock_product1.dta, replace

*****************************************************************************

** MERGE HUNTING/COLLECTING/LOGGING DATA **

//// wave 8
// QID still has to be added by merging with TVSEP2019.dta.
cd "${cleandata_w8}"
use natres.dta, clear
merge m:1 interview__key using TVSEP2019.dta, keepusing (QID) keep (match master) nogen
save natres1.dta, replace

*****************************************************************************

** MERGE OFF-FARM EMPLOYMENT DATA **

//// wave 8
// QID still has to be added by merging with TVSEP2019.dta.
cd "${cleandata_w8}"
use offempl.dta, clear
merge m:1 interview__key using TVSEP2019.dta, keepusing (QID) keep (match master) nogen
save offempl1.dta, replace

*****************************************************************************

** MERGE SELF-EMPLOYMENT  DATA **

//// wave 8
// QID still has to be added by merging with TVSEP2019.dta.
cd "${cleandata_w8}"
use selfempl.dta, clear
merge m:1 interview__key using TVSEP2019.dta, keepusing (QID) keep (match master) nogen
save selfempl1.dta, replace

*****************************************************************************

** MERGE ASSETS DATA **

//// wave 1
cd "${cleandata_w1}"
use assetsclean.dta, clear
gen _x91009 = _x91002 * _x91003 // Variable 91009 (How much would you get if you sold all items today?) doesn't exist in wave 1, but a good substitute can be built by multiplicating variable 91002='no. of items of assets the household holds' with variable 91003='Amount paid for the last recent obtained item'.
save assetsclean1.dta, replace

//// wave 8
// QID and prov still has to be added by merging with TVSEP2019.dta.
cd "${cleandata_w8}"
use asset_detail.dta, clear
replace asset_detail__id=asset_detail__id+1 // asset_detail__id is the number of assets, but 0 means that the household owns 1 asset etc. so 1 needs to be added so that the variable has the same definition as the other waves.
merge m:1 interview__key using TVSEP2019.dta, keepusing (QID v10001) keep (match master) nogen
save asset_detail1.dta, replace

*****************************************************************************

** MERGE INVESTMENT DATA **

//// wave 6 + 7
// adding T to investclean by merging with the hhclean dataset from wave 2.
foreach wave in w6 w7 {
cd "${cleandata_`wave'}"
use investclean.dta, clear
merge m:1 QID using "${cleandata_w2}/hhclean.dta", keepusing (T) keep (match master) nogen 
save investclean1.dta, replace
}

//// wave 8
// Q still has to be added by merging with TVSEP2019.dta, T has to be added by merging with hhclean.dta from wave 2 and variable 62006a (year) has to be corrected.
cd "${cleandata_w8}"
use invdetail, clear
foreach root in 62006a {
	replace v`root'=. if v`root'==9999 // 9999 is a label for "Don't know"
	replace v`root'=2560-543 if v`root'==4 // 4 is used as a label for buddhist year 2560
	replace v`root'=2561-543 if v`root'==5 // 5 is used as a label for buddhist year 2561
	replace v`root'=2562-543 if v`root'==6 // 6 is used as a label for buddhist year 2562
}
merge m:1 interview__key using TVSEP2019.dta, keepusing (QID) keep (match master) nogen
tostring QID, replace // Just for merging in the next line
merge m:1 QID using "${cleandata_w2}/hhclean.dta", keepusing (T) keep (match master) nogen
destring QID, replace
save invdetail1.dta, replace

//disinvestment

//// wave 3
// Adding variables 62016 (divestment type) and 62017 (amount divestment) to the disinvestclean dataset from the disinvestraw dataset, because the clean dataset somehow misses them.
cd "${cleandata_w3}"
use disinvestclean.dta, clear
merge 1:1 ID using disinvestraw.dta, keepusing (__62016 __62017) keep (match master) nogen
rename (__62016 __62017) (_x62016 _x62017)
save disinvestclean1.dta, replace

//// wave 8
// QID still has to be added by merging with TVSEP2019.dta.
cd "${cleandata_w8}"
use disinvdetail.dta, clear
merge m:1 interview__key using TVSEP2019.dta, keepusing (QID) keep (match master) nogen
save disinvdetail1.dta, replace


*****************************************************************************

** MERGE BORROWING DATA **

//// wave 1
cd "${cleandata_w1}"
	use borrclean.dta, clear
	gen _x71119b = _x71119 // Variable 71119b ('Remaining debt') doesn't exist, but variable 71119 can be used as a substitute ('In case of lump sum repayment: specify amount')
	replace _x71119b=. if _x71119b==97 // Replacing 97 with missing values as they are used as a label for 'Don't know'.
	replace _x71119b=. if _x71119b==98 // Replacing 98 with missing values as they are used as a label for 'No answer.
	replace _x71119b=. if _x71119b==99 // Replacing 99 with missing values as they are used as a label for missing values/not applicable.
	save borrclean1.dta, replace

//// wave 8
// QID and prov still has to be added by merging with TVSEP2019.dta.
cd "${cleandata_w8}"
use borr.dta, clear
merge m:1 interview__key using TVSEP2019.dta, keepusing (QID v10001) keep (match master) nogen
save borr1.dta, replace

*****************************************************************************

** MERGE MORE BORROWING DATA **

// No changes needed as for all waves that needed to be integrated the datasets that were prepared in the previous block can be used.

*****************************************************************************

** MERGE SAVINGS DATA **

//// wave 8
// QID still has to be added by merging with TVSEP2019.dta.
cd "${cleandata_w8}"
use savings.dta, clear
merge m:1 interview__key using TVSEP2019.dta, keepusing (QID) keep (match master) nogen
save savings1.dta, replace

*****************************************************************************

** MERGE FARMER INCOME GUARANTEE TRANSFER DATA **

// Nothing needed to be done here, as this part only applies to wave 3.

*****************************************************************************

** MERGE CREDIT DEFAULT DATA **

//// wave 2
// Adding variable 71415 () from the defhistraw to the defhistclean dataset, because somehow in the clean dataset it's missing.
cd "${cleandata_w2}"
use defhistclean.dta, clear
merge 1:1 ID using defhistraw.dta, keepusing (__71414 __71415) keep (match master) nogen
rename (__71414 __71415) (_x71414 _x71415)
save defhistclean1.dta, replace

//// wave 8
// QID still has to be added by merging with TVSEP2019.dta.
cd "${cleandata_w8}"
use default_ros.dta, clear
merge m:1 interview__key using TVSEP2019.dta, keepusing (QID) keep (match master) nogen
tostring QID, replace
save default_ros1.dta, replace

*****************************************************************************

** MERGE FARMER INCOME GUARANTEE REGISTRATION DATA **

// Nothing needed to be done as this dataset only exists in wave 5, so no other waves need integration.

*****************************************************************************

** PREPARATION FOR MERGE INCOME DATA ** NEEDS TO BE DONE HERE ALREADY OTHERWISE MERGING WOULDN'T WORK **

//// waves 1-8
// Repair of variable 10093 (Total value of public transfers received). w5 is wrong and also the other waves have only fewer observations than they should compared to if I check the number of observations in the raw transfer datasets. w7 already contains _x10093 and w8 gets already handled in the next block.

foreach wave in w1 w2 w3 w5 w6 {
	if "`wave'"=="w1" {
		cd "${cleandata_`wave'}"
	    use transfclean.dta, clear
		gen _x10093 = _x72103
		collapse (sum) _x10093, by(QID)
		save transfcleanfor1.dta, replace
	}
	else if "`wave'"=="w2" {
		cd "${cleandata_`wave'}"
	    use transfclean.dta, clear
		gen _x10093 = _x72103
		collapse (sum) _x10093, by(QID)
		cd "$cleandata_w3"
		save transfcleanforw2.dta, replace
	}
	else if "`wave'"=="w3" {
		cd "${cleandata_`wave'}"
	    use transfclean.dta, clear
		gen _x10093 = _x72103
		collapse (sum) _x10093, by(QID)
		save transfcleanforw3.dta, replace
	}
	else {
		cd "${cleandata_`wave'}"
	    use transfclean.dta, clear
		gen _x10093 = _x72103
		collapse (sum) _x10093, by(QID)
		save transfclean1.dta, replace
	}
}

*****************************************************************************

*** SECTION 2.2d - CREATE PANEL  ********************************************   

//// wave 1
// values 97, 98 and 99 need to be replaced in the variables used for merging the hhincclean dataset. Also variable _x10093 needs to be replaced as it's corrupted. Preparations for this were done in the "MERGE INCOME DATA" block.
cd "${cleandata_w1}"
use hhInc2clean.dta, clear
drop _x10093 
merge 1:1 QID using transfcleanfor1.dta, keepusing(_x10093) keep(match master) nogen
foreach root in 10080 10081 10082 10083 10084 10085 10086 10087 10088 10091 10092 10093 10094 10100 10101  { 
	replace _x`root'=. if _x`root'==97 // Replacing 97 with missing values as they are used as a label for 'Don't know'.
	replace _x`root'=. if _x`root'==98 // Replacing 98 with missing values as they are used as a label for 'no answer'.
	replace _x`root'=. if _x`root'==99 // Replacing 99 with missing values as they are used as a label for missing values/not applicable.
}
save hhInc2clean1.dta, replace
erase transfcleanfor1.dta

//// wave 6
// T has to be added by merging with hhclean.dta from wave 2. _x10093 needs to be replaced as it's corrupted. Preparations for this were done in the "MERGE INCOME DATA" block.
cd "${cleandata_w6}"
use hhincclean.dta, clear
drop _x10093
gen _x10101 = _x10100 / _x12122 // _x10101 (total annual income per nucleus household member) is missing, but can be created by dividing _x10100 (total annual household income) with _x12122 (household nucleus size). 
merge 1:1 QID using "${cleandata_w2}/hhclean.dta", keepusing (T) keep (match master) nogen
merge 1:1 QID using transfclean1.dta, keepusing(_x10093) keep(match master) nogen // <- Is already included in the clean dataset
drop _x10093c _x10093k // They will not be used anymore and otherwise leads to error code later, when _x10093 get's used, because of ambiguity
save hhincclean1, replace

//// wave 7
// T has to be added by merging with hhclean.dta. _x10093 needs to be replaced as it's corrupted. Preparations for this were done in the "MERGE INCOME DATA" block.
cd "${cleandata_w7}"
use hhincclean.dta, clear
gen _x10101 = _x10100 / _x12122 // _x10101 (total annual income per nucleus household member) is missing, but can be created by dividing _x10100 (total annual household income) with _x12122 (household nucleus size). 
merge 1:1 QID using "${cleandata_w2}/hhclean.dta", keepusing (T) keep (match master) nogen
drop _x10093c _x10093k // They will not be used anymore and otherwise leads to error code later, when _x10093 get's used, because of ambiguity
save hhincclean1, replace
***...

*****************************************************************************

** MERGE INCOME DATA**

//// wave 2 + 3
// Merging variable 10093 to the HH Income dataset of waves 2 and 3. Merging for wave 5 and wave 8 is following. Merging for waves 1, 6 and 7 takes place one block further up ("SECTION 2.2d - CREATE PANEL").
		cd "$cleandata_w3"
		use hhinc_w3_w2clean.dta, clear
		drop w2_x10093 _x10093
		merge 1:1 QID using transfcleanforw2.dta, keepusing(_x10093) keep(match master) nogen
		rename _x10093 w2_x10093
		merge 1:1 QID using transfcleanforw3.dta, keepusing(_x10093) keep(match master) nogen
		save hhinc_w3_w2clean1.dta, replace
		erase transfcleanforw2.dta
		erase transfcleanforw3.dta

//// wave 5
// Variable 10094 (Compensation payments received from insur. in reference period in PPP$) seems to be corrupted as it's values are extremely low (around 30-fold compared to the other waves), so it gets repaired. Variable 72201 (HH receives compensation payments: value, PPP USD) gets used.
cd "$cleandata_w5"
use insurclean.dta, clear
collapse (sum) _x72212, by(QID)
save insurclean1.dta, replace
use hhincclean.dta, clear
drop _x10093
drop if QID==.
tostring QID, replace
merge 1:1 QID using insurclean1.dta, keepusing (_x72212) keep(match master) nogen
merge 1:1 QID using transfclean1.dta, keepusing(_x10093) keep(match master) nogen
drop _x10094
rename _x72212 _x10094
label var _x10094 "Income from public transfers, PPP USD"
save hhincclean1.dta, replace
erase insurclean1.dta
erase transfclean1.dta


*****************************************************************************

//// wave 8
// creating the hhincclean-Dataset for wave 8
cd "${cleandata_w8}"
// Adding 10080: Remittances received from absent HH members
use members.dta, clear
sort interview__key
by interview__key: egen _x10080= sum(v21020) if v21019a__2==1 // v21020: Amount of money/value of gifts the HH received between 05/18-04/19, v21019a__2==1 means "Did HH member send money to the HH while being absent ==1 == yes"
by interview__key, sort: gen nvals = _n == 1 // Mark and drop all but the first observation of each interview__key (HH), so that per HH only one observation remains for merging later. This will be repeated in the following blocks for all datasets.
drop if nvals!=1
save membersforw8.dta, replace

// Adding 10081: Remittances received from friends/relatives
use HHDynamic.dta, clear
sort interview__key
by interview__key: egen _x10081= sum(v24012) // v24012: Amount of money/value of gifts the HH received between 05/18-04/19
by interview__key, sort: gen nvals = _n == 1
drop if nvals!=1
save HHdynamicforw8.dta, replace

// Adding 10082: Income from owner-occupied dwelling and 10083: Income from land rent
use land_used.dta, clear
sort interview__key
by interview__key: egen _x10082=sum(v41011j) if v41004==1 // v41011j: Total value of rent received between 05/18-04/19; v41004==1: Residential use. This isn't perfect, as there are very few observations.
sort interview__key
by interview__key: egen _x10083=sum(v41011j)
by interview__key, sort: gen nvals = _n == 1 
drop if nvals!=1 
save land_usedforw8.dta, replace

// Adding 10084: Income from crops
use crops_plots.dta, clear
sort interview__key
replace v42013b=0 if v42013b==-99 // v42013b==-99 is a label for Value of byproducts sold: Did not have any byproducts and needs to be deleted.
mvencode v42014 v42016 v42014b v42016b, mv(0) override // Replacing missing values in v42014, v42016, v42014b and v42016b with zeros, because otherwise if there is a missing value in one or more of the four variables, the variable ricerev that's created in the next line will become zero too. The option override needs to be used, because there are already zeros in these variables and Stata otherwise would stop as soon as it realizes. 
gen cropsrev = v42014*v42016 + v42014b*v42016b
by interview__key: egen _x10084=sum(cropsrev)
by interview__key, sort: gen nvals = _n == 1
drop if nvals!=1
save crops_plotsforw8.dta, replace

// Adding 10085: Total income from livestock
use livest.dta, clear
sort interview__key
by interview__key: egen _x10085=sum(v43110) // v43110: Sales value
by interview__key, sort: gen nvals = _n == 1
drop if nvals!=1
save livestforw8.dta, replace

// Adding 10086: Income from hunting
use natres.dta, clear
sort interview__key
egen rowtotal = rowtotal(v44017a) // v44017a: Value of quantity sold
by interview__key: egen _x10086=sum(rowtotal)
by interview__key, sort: gen nvals = _n == 1
drop if nvals!=1
save natresforw8.dta, replace

// Adding 10087: Income from off-farm (self)-employment
use offempl.dta, clear
sort interview__key
gen v51022new=v51022 * v51028a * v51029 if v51023==2 // v51022: Net wage in cash (including regular & irregular bonuses), v51028a: Average number of days worked per month in this job between 5/18-4/19, v51029: Number of months worked in this job between 5/18-4/19, v51023==2: Time unit for Net wage in cash: Day
replace v51022new=v51022 * v51029 if v51023==4 // v51023==2: Time unit for Net wage in cash: Month
replace v51022new=v51022 if v51023==5 | v51023==6 // v51023==5: Time unit for Net wage in cash: Year, v51023==6: Time unit for Net wage in cash: Lumpsum payment
by interview__key: egen _x10087=sum(v51022new)
by interview__key, sort: gen nvals = _n == 1
drop if nvals!=1
save offemplforw8.dta, replace

// Adding 10088: Income from self-employment. 60038 (Average monthly cash profit/loss) will be created out of the variables v61029 (volume of sales per month) - v61021 (monthly payroll) - v61033 (costs for input purchases) as described on page 55 of the Questionair of wave 5. Missing values will be treated as zeros, because otherwise if one or more of the three variables used have missing values 60038 will also have a missing value.
use selfempl.dta, clear
sort interview__key
foreach x of varlist v61029 v61021 v61033 {
	    replace `x'=0 if missing(`x')
		}
cap gen _x60038 = v61029 - v61021 - v61033
by interview__key: egen _x10088=sum(_x60038)
by interview__key, sort: gen nvals = _n == 1
drop if nvals!=1
save selfemplforw8.dta, replace


// Adding 10091: Income received from lending
use lending.dta, clear
sort interview__key
by interview__key: egen _x10091=sum(v71302b) // v71302b: Value of lendings that have been repaid to you between 5/18-4/19
by interview__key, sort: gen nvals = _n == 1
drop if nvals!=1
save lendingforw8.dta, replace

// Adding 10092: Income from savings
use savings.dta, clear
sort interview__key
by interview__key: egen _x10092=sum(v71420) // v71414: How much is the value?
by interview__key, sort: gen nvals = _n == 1
drop if nvals!=1
save savingsforw8.dta, replace

// Adding 10093: Transfer income received in reference period in PPP$
use pub_trans.dta, clear
sort interview__key
by interview__key: egen _x10093=sum(v72103) // v72103: Total value received between 5/18-4/19
by interview__key, sort: gen nvals = _n == 1
drop if nvals!=1
save pub_transforw8.dta, replace

// Adding 10094: Compensation payments received from insur. in reference period in PPP$
use insurance.dta, clear
sort interview__key
by interview__key: egen _x10094=sum(v72212) // Total amount of compensation payment HH received between 5/18 - 4/19?
by interview__key, sort: gen nvals = _n == 1
drop if nvals!=1
save insuranceforw8.dta, replace



// Merging
save hhincclean, replace emptyok // Creating an empty dataset "hhincclean"
use hhincclean.dta, clear // hhincclean is an empty dataset, so by appending it with the TVSEP2019-dataset the most important variables are added
drop * // Variables are dropped from possible previous run-throughs
append using TVSEP2019.dta, keep(interview__key interview__id v10001 v10002 v10003 v10004 v10005 QID)
merge 1:1 interview__key using membersforw8.dta, keepusing(_x10080) keep(match master) nogen
label var _x10080 "Remittances received from absent HH members"
merge 1:1 interview__key using HHDynamicforw8.dta, keepusing(_x10081) keep(match master) nogen
label var _x10081 "Remittances received from friends/relatives"
merge 1:1 interview__key using land_usedforw8.dta, keepusing(_x10082 _x10083) keep(match master) nogen
label var _x10082 "Income from owner-occupied dwelling"
label var _x10083 "Income from land rent"
merge 1:1 interview__key using crops_plotsforw8.dta, keepusing(_x10084) keep(match master) nogen
label var _x10084 "Income from crops"
merge 1:1 interview__key using livestforw8.dta, keepusing(_x10085) keep(match master) nogen
label var _x10085 "Total income from livestock"
merge 1:1 interview__key using natresforw8.dta, keepusing(_x10086) keep(match master) nogen
label var _x10086 "Income from hunting"
merge 1:1 interview__key using offemplforw8.dta, keepusing(_x10087) keep(match master) nogen
label var _x10087 "Income from off-farm (self)-employment"
merge 1:1 interview__key using selfemplforw8.dta, keepusing(_x10088) keep(match master) nogen
label var _x10088 "Income from self-employment"
merge 1:1 interview__key using lendingforw8.dta, keepusing(_x10091) keep(match master) nogen
label var _x10091 "Income received from lending"
merge 1:1 interview__key using savingsforw8.dta, keepusing(_x10092) keep(match master) nogen
label var _x10092 "Income from savings"
merge 1:1 interview__key using pub_transforw8.dta, keepusing(_x10093) keep(match master) nogen
label var _x10093 "Transfer income received in reference period in PPP$"
merge 1:1 interview__key using insuranceforw8.dta, keepusing(_x10094) keep(match master) nogen
label var _x10094 "Compensation payments received from insur. in reference period in PPP$"

// Adding 10100: Total annual household income (sum of 10080-10094)
egen _x10100=rowtotal(_x10080 _x10081 _x10082 _x10083 _x10084 _x10085 _x10086 _x10087 _x10088 _x10091 _x10092 _x10093 _x10094)
label var _x10100 "Total annual household income"
tostring QID, replace
save hhincclean.dta, replace

// Adding 12123: Number of household size (wider definition) hhincclean and to TVSEP20191
use members.dta, clear
cap gen __12123D=1
sort interview__key
cap by interview__key: egen _x12123=sum(__12123D)
by interview__key, sort: gen nvals = _n == 1 
drop if nvals!=1
save members3.dta, replace
use hhincclean.dta, clear
merge 1:m interview__key using members3.dta, keepusing (_x12123) keep(match master) nogen
by interview__key, sort: gen nvals = _n == 1 
drop if nvals!=1
save hhincclean.dta, replace
use TVSEP20191.dta, clear 
merge 1:m interview__key using members3.dta, keepusing (_x12123) keep(match master) nogen
save TVSEP20191.dta, replace

// egen __10101 still needs to be added once the household nucleus size variable (12122) exists.

erase membersforw8.dta
erase HHdynamicforw8.dta
erase land_usedforw8.dta
erase crops_plotsforw8.dta
erase livestforw8.dta
erase natresforw8.dta
erase offemplforw8.dta
erase selfemplforw8.dta
erase lendingforw8.dta
erase savingsforw8.dta
erase pub_transforw8.dta
erase insuranceforw8.dta
erase members3.dta