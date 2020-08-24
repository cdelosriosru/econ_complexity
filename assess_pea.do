**asessment_PEA**

import excel "C:\Users\cdelo\Dropbox\Networks_Extractives_2020\assess_maps2.xlsx", sheet("Depto_Ing_Reportado_NC") firstrow clear

drop if Departamento=="" 
destring Departamento, gen(codigo_depto)
destring ano, replace

merge 1:1 codigo_depto ano using "C:\Users\cdelo\Dropbox\HK_Extractives_2020\DATA\PoliticalBoundaries\pea.dta"
keep if _merge==3
rename ano year

gen emp_pea=(Obs/pea)*100
keep emp_pea codigo_depto year
reshape wide emp_pea, i(codigo_depto) j(year)

export excel using "C:\Users\cdelo\Dropbox\Networks_Extractives_2020\tables\pea_pila.xls", firstrow(variables)
