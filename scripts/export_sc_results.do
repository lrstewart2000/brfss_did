/*
This file loads in results from the synthetic controls estimation carried out in python and outputs them to STATA figures and latex tables
*/


* set directory and globals
	cd "/Users/lukestewart/Dropbox (MIT)/14.33/Project/Analysis/Scripts"

	global scripts = c(pwd) + "/"
	global output = subinstr("$scripts", "Scripts/", "Output/",.)
	global source = subinstr("$scripts", "Analysis/Scripts/", "Data/Processing/Output",.)
	
*** SMOKING RESULTS ***
** plotting **
	import delim "$output/sc_vs_actual_smoking.csv", clear
	
	replace v1=v1+1994
	rename v1 year
	
	la var year "Year"
	la var ar "Arkansas"
	la var synthetic_ar "Synthetic Arkansas"
	la var la "Louisiana"
	la var synthetic_la "Synthetic Louisiana"
	la var ky "Kentucky"
	la var synthetic_ky "Synthetic Kentucky"
	
	line ar synthetic_ar year, xline(2014) title("AR vs. Synthetic AR") ytitle("Smoking Rate")
	graph export "$output/AR_smoking_sc.png", replace
	line la synthetic_la year, xline(2016) title("LA vs. Synthetic LA") ytitle("Smoking Rate")
	graph export "$output/LA_smoking_sc.png", replace
	line ky synthetic_ky year, xline(2014) title("KY vs. Synthetic KY") ytitle("Smoking Rate")
	graph export "$output/KY_smoking_sc.png", replace
	
** table **
	import delim "$output/sc_estimates_smoking.csv", clear
	rename v* va*
	cd "$output"
	dataout, save("sc_estimates_smoking_table.txt") tex replace
	cd "$scripts"

*** DRINKING RESULTS ***
** plotting **
	import delim "$output/sc_vs_actual_drinking.csv", clear
	
	replace v1=v1+2001
	rename v1 year
	
	la var year "Year"
	la var ar "Arkansas"
	la var synthetic_ar "Synthetic Arkansas"
	la var la "Louisiana"
	la var synthetic_la "Synthetic Louisiana"
	la var ky "Kentucky"
	la var synthetic_ky "Synthetic Kentucky"
	
	line ar synthetic_ar year, xline(2014) title("AR vs. Synthetic AR") ytitle("Binge Drinking Occ.")
	graph export "$output/AR_drinking_sc.png", replace
	line la synthetic_la year, xline(2016) title("LA vs. Synthetic LA") ytitle("Binge Drinking Occ.")
	graph export "$output/LA_drinking_sc.png", replace
	line ky synthetic_ky year, xline(2014) title("KY vs. Synthetic KY") ytitle("Binge Drinking Occ.")
	graph export "$output/KY_drinking_sc.png", replace
	
** table **
	import delim "$output/sc_estimates_drinking.csv", clear
	rename v* va*
	cd "$output"
	dataout, save("sc_estimates_drinking_table.txt") tex replace
	
**** YOUNG RESULTS ****
*** SMOKING RESULTS ***
** plotting **
	import delim "$output/sc_vs_actual_smoking_young.csv", clear
	
	replace v1=v1+1994
	rename v1 year
	
	la var year "Year"
	la var ar "Arkansas"
	la var synthetic_ar "Synthetic Arkansas"
	la var la "Louisiana"
	la var synthetic_la "Synthetic Louisiana"
	la var ky "Kentucky"
	la var synthetic_ky "Synthetic Kentucky"
	
	line ar synthetic_ar year, xline(2014) title("AR vs. Synthetic AR") ytitle("Smoking Rate")
	graph export "$output/AR_smoking_sc_young.png", replace
	line la synthetic_la year, xline(2016) title("LA vs. Synthetic LA") ytitle("Smoking Rate")
	graph export "$output/LA_smoking_sc_young.png", replace
	line ky synthetic_ky year, xline(2014) title("KY vs. Synthetic KY") ytitle("Smoking Rate")
	graph export "$output/KY_smoking_sc_young.png", replace
	
** table **
	import delim "$output/sc_estimates_smoking_young.csv", clear
	rename v* va*
	cd "$output"
	dataout, save("sc_estimates_smoking_table_young.txt") tex replace
	cd "$scripts"

*** DRINKING RESULTS ***
** plotting **
	import delim "$output/sc_vs_actual_drinking_young.csv", clear
	
	replace v1=v1+2001
	rename v1 year
	
	la var year "Year"
	la var ar "Arkansas"
	la var synthetic_ar "Synthetic Arkansas"
	la var la "Louisiana"
	la var synthetic_la "Synthetic Louisiana"
	la var ky "Kentucky"
	la var synthetic_ky "Synthetic Kentucky"
	
	line ar synthetic_ar year, xline(2014) title("AR vs. Synthetic AR") ytitle("Binge Drinking Occ.")
	graph export "$output/AR_drinking_sc_young.png", replace
	line la synthetic_la year, xline(2016) title("LA vs. Synthetic LA") ytitle("Binge Drinking Occ.")
	graph export "$output/LA_drinking_sc_young.png", replace
	line ky synthetic_ky year, xline(2014) title("KY vs. Synthetic KY") ytitle("Binge Drinking Occ.")
	graph export "$output/KY_drinking_sc_young.png", replace
	
** table **
	import delim "$output/sc_estimates_drinking_young.csv", clear
	rename v* va*
	cd "$output"
	dataout, save("sc_estimates_drinking_table_young.txt") tex replace
