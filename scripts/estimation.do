/*****************************************************************************************
This script estimates the main DID models using the Calloway Sant'anna framework
*****************************************************************************************/

* load data
use "$data/temp/regdata", clear
keep if inrange(year, 2000, 2019)
replace year_adopted = 0 if year_adopted > 2019
set scheme cf_custom

* start in 1995 for smoking, start in 2000 for inactivity (potentially only doing even years?)

/* for each of my main samples (full, young, non-college), estimated with/without weights 
and with/without pre-treatment covariates (income in 2010, college education share in 
2010, possibly others related to health behavior or health care access */
foreach outcome in smk inact {

    if "`outcome'" == "inact" {
        keep if year >= 2000
    }

    foreach samp in full young nc {
        if "`samp'" == "full" {
            local stub
        }
        else if "`samp'" == "young" {
            local stub _young
        }
        else if "`samp'" == "nc" {
            local stub _nc
        }

        * simple ATT aggregation
        csdid `outcome'_rate`stub', ivar(fips) time(year) gvar(year_adopted) agg(simple)        
        eststo `outcome'_`samp'
        csdid `outcome'_rate`stub' coll_share logpci, ivar(fips) time(year) gvar(year_adopted) agg(simple)        
        eststo `outcome'_`samp'_cov

        * event study plotting
        csdid `outcome'_rate`stub', ivar(fips) time(year) gvar(year_adopted) agg(event)        
        csdid_plot, title("")
        csdid `outcome'_rate`stub' coll_share logpci, ivar(fips) time(year) gvar(year_adopted) agg(event)        
        csdid_plot, title("")


    }

}

esttab smk_full smk_full_cov smk_young smk_young_cov ///
    smk_nc smk_nc_cov, b(%5.3f) se(%5.3f) obslast ///
    mtitle("Full sample" "Full sample" "Under 35" "Under 35" "Non-college" "Non-college")

esttab inact_full inact_full_cov inact_young inact_young_cov ///
    inact_nc inact_nc_cov, b(%5.3f) se(%5.3f) obslast ///
    mtitle("Full sample" "Full sample" "Under 35" "Under 35" "Non-college" "Non-college")