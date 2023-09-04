/*****************************************************************************************
This script combines all data into a regdata file, including the smoking and inactivity
rates of multiple brfss subsamples, some covariates, and kff medicaid expansion data
*****************************************************************************************/

* load kff data to get treatment timing
import excel using "$data/raw/kff_medicaid.xlsx", firstrow clear

* create year adopted variable equal to the year medicaid expansion was adopted
* adoptions on July 1 or later are considered to happen in the next year
gen year_adopted = yofd(date_adopted)
gen month_adopted = month(date_adopted)

replace year_adopted = year_adopted + 1 if month_adopted >= 7
replace year_adopted = 0 if mi(date_adopted) | year_adopted > 2021

keep fips year_adopted
tempfile kff
save `kff'

* load covariates (income and college share)
* college share
import excel "$data/raw/acs2010_colldeg_state.xls", cellrange(A8:E59) clear
keep A D
rename (A D) (state coll_share)
statastates, name(state) nogen
drop state_abbrev state
ren state_fips fips
keep if inrange(fips, 1, 56)
destring coll_share, replace
tempfile coll_share
save `coll_share'

* income
import delim "$data/raw/SAINC4__ALL_AREAS_1929_2022.csv", clear
assert industryclassification == "..." | mi(industryclassification)
keep if description == "Per capita personal income (dollars) 4/"
keep geofips v90
gen fips = substr(geofips,3,2)
destring fips, replace
keep if inrange(fips, 1, 56)
gen logpci = log(v90)
keep fips logpci
tempfile income
save `income'

* load brfss data
use "$data/temp/brfss_combined", clear
keep if inrange(fips, 1, 56)
drop if mi(agegroup)

* recode age group 
recode agegroup 1=1 2/3=2 4/5=3 6/9=4 10/13=5, gen(agegroup2)
drop agegroup
ren agegroup2 agegroup

preserve
keep if inlist(agegroup, 1, 2)
collapse (rawsum) popwt=wt (mean) smk_rate_young=smoker inact_rate_young=inactive unins_rate_young=uninsured [aw=wt], by(fips year agegroup)
merge m:1 agegroup using "$data/temp/agestd2000", keep(3) nogen
collapse (rawsum) popwt=wt (mean) smk_rate_young inact_rate_young unins_rate_young [aw=ageshare], by(fips year)
tempfile young
save `young'
restore

preserve
keep if college == 0
collapse (rawsum) popwt=wt (mean) smk_rate_nc=smoker inact_rate_nc=inactive unins_rate_nc=uninsured [aw=wt], by(fips year agegroup)
merge m:1 agegroup using "$data/temp/agestd2000", keep(3) nogen
collapse (rawsum) popwt=wt (mean) smk_rate_nc inact_rate_nc unins_rate_nc [aw=ageshare], by(fips year)
tempfile nc
save `nc'
restore

collapse (mean) smk_rate=smoker inact_rate=inactive unins_rate=uninsured [aw=wt], by(fips year agegroup)
merge m:1 agegroup using "$data/temp/agestd2000", keep(3) nogen
collapse (rawsum) popwt=wt (mean) smk_rate inact_rate unins_rate [aw=ageshare], by(fips year)
merge 1:1 fips year using `young', assert(3) nogen
merge 1:1 fips year using `nc', assert(3) nogen
merge m:1 fips using `coll_share', assert(3) gen(merge1)
merge m:1 fips using `income', assert(3) gen(merge2)

merge m:1 fips using `kff'
assert _merge == 3 if inrange(fips, 1, 56)
keep if _merge == 3
drop _merge

save "$data/temp/regdata", replace