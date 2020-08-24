/*------------------------------------------------------------------------------
PROJECT :     			Network Analysis of Extractives (Colombia)
AUTHOR :				Camilo De Los Rios
PURPOSE :				Generates the files for Gephi to map the industry space network. For the new results
------------------------------------------------------------------------------*/

* Basic setting 

set more off
cap log close
clear all

* paths
global data "C:/Users/cdelo/Dropbox/Networks_Extractives_2020/NewResults"
global rawdata_un "${data}/rawdata/undirected"
capture mkdir "${rawdata_un}/txt"
global textfiles "${rawdata_un}/txt"
global matlab "${data}/rawdata/matlab"
global gephi_un "${data}/gephi_undirected"

*----------------------------------EDGES FILES----------------------------------

* Create local with names of all the files in folder with raw data (the results Luis sent)

local files : dir "${rawdata_un}" files "*.dta"

foreach file in `files' { // loop over every file in the rawdata folder
	
	use "${rawdata_un}/`file'", clear
		
	local simif = substr("`file'", 1, strpos("`file'",".dta")-1) // I use this to have only the name of the file without the extension it its way more useful. 

	rename ind_i Source
	rename ind_j Target
	rename SRt Weight
	keep Source Target Weight 
	
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
	
	* Create matrix for Matlab input
	
	egen x=tag(Source) // tags every industry with a 1 only once (it tags the duplicates with 0)
	egen y=sum(x) // creates var with total number of uniques industries
	local k=y[1]
	
	sort Source Target
		
	mata flow = st_data(.,"Weight")  // returns all observations in the Weight variable (a single column)
	mata flow = rowshape(flow,`k') // Converts flow to a matrix with `k' rows. This means that every column makes reference to ind_1 
	mata mm_outsheet("${textfiles}/`simif'.txt", strofreal(flow), mode="r") // Write ASCII file, named flow, with values as strings, replace it. 

}

local mylist : dir "${textfiles}" files "*.txt"

foreach filename of local mylist { // loop over every file in textfiles folder
	
	cd "$textfiles"
	shell ren "`filename'" "flow.txt"
	
	sleep 10000
	
	shell "C:/Program Files/MATLAB/R2020a/bin/matlab.exe" -nojvm -nodesktop -nodisplay -r "COL_build_gephi_files_4dcdr();exit" > log.txt // run function build_gephi_files in MATLAB
	sleep 100000

	cd "$textfiles"
	shell ren "flow.txt" "`filename'"
	
	sleep 10000
	
	cd "$matlab"
	shell ren "simi_mst_flow.txt" "simi_`filename'"
	sleep 10000

	
}

local files : dir "${rawdata_un}" files "*.dta"

foreach file in `files' { // I have to do this part of the loop again since this is going to be a three step process. But in a scenario where everything is done with a single CPU this part could be earased
	
	local simif = substr("`file'", 1, strpos("`file'",".dta")-1) // I use this to have only the name of the file without the extension it its way more useful. 
	
	* we could erase this part  until right before we import the simi files if we'd use the same cpu
	
	use "${rawdata_un}/`file'", clear
	
	rename ind_i Source
	rename ind_j Target
	rename SRt Weight
	keep Source Target Weight 
	
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
	
	* Create matrix for Matlab input
	
	egen x=tag(Source) // tags every industry with a 1 only once (it tags the duplicates with 0)
	egen y=sum(x) // creates var with total number of uniques industries
	local k=y[1]
	
	sort Source Target
		
	mata flow = st_data(.,"Weight")  // returns all observations in the Weight variable (a single column)
	mata flow = rowshape(flow,`k') // Converts flow to a matrix with `k' rows. This means that every column makes reference to ind_1 

	mata simi_mst_flow = mm_insheet("$matlab/simi_`simif'.txt", ",") // read the file created in MATLAB with the .m code

	set more off
	cap fillin Source Target
	duplicates drop Source Target, force
	sort Source Target
	
	gen Flow = .
	mata tostata = colshape(flow,1)
	sort Source Target
	mata st_store(.,"Flow",tostata)
	
	gen Flow_MST = .
	mata tostata = colshape(strtoreal(simi_mst_flow),1)
	sort Source Target
	mata st_store(.,"Flow_MST",tostata) 
	gen MST=Flow_MST>0
	
	tostring Source, gen(str_id_4)
    gen id_4=Source 
	
	outsheet Source Target Weight MST Flow_MST using "${gephi_un}/COL_edges_`simif'.txt", replace
	outsheet Source Target Weight MST Flow_MST using "${gephi_un}/COL_edges_`simif'.csv", replace comma

	*sa "${gephi_un}/COL_edges_`simif'.dta", replace

	forvalues k=40(10)100{
	
		preserve
			
			keep if MST>0 | Weight>`k'/100
			sort Source
			*rename Source id
			capture tostring Source, gen(str_id_4)
			capture gen id_4=Source 
			sort id_4
			sort Source Target
			outsheet Source Target Weight MST Flow_MST using "${gephi_un}/COL_edges_`k'_`simif'.txt", replace
			outsheet Source Target Weight MST Flow_MST using "${gephi_un}/COL_edges_`k'_`simif'.csv", replace comma
			
		restore
		
	}
}


local files : dir "${gephi_un}" files "COL_edges_col**.csv"

foreach x in `files'{
	import delimited "${gephi_un}/`x'", case(preserve) clear 
	keep if MST==1
	outsheet Source Target Weight MST Flow_MST using "${gephi_un}/MST_`x'", replace comma
}


*----------------------------------NODES FILE-----------------------------------

*WORK IN PROGRESS.....
