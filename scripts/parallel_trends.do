/*
This file estimates dynamic DD models, getting DD and DDD estimators for each post treatment year to get dynamic estimates and check parallel trends
*/


* set directory and globals
	cd "/Users/lukestewart/Dropbox (MIT)/14.33/Project/Analysis/Scripts"

	global scripts = c(pwd) + "/"
	global output = subinstr("$scripts", "Scripts/", "Output/",.)
	global source = subinstr("$scripts", "Analysis/Scripts/", "Data/Processing/Output",.)
	
* import data
	use "$source/processed_brfss", clear
	
* handle dates
	gen DATE_EXPANSION = date(DATE, "MDY", 2021)
	gen DATE_INTERVIEW = mdy(IMONTH, IDAY, IYEAR)

	gen POST = DATE_INTERVIEW > DATE_EXPANSION & !mi(DATE_EXPANSION)
	replace EXPANSION = 0 if DATE_EXPANSION >= mdy(1, 1, 2021)
	
* constructing "years post treatment"
	gen YEARS_POST = ceil((DATE_INTERVIEW - DATE_EXPANSION)/365) if !mi(DATE_EXPANSION)
	replace YEARS_POST = 0 if mi(YEARS_POST)
* handle negative values, because stata does not accept negative factor vars. can simply undo this operation later
	
* limit sample, need all states in this analysis to have not expanded or to have expanded at the same time
	drop if _AGEG5YR >= 10
	drop if NUMADULT > 2
	keep if DATE_EXPANSION == mdy(1,1,2014) | EXPANSION == 0

	
* code dummies and interactions
	gen LOWINCOME = (INCOME <= 3)
	gen HIGHINCOME = (INCOME == 7)
	gen SMOKE_DUM = inlist(_SMOKER, 1, 2)
	keep if LOWINCOME | HIGHINCOME
	
* recode vars
	recode MARITAL EDUCA HLTHPLAN MEDCOST FLUSHOT EXERANY (7 9 = .)
	recode EMPLOY 9 = .
	recode MEDCOST 0 = .
	
* control locals
	local basic_controls i.MARITAL i.EDUCA i.INCOME i.SEX i.WHITE i.BLACK i.HISPANIC i.EMPLOY i.OTHERRACE i._AGEG5YR
	local full_controls c.GENHLTH c.PHYSHLTH c.MENTHLTH c.POORHLTH i.MEDCOST i.EMPLOY i.FLUSHOT i.EXERANY
	

* partial out effect of different control sets for parallel trends analysis
* smoking
	reg SMOKE_DUM i._STATE i.IYEAR if LOWINCOME
	predict SMOKE_RESID_NOCON, residuals
	
	reg SMOKE_DUM i._STATE i.IYEAR `basic_controls' if LOWINCOME
	predict SMOKE_RESID_BASIC, residuals
	
	reg SMOKE_DUM i._STATE i.IYEAR `basic_controls' `full_controls' if LOWINCOME
	predict SMOKE_RESID_FULL, residuals
	
* smoking DDD
	reg SMOKE_DUM i._STATE i.IYEAR if LOWINCOME
	predict SMOKE_RESIDDD_NOCON, residuals
	
	reg SMOKE_DUM i._STATE i.IYEAR `basic_controls' if LOWINCOME
	predict SMOKE_RESIDDD_BASIC, residuals
	
	reg SMOKE_DUM i._STATE i.IYEAR `basic_controls' `full_controls' if LOWINCOME
	predict SMOKE_RESIDDD_FULL, residuals

* drinking
	reg DRINKGE5 i._STATE i.IYEAR if LOWINCOME
	predict DRINK_RESID_NOCON, residuals
	
	reg DRINKGE5 i._STATE i.IYEAR `basic_controls' if LOWINCOME
	predict DRINK_RESID_BASIC, residuals
	
	reg DRINKGE5 i._STATE i.IYEAR `basic_controls' `full_controls' if LOWINCOME
	predict DRINK_RESID_FULL, residuals
	
* drinking DDD
	reg DRINKGE5 i._STATE i.IYEAR LOWINCOME if LOWINCOME | HIGHINCOME
	predict DRINK_RESIDDD_NOCON, residuals
	
	reg DRINKGE5 i._STATE i.IYEAR LOWINCOME `basic_controls' if LOWINCOME | HIGHINCOME
	predict DRINK_RESIDDD_BASIC, residuals
	
	reg DRINKGE5 i._STATE i.IYEAR LOWINCOME `basic_controls' `full_controls' if LOWINCOME | HIGHINCOME
	predict DRINK_RESIDDD_FULL, residuals
	
* collapse to treatment group-year level
	preserve
	collapse (mean) *_RESID_* *_RESIDDD_* SMOKE_DUM DRINKGE5, by(EXPANSION IYEAR)
	
	la var SMOKE_RESID_NOCON "Mean Smoking Rate"
	la var SMOKE_RESID_BASIC "Mean Smoking Rate"
	la var SMOKE_RESID_FULL "Mean Smoking Rate"
	
	la var DRINK_RESID_NOCON "Mean Binge Drinking Rate"
	la var DRINK_RESID_BASIC "Mean Binge Drinking Rate"
	la var DRINK_RESID_FULL "Mean Binge Drinking Rate"
	
	graph set window fontface "Times New Roman"
	grstyle init
	grstyle color background white
	
* plot for parallel trends	
	line SMOKE_RESID_NOCON IYEAR if !EXPANSION || line SMOKE_RESID_NOCON IYEAR if EXPANSION ||, legend(label(1 "Non-expansion") label(2 "Expansion")) xline(2014) title("Mean Smoking Rate, State & Year FE") xtitle("Year") ytitle("")
	graph export "$output/PT_1.png", replace
	
	line SMOKE_RESID_BASIC IYEAR if !EXPANSION || line SMOKE_RESID_BASIC IYEAR if EXPANSION ||, legend(label(1 "Non-expansion") label(2 "Expansion")) xline(2014) title("Mean Smoking Rate, Basic Controls") xtitle("Year") ytitle("")
	graph export "$output/PT_2.png", replace
	
	line SMOKE_RESID_FULL IYEAR if !EXPANSION || line SMOKE_RESID_FULL IYEAR if EXPANSION ||, legend(label(1 "Non-expansion") label(2 "Expansion")) xline(2014) xtitle("Year") ytitle("") title("Mean Smoking Rate, Full Controls")
	graph export "$output/PT_3.png", replace
	
	
	line DRINK_RESID_NOCON IYEAR if !EXPANSION || line DRINK_RESID_NOCON IYEAR if EXPANSION ||, legend(label(1 "Non-expansion") label(2 "Expansion")) xline(2014) title("Mean Binge Drinking Rate, State & Year FE") xtitle("Year") ytitle("")
	graph export "$output/PT_7.png", replace
	
	line DRINK_RESID_BASIC IYEAR if !EXPANSION || line DRINK_RESID_BASIC IYEAR if EXPANSION ||, legend(label(1 "Non-expansion") label(2 "Expansion")) xline(2014) title("Mean Binge Drinking Rate, Basic Controls") xtitle("Year") ytitle("")
	graph export "$output/PT_8.png", replace
	
	line DRINK_RESID_FULL IYEAR if !EXPANSION || line DRINK_RESID_FULL IYEAR if EXPANSION ||, legend(label(1 "Non-expansion") label(2 "Expansion")) xline(2014) xtitle("Year") ytitle("") title("Mean Binge Drinking Rate, Full Controls")
	graph export "$output/PT_9.png", replace

	restore, preserve
	keep if LOWINCOME | HIGHINCOME
	collapse (mean) *_RESID_* *_RESIDDD_* SMOKE_DUM DRINKGE5, by(EXPANSION IYEAR)
	
	la var SMOKE_RESIDDD_NOCON "Mean Smoking Rate"
	la var SMOKE_RESIDDD_BASIC "Mean Smoking Rate"
	la var SMOKE_RESIDDD_FULL "Mean Smoking Rate"
	
	la var DRINK_RESIDDD_NOCON "Mean Binge Drinking Rate"
	la var DRINK_RESIDDD_BASIC "Mean Binge Drinking Rate"
	la var DRINK_RESIDDD_FULL "Mean Binge Drinking Rate"
	
	line SMOKE_RESIDDD_NOCON IYEAR if !EXPANSION || line SMOKE_RESIDDD_NOCON IYEAR if EXPANSION ||, legend(label(1 "Non-expansion") label(2 "Expansion")) xline(2014) xtitle("Year") ytitle("") title("Mean Smoking Rate, State, Year, Income FE")
	graph export "$output/PT_4.png", replace
	
	line SMOKE_RESIDDD_BASIC IYEAR if !EXPANSION || line SMOKE_RESIDDD_BASIC IYEAR if EXPANSION ||, legend(label(1 "Non-expansion") label(2 "Expansion")) xline(2014) xtitle("Year") ytitle("") title("Mean Smoking Rate, Basic + Income Controls")
	graph export "$output/PT_5.png", replace
	
	line SMOKE_RESIDDD_FULL IYEAR if !EXPANSION || line SMOKE_RESIDDD_FULL IYEAR if EXPANSION ||, legend(label(1 "Non-expansion") label(2 "Expansion")) xline(2014) xtitle("Year") ytitle("") title("Mean Smoking Rate, Full + Income Controls")
	graph export "$output/PT_6.png", replace
	
	line DRINK_RESIDDD_NOCON IYEAR if !EXPANSION || line DRINK_RESIDDD_NOCON IYEAR if EXPANSION ||, legend(label(1 "Non-expansion") label(2 "Expansion")) xline(2014) xtitle("Year") ytitle("") title("Mean Binge Drinking Rate, State, Year, Income FE")
	graph export "$output/PT_10.png", replace
	
	line DRINK_RESIDDD_BASIC IYEAR if !EXPANSION || line DRINK_RESIDDD_BASIC IYEAR if EXPANSION ||, legend(label(1 "Non-expansion") label(2 "Expansion")) xline(2014) xtitle("Year") ytitle("") title("Mean Binge Drinking Rate, Basic + Income Controls")
	graph export "$output/PT_11.png", replace
	
	line DRINK_RESIDDD_FULL IYEAR if !EXPANSION || line DRINK_RESIDDD_FULL IYEAR if EXPANSION ||, legend(label(1 "Non-expansion") label(2 "Expansion")) xline(2014) xtitle("Year") ytitle("") title("Mean Binge Drinking Rate, Full + Income Controls")
	graph export "$output/PT_12.png", replace
	
	restore

	
	

