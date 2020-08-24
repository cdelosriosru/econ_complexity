set more off
cap log close
clear all

* paths
global data "C:/Users/camilodel/Dropbox/Networks_Extractives_2020/DATA" // IDB laptop
global data "C:/Users/cdelo/Dropbox/Networks_Extractives_2020/DATA" // personal laptop
global tables "C:/Users/cdelo/Dropbox/Networks_Extractives_2020/tables" // personal laptop
global rawdata_un "${data}/rawdata/undirected"
global rawdata_di "${data}/rawdata/directed"
global gephi_un "${data}/gephi_undirected"
global gephi_di "${data}/gephi_directed"
capture mkdir "${gephi_un}/econometrics"
capture mkdir "${gephi_di}/econometrics"
global eam "${data}/rawdata/EAM"
global RESULTS "C:/Users/cdelo/Dropbox/Networks_Extractives_2020/RESULTS" // personal laptop



use "${gephi_di}/econometrics/COL_centrality_measures_total.dta", clear


keep id Source id out_* in*

rename ind_i id_4

gen extractives_c=0
gen extractives_p=0
replace extractives_c=1 if (id_4==1010 	| id_4==1020 | id_4==1030 | id_4==1110 | id_4==1120 | id_4==1200 | id_4==1310  	  ///
										| id_4==1320 | id_4==1410 | id_4==1429 | id_4==2310 | id_4==2320 | id_4==2413 | id_4==2696 | id_4==2699 | id_4==2710  ///
										| id_4==2720 | id_4==2731 | id_4==2732 | id_4==2811 | id_4==2891 | id_4==4020)
replace extractives_p=1 if (id_4==2922 	| id_4==2923 | id_4==2924 | id_4==5050 | id_4==5141 | id_4==5142 | id_4==5143)

label var extractives_c "Core Extractives"
label var extractives_p "Extractives Periphery"	

rename id_4 ind_i
rename id id_4

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
replace industry="Z" if (id_1=="C") & industry==""			 				// "154,205,50" Real Estate


foreach var in out_strength_yall_wall in_strength_yall_wall out_strength_y1_wall in_strength_y1_wall out_strength_y2_wall in_strength_y2_wall out_strength_y3_wall in_strength_y3_wall out_strength_yall_w1 in_strength_yall_w1 out_strength_yall_w2 in_strength_yall_w2 out_strength_yall_w3 in_strength_yall_w3 out_strength_yall_w4 in_strength_yall_w4{

	gen D`var'=`var'
}

tempfile first_col
collapse (mean) out_* in_* (median) Dout* Din*, by(industry)
sa `first_col'



use "${gephi_di}/econometrics/COL_centrality_measures_total.dta", clear


keep id Source id out_* in*

rename ind_i id_4

gen extractives_c=0
gen extractives_p=0
replace extractives_c=1 if (id_4==1010 	| id_4==1020 | id_4==1030 | id_4==1110 | id_4==1120 | id_4==1200 | id_4==1310  	  ///
										| id_4==1320 | id_4==1410 | id_4==1429 | id_4==2310 | id_4==2320 | id_4==2413 | id_4==2696 | id_4==2699 | id_4==2710  ///
										| id_4==2720 | id_4==2731 | id_4==2732 | id_4==2811 | id_4==2891 | id_4==4020)
replace extractives_p=1 if (id_4==2922 	| id_4==2923 | id_4==2924 | id_4==5050 | id_4==5141 | id_4==5142 | id_4==5143)

label var extractives_c "Core Extractives"
label var extractives_p "Extractives Periphery"	

rename id_4 ind_i
rename id id_4

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
replace industry="K" if  extractives_p==1	// ""227,24,9 Extractives Periphery
replace industry="Z" if (id_1=="C") & industry==""			 				// "154,205,50" Real Estate

keep if industry=="K"
replace industry="KAL" if industry=="K"


foreach var in out_strength_yall_wall in_strength_yall_wall out_strength_y1_wall in_strength_y1_wall out_strength_y2_wall in_strength_y2_wall out_strength_y3_wall in_strength_y3_wall out_strength_yall_w1 in_strength_yall_w1 out_strength_yall_w2 in_strength_yall_w2 out_strength_yall_w3 in_strength_yall_w3 out_strength_yall_w4 in_strength_yall_w4{

	gen D`var'=`var'
}

collapse (mean) out_* in_* (median) Dout* Din*, by(industry)

append using `first_col'


sa "${RESULTS}/Out_In.dta", replace

use "${RESULTS}/Out_In.dta", clear

replace industry="Agriculture" if industry=="A"
replace industry="Manufacture" if industry=="B"
replace industry="Construction" if industry=="C"
replace industry="Commerce" if industry=="D"
replace industry="Transport" if industry=="F"
replace industry="Finance" if industry=="G"
replace industry="Real_Estate" if industry=="I"
replace industry="Government" if industry=="J"
replace industry="Core" if industry=="K"
replace industry="Extractives" if industry=="KAL"
replace industry="Periphery" if industry=="L"
replace industry="Cat_C" if industry=="Z"

levelsof industry, local(indus)

foreach z in `indus' {
	
	preserve
	
		keep if industry=="`z'"
		keep industry *yall* 
		
		foreach x in out_ in_ Dout_ Din_ {
			rename `x'strength_yall_wall `x'strength_yall_w5
		}

		reshape long out_strength_yall_w in_strength_yall_w Dout_strength_yall_w Din_strength_yall_w, i(industry) j(wagegroup)
		
		foreach x in out_strength_yall_w in_strength_yall_w Dout_strength_yall_w Din_strength_yall_w {
			sort `x'
			export excel wagegroup `x' using "${RESULTS}/in_out_`z'.xls", sheet("`x'", replace) firstrow(variables)
		}	
	
	restore
	
	preserve
		
		keep if industry=="`z'"
		keep industry *wall* 
		drop *yall*
		rename industry industry_w
	
		foreach v of var * {
			local new = substr("`v'", 1, strpos("`v'","w")-2)
			rename `v' `new'
		}
		
		reshape long out_strength_y in_strength_y Dout_strength_y Din_strength_y, i(industry) j(subperiod)

		foreach x in out_strength_y in_strength_y Dout_strength_y Din_strength_y {
			sort `x'
			export excel subperiod `x' using "${RESULTS}/in_out_`z'.xls", sheet("Y`x'", replace) firstrow(variables)
		}
		
	restore
}
	












































