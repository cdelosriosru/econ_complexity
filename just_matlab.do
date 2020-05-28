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

global rawdata "C:/Users/camilodel/Dropbox/Networks_Extractives_2020/Resultados may 14 2020" // WHEREVER YOU HAVE SAVED ALL THE RAWRESULTS OF THIS PROJECT. 
capture mkdir "${rawdata}/txt"							// CREATES A FOLDER IN CASE IT DOESENT EXIST. 
global textfiles "${rawdata}/txt"
global matlab "PATH WHERE MATLAB CODE SAVES SIMI MATRIX IT MUST BE THE SAME AS IN build_gephi_files.m " // WARNING
global gephi "PATH TO FOLDER WHERE WE ARE GOING TO SAVE THE FILES TO BE USED IN GEPHI" // WARNING

*----------------------------------EDGES FILES----------------------------------



local files : dir "${textfiles}" files "*.txt"

foreach file in `files' { // loop over every file in textfiles folder
	
	cd "$textfiles"
	shell ren "`file'" "flow.txt"
	
	shell "C:\Program Files\MATLAB\R2012a\bin\matlab.exe" -nojvm -nodesktop -nodisplay -r "build_gephi_files();exit" > log.txt // run function build_gephi_files in MATLAB
	
	cd "$matlab"
	shell ren "simi_mst_flow.txt" "simi_`file'.txt"
	
}
