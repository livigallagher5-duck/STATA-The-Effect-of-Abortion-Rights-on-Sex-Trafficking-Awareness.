import excel using "/Users/livigallagher/Desktop/Thesis Data.xlsx", sheet("Master Sheet") firstrow clear

*install for improved diff-in-diff
ssc install did_multiplegt_dyn, replace
ssc install gtools, replace
gtools, upgrade

*declare panel data
xtset StateID Year

*install fixed effects & dependency if not already done
ssc install reghdfe
ssc install ftools

*************************************SIMPLE DID*************************************
*2015-2025
gen Treatment = Treatment0control1in
drop if Treatment == 2
reghdfe SexTrafficking i.Treatment##i.PostDobbs0before1podt, absorb(StateID Year) vce(cluster StateID)

*immediate effect 2015-2023
drop if Year == 2025
drop if Year == 2024
reghdfe SexTrafficking i.Treatment##i.PostDobbs0before1podt, absorb(StateID Year) vce(cluster StateID)

*immediate effect controlling for FEA 2015-2023
reghdfe SexTrafficking i.Treatment##i.PostDobbs0before1podt Index_2, absorb(StateID Year) vce(cluster StateID)

clear
*************************************CONTINUOUS DID*************************************
import excel using "/Users/livigallagher/Desktop/Thesis Data.xlsx", sheet("Master Sheet") firstrow clear

*2015-2025
did_multiplegt_dyn SexTrafficking StateID Year Restrictiveness, effects(4) placebo(4) cluster(StateID)

*continuous DiD w FEA residuals
reg SexTrafficking Index_2 i.StateID i.Year
predict SexTrafficking_resid, resid
did_multiplegt_dyn SexTrafficking_resid StateID Year Restrictiveness, effects(1) placebo(1) cluster(StateID)

*p-values calculated by hand
 







