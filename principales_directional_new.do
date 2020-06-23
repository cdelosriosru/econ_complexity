/*------------------------------------------------------------------------------

Objective: 	create SR measure for network paper
			-Inflows & Outflows (first loop)
			-Outflows
			-Flows
			Caveats: Can't make it in a single loop or data set.  
			
Project:	Netowrks between industries in Colombia



CHANGES	
		Changed to comment: 
			lines: 127, 269,789, 945
			whole sections: STATES AND MUNICIPALITIES, 			
							SR Directionality. Pair of years. By wages. Country. for the version without window restricctions
							SR DIRECTIONALITY ONE YEAR WINDOW.
							SR REGARDLESS OF DIRECTION THREE YEAR WINDOW.
							 
------------------------------------------------------------------------------ 21*/

* INSTALL (Only if you dont have it installed in your STATA)

*ssc install rowsort
*ssc install egenmore

*PATH

set more off, perm
global mac "/Volumes/Thunder"
global main2 "/disk/homedirs/nber/adkugler/bulk" // nber
global main "/Users/Luisin/Desktop/Networks"
cd "$main"
/*	
	*(sum) tdcpm tibcpa tdcpa (max) tibcpm
	
	**importing PILA**
use "rawdata/PILA_colombia/PILAAfull.dta", clear 
ren * ,lower

label var tdcpm "Total de dias reportados como trabajados a pensión (mensual)"
label var tibcpa "Total del ingreso reportado a pensión (anual)"
label var tdcpa "Total de dias reportados como trabajados a pensión (anual)"
label var tibcpm "Total del ingreso reportado a pensión (mensual)"

label var tibcsm "Total del ingreso reportado a salud (mensual)"
label var tdcsm "Total de dias reportados como trabajados a salud (mensual)"
label var tea "Total de empleados que aparecen reportados por esa empresa en los pagos (anual)"
label var tibcsa "otal del ingreso reportado a salud (anual)"
label var tdcsa "Total de dias reportados como trabajados a salud (anual)"
label var personabasicaid "Person ID"
label var tem "Total de empleados que aparecen reportados por esa empresa en los pagos (anual)"
label var inflacion "Deflactor para llevar montos a valores reales de 2013"

* create the the unqique IDs and ensure that they follow DANE pattern. 

capture destring codigo_depto, replace force 
capture destring codigo_ciudad, replace force
tostring codigo_depto, gen(dptos) 
tostring codigo_ciudad, gen(mpios)
replace mpios="0"+mpios if codigo_ciudad<100 & codigo_ciudad>9
replace mpios="00"+mpios if codigo_ciudad<10
replace dptos="0"+dptos if codigo_depto<10
gen  codigo_mpio= dptos+mpios 

compress
*sa "dtafiles/pila.dta", replace

*collapse the observations to the year level

collapse (first) codigo_ciudad codigo_depto inflacion departamento municipio codigo_mpio dptos mpios (sum) tdcpm tibcpa tdcpa (max) tibcpm, by(personabasicaid codigo_actividad_economica ano)

*save this data base so you dont have to make this collapse ever again

rename codigo_actividad_economica ind_i

compress
sa "dtafiles/collapsed_pila.dta", replace // this will be used for outflows and flows

*/

/*------------------------------------------------------------------------------
--------------------------------------------------------------------------------

							SR DIRECTIONALITY 
						NO YEAR WINDOW RESTRICTION.
							 
--------------------------------------------------------------------------------
------------------------------------------------------------------------------*/

use "dtafiles/collapsed_pila.dta", clear

sum ano

local y_di=r(max)-r(min)
local ny_di=-(r(max)-r(min))

* first create the data sets with outflows or inflows
foreach x of numlist  1/`y_di'{  // only for inflows

use "dtafiles/collapsed_pila.dta", clear

**generating outflows or inflows**	

	preserve
	
		gen ind_j=ind_i
		replace ano=ano+`x' 
		keep personabasicaid ind_j ano
				
		sa "dtafiles/temp_`x'.dta", replace // this data has industries where the person is going to be in x years (was x years ago) but with the current year. It will serve me later for the flows
	
			
	restore
	
joinby personabasicaid ano using "dtafiles/temp_`x'.dta", unmatched(master)
keep codigo_ciudad codigo_depto tdcpm tibcpa tdcpa tibcpm ind_i ind_j personabasicaid ano
compress
sa "dtafiles/directional_`x'.dta", replace
erase "dtafiles/temp_`x'.dta"
}

* inflows data set

use "dtafiles/directional_1.dta", clear
foreach x of numlist  2/`y_di'{
append using "dtafiles/directional_`x'.dta" // this only works if first we make the directionality data sets. 

erase "dtafiles/directional_`x'.dta" // to free space of the disk
}
compress
sa "dtafiles/directional_1.dta", replace


foreach x in 1 {

use "dtafiles/directional_`x'.dta", clear

	if `x'==1{
		local ftype inf
		local ftype2 outf
	}

	else {
		local ftype outf
		local ftype2 inf
	}

*generate outflows (inflows)

gen `ftype'=0
replace `ftype'=1 if ind_i!=ind_j // this is a variable that indicates that there actually is an outflow (inflow) from i to j. 

** collapse at de pair level for every person and year**

collapse (first) codigo_ciudad codigo_depto `ftype' (sum) tdcpm tibcpa tdcpa (max) tibcpm, by(ind_i ind_j personabasicaid ano) // SUPER IMPORTANT TO ENSURE NO DOUBLECOUNTING
	
*Generating different metrics for employees to account for in SR measure

egen salario_promedio=mean(tibcpm), by(personabasicaid ano)
egen p_salariom = xtile(salario_promedio), by(ano ind_i) n(2)  
gen min_wage = 0
replace min_wage=461500 if ano==2008
replace min_wage=496900 if ano==2009
replace min_wage=515000 if ano==2010
replace min_wage=535600 if ano==2011
replace min_wage=566700 if ano==2012
replace min_wage=589500 if ano==2013
gen emp_sr_1 = 0
gen emp_sr_2 = 0
gen emp_sr_3 = 0
gen emp_sr_4 = 0
replace emp_sr_1=1 if p_salariom>=2
replace emp_sr_2=1 if tibcpm>min_wage
replace emp_sr_3=1 if tibcpm>3*min_wage
replace emp_sr_4=1 if tibcpm>10*min_wage
drop tdcpm tibcpa tdcpa tibcpm

*Label vars for better names

capture label var outf "F.O" 
capture label var inf "F.I" 
local flo : variable label `ftype'

*SR Directionality. All years. All workers. Country.

	preserve
			
		egen ij_group_d=group(ind_i ind_j) 
		egen f_ij=total(`ftype'), by(ij_group_d)  
		
		egen F=total(`ftype')						
		egen f_i=total(`ftype'), by(ind_i) 	
		egen f_j=total(`ftype'), by(ind_j) 	

		gen SR = f_ij/(f_i*f_j/F)	
		gen SRt=(SR-1)/(SR+1)			
		
		label var ij_group_d "group for flows between i and j"
		label var f_ij "total flows between i and j (`ftype'low)"
		label var f_i "total `ftype'lows for i"
		label var f_j "total `ftype2'lows for j"
		label var F "total flows in the economy"
		label var SR "skill relatedness measure (raw)"
		label var SRt "skill relatedness measure (between -1,1)"
		
		collapse (first) SR* F f_* ij* `ftype', by(ind_i ind_j)
		
		compress
		sa "dtafiles/COL_SR_`flo'2_Y.all_W.all_L.0.dta", replace
		
	restore
	
*SR Directionality. All years. By wages. Country.

	
forvalues w=1(1)4 {
	
	preserve
		
		drop if emp_sr_`w'!=1
			
		egen ij_group_d=group(ind_i ind_j) 
		egen f_ij=total(`ftype'), by(ij_group_d)  
		
		egen F=total(`ftype')						
		egen f_i=total(`ftype'), by(ind_i) 	
		egen f_j=total(`ftype'), by(ind_j) 	

		gen SR = f_ij/(f_i*f_j/F)	
		gen SRt=(SR-1)/(SR+1)			
		
		label var ij_group_d "group for flows between i and j"
		label var f_ij "total flows between i and j (`ftype'low)"
		label var f_i "total `ftype'lows for i"
		label var f_j "total `ftype2'lows for j"
		label var F "total flows in the economy"
		label var SR "skill relatedness measure (raw)"
		label var SRt "skill relatedness measure (between -1,1)"
		
		collapse (first) SR* F f_* ij* `ftype', by(ind_i ind_j)
		
		compress
		sa "dtafiles/COL_SR_`flo'2_Y.all_W.`w'_L.0.dta", replace
		
	restore
}
	
/*-----------------------------
	SR directionality 
	 PAIRS OF YEARS				
-------------------------------*/

	use "dtafiles/collapsed_pila.dta", clear
	
*Generating some metrics that we need for the analysis	
/*	
	gen min_wage = 0
	replace min_wage=461500 if ano==2008
	replace min_wage=496900 if ano==2009
	replace min_wage=515000 if ano==2010
	replace min_wage=535600 if ano==2011
	replace min_wage=566700 if ano==2012
	replace min_wage=589500 if ano==2013
*/




drop if ano==2009
drop if ano==2012

expand 2 if ano==2010
egen ano_2009=tag(personabasicaid ind_i ano) 
replace ano=2009 if ano_2009==0
drop ano_2009

expand 2 if ano==2011
egen ano_2012=tag(personabasicaid ind_i ano) 
replace ano=2012 if ano_2012==0
drop ano_2012

	
	gen year_pair=0
	replace year_pair=1 if (ano==2008 | ano==2009) // notice this subperiod is actually 2008 - 2010
	replace year_pair=2 if (ano==2010 | ano==2011)
	replace year_pair=3 if (ano==2012 | ano==2013) // notice this subperiod is actually 2011 - 2013
	
	sa "dtafiles/pila_yearpairs.dta", replace
	
	forvalues y=1/3 {
	
		use "dtafiles/pila_yearpairs.dta", clear
		
		keep if year_pair==`y'
		

		**generating outflows (inflows)**	

			preserve 
				gen ind_j=ind_i
				replace ano=ano+`x' 
				keep personabasicaid ind_j ano
				
				tempfile temp_`ftype'
				sa `temp_`ftype''

			restore
			
		joinby personabasicaid ano using `temp_`ftype'', unmatched(master)
		
		compress
*		sa "dtafiles/pila_joinby_`y'_`x'.dta", replace // I could potentially use this when creating the flows regardless of the direction. 

		gen `ftype'=0
		replace `ftype'=1 if ind_i!=ind_j // this is a variable that indicates that there actually is an outflow from 1 to 2. 

		** collapse at de pair level for every person and year**

*		collapse (first) codigo_ciudad codigo_depto `ftype' min_wage (sum) tdcpm tibcpa tdcpa (max) tibcpm, by(ind_i ind_j personabasicaid ano) // actually this collapse does not change anything, just drops some variables, that's all it does. 
			
		*Generating different metrics for employees to account for in SR measure
/*
		egen salario_promedio=mean(tibcpm), by(personabasicaid ano)
		egen p_salariom = xtile(salario_promedio), by(ano ind_i) n(2)  
		gen emp_sr_1 = 0
		gen emp_sr_2 = 0
		gen emp_sr_3 = 0
		gen emp_sr_4 = 0
		replace emp_sr_1=1 if p_salariom>=2
		replace emp_sr_2=1 if tibcpm>min_wage
		replace emp_sr_3=1 if tibcpm>3*min_wage
		replace emp_sr_4=1 if tibcpm>10*min_wage
		drop tdcpm tibcpa tdcpa tibcpm
*/	
		*Label vars for better names

		capture label var outf "F.O" 
		capture label var inf "F.I" 
		local flo : variable label `ftype'
	
*SR Directionality. Pair of years. All workers. Country.

			preserve
					
				egen ij_group_d=group(ind_i ind_j) 
				egen f_ij=total(`ftype'), by(ij_group_d)  
				
				egen F=total(`ftype')						
				egen f_i=total(`ftype'), by(ind_i) 	
				egen f_j=total(`ftype'), by(ind_j) 	

				gen SR = f_ij/(f_i*f_j/F)	
				gen SRt=(SR-1)/(SR+1)			
				
				label var ij_group_d "group for flows between i and j"
				label var f_ij "total flows between i and j (`ftype'low)"
				label var f_i "total `ftype'lows for i"
				label var f_j "total `ftype2'lows for j"
				label var F "total flows in the economy"
				label var SR "skill relatedness measure (raw)"
				label var SRt "skill relatedness measure (between -1,1)"
				
				collapse (first) SR* F f_* ij* `ftype', by(ind_i ind_j)
				
				compress
				sa "dtafiles/COL_SR_`flo'2_Y.`y'_W.all_L.0.dta", replace
				
			restore

	}
}


/*------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
	
						EMPLOYEMENT GROWTH
	
	Here Is the part that makes the correlation in the employement growth. 
	
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------	
------------------------------------------------------------------------------*/




* For the whole country

use "rawdata/PILA_colombia/PILAAfull.dta", clear 
ren * ,lower

	gen empleo=1
	collapse (sum) empleo, by(codigo_actividad_economica ano)
	sort codigo_actividad_economica ano
	drop if codigo_actividad_economica==.
	
	drop if ano==2009
	drop if ano==2012

	expand 2 if ano==2010
	egen ano_2009=tag(codigo_actividad_economica ano) 
	replace ano=2009 if ano_2009==0
	drop ano_2009

	expand 2 if ano==2011
	egen ano_2012=tag(codigo_actividad_economica ano) 
	replace ano=2012 if ano_2012==0
	drop ano_2012
	
	*replace codigo_actividad_economica=" " if codigo_actividad_economica=="NA"
	*drop if codigo_actividad_economica==" "
	gen empleo_t2=.
	replace empleo_t2=empleo[_n+1] if empleo_t2==.
	gen codigo_actividad_economica_temp=.
	replace codigo_actividad_economica_temp=codigo_actividad_economica[_n+1] if codigo_actividad_economica_temp==.
	replace empleo_t2=. if codigo_actividad_economica_temp!=codigo_actividad_economica
	gen emp_growth=(empleo_t2-empleo)/((empleo_t2+empleo)/2)
	keep emp_growth codigo_actividad_economica ano
	capture drop if codigo_actividad_economica==.
	
	reshape wide emp_growth, i(ano) j(codigo_actividad_economica)
	pwcorr
	matrix A=r(C)
	
	putexcel set "tables/corr_employement.xlsx", sheet("Corr") modify
	putexcel B2=matrix(A)
	
	outtable using "tables/corr_employement", mat(A) replace cap("Employement growth correlation between all industries") f(%9.3f)



* for every State	
	
use "rawdata/PILA_colombia/PILAAfull.dta", clear 
ren * ,lower

	gen empleo=1
	collapse (sum) empleo, by(codigo_actividad_economica codigo_depto ano)
	sort codigo_depto codigo_actividad_economica ano 
	
	drop if codigo_actividad_economica==.
	
	drop if ano==2009
	drop if ano==2012

	expand 2 if ano==2010
	egen ano_2009=tag(codigo_actividad_economica codigo_depto ano) 
	replace ano=2009 if ano_2009==0
	drop ano_2009

	expand 2 if ano==2011
	egen ano_2012=tag(codigo_actividad_economica codigo_depto ano) 
	replace ano=2012 if ano_2012==0
	drop ano_2012
	gen empleo_t2=.
	replace empleo_t2=empleo[_n+1] if empleo_t2==.
	
	gen codigo_actividad_economica_temp=.
	replace codigo_actividad_economica_temp=codigo_actividad_economica[_n+1] if codigo_actividad_economica_temp==.
	replace empleo_t2=. if codigo_actividad_economica_temp!=codigo_actividad_economica
	
	gen codigo_depto_temp=""
	replace codigo_depto_temp=codigo_depto[_n+1] if codigo_depto_temp==""
	replace empleo_t2=. if codigo_depto_temp!=codigo_depto

	
	gen emp_growth=(empleo_t2-empleo)/((empleo_t2+empleo)/2)
	drop if codigo_actividad_economica==.

	capture destring codigo_depto, replace force 
	tostring codigo_depto, gen(dptos) 
	replace dptos="0"+dptos if codigo_depto<10
		
	keep emp_growth codigo_actividad_economica ano dptos

	levelsof dptos, local(dep)

	foreach x in `dep'{
		preserve 
		
			keep if dptos=="`x'"
			reshape wide emp_growth, i(ano) j(codigo_actividad_economica)
			pwcorr
			matrix A=r(C)
			putexcel set "tables/corr_employement_`x'.xlsx", sheet("Corr") modify
			putexcel B2=matrix(A)
			outtable using "tables/corr_employement_`x'", mat(A) replace cap("Employement growth correlation between all industries in depto `x'") f(%9.3f)
			
		restore
}
