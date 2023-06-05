/*****************************************************************************************
This script downloads various data from non-BRFSS sources, including median income over 
time and per capita income and education 
*****************************************************************************************/

copy "https://www2.census.gov/programs-surveys/cps/tables/time-series/historical-income-people/p07ar.xlsx" ///
    "$data/raw/p07ar.xlsx", replace
copy "https://www.census.gov/newsroom/releases/xls/cb12-33table1states.xls" ///
    "$data/raw/acs2010_colldeg_state.xls"