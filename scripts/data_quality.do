/*****************************************************************************************
This file checks data quality in BRFSS data, specifically identifies how many records
are used to estimate our state-level rates of inactivity and smoking across our samples
*****************************************************************************************/

use "$data/temp/brfss_combined", clear

gen smoker0 = smoker == 0
gen smoker1 = smoker == 1
gen mismoker = mi(smoker)
gen inactive0 = inactive == 0
gen inactive1 = inactive == 1
gen miinactive = mi(inactive)

collapse (sum) smoker0 smoker1 mismoker inactive0 inactive1 miinactive, by(fips year)

gen total = smoker0 + smoker1 + mismoker

foreach var of varlist *smoker* *inactive* {
    replace `var' = `var'/total
}

keep mismoker miinactive fips year
reshape wide mismoker miinactive, i(year) j(fips)

line miinactive* year, legend(off)
