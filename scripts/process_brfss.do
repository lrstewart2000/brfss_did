/*****************************************************************************************
This script uses BRFSS data to get shares by state and year of people with various 
health conditions/behaviors: current smoker, recent binge drinking event, obese, 
overweight, and inactive 
*****************************************************************************************/

clear all

forvalues year = 1984/2019 {
    /* note that calculated variables like _smoker change names to _smoker2, but stata will
    handle these automatically, no need to rename */
    if `year' <= 1986 {
        local wt _finalwt
        local usevars _smoker drinkany drinkge5 exerany _state `wt'
        use `usevars' using "$root/raw/brfss/temp/`year'", clear 
    }
    else if inrange(`year', 1987, 1993) {
        local wt _finalwt
        local usevars _smoker drinkany drinkge5 _bmi exerany _state `wt'
        use `usevars' using "$root/raw/brfss/temp/`year'", clear 

        replace _bmi = _bmi/10
    }
    else if inrange(`year', 1994, 2000) {
        local wt _finalwt
        if `year' == 2000 local bmi2 2
        local usevars _smoker2 drinkany drinkge5 _bmi`bmi2' exerany _state `wt'
        use `usevars' using "$root/raw/brfss/temp/`year'", clear 
        rename _smoker2 _smoker
        rename _bmi`bmi2' _bmi

        replace _bmi = _bmi/10
    }
    else if inrange(`year', 2001, 2019) {
        if `year' < 2011 local wt _finalwt
        if `year' >= 2011 local wt _llcpwt
        local usevars _smoker? drnkany? drnk?ge5 alcday _bmi? exerany2 _state `wt'
        use `usevars' using "$root/raw/brfss/temp/`year'", clear 
        rename _smoker? _smoker
        rename _bmi? _bmi
        rename drnkany? drinkany
        rename drnk?ge5 drinkge5
        rename exerany2 exerany

        if `year' == 2001 replace _bmi = _bmi/10000
        else replace _bmi = _bmi/100
    }
	
    /* definition of _smoker == 1 here is that you have smoked at least 100 cigarettes in
    your life, you consider yourself an active smoker, and you smoke regularly */
	gen byte smoker = _smoker == 1
	replace smoker = . if _smoker == 9	
	
    /* def of binge: 0 if the individual does not drink OR does drink and has not had
    5 or more drinks on one occasion in the last month. 1 if the individual has had 5 or
    more drinks on at least one occasion in the last month, missing if refused to answer
    either question or did not know whether or not they binged. From 2001 onward, we also
    set binge to 0 if the respondent indicates that they had no drinks in the last 30 days
    (via alday) */
	gen byte binge = .
	replace binge = 0 if drinkany == 2
    if `year' >= 2001 replace binge = 0 if alcday == 888
	replace binge = 0 if drinkge5 == 88
	replace binge = 1 if inrange(drinkge5, 1, 76)
	
	/* not doing obese or overweight for 1984-1986 because bmi was not a calculated 
    variable for, and attempts to recreate the calculation are difficult to do reliably */
	gen byte obese = .
	gen byte overweight = .
    * bmi standards for overweight and obese are based on those from the cdc
    if `year' >= 1987 {
        replace obese = _bmi >= 30
        replace overweight = _bmi >= 25
        replace obese = . if _bmi >= 99 | mi(_bmi)
        replace overweight = . if _bmi >= 99 | mi(_bmi)
    }
	
    /* inactive is 1 if the respondent did not exercise or perform recreational activities
    outside of work, and is 0 if they did (DK/NS and refusal set this to missing) */
	gen inactive = exerany == 2
	replace inactive = . if exerany == . | exerany == 9 | exerany == 7
	
    * keep only states with valid fips and not alaska hawaii
	keep if _state <= 56 & !inlist(_state, 2, 15)
	collapse (mean) smoker binge obese overweight inactive (rawsum) wt = `wt' [aw=`wt'], ///
        by(_state) fast 
	replace wt = int(wt)

	gen year = `year'
	rename _state fips
	
	compress
	tempfile `year'
	save ``year''
}
forvalues year = 1984 / 2018 {
	append using ``year''
}

* make graphs of these over time to make sure they look smooth 
preserve
    collapse (mean) smoker binge obese overweight inactive [aw=wt], by(year) fast
        line smoker binge obese overweight inactive year, xti("") ///
        lc(cranberry orange green navy purple) lp(solid dash solid dash solid) ///
        legend(order(1 "share smoke every day" 2 "share binge drink last month" ///
        3 "share obese" 4 "share overweight or obese" 5 "share no exercise last 30 days")) ///
        ti("Key BRFSS Indicators") xlab(1990(5)2020)
    graph export "$root/figures/brfss_indicators.pdf", replace
restore

statastates, fips(fips)
drop if _merge == 2
assert _merge == 3
drop _merge 

label variable smoker "share smoke every day"
label variable binge "share binge drink last month"
label variable obese "share obese"
label variable overweight "share overweight or obese"
label variable inactive "share no exercise last 30 days"
label variable wt "sum of weights (BRFSS)"
compress
label data "key BRFSS indicators"
save "$root/mid/brfss_state", replace 
