* Basic setting 

set more off
cap log close
clear all

* paths
global data "C:/Users/camilodel/Dropbox/Networks_Extractives_2020/DATA" // IDB laptop
global data "C:/Users/cdelo/Dropbox/Networks_Extractives_2020/DATA" // personal laptop
global tables "C:/Users/cdelo/Dropbox/Networks_Extractives_2020/tables" // personal laptop
global eam "${data}/rawdata/EAM"
/*
global rawdata_un "${data}/rawdata/undirected"
global rawdata_di "${data}/rawdata/directed"
global gephi_un "${data}/gephi_undirected2"
global gephi_di "${data}/gephi_directed"
capture mkdir "${gephi_un}/econometrics"
capture mkdir "${gephi_di}/econometrics"
*/


/*
			CORRELATIVAS
*/

import excel "${eam}/correlativas_ciiu-rev3.1_ciiu-rev4.xls", firstrow sheet("Sheet1") clear
ren *, lower
destring ciiu_rev3, replace
gen ciiu_rev4c=substr(ciiu_rev4,1,4)
drop ciiu_rev4
rename ciiu_rev4c ciiu_rev4
destring ciiu_rev4, replace
drop if ciiu_rev4==.
sa "${eam}/correlativas_3_4.dta", replace

/*
			Create clean EAM
*/

use "${eam}/EAM_2008.dta", clear
ren * ,lower
sa, replace
use "${eam}/EAM_2009.dta", clear
ren * ,lower
sa, replace
use "${eam}/EAM_2010.dta", clear
ren * ,lower
sa, replace
use "${eam}/EAM_2011.dta", clear
ren * ,lower
sa, replace
use "${eam}/EAM_2012.dta", clear
ren * ,lower
capture rename ciiu_4 ciiu4
sa, replace
use "${eam}/EAM_2013.dta", clear
ren * ,lower
capture rename ciiu_4 ciiu4
sa, replace


*  Use correlatives to give the appropiate ciiu_3 code to EAM 2012 & 2013. 

foreach x in 2012 2013{
	use "${eam}/EAM_`x'.dta", clear
	collapse(mean) c4r1c1n c4r1c2n c4r2c1e c4r2c2e c4r1c1 c4r1c2 c4r1c3 c4r1c4 c4r4c1t c4r4c2t c4r1c3n c4r1c4n c4r2c3e c4r2c4e c4r2c1 c4r2c2 c4r2c3 c4r2c4 c4r4c3t c4r4c4t c4r1c5n c4r1c6n c4r2c5e c4r2c6e c4r3c1 c4r3c2 c4r3c3 c4r3c4 c4r4c5t c4r4c6t c4r1c7n c4r1c8n c4r2c7e c4r2c8e c4r4c1 c4r4c2 c4r4c3 c4r4c4 c4r4c7t c4r4c8t c4r6mn c4r6hn c4r6me c4r6he c4r6om c4r6oh c4r6dm c4r6dh c4r6tm c4r6th c3r1pt c3r1c1 c3r1c2 c3r1c3 c3r2pt c3r2c1 c3r2c2 c3r2c3 c3r3pt c3r3c1 c3r3c2 c3r3c3 c3r4pt c3r4c1 c3r4c2 c3r4c3 c3r5pt c3r5c1 c3r5c2 c3r5c3 c3r6pt c3r6c1 c3r6c2 c3r6c3 porcon porcvt (sum) c4r1c9n c4r1c10n c4r2c9e c4r2c10e c4r5c1 c4r5c2 c4r5c3 c4r5c4 c4r4c9t c4r4c10t invebrta activfi persocu valagri valvfab, by(ciiu4 periodo)

	rename ciiu4 ciiu_rev4
	merge 1:m ciiu_rev4 using "${eam}/correlativas_3_4.dta", gen(_mergeciiu4) 
		drop if _mergeciiu4==2 // estos simplemente no están en la EAM; los que son igual a 1 simplemente, se quedaron constantes entre rev_3 y rev_4. 
	replace ciiu_rev3=ciiu_rev4 if ciiu_rev3==. // done. 
	rename ciiu_rev3 ciiu3
	sa "${eam}/EAM_c_`x'.dta", replace
}

* simply collapse the other data sets.

forvalues x=2008(1)2011{
	use "${eam}/EAM_`x'.dta", clear
	collapse(mean) c4r1c1n c4r1c2n c4r2c1e c4r2c2e c4r1c1 c4r1c2 c4r1c3 c4r1c4 c4r4c1t c4r4c2t c4r1c3n c4r1c4n c4r2c3e c4r2c4e c4r2c1 c4r2c2 c4r2c3 c4r2c4 c4r4c3t c4r4c4t c4r1c5n c4r1c6n c4r2c5e c4r2c6e c4r3c1 c4r3c2 c4r3c3 c4r3c4 c4r4c5t c4r4c6t c4r1c7n c4r1c8n c4r2c7e c4r2c8e c4r4c1 c4r4c2 c4r4c3 c4r4c4 c4r4c7t c4r4c8t c4r6mn c4r6hn c4r6me c4r6he c4r6om c4r6oh c4r6dm c4r6dh c4r6tm c4r6th c3r1pt c3r1c1 c3r1c2 c3r1c3 c3r2pt c3r2c1 c3r2c2 c3r2c3 c3r3pt c3r3c1 c3r3c2 c3r3c3 c3r4pt c3r4c1 c3r4c2 c3r4c3 c3r5pt c3r5c1 c3r5c2 c3r5c3 c3r6pt c3r6c1 c3r6c2 c3r6c3 porcon porcvt (sum) c4r1c9n c4r1c10n c4r2c9e c4r2c10e c4r5c1 c4r5c2 c4r5c3 c4r5c4 c4r4c9t c4r4c10t invebrta activfi persocu valagri valvfab, by(ciiu3 periodo)

	sa "${eam}/EAM_c_`x'.dta", replace
}

*append and create the whole data set of EAM. 

use "${eam}/EAM_c_2008.dta", clear
append using "${eam}/EAM_c_2009.dta"
append using "${eam}/EAM_c_2010.dta"
append using "${eam}/EAM_c_2011.dta"
append using "${eam}/EAM_c_2012.dta"
append using "${eam}/EAM_c_2013.dta"

collapse (mean) invebrta persocu valagri, by(ciiu3 period) // there are 8 duplicates from 2012 & 2013 related to the files of coorelativas. 

sa "${eam}/COL_EAM_national_2008_2013", replace




