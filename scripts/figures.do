/*****************************************************************************************
This script produces the main descriptive figures (NOT the event study plots) of the 
paper, using data from BRFSS/NHIS
*****************************************************************************************/

clear all
set scheme cf_custom

*** NHIS national trend plots ***
use "$data/raw/nhis_00001.dta", clear

* limit to sampled adults 18-64
keep if astatflg == 1 & inrange(age, 18, 64)

* recode insurance coverage variables
recode hinotcove 1=0 2=1 9=., gen(uninsured)
recode himcaide 1=0 2/3=1 7/9=., gen(medicaid)

* get proportions one variable at a time 
preserve
    drop if mi(uninsured)
    collapse (mean) uninsured [aw=sampweight], by(year)
    tempfile uninsured
    save `uninsured'
restore

drop if mi(medicaid)
collapse (mean) medicaid [aw=sampweight], by(year)
merge 1:1 year using `uninsured', assert(3) nogen

replace medicaid = 100*medicaid
replace uninsured = 100*uninsured

* plot
line uninsured medicaid year, xline(2014, lc(black)) xtitle("") ytitle("Percent") ///
    legend(order(1 "Percent uninsured" 2 "Percent on Medicaid") rows(2) pos(10))
gr export "$root/out/plots/nat_insurance.pdf", as(pdf) replace

*** brfss plots ***
use "$data/temp/regdata", clear

* trend in share smoking/inactive
preserve
    collapse (mean) smk_rate inact_rate [aw=popwt], by(year)
    replace smk_rate = 100*smk_rate
    replace inact_rate = 100*inact_rate
    line smk_rate year, title("") xline(2014, lc(black))
    gr export "$root/out/plots/nat_smk_rate.pdf", as(pdf) replace

    line inact_rate year, title("") xline(2014, lc(black))
    gr export "$root/out/plots/nat_inact_rate.pdf", as(pdf) replace
restore

* trend in share uninsured/smoking/inactive by adoption group (2014 vs no adoption)
collapse (mean) unins_rate* smk_rate* inact_rate* [aw=popwt], by(year year_adopted)
foreach var of varlist *_rate* {
    replace `var' = 100*`var'
}

foreach stub in none _young _nc {
    if "`stub'" == "none" local stub
    gr tw (line unins_rate`stub' year if year_adopted == 0) ///
            (line unins_rate`stub' year if year_adopted == 2014), ///
            legend(order(1 "No Medicaid expansion" 2 "Expansion in 2014")) xline(2014, lc(black)) ///
            title("") xtitle("") ytitle("Percent")
    gr export "$root/out/plots/comparing_unins_rates`stub'.pdf", as(pdf) replace

    gr tw (line smk_rate`stub' year if year_adopted == 0) ///
            (line smk_rate`stub' year if year_adopted == 2014), ///
            legend(order(1 "No Medicaid expansion" 2 "Expansion in 2014")) xline(2014, lc(black)) ///
            title("") xtitle("") ytitle("Percent")
    gr export "$root/out/plots/comparing_smk_rates`stub'.pdf", as(pdf) replace

    gr tw (line inact_rate`stub' year if year_adopted == 0) ///
            (line inact_rate`stub' year if year_adopted == 2014), ///
            legend(order(1 "No Medicaid expansion" 2 "Expansion in 2014")) xline(2014, lc(black)) ///
            title("") xtitle("") ytitle("Percent")
    gr export "$root/out/plots/comparing_inact_rates`stub'.pdf", as(pdf) replace
}

combine_pdf, inputdir("$root/out/plots/*.pdf") output("$root/out/plots/binder.pdf")