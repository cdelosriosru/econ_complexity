
*ECONOMETRICS.

*SO NOW ITS REAL AND YOU WILL DO THE ECONOMETRICS RIGHT AWAY!.

/* NEEDS

Archivo de Nodos. -> para usar las caracter´siticas de los c+odigos industriales
Archivo de edges -> apra usar los pesos y poder hablar de centralidad. ES LA RED COMPLETA 

*/




* Basic setting 

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



/*------------------------------------------------------------------------------
						NODES CONVERSIONS
------------------------------------------------------------------------------*/

import delimited "${gephi_un}/nodes_all.csv", case(preserve) clear

tostring id, replace

sa  "${gephi_un}/nodes_all.dta", replace



/*------------------------------------------------------------------------------
--------------------------------------------------------------------------------
						
						PREPARING DATA AND 
						OBTAINING MEASURES
						
--------------------------------------------------------------------------------
------------------------------------------------------------------------------*/



/*------------------------------------------------------------------------------
						FOR THE UNDIRECTED NETWORKS
------------------------------------------------------------------------------*/
foreach y in all 1 2 3 {

	foreach w in all 1 2 3 4 {
	
		use "${rawdata_un}/col_sr_f.all_y.`y'_w.`w'_l.0.dta", clear

		
		rename ind_i Source
		rename ind_j Target
		keep Source Target SRt
				
		gen extractives_c=0
		gen extractives_p=0
		gen id_4=Target


		replace extractives_c=1 if (id_4==1010 | id_4==1020 | id_4==1030 | id_4==1110 | id_4==1120 | id_4==1200 | id_4==1310 | id_4==1320 | id_4==1410 | id_4==1429 | id_4==2310 | id_4==2320 | id_4==2413 | id_4==2696 | id_4==2699 | id_4==2710 | id_4==2720 | id_4==2731 | id_4==2732 | id_4==2811 | id_4==2891 | id_4==4020)
		replace extractives_p=1 if (id_4==2922 | id_4==2923 | id_4==2924 | id_4==5050 | id_4==5141 | id_4==5142 | id_4==5143)
		label var extractives_c "Core Extractives"
		label var extractives_p "Extractives Periphery"
	
		bysort Source: egen strength_ex_c=mean(SRt) if extractives_c==1
		bysort Source: egen strength_ex_p=mean(SRt) if extractives_p==1
	*	replace strength_ex_c =0 if strength_ex_c==. // if we make this first, then it would not work. 
	*	replace strength_ex_p =0 if strength_ex_p==.
		
		bysort Source (strength_ex_c) : gen strength_ex_c2 = strength_ex_c[1]  // If we make the recode before this step, it is the mean only if the value of line 82<0, otherwise it would take the value of 0
		bysort Source (strength_ex_p) : gen strength_ex_p2 = strength_ex_p[1] 
		
		recode strength_ex_c(.=0) 
		recode strength_ex_p(.=0) 
		recode strength_ex_c2(.=0) 
		recode strength_ex_p2(.=0) // Now we are talking. Here we can make the replacement. 



		
		/*
			PAGE 15 OF PAPER
			
		Dist_i,j,w will be given by the network distance between economic activity i and extractive activities j ,
		which will be constructed based on the skill-relatedness measure discussed in Section II, which in this
		case will correspond to the industry space built by accounting for labor flow between all workers w.
		
		So why dont we do exactly that here?
		
		*/
		
		drop strength_ex_c strength_ex_p
		rename strength_ex_c2 strength_ex_c_y`y'_w`w'
		rename strength_ex_p2 strength_ex_p_y`y'_w`w'
		label variable strength_ex_c_y`y'_w`w' "Strength (degree) of connection to Core Extractive Activities y`y'_w`w'" 
		label variable strength_ex_p_y`y'_w`w' "Strength (degree) of connection to Periphery Extractive Activities y`y'_w`w'"
		collapse (first) strength_ex_c_y`y'_w`w' strength_ex_p_y`y'_w`w', by(Source)
		
		tostring Source, gen(id)

		sa "${gephi_un}/econometrics/COL_edges_c_ext_4d_y`y'_w`w'.dta", replace
		
		use "${rawdata_un}/col_sr_f.all_y.`y'_w.`w'_l.0.dta", clear

		sort ij_group  // don´t really know why but it seems necessary. 
		
		tostring ind_i, gen(Source)
		tostring ind_j, gen(Target)
		keep Source Target SRt
		
		capture nwset, clear
		mata: mata clear



		nwset Source Target SRt, edgelist undirected name(y`y'_w`w')	
				
		nwdegree y`y'_w`w', isolates valued standardize  		// Degree centrality
		*nwbetween y`y'_w`w', standardize						// Betweeness centrality
		nwcloseness y`y'_w`w', unconnected(max)				// Closeness centrality		
		
		keep _nodelab _strength _isolate _closeness _farness _nearness
		gen id=substr(_nodelab,2,.)

		egen rank_strength_y`y'_w`w' = rank(_strength), field
		egen rank_closeness_y`y'_w`w' = rank(_closeness), field
		egen rank_farness_y`y'_w`w' = rank(_farness), field
		egen rank_nearness_y`y'_w`w' = rank(_nearness), field
		cap rename _strength strength_y`y'_w`w'
		cap rename _isolate isolate_y`y'_w`w'
		cap rename _closeness closeness_y`y'_w`w'
		cap rename _farness farness_y`y'_w`w'
		cap rename _nearness nearness_y`y'_w`w'

		sa "${gephi_un}/econometrics/COL_centrality_y`y'_w`w'", replace


		use "${gephi_un}/nodes_all.dta", clear
		merge 1:1 id using "${gephi_un}/econometrics/COL_centrality_y`y'_w`w'", gen(_merge_y`y'_w`w')

		merge 1:1 id using "${gephi_un}/econometrics/COL_edges_c_ext_4d_y`y'_w`w'.dta", gen(_merge_c_ext_y`y'_w`w')
		drop _merge*
		sa "${gephi_un}/econometrics/COL_nodes_4d_2_y`y'_w`w'.dta", replace
	}

}

 * I think this is what you did the last time but cant be certain. 
 
use "${gephi_un}/econometrics/COL_nodes_4d_2_yall_wall.dta", clear 

foreach y in  1 2 3 {
	foreach w in 1 2 3 4 {
		merge 1:1  id using "${gephi_un}/econometrics/COL_centrality_y`y'_w`w'.dta", gen(m_`y'_`w')
	}
}

foreach w in 1 2 3 4 {
	merge 1:1  id using "${gephi_un}/econometrics/COL_centrality_yall_w`w'.dta", gen(m_all_`w')
}

foreach y in  1 2 3 {
	merge 1:1  id using "${gephi_un}/econometrics/COL_centrality_y`y'_wall.dta", gen(m_`y'_all)
}

sa "${gephi_un}/econometrics/COL_centrality_measures_total.dta", replace



/*------------------------------------------------------------------------------
						FOR THE DIRECTED NETWORKS
------------------------------------------------------------------------------*/



foreach y in all {

	foreach w in all 1 2 3 4 {

		use "${rawdata_di}/col_sr_f.I2_y.`y'_w.`w'_l.0.dta", clear
		
		rename ind_i Source
		rename ind_j Target
		keep Source Target SRt
				
		gen extractives_c=0
		gen extractives_p=0
		
		gen id_4=Target

		replace extractives_c=1 if (id_4==1010 | id_4==1020 | id_4==1030 | id_4==1110 | id_4==1120 | id_4==1200 | id_4==1310 | id_4==1320 | id_4==1410 | id_4==1429 | id_4==2310 | id_4==2320 | id_4==2413 | id_4==2696 | id_4==2699 | id_4==2710 | id_4==2720 | id_4==2731 | id_4==2732 | id_4==2811 | id_4==2891 | id_4==4020)
		replace extractives_p=1 if (id_4==2922 | id_4==2923 | id_4==2924 | id_4==5050 | id_4==5141 | id_4==5142 | id_4==5143)
		label var extractives_c "Core Extractives"
		label var extractives_p "Extractives Periphery"
	
		bysort Source: egen strength_ex_c=mean(SRt) if extractives_c==1
		bysort Source: egen strength_ex_p=mean(SRt) if extractives_p==1
	*	replace strength_ex_c =0 if strength_ex_c==.
	*	replace strength_ex_p =0 if strength_ex_p==.
	
		bysort Source (strength_ex_c) : gen strength_ex_c2 = strength_ex_c[1]  
		bysort Source (strength_ex_p) : gen strength_ex_p2 = strength_ex_p[1] 
		
		recode strength_ex_c(.=0) 
		recode strength_ex_p(.=0) 
		recode strength_ex_c2(.=0) 
		recode strength_ex_p2(.=0) // Now we are talkin. Here we can make the replacement. 
		
		/*
			PAGE 15 OF PAPER
			
		Dist_i,j,w will be given by the network distance between economic activity i and extractive activities j ,
		which will be constructed based on the skill-relatedness measure discussed in Section II, which in this
		case will correspond to the industry space built by accounting for labor flow between all workers w.
		
		So why dont we do exactly that here?
		
		*/
		
		drop strength_ex_c strength_ex_p
		rename strength_ex_c2 strength_ex_c_y`y'_w`w'
		rename strength_ex_p2 strength_ex_p_y`y'_w`w'
		label variable strength_ex_c_y`y'_w`w' "Strength (degree) of connection to Core Extractive Activities y`y'_w`w'" // I dont get this measure
		label variable strength_ex_p_y`y'_w`w' "Strength (degree) of connection to Periphery Extractive Activities y`y'_w`w'"
		collapse (first) strength_ex_c_y`y'_w`w' strength_ex_p_y`y'_w`w', by(Source)
		
		tostring Source, gen(id)

		sa "${gephi_di}/econometrics/COL_edges_c_ext_4d_y`y'_w`w'.dta", replace
		
		use "${rawdata_di}/col_sr_f.I2_y.`y'_w.`w'_l.0.dta", clear

		tostring ind_i, gen(id_s)
		tostring ind_j, gen(id_j)

		sort ij_group  // don´t really know why but it seems necessary. 

		capture nwset, clear
		mata: mata clear
		
		nwset id_s id_j SRt, edgelist directed name(y`y'_w`w')
				
		nwdegree y`y'_w`w', isolates valued standardize  		// Degree centrality
		nwcloseness y`y'_w`w', unconnected(max)				// Closeness centrality		
				
		keep _nodelab *_strength _isolate _closeness _farness _nearness
		gen id=substr(_nodelab,2,.)
				
		egen rank_out_strength_y`y'_w`w' = rank(_out_strength), field
		egen rank_in_strength_y`y'_w`w' = rank(_in_strength), field
		egen rank_closeness_y`y'_w`w' = rank(_closeness), field
		egen rank_farness_y`y'_w`w' = rank(_farness), field
		egen rank_nearness_y`y'_w`w' = rank(_nearness), field
		cap rename _out_strength out_strength_y`y'_w`w'
		cap rename _in_strength in_strength_y`y'_w`w'
		cap rename _isolate isolate_y`y'_w`w'
		cap rename _closeness closeness_y`y'_w`w'
		cap rename _farness farness_y`y'_w`w'
		cap rename _nearness nearness_y`y'_w`w'

		sa "${gephi_di}/econometrics/COL_centrality_y`y'_w`w'", replace


		use "${gephi_un}/nodes_all.dta", clear // this is simply the nodes information. That is why i keep the undirected path
		merge 1:1 id using "${gephi_di}/econometrics/COL_centrality_y`y'_w`w'", gen(_merge_y`y'_w`w')


		merge 1:1 id using "${gephi_di}/econometrics/COL_edges_c_ext_4d_y`y'_w`w'.dta", gen(_merge_c_ext_y`y'_w`w')
		drop _merge*
		sa "${gephi_di}/econometrics/COL_nodes_4d_2_y`y'_w`w'.dta", replace

	}
}


foreach y in 1 2 3 {

	foreach w in all{

		use "${rawdata_di}/col_sr_f.I2_y.`y'_w.`w'_l.0.dta", clear
		
		rename ind_i Source
		rename ind_j Target
		keep Source Target SRt
				
		gen extractives_c=0
		gen extractives_p=0
		
		gen id_4=Target

		replace extractives_c=1 if (id_4==1010 | id_4==1020 | id_4==1030 | id_4==1110 | id_4==1120 | id_4==1200 | id_4==1310 | id_4==1320 | id_4==1410 | id_4==1429 | id_4==2310 | id_4==2320 | id_4==2413 | id_4==2696 | id_4==2699 | id_4==2710 | id_4==2720 | id_4==2731 | id_4==2732 | id_4==2811 | id_4==2891 | id_4==4020)
		replace extractives_p=1 if (id_4==2922 | id_4==2923 | id_4==2924 | id_4==5050 | id_4==5141 | id_4==5142 | id_4==5143)
		label var extractives_c "Core Extractives"
		label var extractives_p "Extractives Periphery"
	
		bysort Source: egen strength_ex_c=mean(SRt) if extractives_c==1
		bysort Source: egen strength_ex_p=mean(SRt) if extractives_p==1
	*	replace strength_ex_c =0 if strength_ex_c==.
	*	replace strength_ex_p =0 if strength_ex_p==.
	
		bysort Source (strength_ex_c) : gen strength_ex_c2 = strength_ex_c[1]  // this is the Min. Why? Why dont we use the Max?
		bysort Source (strength_ex_p) : gen strength_ex_p2 = strength_ex_p[1] 
		
		recode strength_ex_c(.=0) 
		recode strength_ex_p(.=0) 
		recode strength_ex_c2(.=0) 
		recode strength_ex_p2(.=0) // Now we are talkin. Here we can make the replacement. 
		
		/*
			PAGE 15 OF PAPER
			
		Dist_i,j,w will be given by the network distance between economic activity i and extractive activities j ,
		which will be constructed based on the skill-relatedness measure discussed in Section II, which in this
		case will correspond to the industry space built by accounting for labor flow between all workers w.
		
		So why dont we do exactly that here?
		
		*/
		
		drop strength_ex_c strength_ex_p
		rename strength_ex_c2 strength_ex_c_y`y'_w`w'
		rename strength_ex_p2 strength_ex_p_y`y'_w`w'
		label variable strength_ex_c_y`y'_w`w' "Strength (degree) of connection to Core Extractive Activities y`y'_w`w'" // I dont get this measure
		label variable strength_ex_p_y`y'_w`w' "Strength (degree) of connection to Periphery Extractive Activities y`y'_w`w'"
		collapse (first) strength_ex_c_y`y'_w`w' strength_ex_p_y`y'_w`w', by(Source)
		
		tostring Source, gen(id)

		sa "${gephi_di}/econometrics/COL_edges_c_ext_4d_y`y'_w`w'.dta", replace
		
		use "${rawdata_di}/col_sr_f.I2_y.`y'_w.`w'_l.0.dta", clear

		tostring ind_i, gen(id_s)
		tostring ind_j, gen(id_j)

		sort ij_group  // don´t really know why but it seems necessary. 

		capture nwset, clear
		mata: mata clear
		
		nwset id_s id_j SRt, edgelist directed name(y`y'_w`w')
				
		nwdegree y`y'_w`w', isolates valued standardize  		// Degree centrality
		nwcloseness y`y'_w`w', unconnected(max)				// Closeness centrality		
				
		keep _nodelab *_strength _isolate _closeness _farness _nearness
		gen id=substr(_nodelab,2,.)
				
		egen rank_out_strength_y`y'_w`w' = rank(_out_strength), field
		egen rank_in_strength_y`y'_w`w' = rank(_in_strength), field
		egen rank_closeness_y`y'_w`w' = rank(_closeness), field
		egen rank_farness_y`y'_w`w' = rank(_farness), field
		egen rank_nearness_y`y'_w`w' = rank(_nearness), field
		cap rename _out_strength out_strength_y`y'_w`w'
		cap rename _in_strength in_strength_y`y'_w`w'
		cap rename _isolate isolate_y`y'_w`w'
		cap rename _closeness closeness_y`y'_w`w'
		cap rename _farness farness_y`y'_w`w'
		cap rename _nearness nearness_y`y'_w`w'

		sa "${gephi_di}/econometrics/COL_centrality_y`y'_w`w'", replace


		use "${gephi_un}/nodes_all.dta", clear // this is simply the nodes information. That is why i keep the undirected path
		merge 1:1 id using "${gephi_di}/econometrics/COL_centrality_y`y'_w`w'", gen(_merge_y`y'_w`w')


		merge 1:1 id using "${gephi_di}/econometrics/COL_edges_c_ext_4d_y`y'_w`w'.dta", gen(_merge_c_ext_y`y'_w`w')
		drop _merge*
		sa "${gephi_di}/econometrics/COL_nodes_4d_2_y`y'_w`w'.dta", replace

	}
}




 * I think this is what you did the last time but cant be certain. 
 
use "${gephi_di}/econometrics/COL_nodes_4d_2_yall_wall.dta", clear 

foreach y in  1 2 3 {
		merge 1:1  id using "${gephi_di}/econometrics/COL_centrality_y`y'_wall.dta", gen(m_`y'_`w')
}

foreach w in 1 2 3 4 {
	merge 1:1  id using "${gephi_di}/econometrics/COL_centrality_yall_w`w'.dta", gen(m_all_`w')
}

sa "${gephi_di}/econometrics/COL_centrality_measures_total.dta", replace

/*------------------------------------------------------------------------------
--------------------------------------------------------------------------------
								
								EQUATIONS
								
--------------------------------------------------------------------------------
------------------------------------------------------------------------------*/


/*------------------------------------------------------------------------------							
								EQUATION 8								
------------------------------------------------------------------------------*/


*			UNDIRECTED

use "${gephi_un}/econometrics/COL_centrality_measures_total.dta", clear 


foreach var in strength    {  // this table simple has the means for every group which is precisely what equation 8 makes. 
	foreach w in all 1 2 3 4 {
		foreach y in all 1 2 3 {
		
			sum `var'_y`y'_w`w' if extractives_c==1
			scalar a = r(mean)
			sum `var'_y`y'_w`w' if extractives_p==1
			scalar b = r(mean)
			sum `var'_y`y'_w`w' if extractives_c==0 & extractives_p==0
			scalar c = r(mean)
			
			matrix define r1_`y'=(a\b\c)
			
			sum rank_`var'_y`y'_w`w' if extractives_c==1
			scalar a = r(mean)
			sum rank_`var'_y`y'_w`w' if extractives_p==1
			scalar b = r(mean)
			sum rank_`var'_y`y'_w`w' if extractives_c==0 & extractives_p==0
			scalar c = r(mean)

			matrix define r2_`y'=(a\b\c)
			
			matrix rownames r1_`y' = core peri other
			matrix rownames r2_`y' = core peri other
			matrix colnames r1_`y' = "Subp_`y'"
			matrix colnames r2_`y' = "Rank_Sub_`y'"	
			
		}
		
		matrix Z=(r1_1,r2_1,r1_2,r2_2,r1_3,r2_3, r1_all, r2_all)
		
		outtable using "${RESULTS}/UN_eq_8_`var'_w_`w'", mat(Z) replace  cap("Degree Centrality of economic activities (Network of industries 2008-2013, workers that earn `w' wage)")

	}
}


*			DIRECTED

use "${gephi_di}/econometrics/COL_centrality_measures_total.dta", clear 

foreach var in strength    {  // this table simple has the means for every group which is precisely what equation 8 makes. Lets make it all in one for out and in degree.  
	foreach w in all 1 2 3 4 {
		
			sum out_`var'_yall_w`w' if extractives_c==1
			scalar a = r(mean)
			sum out_`var'_yall_w`w' if extractives_p==1
			scalar b = r(mean)
			sum out_`var'_yall_w`w' if extractives_c==0 & extractives_p==0
			scalar c = r(mean)
			
*			matrix define r1out_`y'=(a\b\c)
			
			
			sum in_`var'_yall_w`w' if extractives_c==1
			scalar a1 = r(mean)
			sum in_`var'_yall_w`w' if extractives_p==1
			scalar b1 = r(mean)
			sum in_`var'_yall_w`w' if extractives_c==0 & extractives_p==0
			scalar c1 = r(mean)
			
			matrix define r1_`w'=(a\b\c\a1\b1\c1)
			
			
			sum rank_out_`var'_yall_w`w' if extractives_c==1
			scalar a = r(mean)
			sum rank_out_`var'_yall_w`w' if extractives_p==1
			scalar b = r(mean)
			sum rank_out_`var'_yall_w`w' if extractives_c==0 & extractives_p==0
			scalar c = r(mean)

*			matrix define r2_`y'=(a\b\c)
			
			
			
			sum rank_in_`var'_yall_w`w' if extractives_c==1
			scalar a1 = r(mean)
			sum rank_in_`var'_yall_w`w' if extractives_p==1
			scalar b1 = r(mean)
			sum rank_in_`var'_yall_w`w' if extractives_c==0 & extractives_p==0
			scalar c1 = r(mean)

			matrix define r2_`w'=(a\b\c\a1\b1\c1)
			
		
			
			matrix rownames r1_`w' = core_out peri_out other_out core_in peri_in other_in
			matrix rownames r2_`w' = core_out peri_out other_out core_in peri_in other_in
			matrix colnames r1_`w' = "All_w_`w'"
			matrix colnames r2_`w' = "Rank_w_`w'"
			di ""
		}
		
		matrix Z=(r1_1,r2_1,r1_2,r2_2,r1_3,r2_3)
		
		outtable using "${RESULTS}/DI_eq_8_`var'_y_all_w_123", mat(Z) replace  cap("Degree Centrality of economic activities (Network of industries all 2008-2013, by workers wage)")	
		
		
		matrix Z=(r1_4,r2_4,r1_all,r2_all)
		
		outtable using "${RESULTS}/DI_eq_8_`var'_y_all_w_4all", mat(Z) replace  cap("Degree Centrality of economic activities (Network of industries all 2008-2013, by workers wage))")	
		
}


foreach var in strength    {  // this table simple has the means for every group which is precisely what equation 8 makes. Lets make it all in one for out and in degree.  
	foreach w in all {
		foreach y in 1 2 3 {
		
			sum out_`var'_y`y'_w`w' if extractives_c==1
			scalar a = r(mean)
			sum out_`var'_y`y'_w`w' if extractives_p==1
			scalar b = r(mean)
			sum out_`var'_y`y'_w`w' if extractives_c==0 & extractives_p==0
			scalar c = r(mean)
			
*			matrix define r1out_`y'=(a\b\c)
			
			
			sum in_`var'_y`y'_w`w' if extractives_c==1
			scalar a1 = r(mean)
			sum in_`var'_y`y'_w`w' if extractives_p==1
			scalar b1 = r(mean)
			sum in_`var'_y`y'_w`w' if extractives_c==0 & extractives_p==0
			scalar c1 = r(mean)
			
			matrix define r1_`y'=(a\b\c\a1\b1\c1)
			
			
			
			
			sum rank_out_`var'_y`y'_w`w' if extractives_c==1
			scalar a = r(mean)
			sum rank_out_`var'_y`y'_w`w' if extractives_p==1
			scalar b = r(mean)
			sum rank_out_`var'_y`y'_w`w' if extractives_c==0 & extractives_p==0
			scalar c = r(mean)

*			matrix define r2_`y'=(a\b\c)
			
			
			
			sum rank_in_`var'_y`y'_w`w' if extractives_c==1
			scalar a1 = r(mean)
			sum rank_in_`var'_y`y'_w`w' if extractives_p==1
			scalar b1 = r(mean)
			sum rank_in_`var'_y`y'_w`w' if extractives_c==0 & extractives_p==0
			scalar c1 = r(mean)

			matrix define r2_`y'=(a\b\c\a1\b1\c1)
			
		
			
			matrix rownames r1_`y' = core_out peri_out other_out core_in peri_in other_in
			matrix rownames r2_`y' = core_out peri_out other_out core_in peri_in other_in
			matrix colnames r1_`y' = "Sub_`y'"
			matrix colnames r2_`y' = "Rank_Sub_`y'"		
		}
		
		matrix Z=(r1_1,r2_1,r1_2,r2_2,r1_3,r2_3)
		
		outtable using "${RESULTS}/DI_eq_8_`var'_y_123_w_all", mat(Z) replace  cap("Degree Centrality of economic activities (Network of industries subperiods 2008-2013, all workers )")	
	}
}

/*------------------------------------------------------------------------------							
								EQUATION 9								
------------------------------------------------------------------------------*/


use "${eam}/COL_EAM_national_2008_2013", clear
		  

*Merge with "disgance to extractives" node attributes

tostring ciiu3, gen(id) // before it was done with ciiu4. But that would be inconsistent with the way we assign the nodes to either extractives or periphery.
			
			
foreach y in all 1 2 3{
	foreach w in all 1 2 3 4{
		merge m:1 id using "${gephi_un}/econometrics/COL_edges_c_ext_4d_y`y'_w`w'.dta", gen(_merge_c_ext_`file')
		drop if _merge_c_ext_`file'==2
		drop _merge*
	}
}
			

rename ciiu3 id_4 // before it was ciiu4. that is not correct. 
gen extractives_c=0
gen extractives_p=0
			
replace extractives_c=1 if (id_4==1010 	| id_4==1020 | id_4==1030 | id_4==1110 | id_4==1120 | id_4==1200 | id_4==1310  	  ///
										| id_4==1320 | id_4==1410 | id_4==1429 | id_4==2310 | id_4==2320 | id_4==2413 | id_4==2696 | id_4==2699 | id_4==2710  ///
										| id_4==2720 | id_4==2731 | id_4==2732 | id_4==2811 | id_4==2891 | id_4==4020)
replace extractives_p=1 if (id_4==2922 	| id_4==2923 | id_4==2924 | id_4==5050 | id_4==5141 | id_4==5142 | id_4==5143)

label var extractives_c "Core Extractives"
label var extractives_p "Extractives Periphery"
rename id_4 ciiu3

*strength_ex_c_y`y'_w`w' strength_ex_p_y`y'_w`w'
			
*Generating "extractives activity" variables

foreach x in invebrta persocu valagri{

	bysort periodo: egen extr_act_cT_`x'=mean(`x') if extractives_c==1 // genere por periodo la media de `x' si es core
	bysort periodo: egen extr_act_pT_`x'=mean(`x') if extractives_p==1

	bysort periodo (extr_act_cT_`x') : gen extr_act_c_`x' = extr_act_cT_`x'[1] // ordene y reemplace por el maximo (puede ser negativo)
	bysort periodo (extr_act_pT_`x') : gen extr_act_p_`x' = extr_act_pT_`x'[1] 

	drop extr_act_cT_`x' extr_act_pT_`x'
	recode extr_act_c_`x'(.=0) // Haga el recode. This should do nothing
	recode extr_act_p_`x'(.=0)

}

* Now make the contemporaneaous Eq 9. 
foreach y in all 1 2 3 {

	foreach w in all 1 2 3 4 {
	
		foreach x in invebrta persocu valagri{

		gen in_y`y'_w`w'_`x'=strength_ex_c_y`y'_w`w'*extr_act_c_`x' 

		}
	}
}
*drop if periodo>2013 //Why should I do this?


*Now run regressions of national magnitude of economic activity on magnitude of extractive activity, interacted by "distance" to extractive activity - for matched years
			*A-Regression for all years
			
			
foreach w in all 1 2 3 4{
	
	foreach x in invebrta persocu valagri {
			
		reg `x' strength_ex_c_yall_w`w' extr_act_c_`x' in_yall_w`w'_`x'
		estimates store r1_`x'
		areg `x' strength_ex_c_yall_w`w' extr_act_c_`x' in_yall_w`w'_`x', absorb(periodo)
		estimates store r2_`x'
	}
	
	esttab r1_invebrta r2_invebrta r1_persocu r2_persocu r1_valagri r2_valagri using "${RESULTS}/UN_eq_9_yall_w`w'", replace f ///
	label booktabs b(4) p(4) eqlabels(none) alignment(S) collabels("\multicolumn{1}{c}{$\beta$ / SE}") ///
	star(* 0.10 ** 0.05 *** 0.01) ///
	cells(b(star fmt(3)) se(par fmt(2))) ///
	mtitle("\specialcell{invebrta_`w' 08-13}" "\specialcell{invebrta_`w' 08-13}" "\specialcell{persocu_`w' 08-13}" "\specialcell{persocu_`w' 08-13}" "\specialcell{valagri_`w' 08-13}" "\specialcell{valagri_`w' 08-13}") ///
	stats(N r2_p chi2 p, fmt(0 3) layout("\multicolumn{1}{c}{@}") labels(`"Observations"' `"Pseudo \(R^{2}\)"' `"LR chi2"' `"Prob > chi2"'))
}
				 
tsset periodo ciiu3, y


foreach w in all 1 2 3 4{
	
	foreach x in invebrta persocu valagri {
			
		reg `x' strength_ex_c_yall_w`w' l.extr_act_c_`x' l.in_yall_w`w'_`x'
		estimates store r1_`x'
		areg `x' strength_ex_c_yall_w`w' l.extr_act_c_`x' l.in_yall_w`w'_`x', absorb(periodo)
		estimates store r2_`x'
	}
	
	esttab r1_invebrta r2_invebrta r1_persocu r2_persocu r1_valagri r2_valagri using "${RESULTS}/UN_eq_9_lag_yall_w`w'", replace f ///
	label booktabs b(4) p(4) eqlabels(none) alignment(S) collabels("\multicolumn{1}{c}{$\beta$ / SE}") ///
	star(* 0.10 ** 0.05 *** 0.01) ///
	cells(b(star fmt(3)) se(par fmt(2))) ///
	mtitle("\specialcell{invebrta_`w' 08-13}" "\specialcell{invebrta_`w' 08-13}" "\specialcell{persocu_`w' 08-13}" "\specialcell{persocu_`w' 08-13}" "\specialcell{valagri_`w' 08-13}" "\specialcell{valagri_`w' 08-13}") ///
	stats(N r2_p chi2 p, fmt(0 3) layout("\multicolumn{1}{c}{@}") labels(`"Observations"' `"Pseudo \(R^{2}\)"' `"LR chi2"' `"Prob > chi2"'))
}

		* Now for every subperiod. 
		
gen year_pair=0
replace year_pair=1 if (periodo==2008 | periodo==2009) // notice this subperiod is actually 2008 - 2010
replace year_pair=2 if (periodo==2010 | periodo==2011)
replace year_pair=3 if (periodo==2012 | periodo==2013) // notice this subperiod is actually 2011 - 2013

foreach y in 1 2 3{

	preserve
	keep if year_pair==`y'
		
	foreach w in all 1 2 3 4{
		
		foreach x in invebrta persocu valagri {
				
			reg `x' strength_ex_c_y`y'_w`w' extr_act_c_`x' in_y`y'_w`w'_`x'
			estimates store r1_`x'
			areg `x' strength_ex_c_y`y'_w`w' extr_act_c_`x' in_y`y'_w`w'_`x', absorb(periodo)
			estimates store r2_`x'
		}
		
	esttab r1_invebrta r2_invebrta r1_persocu r2_persocu r1_valagri r2_valagri using "${RESULTS}/UN_eq_9_y`y'_w`w'", replace f ///
	label booktabs b(4) p(4) eqlabels(none) alignment(S) collabels("\multicolumn{1}{c}{$\beta$ / SE}") ///
	star(* 0.10 ** 0.05 *** 0.01) ///
	cells(b(star fmt(3)) se(par fmt(2))) ///
	mtitle("\specialcell{invebrta_`w' sub `y'}" "\specialcell{invebrta_`w' sub `y'}" "\specialcell{persocu_`w' sub `y'}" "\specialcell{persocu_`w' sub `y'}" "\specialcell{valagri_`w' sub `y'}" "\specialcell{valagri_`w' sub `y'}") ///
	stats(N r2_p chi2 p, fmt(0 3) layout("\multicolumn{1}{c}{@}") labels(`"Observations"' `"Pseudo \(R^{2}\)"' `"LR chi2"' `"Prob > chi2"'))
	}
	restore
}


tsset periodo ciiu3, y


foreach y in 1 2 3{

	preserve
	keep if year_pair==`y'

	foreach w in all 1 2 3 4{
		
		foreach x in invebrta persocu valagri {
				
			reg `x' strength_ex_c_y`y'_w`w' l.extr_act_c_`x' l.in_y`y'_w`w'_`x'
			estimates store r1_`x'
			areg `x' strength_ex_c_y`y'_w`w' l.extr_act_c_`x' l.in_y`y'_w`w'_`x', absorb(periodo)
			estimates store r2_`x'
		}
		
		esttab r1_invebrta r2_invebrta r1_persocu r2_persocu r1_valagri r2_valagri using "${RESULTS}/UN_eq_9_lag_y`y'_w`w'", replace f ///
		label booktabs b(4) p(4) eqlabels(none) alignment(S) collabels("\multicolumn{1}{c}{$\beta$ / SE}") ///
		star(* 0.10 ** 0.05 *** 0.01) ///
		cells(b(star fmt(3)) se(par fmt(2))) ///
		mtitle("\specialcell{invebrta_`w' sub `y'}" "\specialcell{invebrta_`w' sub `y'}" "\specialcell{persocu_`w' sub `y'}" "\specialcell{persocu_`w' sub `y'}" "\specialcell{valagri_`w' sub `y'}" "\specialcell{valagri_`w' sub `y'}") ///
		stats(N r2_p chi2 p, fmt(0 3) layout("\multicolumn{1}{c}{@}") labels(`"Observations"' `"Pseudo \(R^{2}\)"' `"LR chi2"' `"Prob > chi2"'))
	}
	restore
}



/*

			* EXTRA
					foreach var in invebrta persocu valagri {
					 foreach file in sr_all  sr_emp_sr_1 sr_emp_sr_2 sr_emp_sr_3 sr_emp_sr_4 {
						bysort periodo: reg `var' extractives_c_activity_1 i_strength_ex_c_`file'_1
						estimates store r1_`file'			
				}
				}















