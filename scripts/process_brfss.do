/*****************************************************************************************
This script processes raw BRFSS data to be consistent over time, harmonizing demographic
variables and creating indicators for certain health behaviors/outcomes which use roughly
consistent definitions over time
*****************************************************************************************/

clear all

forvalues year = 1993/2021 {
    display "...........................`year'......................."
    /* note that calculated variables like _smoker change names to _smoker2, but stata will
    handle these automatically, no need to rename */
    if `year' <= 1986 {
        local wt _finalwt
        local usevars orace hispan _smoker drinkany drinkge5 exerany _state `wt'
        use `usevars' using "$data/temp/`year'", clear 
    }
    else if inrange(`year', 1987, 1993) {
        local wt _finalwt
        local usevars orace hispan _smoker drinkany drinkge5 _bmi exerany _state `wt'
        use `usevars' using "$data/temp/`year'", clear 

        replace _bmi = _bmi/10
    }
    else if inrange(`year', 1994, 2000) {
        local wt _finalwt
        if `year' == 2000 local bmi2 2
        local usevars orace hispan _smoker2 drinkany drinkge5 _bmi`bmi2' exerany _state `wt'
        use `usevars' using "$data/temp/`year'", clear 
        rename _smoker2 _smoker
        rename _bmi`bmi2' _bmi

        replace _bmi = _bmi/10
    }
    else if inrange(`year', 2001, 2019) {
        if `year' < 2011 local wt _finalwt
        if `year' >= 2011 local wt _llcpwt
        if `year' == 2013 {
            local race _prace1
            local hispan _hispanc
        }
        else if `year' != 2013 {
            local race orace
            local hispan hispanc
        }
        local usevars `race' `hispan' _smoker? drnkany? drnk?ge5 alcday _bmi? exerany2 _state `wt' 
        use `usevars' using "$data/temp/`year'", clear 
        rename _smoker? _smoker
        rename _bmi? _bmi
        rename drnkany? drinkany
        rename drnk?ge5 drinkge5
        rename exerany2 exerany

        if `year' == 2001 replace _bmi = _bmi/10000
        else replace _bmi = _bmi/100
    }

    *** DEMOGRAPHICS ***
    if `year' < 2001 {
        recode orace 1=1 2=2 3=4 4/9=5, gen(wbhao)
        replace wbhao = 3 if hispanic == 1
    }
    else if `year' < 2013 {
        recode orace2 1=1 2=2 3/4=4 5/9=5, gen(wbhao)
        replace wbhao = 3 if hispanc2 == 1
    }
    else if `year' == 2013 {
        recode _prace1 1=1 2=2 4/5=4 6/99=5, gen(wbhao)
        replace wbhao = 3 if _hispanc == 1
    }
    else if `year' > 2013 {
        recode orace3 10=1 20=2 40/54=4 60/99=5, gen(wbhao)
        replace wbhao = 3 if inlist(hispanc3, 1, 2, 3, 4, 5)
    }
	
    *** HEALTH INDICATORS ***
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

	gen year = `year'
	rename _state fips
    keep year fips wbhao smoker binge obese overweight inactive
	tempfile `year'
	save ``year''
}
forvalues year = 1984 / 2018 {
	append using ``year''
}

* save
label variable smoker "share smoke every day"
label variable binge "share binge drink last month"
label variable obese "share obese"
label variable overweight "share overweight or obese"
label variable inactive "share no exercise last 30 days"
compress
save "$data/brfss_combined", replace
