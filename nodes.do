
/*------------------------------------------------------------------------------
PROJECT :     			Network Analysis of Extractives (Colombia)
AUTHOR :				Camilo De Los Rios
PURPOSE :				Generates the nodes files for Gephi to map the industry space network.
------------------------------------------------------------------------------*/

* Basic setting 

set more off
cap log close
clear all

* paths
global data "C:/Users/camilodel/Dropbox/Networks_Extractives_2020/DATA" // IDB laptop
global data "C:/Users/cdelo/Dropbox/Networks_Extractives_2020/DATA" // personal laptop
global rawdata_un "${data}/rawdata/undirected"
global gephi_un "${data}/gephi_undirected2"




* 4 - ASSIGNING PROPERTIES TO NODES FILE (first version)
use "${rawdata_un}/col_sr_f.all_y.all_w.all_l.0.dta", clear
	
	* keep only the codes 
	
collapse (sum) flow, by(ind_i)
keep ind_i
gen id_4=ind_i



* Defining extractive activities
/*
This was the former distribution of the codes. I will propose a new one
		
*/
gen extractives_c=0
gen extractives_p=0
replace extractives_c=1 if (id_4==1010 	| id_4==1020 | id_4==1030 | id_4==1110 | id_4==1120 | id_4==1200 | id_4==1310  	  ///
										| id_4==1320 | id_4==1410 | id_4==1429 | id_4==2310 | id_4==2320 | id_4==2413 | id_4==2696 | id_4==2699 | id_4==2710  ///
										| id_4==2720 | id_4==2731 | id_4==2732 | id_4==2811 | id_4==2891 | id_4==4020)
replace extractives_p=1 if (id_4==2922 	| id_4==2923 | id_4==2924 | id_4==5050 | id_4==5141 | id_4==5142 | id_4==5143)

label var extractives_c "Core Extractives"
label var extractives_p "Extractives Periphery"	
	
	
	
* Merge with economic activity label data
	merge 1:1 id_4 using "${data}/rawdata/COL_02_01_labels_4d.dta", gen(mer_lab1)
	drop ind_1
	drop if mer_lab1==2 // three labels
	drop mer_lab1
	

	
* WE STILL HAVE WAY TO MANY INDUSTRIES WITHOUT LABELS! We should have them!



* assign color to nodes 

gen color="#3F3F3F" // the rest 
replace color="#60B543" if extractives_c==1
replace color="#E31809" if extractives_p==1
	
* assign size to nodes
	
gen sizefloat=13
replace sizefloat=20 if (extractives_c==1  | extractives_p==1)

* Some Labels

gen label_id="Core Extractives" if extractives_c==1
replace label_id="Extractives Periphery" if extractives_p==1
replace label_id="All other activities" if extractives_p!=1 & extractives_c!=1

/* Merge with coordinate data  // I still have to generate this data

cap drop id
merge m:1 ind_1 using "COL_nodes_coord.dta", gen(_merge6)
drop if _merge6==2
cap drop _merge6
*/

rename id_4 id
drop if id==. 
outsheet using "${gephi_un}/nodes_v1.csv", replace comma



/*
Second Version.

To make the network analysis with other industry sectors. 

*/

use "${rawdata_un}/col_sr_f.all_y.all_w.all_l.0.dta", clear

collapse (sum) flow, by(ind_i)
keep ind_i

tostring ind_i, g(id_4)
replace id_4="000"+id_4 if ind_i<10
replace id_4="00"+id_4 if ind_i>9 & ind_i<100
replace id_4="0"+id_4 if ind_i>99 & ind_i<1000

compress

*gen ciiu_3=substr(id_4,1,3)
*gen ciiu_2=substr(id_4,1,2)
*order ind_i id id_4 ciiu_3

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

destring id_4, replace

gen extractives_c=0
gen extractives_p=0
replace extractives_c=1 if (id_4==1010 	| id_4==1020 | id_4==1030 | id_4==1110 | id_4==1120 | id_4==1200 | id_4==1310  	  ///
										| id_4==1320 | id_4==1410 | id_4==1429 | id_4==2310 | id_4==2320 | id_4==2413 | id_4==2696 | id_4==2699 | id_4==2710  ///
										| id_4==2720 | id_4==2731 | id_4==2732 | id_4==2811 | id_4==2891 | id_4==4020)
replace extractives_p=1 if (id_4==2922 	| id_4==2923 | id_4==2924 | id_4==5050 | id_4==5141 | id_4==5142 | id_4==5143)

* Add colors

gen color="#FFDAFB" if (id_1=="A" | id_1=="B")			// Agriculture, Fishing
replace color="#AFEEEE" if (id_1=="D")		 					// Manufacture
replace color="#008B8B" if (id_1=="F") 							// Construction
replace color="#FFA500" if (id_1=="G" | id_1=="H") 				// "255,165,0" Commerce, Tourism, Food Services
replace color="#FFD700" if (id_1=="I")			 				// "255,215,0" Transport
replace color="#F0E68C" if (id_1=="J")						 	// "240,230,140" Finance
replace color="#9ACD32" if (id_1=="K")			 				// "154,205,50" Real Estate
replace color="#FF00FF" if (id_1=="L" | id_1=="M" | id_1=="N" | id_1=="O") 	// "0,128,0" Public Services / Government
replace color="#60B543" if  extractives_c==1		// "96,181,67" Core Extractives
replace color="#E31809" if  extractives_p==1	// ""227,24,9 Extractives Periphery

* Add labels

gen label_id=""
replace label_id="Agriculture, Forestry & Fishing" if  (id_1=="A" | id_1=="B")
replace label_id="Manufactures" if (id_1=="D")
replace label_id="Construction" if (id_1=="F") 
replace label_id="Commerce, Tourism & Food Services" if (id_1=="G" | id_1=="H")
replace label_id="Transport" if (id_1=="I")
replace label_id="Finance" if (id_1=="J")
replace label_id="Real Estate" if (id_1=="K")	
replace label_id="Public Services / Government" if (id_1=="L" | id_1=="M" | id_1=="N" | id_1=="O") 
replace label_id="Core Extractives" if extractives_c==1
replace label_id="Extractives Periphery" if extractives_p==1

* Save

rename id_4 id
destring id, replace
drop if id==. 
outsheet using "${gephi_un}/nodes_v2.csv", replace comma




* Is is easier to simply combine both node color and labels in jsut one node csv. The changes are then easier to make in gephi. 




*use data
use "${rawdata_un}/col_sr_f.all_y.all_w.all_l.0.dta", clear
	
	* keep only the codes 
	
collapse (sum) flow, by(ind_i)
keep ind_i
gen id_4=ind_i



* Defining extractive activities
/*
This was the former distribution of the codes. I will propose a new one
		
*/
gen extractives_c=0
gen extractives_p=0
replace extractives_c=1 if (id_4==1010 	| id_4==1020 | id_4==1030 | id_4==1110 | id_4==1120 | id_4==1200 | id_4==1310  	  ///
										| id_4==1320 | id_4==1410 | id_4==1429 | id_4==2310 | id_4==2320 | id_4==2413 | id_4==2696 | id_4==2699 | id_4==2710  ///
										| id_4==2720 | id_4==2731 | id_4==2732 | id_4==2811 | id_4==2891 | id_4==4020)
replace extractives_p=1 if (id_4==2922 	| id_4==2923 | id_4==2924 | id_4==5050 | id_4==5141 | id_4==5142 | id_4==5143)

label var extractives_c "Core Extractives"
label var extractives_p "Extractives Periphery"	
	
	
	
* Merge with economic activity label data
	merge 1:1 id_4 using "${data}/rawdata/COL_02_01_labels_4d.dta", gen(mer_lab1)
	drop ind_1
	drop if mer_lab1==2 // three labels
	drop mer_lab1
	

	
* WE STILL HAVE WAY TO MANY INDUSTRIES WITHOUT LABELS! We should have them!



* assign color to nodes 

gen color="#3F3F3F" // the rest 
replace color="#60B543" if extractives_c==1
replace color="#E31809" if extractives_p==1
	
* assign size to nodes
	
gen sizefloat=13
replace sizefloat=20 if (extractives_c==1  | extractives_p==1)

* Some Labels

gen label_id="Core Extractives" if extractives_c==1
replace label_id="Extractives Periphery" if extractives_p==1
replace label_id="All other activities" if extractives_p!=1 & extractives_c!=1

/* Merge with coordinate data  // I still have to generate this data

cap drop id
merge m:1 ind_1 using "COL_nodes_coord.dta", gen(_merge6)
drop if _merge6==2
cap drop _merge6
*/




/*


To make the network analysis with other industry sectors. 

*/


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

* Add colors
gen colour=""
replace colour="#FFDAFB" if (id_1=="A" | id_1=="B")			// Agriculture, Fishing
replace colour="#AFEEEE" if (id_1=="D")		 					// Manufacture
replace colour="#008B8B" if (id_1=="F") 							// Construction
replace colour="#FFA500" if (id_1=="G" | id_1=="H") 				// "255,165,0" Commerce, Tourism, Food Services
replace colour="#FFD700" if (id_1=="I")			 				// "255,215,0" Transport
replace colour="#F0E68C" if (id_1=="J")						 	// "240,230,140" Finance
replace colour="#9ACD32" if (id_1=="K")			 				// "154,205,50" Real Estate
replace colour="#FF00FF" if (id_1=="L" | id_1=="M" | id_1=="N" | id_1=="O") 	// "0,128,0" Public Services / Government
replace colour="#60B543" if  extractives_c==1		// "96,181,67" Core Extractives
replace colour="#E31809" if  extractives_p==1	// ""227,24,9 Extractives Periphery
replace colour="#3F3F3F" if  colour=="" & id_1=="C" // "63,63,63 this are part of category C; minerals and stuff but not within "core" or "periphery"


gen colour1=""
replace colour1="#FFDAFB" if (id_1=="A" | id_1=="B")			// Agriculture, Fishing
replace colour1="#AFEEEE" if (id_1=="D")		 					// Manufacture
replace colour1="#008B8B" if (id_1=="F") 							// Construction
replace colour1="#FFA500" if (id_1=="G" | id_1=="H") 				// "255,165,0" Commerce, Tourism, Food Services
replace colour1="#FFD700" if (id_1=="I")			 				// "255,215,0" Transport
replace colour1="#F0E68C" if (id_1=="J")						 	// "240,230,140" Finance
replace colour1="#9ACD32" if (id_1=="K")			 				// "154,205,50" Real Estate
replace colour1="#FF00FF" if (id_1=="L" | id_1=="M" | id_1=="N" | id_1=="O") 	// "0,128,0" Public Services / Government
replace colour1="#60B543" if  extractives_c==1		// "96,181,67" Core Extractives
replace colour1="#E31809" if  extractives_p==1	// ""227,24,9 Extractives Periphery




gen colour2=""
replace colour2="#FFDAFB" if (id_1=="A" | id_1=="B")			// Agriculture, Fishing
replace colour2="#AFEEEE" if (id_1=="D")		 					// Manufacture
replace colour2="#008B8B" if (id_1=="F") 							// Construction
replace colour2="#FFA500" if (id_1=="G" | id_1=="H") 				// "255,165,0" Commerce, Tourism, Food Services
replace colour2="#FFD700" if (id_1=="I")			 				// "255,215,0" Transport
replace colour2="#F0E68C" if (id_1=="J")						 	// "240,230,140" Finance
replace colour2="#9ACD32" if (id_1=="K")			 				// "154,205,50" Real Estate
replace colour2="#FF00FF" if (id_1=="L" | id_1=="M" | id_1=="N" | id_1=="O") 	// "0,128,0" Public Services / Government
replace colour2="#60B543" if  extractives_c==1		// "96,181,67" Core Extractives
replace colour2="#E31809" if  extractives_p==1	// ""227,24,9 Extractives Periphery
replace colour2="#8B3C6B" if  colour=="" & id_1=="C" // "246,246,15 this are part of category C; minerals and stuff but not within "core" or "periphery"

* Add labels

gen label_id2=""
replace label_id2="Agriculture, Forestry & Fishing" if  (id_1=="A" | id_1=="B")
replace label_id2="Manufactures" if (id_1=="D")
replace label_id2="Construction" if (id_1=="F") 
replace label_id2="Commerce, Tourism & Food Services" if (id_1=="G" | id_1=="H")
replace label_id2="Transport" if (id_1=="I")
replace label_id2="Finance" if (id_1=="J")
replace label_id2="Real Estate" if (id_1=="K")	
replace label_id2="Public Services / Government" if (id_1=="L" | id_1=="M" | id_1=="N" | id_1=="O") 
replace label_id2="Core Extractives" if extractives_c==1
replace label_id2="Extractives Periphery" if extractives_p==1

* Save

rename id_4 id
destring id, replace
drop if id==. 


order id color colour colour2 label_id label_id2
outsheet using "${gephi_un}/nodes_all.csv", replace comma






