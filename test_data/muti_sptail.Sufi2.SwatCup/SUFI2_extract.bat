@echo off
SUFI2_extract_rch.exe

rem SUFI2_extract_hru.exe
SUFI2_extract_sub.exe
rem SUFI2_extract_res.exe
rem SUFI2_extract_mgt_CropYield.exe
::
rem extract_rch_No_Obs.exe
rem extract_hru_No_Obs.exe
rem extract_sub_No_Obs.exe






::
::
::
::
:: Remarks:
::
:: These programs are all optional, but at least one of them must be selected.
:: The extrcat programs extract variables from the respective rch, hru, and sub output files
:: for these programs to work you need to have observation in the observation files.
::
:: The No_Obs programs extrcats from the respective rch, hru, and sub output files.
:: With these, you can extacts variables for which you have no observations but want to see the 95PPU.
:: This is useful if you simulate two different scenarios and want to see their difference on some variables
:: i.e., GW recharge, evapotranspiration, soil moisture etc., as well as the changes in the uncertainty about them.
::
:: Simply chech the programs you want to run.
::