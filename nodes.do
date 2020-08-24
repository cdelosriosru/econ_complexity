
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
global gephi_un "${data}/gephi_undirected"




* ASSIGNING PROPERTIES TO NODES FILE 
* Is is easier to simply combine both node color and labels in jsut one node csv. The changes are then easier to make in gephi. 
		* THIS IS FOLLOWING THE PREVIOUS WAY OF DOING IT. 

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
	

	
* assign color to nodes 

gen color="#B0A4A4" // the rest 
replace color="#60B543" if extractives_c==1
replace color="#E31809" if extractives_p==1
	
* assign size to nodes
	
gen sizefloat=13
replace sizefloat=20 if (extractives_c==1  | extractives_p==1)

* Some Labels

gen label_id="Core Extractives" if extractives_c==1
replace label_id="Extractives Periphery" if extractives_p==1
replace label_id="All other activities" if extractives_p!=1 & extractives_c!=1

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
replace colour="#B0A4A4" if  colour=="" & id_1=="C" // "63,63,63 this are part of category C; minerals and stuff but not within "core" or "periphery"

/*
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
*/
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


order id color colour label_id label_id2
outsheet using "${gephi_un}/nodes_all.csv", replace comma


		* THIS IS MY VERSION ADDING SOME NEW ACTIVITIES TO CORE AND PERIPHERY AS EXPLAINED IN THE EXCEL DOC.  

		
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
										| id_4==2720 | id_4==2731 | id_4==2732 | id_4==2811 | id_4==2891 | id_4==4020 ///
										| id_4==2721 | id_4==2729 | id_4==1431 | id_4==1432 | id_4==1411 | id_4==1412 | id_4==1413 | id_4==1414 | id_4==1415 )
replace extractives_p=1 if (id_4==2922 	| id_4==2923 | id_4==2924 | id_4==5050 | id_4==5141 | id_4==5142 | id_4==5143)

label var extractives_c "Core Extractives"
label var extractives_p "Extractives Periphery"	
	
	
	
* Merge with economic activity label data
	merge 1:1 id_4 using "${data}/rawdata/COL_02_01_labels_4d.dta", gen(mer_lab1)
	drop ind_1
	drop if mer_lab1==2 // three labels
	drop mer_lab1
	

	
* assign color to nodes 

gen color="#B0A4A4" // the rest 
replace color="#60B543" if extractives_c==1
replace color="#E31809" if extractives_p==1
	
* assign size to nodes
	
gen sizefloat=13
replace sizefloat=20 if (extractives_c==1  | extractives_p==1)

* Some Labels

gen label_id="Core Extractives" if extractives_c==1
replace label_id="Extractives Periphery" if extractives_p==1
replace label_id="All other activities" if extractives_p!=1 & extractives_c!=1

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
replace colour="#B0A4A4" if  colour=="" & id_1=="C" // "63,63,63 this are part of category C; minerals and stuff but not within "core" or "periphery"

/*
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
*/
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


order id color colour label_id label_id2
outsheet using "${gephi_un}/nodes_all_cdr.csv", replace comma





		* NOW USING CIIU REV 4 (I dont really buy this.)  

		
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
tostring id_4, replace
replace id_4="000"+id_4 if ind_i<10
replace id_4="00"+id_4 if ind_i>9 & ind_i<100
replace id_4="0"+id_4 if ind_i>99 & ind_i<1000
replace extractives_c=1 if substr(id_4,1,2)>="05" & substr(id_4,1,2)<"10"	// label
destring id_4, replace
replace extractives_p=1 if (id_4==2822 	| id_4==2823 | id_4==2824 | id_4==4661 | id_4==4662 | id_4==4663 | id_4==4664)

label var extractives_c "Core Extractives"
label var extractives_p "Extractives Periphery"	
	
	
	
* Merge with economic activity label data
	merge 1:1 id_4 using "${data}/rawdata/COL_02_01_labels_4d.dta", gen(mer_lab1)
	drop ind_1
	drop if mer_lab1==2 // three labels
	drop mer_lab1
	

	
* assign color to nodes 

gen color="#B0A4A4" // the rest 
replace color="#60B543" if extractives_c==1
replace color="#E31809" if extractives_p==1
	
* assign size to nodes
	
gen sizefloat=13
replace sizefloat=20 if (extractives_c==1  | extractives_p==1)

* Some Labels

gen label_id="Core Extractives" if extractives_c==1
replace label_id="Extractives Periphery" if extractives_p==1
replace label_id="All other activities" if extractives_p!=1 & extractives_c!=1

/*


To make the network analysis with other industry sectors. 

*/


tostring id_4, replace
replace id_4="000"+id_4 if ind_i<10
replace id_4="00"+id_4 if ind_i>9 & ind_i<100
replace id_4="0"+id_4 if ind_i>99 & ind_i<1000

compress

* create categories for labels and colors

gen id_1="A" if substr(id_4,1,2)<"03"			 				// label
replace id_1="B" if substr(id_4,1,2)>="05" & substr(id_4,1,2)<"10"	// label
replace id_1="C" if substr(id_4,1,2)>="10" & substr(id_4,1,2)<"34"
replace id_1="D" if substr(id_4,1,2)>="35" & substr(id_4,1,2)<"40"	// label
replace id_1="F" if substr(id_4,1,2)>="41" & substr(id_4,1,2)<"44"	// label
replace id_1="G" if substr(id_4,1,2)>="45" & substr(id_4,1,2)<"48"	// label
replace id_1="H" if substr(id_4,1,2)>="49" & substr(id_4,1,2)<"54"	// label
replace id_1="I" if substr(id_4,1,2)>="51" & substr(id_4,1,2)<"57"	// label
replace id_1="J" if substr(id_4,1,2)>="58" & substr(id_4,1,2)<"64"	// label
replace id_1="K" if substr(id_4,1,2)>="64" & substr(id_4,1,2)<"67"	// label
replace id_1="L" if substr(id_4,1,2)=="68"							// label
replace id_1="M" if substr(id_4,1,2)>="69" & substr(id_4,1,2)<"76"	// label
replace id_1="N" if substr(id_4,1,2)>="77" & substr(id_4,1,2)<"83"	// label
replace id_1="O" if substr(id_4,1,2)>="84" & substr(id_4,1,2)<"89"	// label
replace id_1="P" if substr(id_4,1,2)>="90" & substr(id_4,1,2)<"99"	// label
replace id_1="Q" if substr(id_4,1,2)>="99" 						// label



* Add labels

gen label_id2=""
replace label_id2="Agriculture, Forestry & Fishing" if  (id_1=="A")
replace label_id2="Mining, Oil & Gas Exploitation" if  (id_1=="B")
replace label_id2="Manufactures" if (id_1=="C")
replace label_id2="Basic needs services" if (id_1=="D")
replace label_id2="Construction" if (id_1=="F") 
replace label_id2="Commerce, food tourism services & automobile repair" if (id_1=="G" | id_1=="I")
replace label_id2="Transport" if (id_1=="H")
replace label_id2="Finance" if (id_1=="K")
replace label_id2="Real Estate" if (id_1=="L")	
replace label_id2="Public Services / Government" if (id_1=="P" | id_1=="M" | id_1=="N" | id_1=="O") 
replace label_id2="Core Extractives" if extractives_c==1
replace label_id2="Extractives Periphery" if extractives_p==1




* Add colors
gen colour=""
replace colour="#FFDAFB" if (id_1=="A")			// Agriculture, Fishing
replace colour="#AFEEEE" if (id_1=="C")		 					// Manufacture
replace colour="#008B8B" if (id_1=="F") 							// Construction
replace colour="#FFA500" if (id_1=="G" | id_1=="I") 				// "255,165,0" Commerce, Tourism, Food Services
replace colour="#FFD700" if (id_1=="H")			 				// "255,215,0" Transport
replace colour="#F0E68C" if (id_1=="K")						 	// "240,230,140" Finance
replace colour="#9ACD32" if (id_1=="L")			 				// "154,205,50" Real Estate
replace colour="#FF00FF" if (id_1=="P" | id_1=="M" | id_1=="N" | id_1=="O") 	// "0,128,0" Public Services / Government
replace colour="#60B543" if  extractives_c==1		// "96,181,67" Core Extractives
replace colour="#E31809" if  extractives_p==1	// ""227,24,9 Extractives Periphery
replace colour="#B0A4A4" if  colour=="" & id_1=="C" // "63,63,63 this are part of category C; minerals and stuff but not within "core" or "periphery"






/*
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
*/

* Save

rename id_4 id
destring id, replace
drop if id==. 


order id color colour label_id label_id2
outsheet using "${gephi_un}/nodes_all_cdr_rev4.csv", replace comma


