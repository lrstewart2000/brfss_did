/*
This file creates tables containing diff and diff and triple diff estimates for A) the full sample, B) individuals under 30, and C) interviews not conducted in 2020/2021
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
	
* limit sample
	drop if _AGEG5YR >= 10
	drop if NUMADULT > 2 & !mi(NUMADULT)

* recode vars
	recode MARITAL EDUCA HLTHPLAN MEDCOST FLUSHOT EXERANY CHECKUP (7 9 = .)
	recode EMPLOY 9 = .
	recode MEDCOST 0 = .

* code dummies and interactions
	gen LOWINCOME = (INCOME <= 3)
	gen HIGHINCOME = (INCOME == 7)
	
	gen LOWINC_POST = LOWINCOME*POST
	
	gen SMOKE_DUM = inlist(_SMOKER, 1, 2)
	
	gen COLGRAD = EDUCA == 6
	gen HSGRAD = inlist(EDUCA, 4, 5)
	
	gen YOUNG = inlist(_AGEG5YR, 1, 2)
	gen MIDAGE = inlist(_AGEG5YR, 3, 4, 5, 6)
	gen OLD = inlist(_AGEG5YR, 7, 8, 9)
	
	gen FEMALE = SEX == 2
	
	la var POST "Treatment indicator"
	la var LOWINC_POST "Treated*Low Income"
	la var LOWINCOME "Low Income"
	la var COLGRAD "Col. Grad."
	la var HSGRAD "HS Grad."
	la var YOUNG "Less than 25 y.o."
	la var MIDAGE "25 - 50 y.o."
	la var OLD "50+ y.o."
	la var FEMALE "Female"
	la var BLACK "Black"
	la var HISPANIC "Hispanic"
	la var OTHERRACE "Other Race"
	
	tempfile prepped
	save `prepped'
	
* regs: 1) DD 2) DD with control 3) DDD 4) DDD with controls
	local basic_controls FEMALE BLACK HISPANIC OTHERRACE HSGRAD COLGRAD MIDAGE OLD i.MARITAL i.INCOME i.EMPLOY

* smoking regs
	reghdfe SMOKE_DUM POST i._STATE i.IYEAR if LOWINCOME, noabsorb cluster(_STATE IYEAR)
	eststo m1
	reghdfe SMOKE_DUM POST `basic_controls' i._STATE i.IYEAR if LOWINCOME, noabsorb cluster(_STATE IYEAR)
	eststo m2
	
	reghdfe SMOKE_DUM LOWINC_POST POST LOWINCOME i._STATE i.IYEAR if LOWINCOME | HIGHINCOME, noabsorb cluster(_STATE IYEAR)
	lincom POST + LOWINC_POST
	eststo m3
	reghdfe SMOKE_DUM LOWINC_POST POST LOWINCOME `basic_controls' i._STATE i.IYEAR if LOWINCOME | HIGHINCOME, noabsorb cluster(_STATE IYEAR)
	lincom POST + LOWINC_POST
	eststo m4
	
	esttab m1 m2 m3 m4 using "$output/smoke_dd_table.txt", b(%16.3fc) se(%16.3fc) not nostar nogaps label title("DD/DDD regression estimates - Smoking") mtitles("DD" "DD w/ controls" "DDD" "DDD w/ controls") keep(POST LOWINCOME LOWINC_POST FEMALE BLACK HISPANIC OTHERRACE HSGRAD COLGRAD MIDAGE OLD) order(POST LOWINCOME LOWINC_POST FEMALE BLACK HISPANIC OTHERRACE HSGRAD COLGRAD MIDAGE OLD) tex replace
	
* drinking regs
	reghdfe DRINKGE5 POST i._STATE i.IYEAR if LOWINCOME, noabsorb cluster(_STATE IYEAR)
	eststo m5
	reghdfe DRINKGE5 POST `basic_controls' i._STATE i.IYEAR if LOWINCOME, noabsorb cluster(_STATE IYEAR)
	eststo m6

	
	reghdfe DRINKGE5 LOWINC_POST POST LOWINCOME i._STATE i.IYEAR if LOWINCOME | HIGHINCOME, noabsorb cluster(_STATE IYEAR)
	lincom POST + LOWINC_POST
	eststo m7
	reghdfe DRINKGE5 LOWINC_POST POST LOWINCOME `basic_controls' i._STATE i.IYEAR if LOWINCOME | HIGHINCOME, noabsorb cluster(_STATE IYEAR)
	lincom POST + LOWINC_POST
	eststo m8
	
	esttab m5 m6 m7 m8 using "$output/drink_dd_table.txt", b(%16.3fc) se(%16.3fc) not nostar nogaps label title("DD/DDD regression estimates - Drinking") mtitles("DD" "DD w/ controls" "DDD" "DDD w/ controls") keep(POST LOWINCOME LOWINC_POST FEMALE BLACK HISPANIC OTHERRACE HSGRAD COLGRAD MIDAGE OLD) order(POST LOWINCOME LOWINC_POST FEMALE BLACK HISPANIC OTHERRACE HSGRAD COLGRAD MIDAGE OLD) tex replace
	
*** repeat regs with age interactions on treatment at 3 age levels ***
	use `prepped', clear
	local basic_controls FEMALE BLACK HISPANIC OTHERRACE HSGRAD COLGRAD i.MARITAL i.INCOME i.EMPLOY

* create interaction vars and label them
	gen POST_YOUNG = POST*YOUNG
	gen POST_MID = POST*MIDAGE
	gen LOWINC_YOUNG = LOWINCOME*YOUNG
	gen LOWINC_MID = LOWINCOME*MIDAGE
	gen LOWINC_POST_YOUNG = LOWINC_POST*YOUNG
	gen LOWINC_POST_MID = LOWINC_POST*MIDAGE
	
	la var POST_YOUNG "Treated*Young"
	la var POST_MID "Treated*Middle-aged"
	la var LOWINC_YOUNG "Low Income*Young"
	la var LOWINC_MID "Low Income*Middle-aged"
	la var LOWINC_POST_YOUNG "Treatment*Low Income*Young"
	la var LOWINC_POST_MID "Treatment*Low Income*Middle-aged"

* smoking regs
	reghdfe SMOKE_DUM POST YOUNG MIDAGE POST_YOUNG POST_MID i._STATE i.IYEAR if LOWINCOME, noabsorb cluster(_STATE IYEAR)
	lincom POST + POST_YOUNG
	lincom POST + POST_MID
	eststo m1
	reghdfe SMOKE_DUM POST YOUNG MIDAGE POST_YOUNG POST_MID `basic_controls' i._STATE i.IYEAR if LOWINCOME, noabsorb cluster(_STATE IYEAR)
	lincom POST + POST_YOUNG
	lincom POST + POST_MID
	eststo m2
	
	reghdfe SMOKE_DUM POST LOWINCOME YOUNG MIDAGE LOWINC_YOUNG LOWINC_MID LOWINC_POST POST_YOUNG POST_MID LOWINC_POST_YOUNG LOWINC_POST_MID i._STATE i.IYEAR if LOWINCOME | HIGHINCOME, noabsorb cluster(_STATE IYEAR)
	lincom LOWINC_POST - POST
	lincom (LOWINC_POST + LOWINC_POST_YOUNG) - (POST + POST_YOUNG))	lincom (LOWINC_POST + LOWINC_POST_MID) - (POST + POST_MID))	eststo m3
	reghdfe SMOKE_DUM POST LOWINCOME YOUNG MIDAGE LOWINC_YOUNG LOWINC_MID LOWINC_POST POST_YOUNG POST_MID LOWINC_POST_YOUNG LOWINC_POST_MID `basic_controls' i._STATE i.IYEAR if LOWINCOME | HIGHINCOME, noabsorb cluster(_STATE IYEAR)
	lincom LOWINC_POST - POST
	lincom (LOWINC_POST + LOWINC_POST_YOUNG) - (POST + POST_YOUNG)
	lincom (LOWINC_POST + LOWINC_POST_MID) - (POST + POST_MID)
	eststo m4
	
	esttab m1 m2 m3 m4 using "$output/age_smoke_dd_table.txt", b(%16.3fc) se(%16.3fc) not nostar nogaps label title("Young pop. DD/DDD regression estimates - Smoking") mtitles("DD" "DD w/ controls" "DDD" "DDD w/ controls") keep(POST YOUNG MIDAGE POST_YOUNG POST_MID LOWINCOME LOWINC_YOUNG LOWINC_MID LOWINC_POST LOWINC_POST_YOUNG LOWINC_POST_MID FEMALE BLACK HISPANIC OTHERRACE HSGRAD COLGRAD) order(POST YOUNG MIDAGE POST_YOUNG POST_MID LOWINCOME LOWINC_YOUNG LOWINC_MID LOWINC_POST LOWINC_POST_YOUNG LOWINC_POST_MID FEMALE BLACK HISPANIC OTHERRACE HSGRAD COLGRAD) tex replace
	
* drinking regs
	reghdfe DRINKGE5 POST YOUNG MIDAGE POST_YOUNG POST_MID i._STATE i.IYEAR if LOWINCOME, noabsorb cluster(_STATE IYEAR)
	lincom POST + POST_YOUNG
	lincom POST + POST_MID
	eststo m5
	reghdfe DRINKGE5 POST YOUNG MIDAGE POST_YOUNG POST_MID `basic_controls' i._STATE i.IYEAR if LOWINCOME, noabsorb cluster(_STATE IYEAR)
	lincom POST + POST_YOUNG
	lincom POST + POST_MID
	eststo m6

	
	reghdfe DRINKGE5 POST LOWINCOME YOUNG MIDAGE LOWINC_YOUNG LOWINC_MID LOWINC_POST POST_YOUNG POST_MID LOWINC_POST_YOUNG LOWINC_POST_MID i._STATE i.IYEAR if LOWINCOME | HIGHINCOME, noabsorb cluster(_STATE IYEAR)
	lincom LOWINC_POST - POST
	lincom (LOWINC_POST + LOWINC_POST_YOUNG) - (POST + POST_YOUNG)
	lincom (LOWINC_POST + LOWINC_POST_MID) - (POST + POST_MID)
	eststo m7
	reghdfe DRINKGE5 POST LOWINCOME YOUNG MIDAGE LOWINC_YOUNG LOWINC_MID LOWINC_POST POST_YOUNG POST_MID LOWINC_POST_YOUNG LOWINC_POST_MID `basic_controls' i._STATE i.IYEAR if LOWINCOME | HIGHINCOME, noabsorb cluster(_STATE IYEAR)
	lincom LOWINC_POST - POST
	lincom (LOWINC_POST + LOWINC_POST_YOUNG) - (POST + POST_YOUNG)
	lincom (LOWINC_POST + LOWINC_POST_MID) - (POST + POST_MID)
	eststo m8
	
	esttab m5 m6 m7 m8 using "$output/age_drink_dd_table.txt", b(%16.3fc) se(%16.3fc) not nostar nogaps label title("Young pop. DD/DDD regression estimates - Drinking") mtitles("DD" "DD w/ controls" "DDD" "DDD w/ controls") keep(POST YOUNG MIDAGE POST_YOUNG POST_MID LOWINCOME LOWINC_YOUNG LOWINC_MID LOWINC_POST LOWINC_POST_YOUNG LOWINC_POST_MID FEMALE BLACK HISPANIC OTHERRACE HSGRAD COLGRAD) order(POST YOUNG MIDAGE POST_YOUNG POST_MID LOWINCOME LOWINC_YOUNG LOWINC_MID LOWINC_POST LOWINC_POST_YOUNG LOWINC_POST_MID FEMALE BLACK HISPANIC OTHERRACE HSGRAD COLGRAD) tex replace

*** checkup regs, age interacted ***
	reghdfe CHECKUP POST YOUNG MIDAGE POST_YOUNG POST_MID i._STATE i.IYEAR if LOWINCOME, noabsorb cluster(_STATE IYEAR)
	lincom POST + POST_YOUNG
	lincom POST + POST_MID
	eststo m9
	reghdfe CHECKUP POST YOUNG MIDAGE POST_YOUNG POST_MID `basic_controls' i._STATE i.IYEAR if LOWINCOME, noabsorb cluster(_STATE IYEAR)
	lincom POST + POST_YOUNG
	lincom POST + POST_MID
	eststo m10
	
	reghdfe CHECKUP POST LOWINCOME YOUNG MIDAGE LOWINC_YOUNG LOWINC_MID LOWINC_POST POST_YOUNG POST_MID LOWINC_POST_YOUNG LOWINC_POST_MID i._STATE i.IYEAR if LOWINCOME | HIGHINCOME, noabsorb cluster(_STATE IYEAR)
	lincom LOWINC_POST - POST
	lincom (LOWINC_POST + LOWINC_POST_YOUNG) - (POST + POST_YOUNG)
	lincom (LOWINC_POST + LOWINC_POST_MID) - (POST + POST_MID)
	eststo m11
	reghdfe CHECKUP POST LOWINCOME YOUNG MIDAGE LOWINC_YOUNG LOWINC_MID LOWINC_POST POST_YOUNG POST_MID LOWINC_POST_YOUNG LOWINC_POST_MID `basic_controls' i._STATE i.IYEAR if LOWINCOME | HIGHINCOME, noabsorb cluster(_STATE IYEAR)
	lincom LOWINC_POST - POST
	lincom (LOWINC_POST + LOWINC_POST_YOUNG) - (POST + POST_YOUNG)
	lincom (LOWINC_POST + LOWINC_POST_MID) - (POST + POST_MID)
	eststo m12
	
	esttab m9 m10 m11 m12 using "$output/age_checkup_dd_table.txt", b(%16.3fc) se(%16.3fc) not nostar nogaps label title("Young pop. DD/DDD regression estimates - Checkup") mtitles("DD" "DD w/ controls" "DDD" "DDD w/ controls") keep(POST YOUNG MIDAGE POST_YOUNG POST_MID LOWINCOME LOWINC_YOUNG LOWINC_MID LOWINC_POST LOWINC_POST_YOUNG LOWINC_POST_MID FEMALE BLACK HISPANIC OTHERRACE HSGRAD COLGRAD) order(POST YOUNG MIDAGE POST_YOUNG POST_MID LOWINCOME LOWINC_YOUNG LOWINC_MID LOWINC_POST LOWINC_POST_YOUNG LOWINC_POST_MID FEMALE BLACK HISPANIC OTHERRACE HSGRAD COLGRAD) tex replace
	
	
*** state and year fixed effects table ***
	use `prepped', clear
	
	local basic_controls FEMALE BLACK HISPANIC OTHERRACE HSGRAD COLGRAD MIDAGE OLD i.MARITAL i.INCOME i.EMPLOY
	
	reg SMOKE_DUM POST i.IYEAR i._STATE `basic_controls' if LOWINCOME
	eststo m1
	
	reg DRINKGE5 POST i.IYEAR i._STATE `basic_controls' if LOWINCOME
	eststo m2
	esttab m1 m2 using "$output/fe_table.txt", b(%16.3fc) se(%16.3fc) not nostar nogaps label title("DD reg. estimates with all controls and fixed effects") mtitles("Smoking" "Drinking") tex replace
	

	