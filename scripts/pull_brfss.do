/*****************************************************************************************
This file pulls SAS transport files from the BRFSS database and saves them to stata files
* all raw files are downloaded directly from https://www.cdc.gov/brfss/annual_data/annual_data.htm
*****************************************************************************************/

clear all
set rmsg on 

* some unzipped files have extra spaces in their file extension, fix that
forvalues y = 2011/2019 {
	cap copy "$root/raw/brfss/LLCP`y'.XPT " "$root/raw/brfss/LLCP`y'.XPT", replace
	if !_rc erase "$root/raw/brfss/LLCP`y'.XPT "
}

forvalues y = 2011/2019 {
	confirm file "$root/raw/brfss/LLCP`y'.XPT"
}

* some files have lower case names
forvalues yy = 1/10 {
	if `yy' < 10 local yy 0`yy'
	cap confirm file "$root/raw/brfss/CDBRFS`yy'.XPT"
	if _rc confirm file "$root/raw/brfss/cdbrfs`yy'.xpt"
}
forvalues yy = 84/100 {
	if `yy' == 100 local yy 00
	cap confirm file "$root/raw/brfss/CDBRFS`yy'.XPT"
	if _rc confirm file "$root/raw/brfss/cdbrfs`yy'.xpt"
}

* import files, save as .dta
forvalues yy = 84/100 {
	local y = 19`yy'
	if `yy' == 100 {
		local yy 00
		local y 2000
	}
	cap import sasxport5 "$root/raw/brfss/CDBRFS`yy'.XPT", clear 
	if _rc import sasxport5 "$root/raw/brfss/cdbrfs`yy'.xpt", clear 
	save "$root/raw/brfss/temp/`y'", replace	
}
forvalues yy = 1 / 10 {
	if `yy' < 10 local yy 0`yy'
	local y = 20`yy'
	cap import sasxport5 "$root/raw/brfss/CDBRFS`yy'.XPT", clear 
	if _rc import sasxport5 "$root/raw/brfss/cdbrfs`yy'.xpt", clear 
	save "$root/raw/brfss/temp/20`yy'", replace	
}
forvalues y = 2011 / 2019 {
	import sasxport5 "$root/raw/brfss/LLCP`y'.XPT", clear 
	save "$root/raw/brfss/temp/`y'", replace 
}
