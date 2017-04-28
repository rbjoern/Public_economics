* CODE APPENDIX 4
* STATISTICAL ANALYSIS


********************************************************************************
*LOAD DATA
********************************************************************************
set more off 				// Useful setting
clear all					// Clears existing data, so code can be re-run
cls 						// Clears the results window. 
cd "C:/Users/rbjoe/Dropbox/Kugejl/8. semester/Public Economics/Public_economics/Code/Stata output" 
							// Assign a working folder
use "C:/Users/rbjoe/Dropbox/Kugejl/8. semester/Public Economics/Public_economics/Data/10. Main Dataset.dta"	
							// Load data
cap log close
log using log.txt, replace text
							
********************************************************************************

********************************************************************************
*VARIABLE GROUPS
********************************************************************************
local y "ln_FDIInc_Out_Total"
local yy "ln_FDIInc_Out_Equity ln_FDIInc_Out_Dividends ln_FDIInc_Out_Reinvested ln_FDIInc_Out_Debt"
local Y "FDIInc_Out_Total FDIInc_Out_Equity FDIInc_Out_Dividends FDIInc_Out_Reinvested FDIInc_Out_Debt"
local Gravity_Nlog "GDP GDP_j distw"
local Gravity "ln_GDP ln_GDP_j ln_distw"
local Independent1 "Haven CIT_RATE HavenCIT_RATE"
local Independent2 "Small_Haven Large_Haven CIT_RATE Small_HavenCIT_RATE Large_HavenCIT_RATE"
local Independent3 "Haven CIT_difference HavenCIT_difference"
local Independent4 "CFC Haven CFCHaven CIT_RATE CFCCIT_RATE HavenCIT_RATE CFCHavenCIT_RATE"
local Control1 "contig comlang_off colony comcol" //EXCE

********************************************************************************


********************************************************************************
*GENERATE VARIABLES
********************************************************************************
*Interaction terms 
*Basic interaction
gen HavenCIT_RATE = Haven*CIT_RATE

*Based on size
gen Small_HavenCIT_RATE = Small_Haven*CIT_RATE

gen Large_HavenCIT_RATE = Large_Haven*CIT_RATE

*Based on the tax differences variable
gen HavenCIT_difference = Haven*CIT_difference

*CFC interactions
gen CFCHaven = Haven*CFC

gen CFCHavenCIT_RATE = Haven*CFC*CIT_RATE

gen CFCCIT_RATE = CFC*CIT_RATE

*Encode assigns numerical values to each group in a variable

encode(COU), gen(COU_Tal)
encode(COUNTERPART_AREA), gen(COUNTERPART_AREA_Tal)
encode(Pair), gen(Pair_Tal)

*Create necessary logged variables
foreach var in `Y' `Gravity_Nlog' {
gen ln_`var' = log(`var')
}

*Create first differenced variables
sort Pair_Tal obsTime
foreach var in FDIInc_Out_Total FDIInc_Inw_Total ln_FDIInc_Out_Total ln_FDIInc_Inw_Total `Control_OLS1' {
	cap by Pair_Tal: generate dif`var'=`var'[_n]-`var'[_n-1]
}

********************************************************************************

********************************************************************************
*LABELS 
********************************************************************************

label variable FDIInc_Out_Total 		"FDI income - Total (Outwards)"
label variable FDIInc_Out_Dividends 	"FDI income - Dividends (Outwards)"
label variable FDIInc_Out_Equity 		"FDI income - Income on Equity (Outwards)"
label variable FDIInc_Out_Debt 			"FDI income - Interests from income on debt (Outwards)"
label variable FDIInc_Out_Reinvested 	"FDI income - Reinvested earnings (Outwards)"
label variable FDIInc_Inw_Total 		"FDI income - Total (Inwards)"
label variable FDIInc_Inw_Dividends 	"FDI income - Dividends (Inwards)"
label variable FDIInc_Inw_Equity 		"FDI income - Income on Equity (Inwards)"
label variable FDIInc_Inw_Debt 			"FDI income - Interests from income on debt (Inwards)"
label variable FDIInc_Inw_Reinvested 	"FDI income - Reinvested earnings (Inwards)"
label variable ln_GDP					"$\ln\text{GDP}_{it}$"	
label variable ln_GDP_j					"$\ln\text{GDP}_{jt}$"	
label variable ln_distw					"$\ln\text{Distance (w)}$"
label variable contig 					"Common border"
label variable colony 					"Colony"
label variable comcol 					"Common colony"
label variable comlang_off 				"Common language"
label variable CIT_RATE					"$ \text{CIT}_{it}$ $(\gamma_1)$"
label variable Haven 					"Haven $(\gamma_2)$"
label variable HavenCIT_RATE 			"Haven$\times\text{CIT}_{it}$ $ (\gamma_3)$ "
label variable Small_HavenCIT_RATE 		"Small Haven$\times\text{CIT}_{it}$"
label variable Large_HavenCIT_RATE 		"Large Haven$\times\text{CIT}_{it}$"
label variable HavenCIT_difference 		"Haven$\times\text{CIT}_{it}$ (difference)"
label variable CFCHaven  				"CFC$\times$Haven"
label variable CFCHavenCIT_RATE  		"CFC.Haven$\times\text{CIT}_{it}$"
label variable CFCCIT_RATE   			"CFC$\times\text{CIT}_{it}$ "
********************************************************************************

********************************************************************************
*ANALYSIS
********************************************************************************
*Without OECD tax havens. 
*drop if COU == "IRL" // Ireland

*Panel
xtset Pair_Tal obsTime, yearly


*********************************************************************************************************
* REGRESSION TABLE ONE. BASIC REGRESSION
*********************************************************************************************************
{
regress `y' `Gravity' `Independent1' `Control1', robust
	test CIT_RATE + HavenCIT_RATE=0
		scalar p1 = r(p)
	outreg2 using OLS, replace ctitle("Eq. (\ref{gravity1})") ///
							tex(frag pretty) word label alpha(0.01, 0.05, 0.1, 0.15) symbol(***, **, *, +) ///
							 addstat("$\gamma_1+\gamma_3 =0$ (p-value)", p1)  ///
							 dec(3) keep(`Gravity' `Independent1' `Control1')				 					 
						 
							 
regress `y' `Gravity' `Independent1' `Control1' b2015.obsTime, robust
	test CIT_RATE + HavenCIT_RATE=0
			scalar p1 = r(p)
	outreg2 using OLS, append ctitle("$+\delta_t$") ///
							tex(frag pretty) word label alpha(0.01, 0.05, 0.1, 0.15) symbol(***, **, *, +) ///
							 addstat("$\gamma_1+\gamma_3 =0$ (p-value)", p1)  ///
							 dec(3) keep(`Gravity' `Independent1' `Control1')
*Equivalent alternative:
*areg `y' `Gravity' `Independent1' `Control1', absorb(obsTime) vce(robust) noomitted							

*regress `y' `Gravity' `Independent1' `Control1' b2015.obsTime b6.COU_Tal, robust // Reference group: Germany (most observations)									
areg `y' `Gravity' `Independent1' `Control1' b2015.obsTime, absorb(COU_Tal) vce(robust)
	test CIT_RATE + HavenCIT_RATE=0
			scalar p1 = r(p)
	outreg2 using OLS, append ctitle("$+\zeta_i$") ///
							tex(frag pretty) word label alpha(0.01, 0.05, 0.1, 0.15) symbol(***, **, *, +) ///
							 addstat("$\gamma_1+\gamma_3 =0$ (p-value)", p1)  ///
							 dec(3) keep(`Gravity' `Independent1' `Control1')				 
*Equivalent alternative:
*regress `y' `Gravity' `Independent1' `Control1' b2015.obsTime b6.COU_Tal  b59.COUNTERPART_AREA_Tal, robust //Reference group: Germany

areg `y' `Gravity' `Independent1' `Control1' b2015.obsTime  b6.COU_Tal, absorb(COUNTERPART_AREA_Ta) vce(robust) // Reference group: Germany (most observations)												 
	test CIT_RATE + HavenCIT_RATE=0
			scalar p1 = r(p)
	outreg2 using OLS, append ctitle("$+\eta_j$") ///
							tex(frag pretty) word label alpha(0.01, 0.05, 0.1, 0.15) symbol(***, **, *, +) ///
							 addstat("$\gamma_1+\gamma_3 =0$ (p-value)", p1)  ///
							 dec(3) keep(`Gravity' `Independent1' `Control1')
*Equivalent alternative: 
*regress `y' `Gravity' `Independent1' `Control1' b2015.obsTime b6.COU_Tal  b59.COUNTERPART_AREA_Tal  b1017.Pair_Tal //Reference group: Germany-France (most observations, large flow)


areg `y' `Gravity' `Independent1' `Control1' b2015.obsTime, absorb(Pair_Tal) vce(robust) 
	test CIT_RATE + HavenCIT_RATE=0
		scalar p1 = r(p)
	outreg2 using OLS, append ctitle("$+\theta_{ij}$ (FE)") ///
							tex(frag pretty) word label alpha(0.01, 0.05, 0.1, 0.15) symbol(***, **, *, +) ///
							 addstat("$\gamma_1+\gamma_3 =0$ (p-value)", p1)  ///
							 dec(3) keep(`Gravity' `Independent1' `Control1')

*Equivalent alternative 
*xtreg `y' `Gravity' `Independent1' `Control1' b2015.obsTime, fe robust	

/*
			Time dummies &&X&X&X&X \\
			Country \textit{i} dummies &&&X&X& \\
			Country \textit{j} dummies &&&&X& \\
			Country pair dummies &&&&&X \\	
*/
}

*********************************************************************************************************
* REGRESSION TABLE ONE. BASIC REGRESSION (CLUSTERED STD ERRORS)
*********************************************************************************************************
{
regress `y' `Gravity' `Independent1' `Control1', robust cluster(distw)
	test CIT_RATE + HavenCIT_RATE=0
		scalar p1 = r(p)
	outreg2 using OLSCluster, replace ctitle("Eq. (\ref{gravity1})") ///
							tex(frag pretty) word label alpha(0.01, 0.05, 0.1, 0.15) symbol(***, **, *, +) ///
							 addstat("$\gamma_1+\gamma_3 =0$ (p-value)", p1)  ///
							 dec(3) keep(`Gravity' `Independent1' `Control1')			 					 
						 
							 
regress `y' `Gravity' `Independent1' `Control1' b2015.obsTime, robust cluster(distw)
	test CIT_RATE + HavenCIT_RATE=0
			scalar p1 = r(p)
	outreg2 using OLSCluster, append ctitle("$+\delta_t$") ///
							tex(frag pretty) word label alpha(0.01, 0.05, 0.1, 0.15) symbol(***, **, *, +) ///
							 addstat("$\gamma_1+\gamma_3 =0$ (p-value)", p1)  ///
							 dec(3) keep(`Gravity' `Independent1' `Control1')
*Equivalent alternative:
*areg `y' `Gravity' `Independent1' `Control1', absorb(obsTime) vce(cluster distw) noomitted							

*regress `y' `Gravity' `Independent1' `Control1' b2015.obsTime b6.COU_Tal, robust // Reference group: Germany (most observations)									
areg `y' `Gravity' `Independent1' `Control1' b2015.obsTime, absorb(COU_Tal) vce(cluster distw) 
	test CIT_RATE + HavenCIT_RATE=0
			scalar p1 = r(p)
	outreg2 using OLSCluster, append ctitle("$+\zeta_i$") ///
							tex(frag pretty) word label alpha(0.01, 0.05, 0.1, 0.15) symbol(***, **, *, +) ///
							 addstat("$\gamma_1+\gamma_3 =0$ (p-value)", p1)  ///
							 dec(3) keep(`Gravity' `Independent1' `Control1')			 
*Equivalent alternative:
*regress `y' `Gravity' `Independent1' `Control1' b2015.obsTime b6.COU_Tal  b59.COUNTERPART_AREA_Tal, robust //Reference group: Germany

areg `y' `Gravity' `Independent1' `Control1' b2015.obsTime  b6.COU_Tal, absorb(COUNTERPART_AREA_Ta) vce(cluster distw)  // Reference group: Germany (most observations)												 
	test CIT_RATE + HavenCIT_RATE=0
			scalar p1 = r(p)
	outreg2 using OLSCluster, append ctitle("$+\eta_j$") ///
							tex(frag pretty) word label alpha(0.01, 0.05, 0.1, 0.15) symbol(***, **, *, +) ///
							 addstat("$\gamma_1+\gamma_3 =0$ (p-value)", p1)  ///
							 dec(3) keep(`Gravity' `Independent1' `Control1')
*Equivalent alternative: 
*regress `y' `Gravity' `Independent1' `Control1' b2015.obsTime b6.COU_Tal  b59.COUNTERPART_AREA_Tal  b1017.Pair_Tal //Reference group: Germany-France (most observations, large flow)


areg `y' `Gravity' `Independent1' `Control1' b2015.obsTime, absorb(Pair_Tal) vce(cluster distw)  
	test CIT_RATE + HavenCIT_RATE=0
		scalar p1 = r(p)
	outreg2 using OLSCluster, append ctitle("$+\theta_{ij}$ (FE)") ///
							tex(frag pretty) word label alpha(0.01, 0.05, 0.1, 0.15) symbol(***, **, *, +) ///
							 addstat("$\gamma_1+\gamma_3 =0$ (p-value)", p1)  ///
							 dec(3) keep(`Gravity' `Independent1' `Control1')

*Equivalent alternative 
*xtreg `y' `Gravity' `Independent1' `Control1' b2015.obsTime, fe robust								 
}							 
*********************************************************************************************************
*********************************************************************************************************
*********************************************************************************************************
*********************************************************************************************************
*********************************************************************************************************
						 
*FIGURE TWO. Size of havens 
ta COUNTERPART_AREA_Tal Small_Haven // Tjek om nogen skifter status

regress `y' `Gravity' `Independent2' `Control1', robust
	test CIT_RATE + Small_HavenCIT_RATE=0
		scalar p1 = r(p)
	test CIT_RATE + Large_HavenCIT_RATE=0
		scalar p2 = r(p)
	outreg2 using OLS_Size, replace ctitle("Basic") ///
							tex(frag pretty) word label alpha(0.01, 0.05, 0.1, 0.15) symbol(***, **, *, +) ///
							 addstat("No small haven effect (p)", p1,"No large haven effect (p)", p2)  ///
							 dec(3) keep(`Independent2') nocons nor2 noobs ///
							 addnote("Intercept, GDP, distance and common variables featured in all models")

regress `y' `Gravity' `Independent2' `Control1' b2015.obsTime, robust
	test CIT_RATE + Small_HavenCIT_RATE=0
			scalar p1 = r(p)
	test CIT_RATE + Large_HavenCIT_RATE=0
		scalar p2 = r(p)			
	outreg2 using OLS_Size, append ctitle("Yearly") ///
							tex(frag pretty) word label alpha(0.01, 0.05, 0.1, 0.15) symbol(***, **, *, +) ///
							 addstat("No small haven effect (p)", p1,"No large haven effect (p)", p2)  ///
							 dec(3) keep(`Independent2') nocons nor2 noobs ///
							 addnote("Intercept, GDP, distance and common variables featured in all models")
							 
areg `y' `Gravity' `Independent2' `Control1' b2015.obsTime, absorb(COU_Tal) vce(robust)
	test CIT_RATE + Small_HavenCIT_RATE=0
			scalar p1 = r(p)
	test CIT_RATE + Large_HavenCIT_RATE=0
		scalar p2 = r(p)			
	outreg2 using OLS_Size, append ctitle("Investor") ///
							tex(frag pretty) word label alpha(0.01, 0.05, 0.1, 0.15) symbol(***, **, *, +) ///
							 addstat("No small haven effect (p)", p1,"No large haven effect (p)", p2)  ///
							 dec(3) keep(`Independent2') nocons nor2 noobs ///
							 addnote("Intercept, GDP, distance and common variables featured in all models") 				 
						 
areg `y' `Gravity' `Independent2' `Control1' b2015.obsTime  b6.COU_Tal, absorb(COUNTERPART_AREA_Ta) vce(robust) // Reference group: Germany (most observations)												 
	test CIT_RATE + Small_HavenCIT_RATE=0
			scalar p1 = r(p)
	test CIT_RATE + Large_HavenCIT_RATE=0
		scalar p2 = r(p)			
	outreg2 using OLS_Size, append ctitle("Partner") ///
							tex(frag pretty) word label alpha(0.01, 0.05, 0.1, 0.15) symbol(***, **, *, +) ///
							 addstat("No small haven effect (p)", p1,"No large haven effect (p)", p2)  ///
							 dec(3) keep(`Independent2') nocons nor2 noobs ///
							 addnote("Intercept, GDP, distance and common variables featured in all models")

areg `y' `Gravity' `Independent2' `Control1' b2015.obsTime, absorb(Pair_Tal) vce(robust) 
	test CIT_RATE + Small_HavenCIT_RATE=0
		scalar p1 = r(p)
	test CIT_RATE + Large_HavenCIT_RATE=0
		scalar p2 = r(p)		
	outreg2 using OLS_Size, append ctitle("Pairs") ///
							tex(frag pretty) word label alpha(0.01, 0.05, 0.1, 0.15) symbol(***, **, *, +) ///
							 addstat("No small haven effect (p)", p1,"No large haven effect (p)", p2)  ///
							 dec(3) keep(`Independent2') nocons nor2 noobs ///
							 addnote("Intercept, GDP, distance and common variables featured in all models")

							 
*********************************************************************************************************
*********************************************************************************************************
*********************************************************************************************************
*********************************************************************************************************
*********************************************************************************************************

cap erase OLS_Types.rtf
cap erase OLS_Types.tex
cap erase OLS_Types.txt

/*
	& \multicolumn{2}{c}{Equity} & \multicolumn{2}{c}{Dividends} & \multicolumn{2}{c}{Reinvested earnings} &\multicolumn{2}{c}{Debt income}  \\
	\cline{2-9}
*/
						 
*FIGURE THREE. TYPES OF FDI
foreach var in `yy' {
areg `var' `Gravity' `Independent1' `Control1' b2015.obsTime, absorb(COU_Tal) vce(robust)
	test CIT_RATE + HavenCIT_RATE=0
			scalar p1 = r(p)
	outreg2 using OLS_Types, append ctitle("Investor") ///
							tex(frag pretty) word label alpha(0.01, 0.05, 0.1, 0.15) symbol(***, **, *, +) ///
							 addstat("No haven effect (p)", p1)  ///
							 dec(3) keep(`Gravity' `Independent1')
							 
areg `var' `Gravity' `Independent1' `Control1' b2015.obsTime, absorb(Pair_Tal) vce(robust) 
	test CIT_RATE + HavenCIT_RATE=0
		scalar p1 = r(p)
	outreg2 using OLS_Types, append ctitle("Pairs") ///
							tex(frag pretty) word label alpha(0.01, 0.05, 0.1, 0.15) symbol(***, **, *, +) ///
							 addstat("No haven effect (p)", p1)  ///
							 dec(3) keep(`Gravity' `Independent1')

}

*********************************************************************************************************
*********************************************************************************************************
*********************************************************************************************************
*********************************************************************************************************
*********************************************************************************************************

*FIGURE. TAX DIFFERENCE.  
eststo Check: regress `y' `Gravity' `Independent3' `Control1', robust
	test CIT_difference + HavenCIT_difference=0
		scalar p1 = r(p)
	outreg2 using OLS_taxdifference, replace ctitle("Basic") ///
							tex(frag pretty) word label alpha(0.01, 0.05, 0.1, 0.15) symbol(***, **, *, +) ///
							 addstat("Adj. R-squared", e(r2_a),"No haven effect (p)", p1)  ///
							 dec(3) keep(`Gravity' `Independent3' `Control1')

*areg `y' `Gravity' `Independent3' `Control1', absorb(obsTime) vce(robust) noomitted							 
							 
regress `y' `Gravity' `Independent3' `Control1' b2015.obsTime, robust
	test CIT_difference + HavenCIT_difference=0
			scalar p1 = r(p)
	outreg2 using OLS_taxdifference, append ctitle("Yearly") ///
							tex(frag pretty) word label alpha(0.01, 0.05, 0.1, 0.15) symbol(***, **, *, +) ///
							 addstat("Adj. R-squared", e(r2_a),"No haven effect (p)", p1)  ///
							 dec(3) keep(`Gravity' `Independent3' `Control1')
						

*regress `y' `Gravity' `Independent3' `Control1' b2015.obsTime b6.COU_Tal, robust // Reference group: Germany (most observations)									
areg `y' `Gravity' `Independent3' `Control1' b2015.obsTime, absorb(COU_Tal) vce(robust)
	test CIT_difference + HavenCIT_difference=0
			scalar p1 = r(p)
	outreg2 using OLS_taxdifference, append ctitle("Investor") ///
							tex(frag pretty) word label alpha(0.01, 0.05, 0.1, 0.15) symbol(***, **, *, +) ///
							 addstat("Adj. R-squared", e(r2_a),"No haven effect (p)", p1)  ///
							 dec(3) keep(`Gravity' `Independent3' `Control1')						 
						 
*regress `y' `Gravity' `Independent3' `Control1' b2015.obsTime b6.COU_Tal  b59.COUNTERPART_AREA_Tal, robust //Reference group: Germany


areg `y' `Gravity' `Independent3' `Control1' b2015.obsTime  b6.COU_Tal, absorb(COUNTERPART_AREA_Ta) vce(robust) // Reference group: Germany (most observations)												 
	test CIT_difference + HavenCIT_difference=0
			scalar p1 = r(p)
	outreg2 using OLS_taxdifference, append ctitle("Partner") ///
							tex(frag pretty) word label alpha(0.01, 0.05, 0.1, 0.15) symbol(***, **, *, +) ///
							 addstat("Adj. R-squared", e(r2_a),"No haven effect (p)", p1)  ///
							 dec(3) keep(`Gravity' `Independent3' `Control1')


*regress `y' `Gravity' `Independent3' `Control1' b2015.obsTime b6.COU_Tal  b59.COUNTERPART_AREA_Tal  b1017.Pair_Tal //Reference group: Germany-France (most observations, large flow)


areg `y' `Gravity' `Independent3' `Control1' b2015.obsTime, absorb(Pair_Tal) vce(robust) 
	test CIT_difference + HavenCIT_difference=0
		scalar p1 = r(p)
	outreg2 using OLS_taxdifference, append ctitle("Pairs") ///
							tex(frag pretty) word label alpha(0.01, 0.05, 0.1, 0.15) symbol(***, **, *, +) ///
							 addstat("Adj. R-squared", e(r2_a),"No haven effect (p)", p1)  ///
							 dec(3) keep(`Gravity' `Independent3' `Control1')

*********************************************************************************************************
*********************************************************************************************************
*********************************************************************************************************
*********************************************************************************************************
*********************************************************************************************************							 

*FIGURE. CFC.  
eststo Check: regress `y' `Gravity' `Independent4' `Control1', robust
	test CIT_RATE + HavenCIT_RATE=0
		scalar p1 = r(p)
	test CIT_RATE + HavenCIT_RATE+CFCHavenCIT_RATE=0
		scalar p2 = r(p)
	outreg2 using OLS_CFC, replace ctitle("Basic") ///
							tex(frag pretty) word label alpha(0.01, 0.05, 0.1, 0.15) symbol(***, **, *, +) ///
							 addstat("Adj. R-squared", e(r2_a),"No haven effect (p)", p1, ///
							 "No CFC Haven effect (p)", p2)  ///
							 dec(3) keep(`Gravity' `Independent4' `Control1')

*areg `y' `Gravity' `Independent4' `Control1', absorb(obsTime) vce(robust) noomitted							 
							 
regress `y' `Gravity' `Independent4' `Control1' b2015.obsTime, robust
	test CIT_RATE + HavenCIT_RATE=0
			scalar p1 = r(p)
	test CIT_RATE + HavenCIT_RATE+CFCHavenCIT_RATE=0
		scalar p2 = r(p)
	outreg2 using OLS_CFC, append ctitle("Yearly") ///
							tex(frag pretty) word label alpha(0.01, 0.05, 0.1, 0.15) symbol(***, **, *, +) ///
							 addstat("Adj. R-squared", e(r2_a),"No haven effect (p)", p1, ///
							 "No CFC Haven effect (p)", p2)  ///
							 dec(3) keep(`Gravity' `Independent4' `Control1')
						

*regress `y' `Gravity' `Independent4' `Control1' b2015.obsTime b6.COU_Tal, robust // Reference group: Germany (most observations)									
areg `y' `Gravity' `Independent4' `Control1' b2015.obsTime, absorb(COU_Tal) vce(robust)
	test CIT_RATE + HavenCIT_RATE=0
			scalar p1 = r(p)
	test CIT_RATE + HavenCIT_RATE+CFCHavenCIT_RATE=0
		scalar p2 = r(p)
	outreg2 using OLS_CFC, append ctitle("Investor") ///
							tex(frag pretty) word label alpha(0.01, 0.05, 0.1, 0.15) symbol(***, **, *, +) ///
							 addstat("Adj. R-squared", e(r2_a),"No haven effect (p)", p1, ///
							 "No CFC Haven effect (p)", p2)  ///
							 dec(3) keep(`Gravity' `Independent4' `Control1')						 
						 
*regress `y' `Gravity' `Independent4' `Control1' b2015.obsTime b6.COU_Tal  b59.COUNTERPART_AREA_Tal, robust //Reference group: Germany


areg `y' `Gravity' `Independent4' `Control1' b2015.obsTime  b6.COU_Tal, absorb(COUNTERPART_AREA_Ta) vce(robust) // Reference group: Germany (most observations)												 
	test CIT_RATE + HavenCIT_RATE=0
			scalar p1 = r(p)
	test CIT_RATE + HavenCIT_RATE+CFCHavenCIT_RATE=0
		scalar p2 = r(p)
	outreg2 using OLS_CFC, append ctitle("Partner") ///
							tex(frag pretty) word label alpha(0.01, 0.05, 0.1, 0.15) symbol(***, **, *, +) ///
							 addstat("Adj. R-squared", e(r2_a),"No haven effect (p)", p1, ///
							 "No CFC Haven effect (p)", p2)  ///
							 dec(3) keep(`Gravity' `Independent4' `Control1')


*regress `y' `Gravity' `Independent4' `Control1' b2015.obsTime b6.COU_Tal  b59.COUNTERPART_AREA_Tal  b1017.Pair_Tal //Reference group: Germany-France (most observations, large flow)


areg `y' `Gravity' `Independent4' `Control1' b2015.obsTime, absorb(Pair_Tal) vce(robust) 
	test CIT_RATE + HavenCIT_RATE=0
		scalar p1 = r(p)
	test CIT_RATE + HavenCIT_RATE+CFCHavenCIT_RATE=0
		scalar p2 = r(p)
	outreg2 using OLS_CFC, append ctitle("Pairs") ///
							tex(frag pretty) word label alpha(0.01, 0.05, 0.1, 0.15) symbol(***, **, *, +) ///
							 addstat("Adj. R-squared", e(r2_a),"No haven effect (p)", p1, ///
							 "No CFC Haven effect (p)", p2)  ///
							 dec(3) keep(`Gravity' `Independent4' `Control1')




*********************************************************************************************************
							 
							 
log close


