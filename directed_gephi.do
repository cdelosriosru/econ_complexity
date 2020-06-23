/*------------------------------------------------------------------------------
PROJECT :     			Network Analysis of Extractives (Colombia)
AUTHOR :				Camilo De Los Rios
PURPOSE :				Generates the files for Gephi to map the industry space network of directed graphs.
------------------------------------------------------------------------------*/

* Basic setting 

set more off
cap log close
clear all

* paths

global data "C:/Users/camilodel/Dropbox/Networks_Extractives_2020/DATA"
global rawdata_di "${data}/rawdata/directed"
global gephi_di "${data}/gephi_directed"

*----------------------------------EDGES FILES----------------------------------



local files : dir "${rawdata_di}" files "*.dta"

foreach file in `files' { // I have to do this part of the loop again since this is going to be a three step process. But in a scenario where everything is done with a single CPU this part could be earased
	
	local simif = substr("`file'", 1, strpos("`file'",".dta")-1) // I use this to have only the name of the file without the extension it its way more useful. 
	
	* we could erase this part  until right before we import the simi files if we'd use the same cpu
	
	use "${rawdata_di}/`file'", clear
	
	rename ind_i Source
	rename ind_j Target
	rename SRt Weight
	
	preserve									// this is necessary to make the full rectangular matrix and avoid any error
		keep Source
		rename Source id
		duplicates drop id, force
		tempfile temp_ids
		sa `temp_ids'
	restore
			
	rename Target id
	merge m:1 id using  `temp_ids', gen(m_f_s)
	rename id Target
			
	preserve
		keep Target
		rename Target id
		duplicates drop id, force
		tempfile temp_ids
		sa `temp_ids'
	restore
			
	rename Source id
	merge m:1 id using `temp_ids', gen(m_f_t)
	rename id Source
			
	fillin Source Target
	
	drop if Source==.
	drop if Target==.
	
	replace Weight=0 if Weight==.
	replace Weight=0 if Source==Target
	
	keep Source Target Weight 
		
	* Take only the max in and out for each node
	
	bys Source: egen maxout=max(Weight)  // take the max "outflow"
	bys Target: egen maxin=max(Weight)   // take the max "inflow"

	gen Flow_Tree=Weight if maxout==Weight
	replace Flow_Tree=maxin if maxin==Weight
	
	drop if Flow_Tree==.
	
	replace Flow_Tree=1-Flow_Tree
	drop if Flow_Tree==1 // this drops obs that only have one connection and that is the strongest. 
	tostring Source, gen(str_id_4)
	gen id_4=Source 
	
	*outsheet Source Target Weight Flow_Tree  using "${gephi_di}/ COL_edges_`k'_`simif'.txt", replace
	outsheet Source Target Weight Flow_Tree using "${gephi_di}/ COL_edges_`k'_`simif'.csv", replace comma
	
	*sa "${gephi_di}/COL_edges_`file'.dta", replace

}
