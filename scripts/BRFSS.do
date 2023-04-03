
/*************************
this script imports and processes all separate brfss data files from 1993 onward
interview info:
    disposition
    interview date
calculated basic vars:
    state
    weight
    psu id
demographics:
    number of adults (men/women)
    marital status - MARTIAL has not changed too much through time, but will probably do one hot encoding for marriage
    education - EDUCA changed coding from 1992 to 1993, should probably just do college and noncollege, or no hs, hs, and college
    lf status - EMPLOY appears to retain mostly the same encoding, can interpret "out of work" to mean unemployed probably
    income - strategy on income should be to find bin in which some percentile of the income distribution falls and one-hot a low income variable, maybe for bottom quartile
    sex - prior to 2018 was a binary variable for male female called SEX. 2018 included DK/NS and refused option, called SEX1. 2019 introduced BIRTHSEX
    race - use the question of "best represents your race" (ORACE#) and encode wbho
    age - becomes binned in 2014, probably best to do 18-24, 25-54, 55+
behavior
    smoking
    doctor's visit (checkup)
**************************/ 
* loop through years (we'll see if this is feasible)
local lowinc_cat 3
forvalues year = 1994/2000 {
* set locals
    if `year' == 1994 local incvar INCOME
    if `year' == 1995 local incvar INCOME1995
    if inrange(`year', 1996, 2020) local incvar INCOME2
    if `year' == 2021 local incvar INCOME3
* load data
	import sasxport5 "$data/raw/brfss`year'.XPT", clear

* rename to all caps
    rename *, upper 
	rename _*, upper
	
* keep only necessary vars and completed interviews
	keep _FINALWT _STATE IYEAR IMONTH IDAY DISPCODE AGE MARITAL EDUCA EMPLOY INCOME SEX RACE CHECKUP STOPSMOK _SMOKER2
    keep if DISPCODE == 1

* handle missings
    replace AGE = . if inlist(AGE, 7, 9)
    replace RACE = . if RACE == 99
    replace EDUCA = . if EDUCA == 9
    replace EMPLOY = . if EMPLOY == 9
    replace INCOME = . if inlist(INCOME, 77, 99)
    replace MARITAL = . if MARITAL == 9
    replace _SMOKER2 = . if _SMOKER2 == 9
    replace STOPSMOK = . if inlist(STOPSMOK, 7, 9)

* recode select demographics
    if `year' <= 2013 recode AGE 18/24=1
    recode RACE 1=1 2=2 3/5=3 6/8=4, gen(wbho)
    recode EDUCA 1/3=1 4=2 5=3 6=4, gen(educ4)
    gen lowinc = INCOME <= `lowinc_cat'
    gen married = MARITAL == 1
    recode EMPLOY 1/2=1 3/4=2 5/8=3, gen(lfstat)

* get interview date
    gen idate_str = IDAY + "-" + IMONTH + "-19" + IYEAR
    gen idate = date(idate_str, "DMY")
    format idate %td
    gen year = yofd(idate)

* recode smoking variables
    gen smoker = inlist(_SMOKER, 1,2,3,4,5)
    gen stopsmok = STOPSMOK == 1 if !mi(STOPSMOK)
    assert mi(stopsmok) if smoker == 0

* rename and save to append
    ren (_FINALWT _STATE AGE) (wgt fips age)
    gen id = "`year'" + string(_n)
    keep id wgt fips age wbho educ4 lowinc married lfstat idate year smoker stopsmok

    tempfile temp`year'
    save `temp`year''
}
forvalues year = 1994/1999 {
    append using `temp`year''
}

exit
* 1993
	import sasxport5 "$source/CDBRFS93.XPT", clear
	rename *, upper
	rename _*, upper
	
	keep _FINALWT _STATE _PSU IYEAR IMONTH IDAY DISPCODE NUMADULT NUMMEN NUMWOMEN GENHLTH PHYSHLTH MENTHLTH POORHLTH HLTHPLAN MEDCOST STOPSMOK DRINKANY DRINKGE5 MARITAL EDUCA EMPLOY INCOME SEX FLUSHOT EXERANY RACE _AGEG5YR CHECKUP
	
	recode INCOME 8=77 9=99
	rename INCOME INCOME2
	
	tempfile 1993
	save `1993'	
	
* 1994
	import sasxport5 "$source/CDBRFS94.XPT", clear
	rename *, upper
	rename _*, upper
	
	keep _FINALWT _STATE _PSU IYEAR IMONTH IDAY DISPCODE NUMADULT NUMMEN NUMWOMEN GENHLTH PHYSHLTH MENTHLTH POORHLTH HLTHPLAN MEDCOST STOPSMOK  DRINKANY DRINKGE5 MARITAL EDUCA EMPLOY INCOME SEX FLUSHOT EXERANY RACE _SMOKER2 _AGEG5YR CHECKUP
	
	recode INCOME 8=77 9=99
	rename INCOME INCOME2
	recode _SMOKER2 1=1 2=2 5=3 6=4 3=3 4=.
	rename _SMOKER2 _SMOKER
	
	tempfile 1994
	save `1994'	
	
* 1995
	import sasxport5 "$source/CDBRFS95.XPT", clear
	rename *, upper
	rename _*, upper
	
	keep _FINALWT _STATE _PSU IYEAR IMONTH IDAY DISPCODE NUMADULT NUMMEN NUMWOMEN GENHLTH PHYSHLTH MENTHLTH POORHLTH HLTHPLAN MEDCOST STOPSMOK  DRINKANY DRINKGE5 MARITAL EDUCA EMPLOY INCOME SEX FLUSHOT EXERANY RACE _SMOKER2 _AGEG5YR CHECKUP
	
	rename INCOME95 INCOME2
	recode _SMOKER2 1=1 2=2 5=3 6=4 3=3 4=.
	rename _SMOKER2 _SMOKER
	
	tempfile 1995
	save `1995'	
	
* 1996, replace SMOKENOW and _SMOKER with _SMOKER2
	import sasxport5 "$source/CDBRFS96.XPT", clear
	rename *, upper
	rename _*, upper
	
	keep _FINALWT _STATE _PSU IYEAR IMONTH IDAY DISPCODE NUMADULT NUMMEN NUMWOMEN GENHLTH PHYSHLTH MENTHLTH POORHLTH HLTHPLAN MEDCOST STOPSMOK  DRINKANY DRINKGE5 MARITAL EDUCA EMPLOY INCOME SEX FLUSHOT EXERANY RACE _SMOKER2 _AGEG5YR CHECKUP
	
	rename _SMOKER2 _SMOKER
	
	tempfile 1996
	save `1996'	
	
* 1997
	import sasxport5 "$source/CDBRFS97.XPT", clear
	rename *, upper
	rename _*, upper
	
	keep _FINALWT _STATE _PSU IYEAR IMONTH IDAY DISPCODE NUMADULT NUMMEN NUMWOMEN GENHLTH PHYSHLTH MENTHLTH POORHLTH HLTHPLAN MEDCOST STOPSMOK DRINKANY DRINKGE5 MARITAL EDUCA EMPLOY INCOME SEX FLUSHOT EXERANY RACE _SMOKER2 _AGEG5YR CHECKUP
	
	rename _SMOKER2 _SMOKER
	
	tempfile 1997
	save `1997'	
	
* 1998, replace _STRATA with and _DENSTR
	import sasxport5 "$source/CDBRFS98.XPT", clear
	rename *, upper
	rename _*, upper
	
	keep _FINALWT _STATE _PSU IYEAR IMONTH IDAY DISPCODE NUMADULT NUMMEN NUMWOMEN GENHLTH PHYSHLTH MENTHLTH POORHLTH HLTHPLAN MEDCOST STOPSMOK  DRINKANY DRINKGE5 MARITAL EDUCA EMPLOY INCOME SEX FLUSHOT EXERANY RACE _SMOKER2 _AGEG5YR CHECKUP
	
	rename _SMOKER2 _SMOKER
	
	tempfile 1998
	save `1998'	

* 1999
	import sasxport5 "$source/CDBRFS99.XPT", clear
	rename *, upper
	rename _*, upper
	
	keep _FINALWT _STATE _PSU IYEAR IMONTH IDAY DISPCODE NUMADULT NUMMEN NUMWOMEN GENHLTH PHYSHLTH MENTHLTH POORHLTH HLTHPLAN MEDCOST STOPSMOK  DRINKANY DRINKGE5 MARITAL EDUCA EMPLOY INCOME SEX FLUSHOT EXERANY RACE _SMOKER2 _AGEG5YR CHECKUP
	
	rename _SMOKER2 _SMOKER
	
	tempfile 1999
	save `1999'
	
* 2000
	import sasxport5 "$source/CDBRFS00.XPT", clear
	rename *, upper
	rename _*, upper
	
	keep _FINALWT _STATE _PSU IYEAR IMONTH IDAY DISPCODE NUMADULT NUMMEN NUMWOMEN GENHLTH PHYSHLTH MENTHLTH POORHLTH HLTHPLAN MEDCOST STOPSMOK  DRINKANY DRINKGE5 MARITAL EDUCA EMPLOY INCOME SEX FLUSHOT EXERANY RACE _SMOKER2 _AGEG5YR CHECKUP 
	
	rename _SMOKER2 _SMOKER
	
	tempfile 2000
	save `2000'
	
* 2001, replace with PSTPLAN2, number of cigs per day (smoke num) replaced with freq of smoking (SMOKEDAY), dropped from all previous, STOPSMOK replaced with STOPSMK2,  replaced with LASTSMK, DRINKANY replaced with DRNKANY2

	import sasxport5 "$source/CDBRFS01.XPT", clear
	rename *, upper
	rename _*, upper
	
	keep _FINALWT _STATE _PSU IYEAR IMONTH IDAY DISPCODE NUMADULT NUMMEN NUMWOMEN GENHLTH PHYSHLTH MENTHLTH POORHLTH HLTHPLAN MEDCOST STOPSMK2 DRNKANY2 DRNK2GE5 MARITAL EDUCA EMPLOY INCOME SEX FLUSHOT EXERANY RACE _SMOKER2 _AGEG5YR CHECKUP 
	
	rename _SMOKER2 _SMOKER
	rename DRNK2GE5 DRINKGE5
	rename DRNKANY2 DRINKANY
	rename STOPSMK2 STOPSMOK
	rename EXERANY2 EXERANY
	
	tempfile 2001
	save `2001'
	
* 2002, replace MEDCOST with MEDREAS, replace DRNKANY2 with DRNKANY3
	import sasxport5 "$source/cdbrfs02.xpt", clear
	rename *, upper
	rename _*, upper
	
	keep _FINALWT _STATE _PSU IYEAR IMONTH IDAY DISPCODE NUMADULT NUMMEN NUMWOMEN GENHLTH PHYSHLTH MENTHLTH POORHLTH HLTHPLAN MEDREAS STOPSMK2 DRNKANY3 DRNK2GE5 MARITAL EDUCA EMPLOY INCOME SEX FLUSHOT EXERANY RACE _SMOKER2 _AGEG5YR CHECKUP 
	
	gen MEDCOST = (MEDREAS == 1) if !mi(MEDREAS)
	drop MEDREAS
	
	rename DRNK2GE5 DRINKGE5
	rename DRNKANY3 DRINKANY
	rename STOPSMK2 STOPSMOK
	rename _SMOKER2 _SMOKER
	rename EXERANY2 EXERANY
	
	tempfile 2002
	save `2002'
	
* 2003, replace MEDCOST with MEDREAS, replace DRNKANY2 with DRNKANY3, back to MEDCOST from MEDREAS
	import sasxport5 "$source/cdbrfs03.xpt", clear
	rename *, upper
	rename _*, upper
	
	keep _FINALWT _STATE _PSU IYEAR IMONTH IDAY DISPCODE NUMADULT NUMMEN NUMWOMEN GENHLTH PHYSHLTH MENTHLTH POORHLTH HLTHPLAN MEDCOST STOPSMK2 DRNKANY3 DRNK2GE5 MARITAL EDUCA EMPLOY INCOME SEX FLUSHOT EXERANY RACE _SMOKER2 _AGEG5YR

	rename DRNK2GE5 DRINKGE5
	rename DRNKANY3 DRINKANY
	rename STOPSMK2 STOPSMOK
	rename _SMOKER2 _SMOKER
	rename EXERANY2 EXERANY
		
	tempfile 2003
	save `2003'
	
* 2004, replace with SCLSTSMK
	import sasxport5 "$source/CDBRFS04.XPT", clear
	rename *, upper
	rename _*, upper
	
	keep _FINALWT _STATE _PSU IYEAR IMONTH IDAY DISPCODE NUMADULT NUMMEN NUMWOMEN GENHLTH PHYSHLTH MENTHLTH POORHLTH HLTHPLAN MEDCOST STOPSMK2 DRNKANY3 DRNK2GE5 MARITAL EDUCA EMPLOY INCOME SEX FLUSHOT EXERANY RACE _SMOKER2 _AGEG5YR
	
	rename DRNK2GE5 DRINKGE5
	rename DRNKANY3 DRINKANY
	rename STOPSMK2 STOPSMOK
	rename _SMOKER2 _SMOKER
	rename EXERANY2 EXERANY
	
	tempfile 2004
	save `2004'
	
* 2005, replace DRNKANY3 with DRNKANY4, replace _SMOKER2 with _SMOKER3
	import sasxport5 "$source/CDBRFS05.XPT", clear
	rename *, upper
	rename _*, upper
	
	keep _FINALWT _STATE _PSU IYEAR IMONTH IDAY DISPCODE NUMADULT NUMMEN NUMWOMEN GENHLTH PHYSHLTH MENTHLTH POORHLTH HLTHPLAN MEDCOST STOPSMK2 DRNKANY4 DRNK2GE5 MARITAL EDUCA EMPLOY INCOME SEX FLUSHOT EXERANY RACE _SMOKER3 _AGEG5YR CHECKUP
	
	rename DRNK2GE5 DRINKGE5
	rename DRNKANY4 DRINKANY
	rename STOPSMK2 STOPSMOK
	rename _SMOKER3 _SMOKER
	rename EXERANY2 EXERANY
	
	tempfile 2005
	save `2005'
	
* 2006, replace DRNK2GE5 WITH DRNK3GE5
	import sasxport5 "$source/CDBRFS06.XPT", clear
	rename *, upper
	rename _*, upper
	
	keep _FINALWT _STATE _PSU IYEAR IMONTH IDAY DISPCODE NUMADULT NUMMEN NUMWOMEN GENHLTH PHYSHLTH MENTHLTH POORHLTH HLTHPLAN MEDCOST STOPSMK2 DRNKANY4 DRNK3GE5 MARITAL EDUCA EMPLOY INCOME SEX FLUSHOT EXERANY RACE _SMOKER3 _AGEG5YR CHECKUP
	
	rename DRNK3GE5 DRINKGE5
	rename DRNKANY4 DRINKANY
	rename STOPSMK2 STOPSMOK
	rename _SMOKER3 _SMOKER
	rename EXERANY2 EXERANY
	
	tempfile 2006
	save `2006'
	
* 2007
	import sasxport5 "$source/CDBRFS07.XPT", clear
	rename *, upper
	rename _*, upper
	
	keep _FINALWT _STATE _PSU IYEAR IMONTH IDAY DISPCODE NUMADULT NUMMEN NUMWOMEN GENHLTH PHYSHLTH MENTHLTH POORHLTH HLTHPLAN MEDCOST STOPSMK2 DRNKANY4 DRNK3GE5 MARITAL EDUCA EMPLOY INCOME SEX FLUSHOT EXERANY RACE _SMOKER3 _AGEG5YR CHECKUP1
	
	rename DRNK3GE5 DRINKGE5
	rename DRNKANY4 DRINKANY
	rename STOPSMK2 STOPSMOK
	rename _SMOKER3 _SMOKER
	rename EXERANY2 EXERANY
	rename CHECKUP1 CHECKUP
	
	tempfile 2007
	save `2007'
	
* 2008
	import sasxport5 "$source/CDBRFS08.XPT", clear
	rename *, upper
	rename _*, upper
	
	keep _FINALWT _STATE _PSU IYEAR IMONTH IDAY DISPCODE NUMADULT NUMMEN NUMWOMEN GENHLTH PHYSHLTH MENTHLTH POORHLTH HLTHPLAN MEDCOST STOPSMK2 DRNKANY4 DRNK3GE5 MARITAL EDUCA EMPLOY INCOME SEX FLUSHOT EXERANY RACE _SMOKER3 _AGEG5YR CHECKUP1 
	
	rename DRNK3GE5 DRINKGE5
	rename DRNKANY4 DRINKANY
	rename STOPSMK2 STOPSMOK
	rename _SMOKER3 _SMOKER
	rename EXERANY2 EXERANY
	rename CHECKUP1 CHECKUP
	
	tempfile 2008
	save `2008'
	
* 2009
	import sasxport5 "$source/CDBRFS09.XPT", clear
	rename *, upper
	rename _*, upper
	
	keep _FINALWT _STATE _PSU IYEAR IMONTH IDAY DISPCODE NUMADULT NUMMEN NUMWOMEN GENHLTH PHYSHLTH MENTHLTH POORHLTH HLTHPLAN MEDCOST STOPSMK2 DRNKANY4 DRNK3GE5 MARITAL EDUCA EMPLOY INCOME SEX FLUSHOT EXERANY RACE _SMOKER3 _AGEG5YR CHECKUP1 
	
	rename DRNK3GE5 DRINKGE5
	rename DRNKANY4 DRINKANY
	rename STOPSMK2 STOPSMOK
	rename _SMOKER3 _SMOKER
	rename EXERANY2 EXERANY
	rename CHECKUP1 CHECKUP
	
	tempfile 2009
	save `2009'
	
* 2010
	import sasxport5 "$source/CDBRFS10.XPT", clear
	rename *, upper
	rename _*, upper
	
	keep _FINALWT _STATE _PSU IYEAR IMONTH IDAY DISPCODE NUMADULT NUMMEN NUMWOMEN GENHLTH PHYSHLTH MENTHLTH POORHLTH HLTHPLAN MEDCOST STOPSMK2 DRNKANY4 DRNK3GE5 MARITAL EDUCA EMPLOY INCOME SEX FLUSHOT EXERANY RACE _SMOKER3 _AGEG5YR CHECKUP1
	
	rename DRNK3GE5 DRINKGE5
	rename DRNKANY4 DRINKANY
	rename STOPSMK2 STOPSMOK
	rename _SMOKER3 _SMOKER
	rename EXERANY2 EXERANY
	rename CHECKUP1 CHECKUP

	tempfile 2010
	save `2010'
	
* 2011, replace HLTHPLAN with HLTHPLN1, replace DRNKANY4 with DRNKANY5, replace _AGEG_ with _AGE_G
	import sasxport5 "$source/LLCP2011.XPT", clear
	rename *, upper
	rename _*, upper
	
	keep _LLCPWT _STATE _PSU IYEAR IMONTH IDAY DISPCODE NUMADULT NUMMEN NUMWOMEN GENHLTH PHYSHLTH MENTHLTH POORHLTH HLTHPLN1 MEDCOST STOPSMK2 DRNKANY5 DRNK3GE5 MARITAL EDUCA EMPLOY INCOME SEX FLUSHOT EXERANY RACE _SMOKER3 _AGEG5YR CHECKUP1
	
	rename DRNK3GE5 DRINKGE5
	rename DRNKANY5 DRINKANY
	rename STOPSMK2 STOPSMOK
	rename _SMOKER3 _SMOKER
	rename EXERANY2 EXERANY
	rename _LLCPWT _FINALWT
	rename HLTHPLN1 HLTHPLAN
	rename CHECKUP1 CHECKUP
	
	tempfile 2011
	save `2011'
	
* 2012
	import sasxport5 "$source/LLCP2012.XPT", clear
	rename *, upper
	rename _*, upper
	
	keep _LLCPWT _STATE _PSU IYEAR IMONTH IDAY DISPCODE NUMADULT NUMMEN NUMWOMEN GENHLTH PHYSHLTH MENTHLTH POORHLTH HLTHPLN1 MEDCOST STOPSMK2 DRNKANY5 DRNK3GE5 MARITAL EDUCA EMPLOY INCOME SEX FLUSHOT EXERANY RACE _SMOKER3 _AGEG5YR CHECKUP1
	
	rename DRNK3GE5 DRINKGE5
	rename DRNKANY5 DRINKANY
	rename STOPSMK2 STOPSMOK
	rename _SMOKER3 _SMOKER
	rename EXERANY2 EXERANY
	rename _LLCPWT _FINALWT
	rename HLTHPLN1 HLTHPLAN
	rename CHECKUP1 CHECKUP

	tempfile 2012
	save `2012'
	
* 2013, raw race and age not recorded, using _RACE instead of RACE to define NONWHITE
	import sasxport5 "$source/LLCP2013.XPT", clear
	rename *, upper
	rename _*, upper
	
	keep _LLCPWT _STATE _PSU IYEAR IMONTH IDAY DISPCODE NUMADULT NUMMEN NUMWOMEN GENHLTH PHYSHLTH MENTHLTH POORHLTH HLTHPLN1 MEDCOST STOPSMK2 DRNKANY5 DRNK3GE5 MARITAL EDUCA EMPLOY INCOME SEX FLUSHOT EXERANY _SMOKER3 _AGEG5YR _RACE CHECKUP1

	rename DRNK3GE5 DRINKGE5
	rename DRNKANY5 DRINKANY
	rename STOPSMK2 STOPSMOK
	rename _SMOKER3 _SMOKER
	rename EXERANY2 EXERANY
	rename _LLCPWT _FINALWT
	rename HLTHPLN1 HLTHPLAN
	rename EMPLOY1 EMPLOY
	rename CHECKUP1 CHECKUP
	
	tempfile 2013
	save `2013'
	
* 2014
	import sasxport5 "$source/LLCP2014.XPT", clear
	rename *, upper
	rename _*, upper
	
	keep _LLCPWT _STATE _PSU IYEAR IMONTH IDAY DISPCODE NUMADULT NUMMEN NUMWOMEN GENHLTH PHYSHLTH MENTHLTH POORHLTH HLTHPLN1 MEDCOST STOPSMK2 DRNKANY5 DRNK3GE5 MARITAL EDUCA EMPLOY INCOME SEX FLUSHOT EXERANY _SMOKER3 _AGEG5YR _RACE CHECKUP1

	rename DRNK3GE5 DRINKGE5
	rename DRNKANY5 DRINKANY
	rename STOPSMK2 STOPSMOK
	rename _SMOKER3 _SMOKER
	rename EXERANY2 EXERANY
	rename _LLCPWT _FINALWT
	rename HLTHPLN1 HLTHPLAN
	rename EMPLOY1 EMPLOY
	rename CHECKUP1 CHECKUP
	
	tempfile 2014
	save `2014'
	
* 2015
	import sasxport5 "$source/LLCP2015.XPT", clear
	rename *, upper
	rename _*, upper
	
	keep _LLCPWT _STATE _PSU IYEAR IMONTH IDAY DISPCODE NUMADULT NUMMEN NUMWOMEN GENHLTH PHYSHLTH MENTHLTH POORHLTH HLTHPLN1 MEDCOST STOPSMK2 DRNKANY5 DRNK3GE5 MARITAL EDUCA EMPLOY INCOME SEX FLUSHOT EXERANY _SMOKER3 _AGEG5YR _RACE CHECKUP1

	rename DRNK3GE5 DRINKGE5
	rename DRNKANY5 DRINKANY
	rename STOPSMK2 STOPSMOK
	rename _SMOKER3 _SMOKER
	rename EXERANY2 EXERANY
	rename _LLCPWT _FINALWT
	rename HLTHPLN1 HLTHPLAN
	rename EMPLOY1 EMPLOY
	rename CHECKUP1 CHECKUP
	
	tempfile 2015
	save `2015'
	
* 2016
	import sasxport5 "$source/LLCP2016.XPT", clear
	rename *, upper
	rename _*, upper
	
	keep _LLCPWT _STATE _PSU IYEAR IMONTH IDAY DISPCODE NUMADULT NUMMEN NUMWOMEN GENHLTH PHYSHLTH MENTHLTH POORHLTH HLTHPLN1 MEDCOST STOPSMK2 DRNKANY5 DRNK3GE5 MARITAL EDUCA EMPLOY INCOME SEX FLUSHOT EXERANY _SMOKER3 _AGEG5YR  _RACE CHECKUP1
	
	rename DRNK3GE5 DRINKGE5
	rename DRNKANY5 DRINKANY
	rename STOPSMK2 STOPSMOK
	rename _SMOKER3 _SMOKER
	rename EXERANY2 EXERANY
	rename _LLCPWT _FINALWT
	rename HLTHPLN1 HLTHPLAN
	rename EMPLOY1 EMPLOY
	rename CHECKUP1 CHECKUP

	tempfile 2016
	save `2016'
	
* 2017
	import sasxport5 "$source/LLCP2017.XPT", clear
	rename *, upper
	rename _*, upper
	
	keep _LLCPWT _STATE _PSU IYEAR IMONTH IDAY DISPCODE NUMADULT NUMMEN NUMWOMEN GENHLTH PHYSHLTH MENTHLTH POORHLTH HLTHPLN1 MEDCOST STOPSMK2 DRNKANY5 DRNK3GE5 MARITAL EDUCA EMPLOY INCOME SEX FLUSHOT EXERANY _SMOKER3 _AGEG5YR _RACE CHECKUP1
	
	rename DRNK3GE5 DRINKGE5
	rename DRNKANY5 DRINKANY
	rename STOPSMK2 STOPSMOK
	rename _SMOKER3 _SMOKER
	rename EXERANY2 EXERANY
	rename _LLCPWT _FINALWT
	rename HLTHPLN1 HLTHPLAN
	rename EMPLOY1 EMPLOY
	rename CHECKUP1 CHECKUP

	tempfile 2017
	save `2017'
	
* 2018
	import sasxport5 "$source/LLCP2018.XPT", clear
	rename *, upper
	rename _*, upper
	
	keep _LLCPWT _STATE _PSU IYEAR IMONTH IDAY DISPCODE NUMADULT NUMMEN NUMWOMEN GENHLTH PHYSHLTH MENTHLTH POORHLTH HLTHPLN1 MEDCOST STOPSMK2 DRNKANY5 DRNK3GE5 MARITAL EDUCA EMPLOY INCOME SEX FLUSHOT EXERANY _SMOKER3 _AGEG5YR _RACE CHECKUP1
	
	rename SEX1 SEX
	
	rename DRNK3GE5 DRINKGE5
	rename DRNKANY5 DRINKANY
	rename STOPSMK2 STOPSMOK
	rename _SMOKER3 _SMOKER
	rename EXERANY2 EXERANY
	rename _LLCPWT _FINALWT
	rename HLTHPLN1 HLTHPLAN
	rename EMPLOY1 EMPLOY
	rename CHECKUP1 CHECKUP

	tempfile 2018
	save `2018'
	
* 2019
	import sasxport5 "$source/LLCP2019.XPT", clear
	rename *, upper
	rename _*, upper
	
	keep _LLCPWT _STATE _PSU IYEAR IMONTH IDAY DISPCODE NUMADULT NUMMEN NUMWOMEN GENHLTH PHYSHLTH MENTHLTH POORHLTH HLTHPLN1 MEDCOST STOPSMK2 DRNKANY5 DRNK3GE5 MARITAL EDUCA EMPLOY INCOME SEX FLUSHOT EXERANY _SMOKER3 _AGEG5YR _RACE CHECKUP1
	
	rename SEXVAR SEX
	rename DRNK3GE5 DRINKGE5
	rename DRNKANY5 DRINKANY
	rename STOPSMK2 STOPSMOK
	rename _SMOKER3 _SMOKER
	rename EXERANY2 EXERANY
	rename _LLCPWT _FINALWT
	rename HLTHPLN1 HLTHPLAN
	rename EMPLOY1 EMPLOY
	rename CHECKUP1 CHECKUP

	tempfile 2019
	save `2019'
	
* 2020
	import sasxport5 "$source/LLCP2020.XPT", clear
	rename *, upper
	rename _*, upper
	
	keep _LLCPWT _STATE _PSU IYEAR IMONTH IDAY DISPCODE NUMADULT NUMMEN NUMWOMEN GENHLTH PHYSHLTH MENTHLTH POORHLTH HLTHPLN1 MEDCOST STOPSMK2 DRNKANY5 DRNK3GE5 MARITAL EDUCA EMPLOY INCOME SEX FLUSHOT EXERANY _SMOKER3 _AGEG5YR _RACE CHECKUP1 
	
	rename SEXVAR SEX
	rename DRNK3GE5 DRINKGE5
	rename DRNKANY5 DRINKANY
	rename STOPSMK2 STOPSMOK
	rename _SMOKER3 _SMOKER
	rename EXERANY2 EXERANY
	rename _LLCPWT _FINALWT
	rename HLTHPLN1 HLTHPLAN
	rename EMPLOY1 EMPLOY
	rename CHECKUP1 CHECKUP

	tempfile 2020
	save `2020'
	
* append all files together
	use `1993', clear
	forvalues year = 1994/2020 {
		append using ``year''
	}
	
	rename INCOME2 INCOME
	
* standardize year, drop any interviews with IYEAR = 2021
	replace IYEAR = "19" + IYEAR if strlen(IYEAR) == 2
	destring IYEAR IMONTH IDAY, replace
	drop if IYEAR == 2021
	
* standardize flushot
	replace FLUSHOT = FLUSHOT2 if mi(FLUSHOT) & !mi(FLUSHOT2)
	replace FLUSHOT = FLUSHOT3 if mi(FLUSHOT) & !mi(FLUSHOT3)
	replace FLUSHOT = FLUSHOT4 if mi(FLUSHOT) & !mi(FLUSHOT4)
	replace FLUSHOT = FLUSHOT5 if mi(FLUSHOT) & !mi(FLUSHOT5)
	replace FLUSHOT = FLUSHOT6 if mi(FLUSHOT) & !mi(FLUSHOT6)
	replace FLUSHOT = FLUSHOT7 if mi(FLUSHOT) & !mi(FLUSHOT7)
	
	drop FLUSHOT2 FLUSHOT3 FLUSHOT4 FLUSHOT5 FLUSHOT6 FLUSHOT7
	
* race dummies
	gen WHITE = (RACE == 1 & inrange(IYEAR, 1993, 2000)) | (RACE2 == 1 & inrange(IYEAR, 2001, 2012)) | (_RACE == 1 & inrange(IYEAR, 2013, 2021))
	gen BLACK = (RACE == 2 & inrange(IYEAR, 1993, 2000)) | (RACE2 == 2 & inrange(IYEAR, 2001, 2012)) | (_RACE == 2 & inrange(IYEAR, 2013, 2021))
	gen HISPANIC = (inlist(RACE, 3, 4, 5) & inrange(IYEAR, 1993, 2000)) | (RACE2 == 8 & inrange(IYEAR, 2001, 2012)) | (_RACE == 8 & inrange(IYEAR, 2013, 2021))
	gen OTHERRACE = (!WHITE & !BLACK & !HISPANIC)
	drop RACE _RACE RACE2
	
* keep only complete interviews
	keep if inlist(DISPCODE, 1, 110, 1100)
	drop DISPCODE
	
* recode some variables to better make sense, income becomes a 50k top code
	recode PHYSHLTH 88 = 0 77 99 = .
	recode MENTHLTH 88 = 0 77 99 = .
	recode POORHLTH 88 = 0 77 99 = .
	recode DRINKGE5 88 = 0 77 99 = .
	recode INCOME 8=7
	replace SEX = . if inlist(SEX, 7, 9)
	recode CHECKUP 2 3 4 5 6 8 = 0 1 = 1 7=7 9=9
	
	
* create value labels
	label define GENHLTH_lbl 1 "Excellent" 2 "Very good" 3 "Good" 4 "Fair" 5 "Poor" 7 "Don't know/Not sure" 9 "Refused"
	label define YESNO_lbl 1 "Yes" 2 "No" 7 "Don't know/Not sure" 9 "Refused"
	label define MARITAL_lbl 1 "Married" 2 "Divorced" 3 "Widowed" 4 "Separated" 5 "Never been married" 6 "A member of an unmarried couple" 9 "Refused"
	label define EDUCA_lbl 1 "Never attended school or kindergarten only" 2 "Grades 1 though 8" 3 "Grades 9 through 11" 4 "High school graduate" 5 "College 1-3 years" 6 "College 4 years or more"
	label define EMPLOY_lbl 1 "Employed for wages" 2 "Self-employed" 3 "Out of work for more than 1 year" 4 "Out of work for less than 1 year" 5 "Homemaker" 6 "Student" 7 "Retired" 8 "Unable to work" 9 "Refused"
	label define INCOME_lbl 1 "Less than $10,000" 2 "$10,000 - $15,000" 3 "$15,000 - $20,000" 4 "$20,000 - $25,000" 5 "$25,000 - $35,000" 6 "$35,000 - $50,000" 7 "Over $50,000"
	label define SEX_lbl 1 "Male" 2 "Female" 
	label define AGE_lbl 1 "18 - 24" 2 "25 - 29" 3 "30 - 34" 4 "35 - 39" 5 "40 - 44" 6 "45 - 49" 7 "50 - 54" 8 "55 - 59" 9 "60 - 64" 10 "65 - 69" 11 "70 - 74" 12 "75 - 79" 13 "80 - 99" 14 "Don't know/not sure/refused/missing"
	label define SMOKER_lbl 1 "Everyday smoker" 2 "Smokes some days" 3 "Former smoker" 4 "Never smoked" 9 "Refused/missing"
	
	
* assign labels to vars
	local yesno HLTHPLAN MEDCOST STOPSMOK DRINKANY FLUSHOT EXERANY CHECKUP
	label values `yesno' YESNO_lbl
	
	foreach var of varlist GENHLTH MARITAL EDUCA EMPLOY INCOME SEX {
		label values `var' `var'_lbl
	}
	
	label values _AGEG5YR AGE_lbl 
	label values _SMOKER SMOKER_lbl
	
	drop if _STATE > 56
	
	tempfile brfss
	save `brfss'
	
* merge with medicaid expansion data from KFF
	import delim "$root/expansion_data.csv", varnames(1) clear
	rename *, upper
	rename _*, upper
	tempfile expansion
	save `expansion'
	
	use `brfss', clear
	merge m:1 _STATE using `expansion'
	
* save out for analysis
	save "$output/processed_brfss", replace
	
	