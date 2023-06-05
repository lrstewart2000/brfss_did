/*****************************************************************************************
This file pulls SAS transport files from the BRFSS database and saves them to stata files
* all raw files are downloaded directly from https://www.cdc.gov/brfss/annual_data/annual_data.htm
*****************************************************************************************/

clear all
set rmsg on 

forvalues y = 1993/2021 {
	import sasxport5 "$data/raw/brfss`y'.xpt", clear 
	save "$data/temp/brfss/`y'", replace 
}
