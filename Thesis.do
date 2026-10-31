import excel using "/Users/livigallagher/Desktop/Thesis Data.xlsx", sheet("Index") cellrange(A1:J451) firstrow clear

*destring any type mismatch
destring AgeatFirstMarriage, replace

*inflation adjust total income to 2025 (CPI estimates from federal reserve of minneapolis)
gen cpi = .
replace cpi = 237.0 if Year==2015
replace cpi = 240.0 if Year==2016
replace cpi = 245.1 if Year==2017
replace cpi = 251.1 if Year==2018
replace cpi = 255.7 if Year==2019
replace cpi = 258.8 if Year==2020
replace cpi = 271.0 if Year==2021
replace cpi = 292.7 if Year==2022
replace cpi = 304.7 if Year==2023

gen Income_2025 = Income * (321.9 / cpi)

*Creating index:
* 0) Declare panel
xtset ID Year

* 1) higher index = "better":
* poverty is "worse" when higher, fertility is "worse" when higher
* reverse those by multiplying by -1 before standardizing 
gen PercentBelowPovertyLevel_reverse = -PercentBelowPovertyLevel
rename PercentBelowPovertyLevel_reverse Pov_reverse
gen FertilityRates_reverse = -FertilityRates

* 2) Standardize (z-scores)
foreach v in FertilityRates_reverse Pov_reverse Income_2025 Education HealthInsurance FemaleLaborForceParticipation AgeatFirstMarriage {
    egen z_`v' = std(`v')
}
describe z_*
summarize z_*

* 3) Index = average of standardized components
egen index_z = rowmean(z_FertilityRates_reverse z_Pov_reverse z_Income_2025 z_Education z_HealthInsurance z_FemaleLaborForceParticipation z_AgeatFirstMarriage)

* 4) Re-standardize so final index has SD=1. Now a "one unit" result is one ST  
egen index = std(index_z)

import excel using "/Users/livigallagher/Desktop/Thesis Data.xlsx", sheet("Trafficking") firstrow clear

*change dates into years then collapse means
gen Year = year(Date)
collapse (mean) Sex Human, by(State Year)
drop if Year > 2023
