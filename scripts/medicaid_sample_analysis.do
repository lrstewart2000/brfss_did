/*
Examines what proportion of the full sample do I keep over time, compared to proportion of medicaid enrollees in a comparable sample (likely CPS)
*/


* set directory and globals
	cd "/Users/lukestewart/Dropbox (MIT)/14.33/Project/Analysis/Scripts"

	global scripts = c(pwd) + "/"
	global output = subinstr("$scripts", "Scripts/", "Output/",.)
	global source = subinstr("$scripts", "Analysis/Scripts/", "Data/Processing/Output",.)
	global input = subinstr("$scripts", "Scripts/", "Input/",.)
	
* import data
	use "$source/processed_brfss", clear

* get sample sizes pre-filter
	collapse (count) _PSU, by(IYEAR)
	rename _PSU count
	la var count "Num of Obs"
	
	tempfile nofilter
	save `nofilter'

* limit sample
	use "$source/processed_brfss", clear
	drop if _AGEG5YR >= 10
	drop if NUMADULT > 2 & !mi(NUMADULT)
	gen LOWINCOME = (INCOME <= 3)
	gen HIGHINCOME = (INCOME == 7)
	keep if LOWINCOME
	
	collapse (count) _PSU, by(IYEAR)
	rename _PSU filtered_count
	la var filtered_count "Num of Obs"
	
	merge 1:1 IYEAR using `nofilter', assert(3)
	gen prop = filtered_count/count
	
	keep prop IYEAR
	
	tempfile temp
	save `temp'
	
* load in Statista data, merge datasets
	import excel "$input/statistic_id200960_percentage-of-us-americans-covered-by-medicaid-1990-2020.xlsx", sheet("Data") cellrange(B6:C36) clear
	rename (B C) (year prop_actual)
	
	replace year = subinstr(year, "'", "19",.) in 1/10
	replace year = subinstr(year, "'", "20",.) in 11/31
	
	destring year prop, replace
	rename year IYEAR
	
	merge 1:1 IYEAR using `temp', keep(3)
	
	replace prop = 100*prop
	format prop %16.1fc
	
* plot and export
	graph set window fontface "Times New Roman"
	grstyle init
	grstyle color background white
	
	line prop_actual prop IYEAR, legend(label(1 "Medicaid enrolled proportion") label(2 "Proportion kept from sample")) title("Medicaid enrollment compared to proportion of sample kept") ytitle("Proportion (%)") xtitle("Year")
	graph export "$output/medicaid_sample.png", replace
	
	
