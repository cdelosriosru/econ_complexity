/*------------------------------------------------------------------------------
PROJECT :     			Network Analysis of Extractives (Colombia)
AUTHOR :				Camilo De Los Rios
PURPOSE :				Generates the files for Gephi to map the industry space network.
------------------------------------------------------------------------------*/

* Basic setting 

set more off
cap log close
clear all

* paths

global rawdata "C:/Users/camilodel/Dropbox/Networks_Extractives_2020/Resultados may 14 2020"
capture mkdir "${rawdata}/txt"
global textfiles "${rawdata}/txt"
global matlab "PATH WHERE MATLAB CODE SAVES SIMI MATRIX"
global gephi "PATH TO FOLDER WHERE WE ARE GOING TO SAVE THE FILES TO BE USED IN GEPHI"
global rawdata "C:/Users/camilodel/Desktop/dropbox/results"
global matlab "C:/Users/camilodel/Desktop/dropbox/results/txt"


*----------------------------------EDGES FILES----------------------------------

* Create local with names of all the files in folder with raw data (the results Luis sent)

local files : dir "${rawdata}" files "*.dta"

foreach file in `files' { // loop over every file in the rawdata folder
	
	use "${rawdata}/`file'", clear
	
	rename ind_i Source
	rename ind_j Target
	rename SRt Weight
	keep Source Target Weight 
	
	drop if Source==. // if we dont do this it wont work
	drop if Target==. // if we dont do this it wont work
	
	fillin Source Target // create with missing all the possible combinations of Source andTarget (rectangularize data)

	replace Weight=0 if Weight==.
	replace Weight=0 if Source==Target
	
	* Create matrix for Matlab input
	
	egen x=tag(Source) // tags every industry with a 1 only once (it tags the duplicates with 0)
	egen y=sum(x) // creates var with total number of uniques industries
	local k=y[1]
	
	sort Source Target
		
	mata flow = st_data(.,"Weight")  // returns all observations in the Weight variable (a single column)
	mata flow = rowshape(flow,`k') // Converts flow to a matrix with `k' rows. This means that every column makes reference to ind_1 
	mata mm_outsheet("${textfiles}/`file'.txt", strofreal(flow), mode="r") // Write ASCII file, named flow, with values as strings, replace it. 

}

local files : dir "${textfiles}" files "*.txt"

foreach file in `files' { // loop over every file in textfiles folder
	
	cd "$textfiles"
	shell ren "`file'" "flow.txt"
	
	shell "C:\Program Files\MATLAB\R2012a\bin\matlab.exe" -nojvm -nodesktop -nodisplay -r "build_gephi_files();exit" > log.txt // run function build_gephi_files in MATLAB
	
	cd "$matlab"
	shell ren "simi_mst_flow.txt" "simi_`file'.txt"
	
}

local files : dir "${rawdata}" files "*.dta"

foreach file in `files' { // I have to do this part of the loop again since this is going to be a three step process. But in a scenario where everything is done with a single CPU this part could be earased
	
	local simif = substr("`file'", 1, strpos("`file'",".")-1) // I use this to have only the name of the file without the extension it its way more useful. 
	
	* we could erase this part  until right before we import the simi files if we'd use the same cpu
	
	use "${rawdata}/`file'", clear
	
	rename ind_i Source
	rename ind_j Target
	rename SRt Weight
	keep Source Target Weight 
	
	drop if Source==. // if we dont do this it wont work
	drop if Target==. // if we dont do this it wont work
	
	fillin Source Target // create with missing all the possible combinations of Source andTarget (rectangularize data)
	
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
	sa "${gephi}/COL_edges_`simif'.dta", replace

	forvalues k=40(10)100{
	
		preserve
			
			keep if MST>0 | Weight>`k'/100
			sort Source
			*rename Source id
			tostring Source, gen(str_id_4)
			gen id_4=Source 
			sort id_4
			sort Source Target
			outsheet Source Target Weight MST Flow_MST using COL_edges_`k'_`simif'.txt, replace
			outsheet Source Target Weight MST Flow_MST using COL_edges_`k'_`simif'.csv, replace comma
			
		restore
		
	}
}


*----------------------------------NODES FILE-----------------------------------

*WORK IN PROGRESS.....



