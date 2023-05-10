/*
This file cleans data for synthetic controls analysis
*/


* set directory and globals
	cd "/Users/lukestewart/Dropbox (MIT)/14.33/Project/Analysis/Scripts"

	global scripts = c(pwd) + "/"
	global output = subinstr("$scripts", "Scripts/", "Output/",.)
	global source = subinstr("$scripts", "Analysis/Scripts/", "Data/Processing/Output",.)
	
* import data
	use "$source/processed_brfss", clear
	
* limit sample
	drop if _AGEG5YR >= 10
	drop if NUMADULT > 2 & !mi(NUMADULT)
	
* recode missings on dummy vars
	recode HLTHPLAN MEDCOST STOPSMOK DRINKANY FLUSHOT EXERANY (7 9 0 = .)
	drop if mi(HLTHPLAN) & mi(MEDCOST) & mi(STOPSMOK) & mi(DRINKANY) & mi(FLUSHOT) & mi(EXERANY)
	
* gen new dummies for income and employment status
	levelsof _AGEG5YR, local(ages)
	levelsof EMPLOY, local(employ)
	
	foreach age in `ages' {
		gen AGE_DUMMY_`age' = (_AGEG5YR == `age')
	}
	
	foreach employment in `employ' {
		gen EMPLOY_DUMMY_`employment' = (EMPLOY == `employment')
	}
	
* collapse to state-year level
	gen SMOKE_DUM = inlist(_SMOKER, 1, 2)
	keep if inlist(INCOME, 1, 2)
	
	preserve
	
		collapse (mean) GENHLTH PHYSHLTH MENTHLTH POORHLTH HLTHPLAN MEDCOST STOPSMOK SMOKE_DUM DRINKANY DRINKGE5 SEX EXPANSION WHITE HISPANIC BLACK OTHERRACE FLUSHOT EXERANY AGE_DUMMY_* EMPLOY_DUMMY_*, by(_STATE IYEAR STATE_CODE)
	
		sort STATE_CODE IYEAR
		save "$source/sc_prepped.dta", replace
		export delimited using "$source/sc_prepped.csv", replace
	
	restore
	
* export for young groups only
	gen YOUNG = inlist(_AGEG5YR, 1, 2)
	keep if YOUNG
	collapse (mean) GENHLTH PHYSHLTH MENTHLTH POORHLTH HLTHPLAN MEDCOST STOPSMOK SMOKE_DUM DRINKANY DRINKGE5 SEX EXPANSION WHITE HISPANIC BLACK OTHERRACE FLUSHOT EXERANY AGE_DUMMY_* EMPLOY_DUMMY_*, by(_STATE IYEAR STATE_CODE)
	
	sort STATE_CODE IYEAR
	save "$source/sc_prepped_young.dta", replace
	export delimited using "$source/sc_prepped_young.csv", replace
