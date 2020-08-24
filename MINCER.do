global RESULTS "C:/Users/cdelo/Dropbox/Networks_Extractives_2020/RESULTS" // personal laptop

* Mincer equation para Mexico

use "C:\Users\cdelo\Downloads\person_loc_variables_census.dta", clear 
* Create dummies for core and periphery extractives 

gen extractives_c=.
gen extractives_p=.

label var extractives_c "Core Extractives"
label var extractives_p "Extractives Periphery"

replace extractives_c=0 if extractives_c==.
replace extractives_p=0 if extractives_p==.

gen extractives_occup = 0
gen extractives_occup_c = 0
gen extractives_occup_p = 0

replace extractives_occup=1 if (ocuactiv_c=="1312" | ocuactiv_c=="1612" | ocuactiv_c=="2241" | ocuactiv_c=="2251" | ocuactiv_c=="2252" | ocuactiv_c=="2253" | ocuactiv_c=="2254" | ocuactiv_c=="2623" | ocuactiv_c=="7101" | ocuactiv_c=="7111" | ocuactiv_c=="7112" | ocuactiv_c=="7411" | ocuactiv_c=="7412" | ocuactiv_c=="8111" | ocuactiv_c=="8112" | ocuactiv_c=="8113" | ocuactiv_c=="8114" | ocuactiv_c=="8121" | ocuactiv_c=="8122" | ocuactiv_c=="8123" | ocuactiv_c=="8131" | ocuactiv_c=="8132" | ocuactiv_c=="8133" | ocuactiv_c=="8134" | ocuactiv_c=="8135"  | ocuactiv_c=="8141" | ocuactiv_c=="8142" | ocuactiv_c=="8143" | ocuactiv_c=="8144" | ocuactiv_c=="8145"  | ocuactiv_c=="8171" | ocuactiv_c=="1314" | ocuactiv_c=="1315" | ocuactiv_c=="2261" | ocuactiv_c=="2262" | ocuactiv_c=="2611" | ocuactiv_c=="2612" | ocuactiv_c=="2621" | ocuactiv_c=="2622" | ocuactiv_c=="8351" | ocuactiv_c=="8352")

replace extractives_occup_c=1 if (ocuactiv_c=="1312" | ocuactiv_c=="1612" | ocuactiv_c=="2241" | ocuactiv_c=="2251" | ocuactiv_c=="2252" | ocuactiv_c=="2253" | ocuactiv_c=="2254" | ocuactiv_c=="2623" | ocuactiv_c=="7101" | ocuactiv_c=="7111" | ocuactiv_c=="7112" | ocuactiv_c=="7411" | ocuactiv_c=="7412" | ocuactiv_c=="8111" | ocuactiv_c=="8112" | ocuactiv_c=="8113" | ocuactiv_c=="8114" | ocuactiv_c=="8121" | ocuactiv_c=="8122" | ocuactiv_c=="8123" | ocuactiv_c=="8131" | ocuactiv_c=="8132" | ocuactiv_c=="8133" | ocuactiv_c=="8134" | ocuactiv_c=="8135"  | ocuactiv_c=="8141" | ocuactiv_c=="8142" | ocuactiv_c=="8143" | ocuactiv_c=="8144" | ocuactiv_c=="8145"  | ocuactiv_c=="8171")

replace extractives_occup_p=1 if (ocuactiv_c=="1314" | ocuactiv_c=="1315" | ocuactiv_c=="2261" | ocuactiv_c=="2262" | ocuactiv_c=="2611" | ocuactiv_c=="2612" | ocuactiv_c=="2621" | ocuactiv_c=="2622" | ocuactiv_c=="8351" | ocuactiv_c=="8352")

gen extractives_formal = 0
replace extractives_formal=1 if (extractives_c==1 | extractives_p==1) & formal==1
gen extractives_ocup_formal = 0
replace extractives_ocup_formal=1 if extractives_occup==1 & formal==1	



des id_per escoacum exper exper2 lningtrmen



* Basic Mincer

reg lningtrmen escoacum exper exper2
estimates store simple
reg lningtrmen escoacum exper exper2 extractives_occup
estimates store extractives
reg lningtrmen escoacum exper exper2 extractives_occup_c
estimates store core
reg lningtrmen escoacum exper exper2 extractives_occup_p
estimates store periphery
reg lningtrmen escoacum exper exper2 extractives_occup_c extractives_occup_p
estimates store peripherycore
reg lningtrmen escoacum exper exper2 extractives_ocup_formal
estimates store formal
		
esttab simple extractives core periphery peripherycore formal using "${RESULTS}/MINCER_MEX", replace f ///
		label booktabs b(4) p(4) eqlabels(none) alignment(S) collabels("\multicolumn{1}{c}{$\beta$ / SE}") ///
		star(* 0.10 ** 0.05 *** 0.01) ///
		cells(b(star fmt(3)) se(par fmt(2))) ///
		stats(N r2_p chi2 p, fmt(0 3) layout("\multicolumn{1}{c}{@}") labels(`"Observations"' `"Pseudo \(R^{2}\)"' `"LR chi2"' `"Prob > chi2"'))
		
		
		
		
		
oaxaca lningtrmen escoacum exper exper2, by(extractives_occup) noisily

