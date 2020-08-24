* I promise this is the last code that you will have to run. 

set more off, perm
global mac "/Volumes/Thunder"
global main2 "/disk/homedirs/nber/adkugler/bulk" // nber
global main "/Users/Luisin/Desktop/Networks"
cd "$main"

use "rawdata/PILA_colombia/PILAAfull.dta", clear 

ren * ,lower

gen empleo=1
collapse (sum) empleo, by(codigo_actividad_economica ano)
drop if ano==2009
drop if ano==2012	
sort codigo_actividad_economica ano 
capture replace codigo_actividad_economica=" " if codigo_actividad_economica=="NA"
capture drop if codigo_actividad_economica==" "
capture drop if codigo_actividad_economica==.
fillin codigo_actividad_economica ano
sort codigo_actividad_economica ano 
bys codigo_actividad_economica: gen time=_n

keep empleo codigo_actividad_economica time 
	
sort codigo_actividad_economica time
xtset codigo_actividad_economica time
		
gen growth=(F.empleo-empleo)/((F.empleo+empleo)/2)
sa "dtafiles/emp_growth.dta", replace
	
* Ok after the data from Luis Comes: 


global data "C:/Users/cdelo/Dropbox/Networks_Extractives_2020/DATA" // personal laptop
global tables "C:/Users/cdelo/Dropbox/Networks_Extractives_2020/tables" // personal laptop

use "${data}/emp_growth.dta", clear

capture destring codigo_actividad_economica, gen(id_4)
capture gen id_4 = codigo_actividad_economica

gen extractives_c=0
gen extractives_p=0
replace extractives_c=1 if (id_4==1010 	| id_4==1020 | id_4==1030 | id_4==1110 | id_4==1120 | id_4==1200 | id_4==1310  	  ///
										| id_4==1320 | id_4==1410 | id_4==1429 | id_4==2310 | id_4==2320 | id_4==2413 | id_4==2696 | id_4==2699 | id_4==2710  ///
										| id_4==2720 | id_4==2731 | id_4==2732 | id_4==2811 | id_4==2891 | id_4==4020)
replace extractives_p=1 if (id_4==2922 	| id_4==2923 | id_4==2924 | id_4==5050 | id_4==5141 | id_4==5142 | id_4==5143)

label var extractives_c "Core Extractives"
label var extractives_p "Extractives Periphery"	

rename codigo_actividad_economica ind_i
tostring id_4, replace
replace id_4="000"+id_4 if ind_i<10
replace id_4="00"+id_4 if ind_i>9 & ind_i<100
replace id_4="0"+id_4 if ind_i>99 & ind_i<1000

compress

* create categories for labels and colors

gen id_1="A" if substr(id_4,1,2)<"05"			 				// label
replace id_1="B" if substr(id_4,1,2)>="05" & substr(id_4,1,2)<"10"	// label
replace id_1="C" if substr(id_4,1,2)>="10" & substr(id_4,1,2)<"15"
replace id_1="D" if substr(id_4,1,2)>="15" & substr(id_4,1,2)<"45"	// label
replace id_1="F" if substr(id_4,1,2)>="45" & substr(id_4,1,2)<"50"	// label
replace id_1="G" if substr(id_4,1,2)>="50" & substr(id_4,1,2)<"55"	// label
replace id_1="H" if substr(id_4,1,2)>="55" & substr(id_4,1,2)<"60"	// label
replace id_1="I" if substr(id_4,1,2)>="60" & substr(id_4,1,2)<"65"	// label
replace id_1="J" if substr(id_4,1,2)>="65" & substr(id_4,1,2)<"70"	// label
replace id_1="K" if substr(id_4,1,2)>="70" & substr(id_4,1,2)<"75"	// label
replace id_1="L" if substr(id_4,1,2)>="75" & substr(id_4,1,2)<"80"	// label
replace id_1="M" if substr(id_4,1,2)>="80" & substr(id_4,1,2)<"85"	// label
replace id_1="N" if substr(id_4,1,2)>="85" & substr(id_4,1,2)<"90"	// label
replace id_1="O" if substr(id_4,1,2)>="90" & substr(id_4,1,2)<"95"	// label
replace id_1="P" if substr(id_4,1,2)>="95" & substr(id_4,1,2)<"99"	// label
replace id_1="Q" if substr(id_4,1,2)>="99" 						// label

* Create the industry variable (this gathers some industries so it is easy to interpret)

gen industry=""
replace industry="A" if (id_1=="A" | id_1=="B")			// Agriculture, Fishing
replace industry="B" if (id_1=="D")		 					// Manufacture
replace industry="C" if (id_1=="F") 							// Construction
replace industry="D" if (id_1=="G" | id_1=="H") 				// "255,165,0" Commerce, Tourism, Food Services
replace industry="F" if (id_1=="I")			 				// "255,215,0" Transport
replace industry="G" if (id_1=="J")						 	// "240,230,140" Finance
replace industry="I" if (id_1=="K")			 				// "154,205,50" Real Estate
replace industry="J" if (id_1=="L" | id_1=="M" | id_1=="N" | id_1=="O") 	// "0,128,0" Public Services / Government
replace industry="K" if  extractives_c==1		// "96,181,67" Core Extractives
replace industry="L" if  extractives_p==1	// ""227,24,9 Extractives Periphery

tab industry, gen(industries)
gen industries11=1 if industry=="K" | industry=="L" 

forvalues x=1(1)11{

	preserve 
		keep if industries`x'==1
		keep id_4 time growth 
		rename growth growth_`x'
		gen id_cam=_n
		sa "${data}/growth_`x'.dta", replace
	restore
}

use "${data}/growth_1.dta", clear

forvalues x=2(1)11{

	merge 1:1 id_cam using "${data}/growth_`x'.dta", gen(m_`x')

}

rename growth_1 Agriculture_emp
rename growth_2 Manufacture_emp
rename growth_3 Construction_emp
rename growth_4 Commerce_emp
rename growth_5 Transport_emp
rename growth_6 Finance_emp
rename growth_7 RealEstate_emp
rename growth_8 Government_emp
rename growth_9 Core_emp
rename growth_10 Periphery_emp
rename growth_11 Exctractives_all_emp

* NOW THE CORRELATIONS. 

	*For the whole period. 

pwcorr *_emp
matrix A=r(C)

outtable using "${tables}/corr_employement", mat(A) replace cap("Employement growth correlation. Whole period") f(%9.3f)

	* For each subperiod. 

	

forvalues x=1(1)11{
	
	use "${data}/growth_`x'.dta", clear
	
	drop id_cam
	
	gen year=.
	replace year=2008 if time==1
	replace year=2010 if time==2
	replace year=2011 if time==3
	replace year=2013 if time==4

	expand 2 if time==2
	sort id_4 year
	egen ano_2=tag(id_4 year) 
	replace year=2009 if ano_2==0
	drop ano_2

	expand 2 if time==3
	egen ano_3=tag(id_4 year) 
	replace year=2012 if ano_3==0
	drop ano_3

	gen year_pair=0
	replace year_pair=1 if (year==2008 | year==2009) // notice this subperiod is actually 2008 - 2010
	replace year_pair=2 if (year==2010 | year==2011)
	replace year_pair=3 if (year==2012) // notice this subperiod is just growth in 2011, because we cant have it for 2013 and there is no data for 2012
	
	
	forvalues y=1(1)3{
	
		preserve 
		keep if year_pair==`y'
		gen id_cam=_n
		sa "${data}/growth_`x'_`y'.dta", replace
		restore
	}

}
	


forvalues y=1/3 {


	use "${data}/growth_1_`y'.dta", clear

	forvalues x=2(1)11{

		merge 1:1 id_cam using "${data}/growth_`x'_`y'.dta", gen(m_`x')

	}
	
	rename growth_1 Agriculture_emp
	rename growth_2 Manufacture_emp
	rename growth_3 Construction_emp
	rename growth_4 Commerce_emp
	rename growth_5 Transport_emp
	rename growth_6 Finance_emp
	rename growth_7 RealEstate_emp
	rename growth_8 Government_emp
	rename growth_9 Core_emp
	rename growth_10 Periphery_emp
	rename growth_11 Exctractives_all_emp

	pwcorr *_emp
	matrix A=r(C)
	outtable using "${tables}/corr_employement_`y'", mat(A) replace cap("Employement growth correlation. Subperiod `y'") f(%9.3f)
		
}



