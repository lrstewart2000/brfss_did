

* set directory and globals
	cd "/Users/lukestewart/Dropbox (MIT)/14.33/Project/Data/Processing/Scripts"

	global scripts = c(pwd) + "/"
	global output = subinstr("$scripts", "Scripts/", "Output/",.)
	global source = subinstr("$scripts", "Processing/Scripts/", "Source",.)

* load in 2002 data, keep vars
	import sasxport5 "$source/SMART/CNTY02.xpt", novallabels clear
	rename *, upper
	
	keep DISPCODE SEQNO NUMADULT NUMMEN NUMWOMEN GENHLTH HLTHPLAN PERSDOC2 FACILIT3 MEDCARE MEDREAS EXERANY2 FLUSHOT SMOKE100 SMOKEDAY STOPSMK2 ALCDAY3 AVEDRNK DRNK2GE5 DRINKDRI AGE HISPANC2 MRACE MARITAL CHILDREN EDUCA EMPLOY INCOME2 WEIGHT HEIGHT SEX PREGNANT CHECKUP RSNOCOV2 PSTPLAN2 LOSEWT MAINTAIN FEWCAL PHYACT
	
* load in 2003 data, keep vars
	import sasxport5 "$source/SMART/CNTY03.xpt", novallabels clear
	rename *, upper
	
	
	
	
	
	
	
	
* load in data
	import sasxport5 "$source/SMART/MMSA2019.xpt", novallabels clear
	rename *, upper

* select variables
	local demo_vars _RACE _RACEGR3 _SEX _HISPANIC _AGEG5YR _AGE65YR _AGE80 _AGE_G _EDUCAG EDUCA _INCOMG INCOME2 
	local healthvars _BMI5 _BMI5CAT
	keep MMSANAME DISPCODE 
