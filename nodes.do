
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
global data "C:/Users/camilodel/Dropbox/Networks_Extractives_2020/DATA"
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

gen color="#3f3f3f" // the rest 
replace color="#60b543" if extractives_c==1
replace color="#e31809" if extractives_p==1
	
* assign size to nodes
	
gen sizefloat=13
replace sizefloat=20 if (extractives_c==1  | extractives_p==1)
	
/* Merge with coordinate data  // I still have to generate this data

cap drop id
merge m:1 ind_1 using "COL_nodes_coord.dta", gen(_merge6)
drop if _merge6==2
cap drop _merge6
*/

rename id_4 id
outsheet using "${gephi_un}/nodes_v1.csv", replace comma


/*
Second Version of this thing
*/

drop id_4
tostring id, g(id_4)
replace id_4="000"+id_4 if ind_i<10
replace id_4="00"+id_4 if ind_i>9 & ind_i<100
replace id_4="0"+id_4 if ind_i>99 & ind_i<1000

compress

gen ciiu_3=substr(id_4,1,3)
order ind_i id id_4 ciiu_3

/*
	replace id_1="A" if substr(ind_1,1,2)<"05"			 				// label
	replace id_1="B" if substr(ind_1,1,2)>="05" & substr(ind_1,1,2)<"10"	// label
	replace id_1="C" if substr(ind_1,1,2)>="10" & substr(ind_1,1,2)<"15"	// label
	replace id_1="D" if substr(ind_1,1,2)>="15" & substr(ind_1,1,2)<"45"	// label
	*replace id_1="E" if substr(ind_1,1,2)>=05 & substr(ind_1,1,2)<10	// label
	replace id_1="F" if substr(ind_1,1,2)>="45" & substr(ind_1,1,2)<"50"	// label
	replace id_1="G" if substr(ind_1,1,2)>="50" & substr(ind_1,1,2)<"55"	// label
	replace id_1="H" if substr(ind_1,1,2)>="55" & substr(ind_1,1,2)<"60"	// label
	replace id_1="I" if substr(ind_1,1,2)>="60" & substr(ind_1,1,2)<"65"	// label
	replace id_1="J" if substr(ind_1,1,2)>="65" & substr(ind_1,1,2)<"70"	// label
	replace id_1="K" if substr(ind_1,1,2)>="70" & substr(ind_1,1,2)<"75"	// label
	replace id_1="L" if substr(ind_1,1,2)>="75" & substr(ind_1,1,2)<"80"	// label
	replace id_1="M" if substr(ind_1,1,2)>="80" & substr(ind_1,1,2)<"85"	// label
	replace id_1="N" if substr(ind_1,1,2)>="85" & substr(ind_1,1,2)<"90"	// label
	replace id_1="O" if substr(ind_1,1,2)>="90" & substr(ind_1,1,2)<"95"	// label
	replace id_1="P" if substr(ind_1,1,2)>="95" & substr(ind_1,1,2)<"99"	// label
	replace id_1="Q" if substr(ind_1,1,2)>="99" 						// label
	rename id_1 code_1d_pila
	merge m:1 code_1d_pila using "C:\Users\alfre\Dropbox\Harvard\Job Placement\CID\Projects\Other\Oil (iadb)\dtafiles\temp_COL_02_01_labels_code_1d_pila.dta", gen(_merge8)
	rename code_1d_pila id_1
	replace color="255, 218, 251" if (id_1=="A" | id_1=="B")			// Agriculture, Fishing
	replace color="175,238,238" if (id_1=="D")		 					// Manufacture
	replace color="0,139,139" if (id_1=="F") 							// Construction
	replace color="255,165,0" if (id_1=="G" | id_1=="H") 				// Commerce, Tourism, Food Services
	replace color="255,215,0" if (id_1=="I")			 				// Transport
	replace color="240,230,140" if (id_1=="J")						 	// Finance
	replace color="154,205,50" if (id_1=="K")			 				// Real Estate
	replace color="0,128,0" if (id_1=="L" | id_1=="M" | id_1=="N" | id_1=="O") 	// Public Services / Government
	replace color="254,95,85" if  extractives_c==1		// Core Extractives
	replace color="199,239,207" if  extractives_p==1	// Extractives Periphery
	*replace color="199,239,207" if (id_1==A | id_1==B) 				//
	gen label_id=""
	replace label_id="Agriculture, Fishing" if  (id_1=="A" | id_1=="B")
	replace label_id="Manufacture" if (id_1=="D")
	replace label_id="Construction" if (id_1=="F") 
	replace label_id="Commerce, Tourism, Food Services" if (id_1=="G" | id_1=="H")
	replace label_id="Transport" if (id_1=="I")
	replace label_id="Finance" if (id_1=="J")
	replace label_id="Real Estate" if (id_1=="K")	
	replace label_id="Public Services / Government" if (id_1=="L" | id_1=="M" | id_1=="N" | id_1=="O") 
	replace label_id="Core Extractives" if extractives_c==1
	replace label_id="Extractives Periphery" if extractives_p==1
	cap drop label _merge8
	sa "COL_nodes_4d_2.dta", replace
	outsheet using "COL_nodes_4d_2.csv", replace comma
	
