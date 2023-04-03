
/********************************************
This script downloads all BRFSS files from the CDC into the data directory using shell commands
*********************************************/

forvalues year = 2011/2020 {
    !wget -O $data/raw/brfss`year'.zip "https://www.cdc.gov/brfss/annual_data/`year'/files/LLCP`year'XPT.zip" 
}

/* forvalues year = 1993/2010 {
    local 2dig = substr("`year'",3,2)
    !wget -O $data/raw/brfss`year'.zip "https://www.cdc.gov/brfss/annual_data/`year'/files/CDBRFS`2dig'XPT.zip"
} */