/*
This file creates summary statistics figures and tables for assignment A6
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
	
* generate "average" variables for the semi-quantitative variables (will use averages for income and age)
	gen INCOME_NUM = INCOME
	recode INCOME_NUM 1 = 5000 2 = 12500 3 = 17500 4 = 22500 5 = 30000 6 = 42500 7 = 50000 77 =. 99 = .
	
	gen AGE_NUM = _AGEG5YR
	recode AGE_NUM 1 = 21 2 = 27 3 = 32 4 = 37 5 = 42 6 = 47 7 = 52 8 = 57 9 = 62 10 = 67 11 = 72 12 = 77 13 = 90 14 = . 

* limit sample
	drop if _AGEG5YR >= 10
	drop if NUMADULT > 2 & !mi(NUMADULT)
	gen LOWINCOME = (INCOME <= 3)
	gen HIGHINCOME = (INCOME == 7)
	keep if LOWINCOME
	
	la var GENHLTH "General Health"
	la var AGE_NUM "Imputed age"
	la var INCOME_NUM "Imputed income"
	
	label define TREAT_lbl 0 "Donor Pool" 1 "Treatment Group"
	
	label values EXPANSION TREAT_lbl
	
* output summary stats tables
	preserve
		recode GENHLTH 7 9 = .
		keep if inlist(IYEAR, 1993, 2000, 2010, 2020)
		
		estpost tabstat GENHLTH AGE_NUM INCOME_NUM if EXPANSION == 0, by(IYEAR) statistics(mean sd min max count) c(s) 
		esttab using "$output/table1a.txt", cells("mean(fmt(%16.2fc)) sd(fmt(%16.2fc)) min(fmt(%16.0fc)) max(fmt(%16.0fc)) count(fmt(%16.0fc))") noobs label nonumbers tex title("Summary statistics of imputed quantitative variables, by treatment group") replace
		
		estpost tabstat GENHLTH AGE_NUM INCOME_NUM if EXPANSION == 1, by(IYEAR) statistics(mean sd min max count) c(s) 
		esttab using "$output/table1b.txt", cells("mean(fmt(%16.2fc)) sd(fmt(%16.2fc)) min(fmt(%16.0fc)) max(fmt(%16.0fc)) count(fmt(%16.0fc))") noobs label nonumbers tex replace
		
		estpost tabstat GENHLTH AGE_NUM INCOME_NUM, by(IYEAR) statistics(mean sd min max count) c(s) 
		esttab using "$output/table1c.txt", cells("mean(fmt(%16.2fc)) sd(fmt(%16.2fc)) min(fmt(%16.0fc)) max(fmt(%16.0fc)) count(fmt(%16.0fc))") noobs label nonumbers tex addnotes("General health given as an index from 1 to 5 with 1 being the best." "Age and income imputed from grouped variables by taking the simple average of the bounds of each group.") replace
	restore
	
* output summary figs
	graph set window fontface "Times New Roman"
	grstyle init
	grstyle color background white
	preserve
		recode SEX 1 = 0 2 = 1
		recode DRINKANY 7 = . 9 = . 2 = 0
		gen COL = (EDUCA == 6)
		gen CUR_SMOKE = inlist(_SMOKER, 1, 2)
		
		
		collapse (mean) WHITE BLACK HISPANIC SEX COL CUR_SMOKE DRINKANY, by(EXPANSION IYEAR)
		
		line WHITE BLACK HISPANIC IYEAR if EXPANSION, title("Proportions of race, treatment group") ytitle("") legend(label(1 "White") label(2 "Black") label(3 "Hispanic"))
		graph export "$output/race_expansion.png", replace
		
		line WHITE BLACK HISPANIC IYEAR if !EXPANSION, title("Proportions of race, donor pool") ytitle("") legend(label(1 "White") label(2 "Black") label(3 "Hispanic"))
		graph export "$output/race_nonexpansion.png", replace
		
		line SEX IYEAR if EXPANSION || line SEX IYEAR if !EXPANSION ||, title("Proportion female") legend(label(1 "Treatment group") label(2 "Donor pool")) ytitle("")
		graph export "$output/sex.png", replace
		
		line COL IYEAR if EXPANSION || line COL IYEAR if !EXPANSION ||, title("Proportion college grad") legend(label(1 "Treatment group") label(2 "Donor pool")) ytitle("")
		graph export "$output/college.png", replace
		
		line CUR_SMOKE IYEAR if EXPANSION & IYEAR != 1993 || line CUR_SMOKE IYEAR if !EXPANSION & IYEAR != 1993 ||, title("Proportion currently smoke") legend(label(1 "Treatment group") label(2 "Donor pool")) ytitle("")
		graph export "$output/smoker.png", replace
		
		line DRINKANY IYEAR if EXPANSION || line DRINKANY IYEAR if !EXPANSION ||, title("Proportion currently drink") legend(label(1 "Treatment group") label(2 "Donor pool")) ylabel(, format(%16.2fc)) ytitle("")
		graph export "$output/drinks.png", replace
	
	restore
		

	
	
	
	
	
	
	
	
	
	
	