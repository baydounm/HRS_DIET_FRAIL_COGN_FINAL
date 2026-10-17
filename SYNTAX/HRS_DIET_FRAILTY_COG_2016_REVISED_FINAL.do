clear
clear mata
clear matrix
set maxvar 20000, permanently


**D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_DIET_FRAILTY_COG**

*********************************************************************************************************************************************

capture log close
capture log using "D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_DIET_FRAILTY_COG\OUTPUT\DATA_MANAGEMENT_HRS.txt",text replace

**STEP 0: OPEN FILES AND CREATE HHIDPN VARIABLE, SORT BY THIS VARIABLE**

cd "D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_DIET_FRAILTY_COG\FINAL_DATA\"

use randhrs1992_2020v2,clear


capture drop HHID PN
gen HHID=hhid
gen PN=pn
destring HHID, replace
destring PN, replace

capture drop HHIDPN
egen HHIDPN = concat(HHID PN)

destring HHIDPN, replace
sort HHIDPN

save, replace

use trk2022tr_r,clear
capture rename HHID-VERSION,lower
save, replace

capture drop HHID PN
gen HHID=hhid
gen PN=pn
destring HHID, replace
destring PN, replace

capture drop HHIDPN
egen HHIDPN = concat(HHID PN)

destring HHIDPN, replace
sort HHIDPN

save, replace

**STEP 1: REDUCE RAND FILE TO RESPONDENT VARIABLE FILE****

use randhrs1992_2020v2,clear
 
keep HHIDPN r* inw* h*

save randhrs1992_2020v2_resp, replace



**STEP 2: MERGE REDUCED RAND FILE WITH TRACKER FILE****

use randhrs1992_2020v2_resp,clear
capture drop _merge
merge HHIDPN using trk2022tr_r
tab _merge
capture drop _merge
sort HHIDPN
save randhrs1992_2020v2_resp_tracker, replace




**STEP 3: DESCRIBE AND SUMMARIZE THE FILE****

describe 

su 

**STEP 4: IDENTIFY THE REQUIRED VARIABLES USING RAND AND TRACKER FILE DOCUMENTATION AND LIST THEM ****
use randhrs1992_2020v2_resp_tracker,clear


**LIST OF AGE VARIABLES (2006-2018):
**2006 is r8: r8agey_e
**2008 is r9: r9agey_e
**2010 is r10: r10agey_e
**2012 is r11: r11agey_e
**2014 is r12: r12agey_e
**2016 is r13: r13agey_e
**2018 is r14: r14agey_e

su r8agey_e r9agey_e r10agey_e r11agey_e r12agey_e r13agey_e r14agey_e


**LIST OF VARIABLES NEEDED TO CREATE THE RACE/ETHNICITY (fixed):

**RACD: need to impute, n=5 missing**

capture drop RACE
gen RACE=rarace

tab RACE 

**Ethnicity: 1=Hispanic, 0=Non-Hispanic: n=1 missing

capture drop ETHNICITY
gen ETHNICITY=rahispan

tab ETHNICITY 

**RACE/ETHNICITY: 

capture drop RACE_ETHN
gen RACE_ETHN=.
replace RACE_ETHN=1 if RACE==1 & ETHNICITY==0
replace RACE_ETHN=2 if RACE==2 & ETHNICITY==0
replace RACE_ETHN=3 if ETHNICITY==1 & RACE~=.
replace RACE_ETHN=4 if RACE==3 & ETHNICITY==0

tab RACE_ETHN,missing
tab RACE_ETHN 


**GENDER (fixed):

capture drop SEX
gen SEX=ragender

tab SEX 


**EDUCATION (fixed):

tab raeduc, missing 

capture drop education
gen education = .
replace education = 1 if raeduc == 1 /*< HS*/
replace education = 2 if raeduc == 2 /*GED*/
replace education = 3 if raeduc == 3 /*HS GRADUATE*/
replace education = 4 if raeduc == 4 /*SOME COLLEGE*/
replace education = 5 if raeduc == 5 /*COLLEGE AND ABOVE*/

tab education , missing
tab education 

************************************************************2006*************************************************************


**INCOME VARIABLE (2006):

tab h8itot, missing

 /*< 25,000*/ 
/*25,000–124,999*/ 
/*125,000–299,999*/ 
/*300,000–649,999*/ 
/*≥ 650,000*/


capture drop totwealth_2006
gen totwealth_2006 = .
replace totwealth_2006 = 1 if h8itot < 25000
replace totwealth_2006 = 2 if h8itot >= 25000 & h8itot < 125000
replace totwealth_2006 = 3 if h8itot >= 125000 & h8itot < 300000
replace totwealth_2006 = 4 if h8itot >= 300000 & h8itot < 650000
replace totwealth_2006 = 5 if h8itot >= 650000 & h8itot ~= .


tab totwealth_2006 , missing
tab totwealth_2006 

save, replace

**MARITAL STATUS (2006)**

tab r8mstat, missing

capture drop marital_2006
gen marital_2006 = .
replace marital_2006 = 1 if r8mstat == 8 /*never married*/
replace marital_2006 = 2 if (r8mstat == 1 | r8mstat == 2 | r8mstat == 3) /*married / partnered*/
replace marital_2006 = 3 if (r8mstat == 4 | r8mstat == 5 | r8mstat == 6) /*separated / divorced*/
replace marital_2006 = 4 if (r8mstat == 7) /*widowed*/

tab marital_2006, missing
tab marital_2006

**EMPLOYMENT (2006):

tab r8work, missing

capture drop work_st_2006
gen work_st_2006 = .
replace work_st_2006 = 0 if r8work == 0
replace work_st_2006 = 1 if r8work == 1

tab work_st_2006, missing
tab work_st_2006


**CIGARETTE SMOKING (2006): 
tab r8smokev, missing
tab r8smoken, missing

capture drop smoking_2006
gen smoking_2006 = .
replace smoking_2006 = 1 if r8smokev == 0
replace smoking_2006 = 2 if r8smokev == 1 & r8smoken == 0
replace smoking_2006 = 3 if r8smokev == 1 & r8smoken == 1

tab smoking_2006, missing
tab smoking_2006 

save, replace



*Alcohol driking:(abstinent, 1-3 days per month, 1-2 days per week, ≥3 days per week) *2006* n=173 missing/


tab r8drink, missing
tab r8drinkd, missing


capture drop alcohol_2006
gen alcohol_2006 = .
replace alcohol_2006 = 1 if r8drink == 0
replace alcohol_2006 = 2 if r8drink == 1 & r8drinkd == 0
replace alcohol_2006 = 3 if r8drink == 1 & (r8drinkd == 1 | r8drinkd == 2)
replace alcohol_2006 = 4 if r8drink == 1 & (r8drinkd > 3 & r8drinkd ~= . & r8drinkd ~= .d & r8drinkd ~= .m & r8drinkd ~= .r)

tab alcohol_2006, missing


**PHYSICAL ACTIVITY (2006):
tab r8vgactx, missing
tab r8mdactx, missing

capture drop physic_act_2006
gen physic_act_2006 = .
replace physic_act_2006 = 1 if (r8vgactx ==  5 & r8mdactx == 5)
replace physic_act_2006 = 2 if (r8vgactx ==  3 | r8mdactx == 3 | r8vgactx ==  4 | r8mdactx == 4)
replace physic_act_2006 = 3 if (r8vgactx ==  1 | r8mdactx == 1 | r8vgactx ==  2 | r8mdactx == 2)

tab physic_act_2006, missing
tab physic_act_2006


**SELF-RATED HEALTH (2006):


/*   Excellent/very good/good
    Fair/poor 
*/


tab r8shlt, missing

capture drop srh_2006
gen srh_2006 = .
replace srh_2006 = 1 if (r8shlt == 1 | r8shlt == 2 | r8shlt == 3)
replace srh_2006 = 2 if (r8shlt == 4 | r8shlt == 5)

tab srh_2006, missing
tab srh_2006 

save, replace


**WEIGTH STATUS, 2006**
/*body mass index*/

/*2006*/

*<25 
**  25-29.9
**  ≥30


tab r8pmbmi, missing
tab r8bmi, missing
tab r8bmi , missing
tab r8bmi 
su r8bmi ,det


capture drop bmi_2006
gen bmi_2006 = r8pmbmi if r8pmbmi < 100
else replace bmi_2006 = r8bmi if r8bmi < 100

tab bmi_2006, missing
tab bmi_2006 , missing
tab bmi_2006 
su bmi_2006 , det



capture drop bmibr_2006
gen bmibr_2006 = 1 if bmi_2006 < 25
replace bmibr_2006 = 2 if bmi_2006 >= 25 & bmi_2006 < 30
replace bmibr_2006 = 3 if bmi_2006 >= 30 & bmi_2006 ~= .

tab bmibr_2006, missing


/*cardiometabolic risk factors and chronic conditions, 2006*/

/*HYPERTENSION*/

tab r8hibpe, missing

capture drop hbp_ever_2006sv
gen hbp_ever_2006 = .
replace hbp_ever_2006 = 0 if r8hibpe == 0
replace hbp_ever_2006 = 1 if r8hibpe == 1

tab hbp_ever_2006, missing
tab hbp_ever_2006 


/*DIABETES*/

tab r8diabe, missing

capture drop diab_ever_2006
gen diab_ever_2006 = .
replace diab_ever_2006 = 0 if r8diabe == 0
replace diab_ever_2006 = 1 if r8diabe == 1

tab diab_ever_2006, missing
tab diab_ever_2006 


/*HEART PROBLEMS*/

tab r8hearte, missing

capture drop heart_ever_2006
gen heart_ever_2006 = .
replace heart_ever_2006 = 0 if r8hearte == 0
replace heart_ever_2006 = 1 if r8hearte == 1

tab heart_ever_2006, missing
tab heart_ever_2006 


/*STROKE*/

tab r8stroke, missing

capture drop stroke_ever_2006
gen stroke_ever_2006 = .
replace stroke_ever_2006 = 0 if r8stroke == 0
replace stroke_ever_2006 = 1 if r8stroke == 1

tab stroke_ever_2006, missing
tab stroke_ever_2006 , missing
tab stroke_ever_2006 


/*NUMBER OF CONDITIONS*/
**  0
**    1-2
**    ≥ 3


capture drop cardiometcond_2006
gen cardiometcond_2006 = .
replace cardiometcond_2006 = hbp_ever_2006 + diab_ever_2006 + heart_ever_2006 + stroke_ever_2006

tab cardiometcond_2006, missing
tab cardiometcond_2006 , missing
tab cardiometcond_2006 


capture drop cardiometcondbr_2006
gen cardiometcondbr_2006 = .
replace cardiometcondbr_2006 = 1 if cardiometcond_2006 ==0
replace cardiometcondbr_2006 = 2 if (cardiometcond_2006 == 1 | cardiometcond_2006 == 2)
replace cardiometcondbr_2006 = 3 if (cardiometcond_2006 == 3 | cardiometcond_2006 == 4)

tab cardiometcondbr_2006, missing
tab cardiometcondbr_2006 

**2006 CESD**
capture drop cesd_2006
gen cesd_2006=r8cesd


save, replace


**INW VARIABLES FROM TRACKER FILE (2006-2018):

tab1 inw*

save, replace

**PSU, STRATUM AND WEIGHT VARIABLES (NOT NEEDED FOR THIS ANALYSIS):
tab1 secu stratum 


************************************************2008****************************************************************************************************

**INCOME VARIABLE (2008):

tab h9itot, missing

 /*< 25,000*/ 
/*25,000–124,999*/ 
/*125,000–299,999*/ 
/*300,000–649,999*/ 
/*≥ 650,000*/


capture drop totwealth_2008
gen totwealth_2008 = .
replace totwealth_2008 = 1 if h9itot < 25000
replace totwealth_2008 = 2 if h9itot >= 25000 & h9itot < 125000
replace totwealth_2008 = 3 if h9itot >= 125000 & h9itot < 300000
replace totwealth_2008 = 4 if h9itot >= 300000 & h9itot < 650000
replace totwealth_2008 = 5 if h9itot >= 650000 & h9itot ~= .


tab totwealth_2008 , missing
tab totwealth_2008 

save, replace

**MARITAL STATUS (2008)**

tab r9mstat, missing

capture drop marital_2008
gen marital_2008 = .
replace marital_2008 = 1 if r9mstat == 8 /*never married*/
replace marital_2008 = 2 if (r9mstat == 1 | r9mstat == 2 | r9mstat == 3) /*married / partnered*/
replace marital_2008 = 3 if (r9mstat == 4 | r9mstat == 5 | r9mstat == 6) /*separated / divorced*/
replace marital_2008 = 4 if (r9mstat == 7) /*widowed*/

tab marital_2008, missing
tab marital_2008

**EMPLOYMENT (2008):

tab r9work, missing

capture drop work_st_2008
gen work_st_2008 = .
replace work_st_2008 = 0 if r9work == 0
replace work_st_2008 = 1 if r9work == 1

tab work_st_2008, missing
tab work_st_2008


**CIGARETTE SMOKING (2008): 
tab r9smokev, missing
tab r9smoken, missing

capture drop smoking_2008
gen smoking_2008 = .
replace smoking_2008 = 1 if r9smokev == 0
replace smoking_2008 = 2 if r9smokev == 1 & r9smoken == 0
replace smoking_2008 = 3 if r9smokev == 1 & r9smoken == 1

tab smoking_2008, missing
tab smoking_2008 

save, replace

*Alcohol driking:(abstinent, 1-3 days per month, 1-2 days per week, ≥3 days per week) *2008* n=173 missing/


tab r10drink, missing
tab r10drinkd, missing


*Alcohol driking:(abstinent, 1-3 days per month, 1-2 days per week, ≥3 days per week) *2008* n=173 missing/


tab r9drink, missing
tab r9drinkd, missing


capture drop alcohol_2008
gen alcohol_2008 = .
replace alcohol_2008 = 1 if r9drink == 0
replace alcohol_2008 = 2 if r9drink == 1 & r9drinkd == 0
replace alcohol_2008 = 3 if r9drink == 1 & (r9drinkd == 1 | r9drinkd == 2)
replace alcohol_2008 = 4 if r9drink == 1 & (r9drinkd > 3 & r9drinkd ~= . & r9drinkd ~= .d & r9drinkd ~= .m & r9drinkd ~= .r)

tab alcohol_2008, missing


**PHYSICAL ACTIVITY (2008):
tab r9vgactx, missing
tab r9mdactx, missing

capture drop physic_act_2008
gen physic_act_2008 = .
replace physic_act_2008 = 1 if (r9vgactx ==  5 & r9mdactx == 5)
replace physic_act_2008 = 2 if (r9vgactx ==  3 | r9mdactx == 3 | r9vgactx ==  4 | r9mdactx == 4)
replace physic_act_2008 = 3 if (r9vgactx ==  1 | r9mdactx == 1 | r9vgactx ==  2 | r9mdactx == 2)

tab physic_act_2008, missing
tab physic_act_2008


**SELF-RATED HEALTH (2008):


/*   Excellent/very good/good
    Fair/poor 
*/


tab r9shlt, missing

capture drop srh_2008
gen srh_2008 = .
replace srh_2008 = 1 if (r9shlt == 1 | r9shlt == 2 | r9shlt == 3)
replace srh_2008 = 2 if (r9shlt == 4 | r9shlt == 5)

tab srh_2008, missing
tab srh_2008 

save, replace


**WEIGTH STATUS, 2008**
/*body mass index*/

/*2008*/

*<25 
**  25-29.9
**  ≥30


tab r9pmbmi, missing
tab r9bmi, missing
tab r9bmi , missing
tab r9bmi 
su r9bmi ,det


capture drop bmi_2008
gen bmi_2008 = r9pmbmi if r9pmbmi < 100
else replace bmi_2008 = r9bmi if r9bmi < 100

tab bmi_2008, missing
tab bmi_2008 , missing
tab bmi_2008 
su bmi_2008 , det



capture drop bmibr_2008
gen bmibr_2008 = 1 if bmi_2008 < 25
replace bmibr_2008 = 2 if bmi_2008 >= 25 & bmi_2008 < 30
replace bmibr_2008 = 3 if bmi_2008 >= 30 & bmi_2008 ~= .

tab bmibr_2008, missing


/*cardiometabolic risk factors and chronic conditions, 2008*/

/*HYPERTENSION*/

tab r9hibpe, missing

capture drop hbp_ever_2008
gen hbp_ever_2008 = .
replace hbp_ever_2008 = 0 if r9hibpe == 0
replace hbp_ever_2008 = 1 if r9hibpe == 1

tab hbp_ever_2008, missing
tab hbp_ever_2008 


/*DIABETES*/

tab r9diabe, missing

capture drop diab_ever_2008
gen diab_ever_2008 = .
replace diab_ever_2008 = 0 if r9diabe == 0
replace diab_ever_2008 = 1 if r9diabe == 1

tab diab_ever_2008, missing
tab diab_ever_2008 


/*HEART PROBLEMS*/

tab r9hearte, missing

capture drop heart_ever_2008
gen heart_ever_2008 = .
replace heart_ever_2008 = 0 if r9hearte == 0
replace heart_ever_2008 = 1 if r9hearte == 1

tab heart_ever_2008, missing
tab heart_ever_2008 


/*STROKE*/

tab r9stroke, missing

capture drop stroke_ever_2008
gen stroke_ever_2008 = .
replace stroke_ever_2008 = 0 if r9stroke == 0
replace stroke_ever_2008 = 1 if r9stroke == 1

tab stroke_ever_2008, missing
tab stroke_ever_2008 , missing
tab stroke_ever_2008 


/*NUMBER OF CONDITIONS*/
**  0
**    1-2
**    ≥ 3


capture drop cardiometcond_2008
gen cardiometcond_2008 = .
replace cardiometcond_2008 = hbp_ever_2008 + diab_ever_2008 + heart_ever_2008 + stroke_ever_2008

tab cardiometcond_2008, missing
tab cardiometcond_2008 , missing
tab cardiometcond_2008 


capture drop cardiometcondbr_2008
gen cardiometcondbr_2008 = .
replace cardiometcondbr_2008 = 1 if cardiometcond_2008 ==0
replace cardiometcondbr_2008 = 2 if (cardiometcond_2008 == 1 | cardiometcond_2008 == 2)
replace cardiometcondbr_2008 = 3 if (cardiometcond_2008 == 3 | cardiometcond_2008 == 4)

tab cardiometcondbr_2008, missing
tab cardiometcondbr_2008 

**2008 CESD**
capture drop cesd_2008
gen cesd_2008=r9cesd


save, replace


**INW VARIABLES FROM TRACKER FILE (2008-2018):

tab1 inw*

save, replace

**PSU, STRATUM AND WEIGHT VARIABLES (NOT NEEDED FOR THIS ANALYSIS):
tab1 secu stratum 


**********************************************2010***************************************************************


**INCOME VARIABLE (2010):

tab h10itot, missing

 /*< 25,000*/ 
/*25,000–124,999*/ 
/*125,000–299,999*/ 
/*300,000–649,999*/ 
/*≥ 650,000*/


capture drop totwealth_2010
gen totwealth_2010 = .
replace totwealth_2010 = 1 if h10itot < 25000
replace totwealth_2010 = 2 if h10itot >= 25000 & h10itot < 125000
replace totwealth_2010 = 3 if h10itot >= 125000 & h10itot < 300000
replace totwealth_2010 = 4 if h10itot >= 300000 & h10itot < 650000
replace totwealth_2010 = 5 if h10itot >= 650000 & h10itot ~= .


tab totwealth_2010 , missing
tab totwealth_2010 

save, replace

**MARITAL STATUS (2010)**

tab r10mstat, missing

capture drop marital_2010
gen marital_2010 = .
replace marital_2010 = 1 if r10mstat == 8 /*never married*/
replace marital_2010 = 2 if (r10mstat == 1 | r10mstat == 2 | r10mstat == 3) /*married / partnered*/
replace marital_2010 = 3 if (r10mstat == 4 | r10mstat == 5 | r10mstat == 6) /*separated / divorced*/
replace marital_2010 = 4 if (r10mstat == 7) /*widowed*/

tab marital_2010, missing
tab marital_2010

**EMPLOYMENT (2010):

tab r10work, missing

capture drop work_st_2010
gen work_st_2010 = .
replace work_st_2010 = 0 if r10work == 0
replace work_st_2010 = 1 if r10work == 1

tab work_st_2010, missing
tab work_st_2010


**CIGARETTE SMOKING (2010): 
tab r10smokev, missing
tab r10smoken, missing

capture drop smoking_2010
gen smoking_2010 = .
replace smoking_2010 = 1 if r10smokev == 0
replace smoking_2010 = 2 if r10smokev == 1 & r10smoken == 0
replace smoking_2010 = 3 if r10smokev == 1 & r10smoken == 1

tab smoking_2010, missing
tab smoking_2010 

save, replace


*Alcohol driking:(abstinent, 1-3 days per month, 1-2 days per week, ≥3 days per week) *2010* n=173 missing/


tab r10drink, missing
tab r10drinkd, missing


capture drop alcohol_2010
gen alcohol_2010 = .
replace alcohol_2010 = 1 if r10drink == 0
replace alcohol_2010 = 2 if r10drink == 1 & r10drinkd == 0
replace alcohol_2010 = 3 if r10drink == 1 & (r10drinkd == 1 | r10drinkd == 2)
replace alcohol_2010 = 4 if r10drink == 1 & (r10drinkd > 3 & r10drinkd ~= . & r10drinkd ~= .d & r10drinkd ~= .m & r10drinkd ~= .r)

tab alcohol_2010, missing


**PHYSICAL ACTIVITY (2010):
tab r10vgactx, missing
tab r10mdactx, missing

capture drop physic_act_2010
gen physic_act_2010 = .
replace physic_act_2010 = 1 if (r10vgactx ==  5 & r10mdactx == 5)
replace physic_act_2010 = 2 if (r10vgactx ==  3 | r10mdactx == 3 | r10vgactx ==  4 | r10mdactx == 4)
replace physic_act_2010 = 3 if (r10vgactx ==  1 | r10mdactx == 1 | r10vgactx ==  2 | r10mdactx == 2)

tab physic_act_2010, missing
tab physic_act_2010


**SELF-RATED HEALTH (2010):


/*   Excellent/very good/good
    Fair/poor 
*/


tab r10shlt, missing

capture drop srh_2010
gen srh_2010 = .
replace srh_2010 = 1 if (r10shlt == 1 | r10shlt == 2 | r10shlt == 3)
replace srh_2010 = 2 if (r10shlt == 4 | r10shlt == 5)

tab srh_2010, missing
tab srh_2010 

save, replace


**WEIGTH STATUS, 2010**
/*body mass index*/

/*2010*/

*<25 
**  25-29.9
**  ≥30


tab r10pmbmi, missing
tab r10bmi, missing
tab r10bmi , missing
tab r10bmi 
su r10bmi ,det


capture drop bmi_2010
gen bmi_2010 = r10pmbmi if r10pmbmi < 100
else replace bmi_2010 = r10bmi if r10bmi < 100

tab bmi_2010, missing
tab bmi_2010 , missing
tab bmi_2010 
su bmi_2010 , det



capture drop bmibr_2010
gen bmibr_2010 = 1 if bmi_2010 < 25
replace bmibr_2010 = 2 if bmi_2010 >= 25 & bmi_2010 < 30
replace bmibr_2010 = 3 if bmi_2010 >= 30 & bmi_2010 ~= .

tab bmibr_2010, missing


/*cardiometabolic risk factors and chronic conditions, 2010*/

/*HYPERTENSION*/

tab r10hibpe, missing

capture drop hbp_ever_2010
gen hbp_ever_2010 = .
replace hbp_ever_2010 = 0 if r10hibpe == 0
replace hbp_ever_2010 = 1 if r10hibpe == 1

tab hbp_ever_2010, missing
tab hbp_ever_2010 


/*DIABETES*/

tab r10diabe, missing

capture drop diab_ever_2010
gen diab_ever_2010 = .
replace diab_ever_2010 = 0 if r10diabe == 0
replace diab_ever_2010 = 1 if r10diabe == 1

tab diab_ever_2010, missing
tab diab_ever_2010 


/*HEART PROBLEMS*/

tab r10hearte, missing

capture drop heart_ever_2010
gen heart_ever_2010 = .
replace heart_ever_2010 = 0 if r10hearte == 0
replace heart_ever_2010 = 1 if r10hearte == 1

tab heart_ever_2010, missing
tab heart_ever_2010 


/*STROKE*/

tab r10stroke, missing

capture drop stroke_ever_2010
gen stroke_ever_2010 = .
replace stroke_ever_2010 = 0 if r10stroke == 0
replace stroke_ever_2010 = 1 if r10stroke == 1

tab stroke_ever_2010, missing
tab stroke_ever_2010 , missing
tab stroke_ever_2010 


/*NUMBER OF CONDITIONS*/
**  0
**    1-2
**    ≥ 3


capture drop cardiometcond_2010
gen cardiometcond_2010 = .
replace cardiometcond_2010 = hbp_ever_2010 + diab_ever_2010 + heart_ever_2010 + stroke_ever_2010

tab cardiometcond_2010, missing
tab cardiometcond_2010 , missing
tab cardiometcond_2010 


capture drop cardiometcondbr_2010
gen cardiometcondbr_2010 = .
replace cardiometcondbr_2010 = 1 if cardiometcond_2010 ==0
replace cardiometcondbr_2010 = 2 if (cardiometcond_2010 == 1 | cardiometcond_2010 == 2)
replace cardiometcondbr_2010 = 3 if (cardiometcond_2010 == 3 | cardiometcond_2010 == 4)

tab cardiometcondbr_2010, missing
tab cardiometcondbr_2010 

**2010 CESD**
capture drop cesd_2010
gen cesd_2010=r10cesd


save, replace


**INW VARIABLES FROM TRACKER FILE (2010-2018):

tab1 inw*

save, replace

**PSU, STRATUM AND WEIGHT VARIABLES (NOT NEEDED FOR THIS ANALYSIS):
tab1 secu stratum 

save,replace


**********************************************2012***************************************************************


**INCOME VARIABLE (2012):

tab h11itot, missing

 /*< 25,000*/ 
/*25,000–124,999*/ 
/*125,000–299,999*/ 
/*300,000–649,999*/ 
/*≥ 650,000*/


capture drop totwealth_2012
gen totwealth_2012 = .
replace totwealth_2012 = 1 if h11itot < 25000
replace totwealth_2012 = 2 if h11itot >= 25000 & h11itot < 125000
replace totwealth_2012 = 3 if h11itot >= 125000 & h11itot < 300000
replace totwealth_2012 = 4 if h11itot >= 300000 & h11itot < 650000
replace totwealth_2012 = 5 if h11itot >= 650000 & h11itot ~= .


tab totwealth_2012 , missing
tab totwealth_2012 

save, replace

**MARITAL STATUS (2012)**

tab r11mstat, missing

capture drop marital_2012
gen marital_2012 = .
replace marital_2012 = 1 if r11mstat == 8 /*never married*/
replace marital_2012 = 2 if (r11mstat == 1 | r11mstat == 2 | r11mstat == 3) /*married / partnered*/
replace marital_2012 = 3 if (r11mstat == 4 | r11mstat == 5 | r11mstat == 6) /*separated / divorced*/
replace marital_2012 = 4 if (r11mstat == 7) /*widowed*/

tab marital_2012, missing
tab marital_2012

**EMPLOYMENT (2012):

tab r11work, missing

capture drop work_st_2012
gen work_st_2012 = .
replace work_st_2012 = 0 if r11work == 0
replace work_st_2012 = 1 if r11work == 1

tab work_st_2012, missing
tab work_st_2012


**CIGARETTE SMOKING (2012): 
tab r11smokev, missing
tab r11smoken, missing

capture drop smoking_2012
gen smoking_2012 = .
replace smoking_2012 = 1 if r11smokev == 0
replace smoking_2012 = 2 if r11smokev == 1 & r11smoken == 0
replace smoking_2012 = 3 if r11smokev == 1 & r11smoken == 1

tab smoking_2012, missing
tab smoking_2012 

save, replace

*Alcohol driking:(abstinent, 1-3 days per month, 1-2 days per week, ≥3 days per week) *2012* n=173 missing/


tab r11drink, missing
tab r11drinkd, missing


capture drop alcohol_2012
gen alcohol_2012 = .
replace alcohol_2012 = 1 if r11drink == 0
replace alcohol_2012 = 2 if r11drink == 1 & r11drinkd == 0
replace alcohol_2012 = 3 if r11drink == 1 & (r11drinkd == 1 | r11drinkd == 2)
replace alcohol_2012 = 4 if r11drink == 1 & (r11drinkd > 3 & r11drinkd ~= . & r11drinkd ~= .d & r11drinkd ~= .m & r11drinkd ~= .r)

tab alcohol_2012, missing


**PHYSICAL ACTIVITY (2012):
tab r11vgactx, missing
tab r11mdactx, missing

capture drop physic_act_2012
gen physic_act_2012 = .
replace physic_act_2012 = 1 if (r11vgactx ==  5 & r11mdactx == 5)
replace physic_act_2012 = 2 if (r11vgactx ==  3 | r11mdactx == 3 | r11vgactx ==  4 | r11mdactx == 4)
replace physic_act_2012 = 3 if (r11vgactx ==  1 | r11mdactx == 1 | r11vgactx ==  2 | r11mdactx == 2)

tab physic_act_2012, missing
tab physic_act_2012


**SELF-RATED HEALTH (2012):


/*   Excellent/very good/good
    Fair/poor 
*/


tab r11shlt, missing

capture drop srh_2012
gen srh_2012 = .
replace srh_2012 = 1 if (r11shlt == 1 | r11shlt == 2 | r11shlt == 3)
replace srh_2012 = 2 if (r11shlt == 4 | r11shlt == 5)

tab srh_2012, missing
tab srh_2012 

save, replace


**WEIGTH STATUS, 2012**
/*body mass index*/

/*2012*/

*<25 
**  25-29.9
**  ≥30


tab r11pmbmi, missing
tab r11bmi, missing
tab r11bmi , missing
tab r11bmi 
su r11bmi ,det


capture drop bmi_2012
gen bmi_2012 = r11pmbmi if r11pmbmi < 100
else replace bmi_2012 = r11bmi if r11bmi < 100

tab bmi_2012, missing
tab bmi_2012 , missing
tab bmi_2012 
su bmi_2012 , det



capture drop bmibr_2012
gen bmibr_2012 = 1 if bmi_2012 < 25
replace bmibr_2012 = 2 if bmi_2012 >= 25 & bmi_2012 < 30
replace bmibr_2012 = 3 if bmi_2012 >= 30 & bmi_2012 ~= .

tab bmibr_2012, missing


/*cardiometabolic risk factors and chronic conditions, 2012*/

/*HYPERTENSION*/

tab r11hibpe, missing

capture drop hbp_ever_2012
gen hbp_ever_2012 = .
replace hbp_ever_2012 = 0 if r11hibpe == 0
replace hbp_ever_2012 = 1 if r11hibpe == 1

tab hbp_ever_2012, missing
tab hbp_ever_2012 


/*DIABETES*/

tab r11diabe, missing

capture drop diab_ever_2012
gen diab_ever_2012 = .
replace diab_ever_2012 = 0 if r11diabe == 0
replace diab_ever_2012 = 1 if r11diabe == 1

tab diab_ever_2012, missing
tab diab_ever_2012 


/*HEART PROBLEMS*/

tab r11hearte, missing

capture drop heart_ever_2012
gen heart_ever_2012 = .
replace heart_ever_2012 = 0 if r11hearte == 0
replace heart_ever_2012 = 1 if r11hearte == 1

tab heart_ever_2012, missing
tab heart_ever_2012 


/*STROKE*/

tab r11stroke, missing

capture drop stroke_ever_2012
gen stroke_ever_2012 = .
replace stroke_ever_2012 = 0 if r11stroke == 0
replace stroke_ever_2012 = 1 if r11stroke == 1

tab stroke_ever_2012, missing
tab stroke_ever_2012 , missing
tab stroke_ever_2012 


/*NUMBER OF CONDITIONS*/
**  0
**    1-2
**    ≥ 3


capture drop cardiometcond_2012
gen cardiometcond_2012 = .
replace cardiometcond_2012 = hbp_ever_2012 + diab_ever_2012 + heart_ever_2012 + stroke_ever_2012

tab cardiometcond_2012, missing
tab cardiometcond_2012 , missing
tab cardiometcond_2012 


capture drop cardiometcondbr_2012
gen cardiometcondbr_2012 = .
replace cardiometcondbr_2012 = 1 if cardiometcond_2012 ==0
replace cardiometcondbr_2012 = 2 if (cardiometcond_2012 == 1 | cardiometcond_2012 == 2)
replace cardiometcondbr_2012 = 3 if (cardiometcond_2012 == 3 | cardiometcond_2012 == 4)

tab cardiometcondbr_2012, missing
tab cardiometcondbr_2012 

**2012 CESD**
capture drop cesd_2012
gen cesd_2012=r11cesd


save, replace




**********************************************2014***************************************************************


**INCOME VARIABLE (2014):

tab h12itot, missing

 /*< 25,000*/ 
/*25,000–124,999*/ 
/*125,000–299,999*/ 
/*300,000–649,999*/ 
/*≥ 650,000*/


capture drop totwealth_2014
gen totwealth_2014 = .
replace totwealth_2014 = 1 if h12itot < 25000
replace totwealth_2014 = 2 if h12itot >= 25000 & h12itot < 125000
replace totwealth_2014 = 3 if h12itot >= 125000 & h12itot < 300000
replace totwealth_2014 = 4 if h12itot >= 300000 & h12itot < 650000
replace totwealth_2014 = 5 if h12itot >= 650000 & h12itot ~= .


tab totwealth_2014 , missing
tab totwealth_2014 

save, replace

**MARITAL STATUS (2014)**

tab r12mstat, missing

capture drop marital_2014
gen marital_2014 = .
replace marital_2014 = 1 if r12mstat == 8 /*never married*/
replace marital_2014 = 2 if (r12mstat == 1 | r12mstat == 2 | r12mstat == 3) /*married / partnered*/
replace marital_2014 = 3 if (r12mstat == 4 | r12mstat == 5 | r12mstat == 6) /*separated / divorced*/
replace marital_2014 = 4 if (r12mstat == 7) /*widowed*/

tab marital_2014, missing
tab marital_2014

**EMPLOYMENT (2014):

tab r12work, missing

capture drop work_st_2014
gen work_st_2014 = .
replace work_st_2014 = 0 if r12work == 0
replace work_st_2014 = 1 if r12work == 1

tab work_st_2014, missing
tab work_st_2014


**CIGARETTE SMOKING (2014): 
tab r12smokev, missing
tab r12smoken, missing

capture drop smoking_2014
gen smoking_2014 = .
replace smoking_2014 = 1 if r12smokev == 0
replace smoking_2014 = 2 if r12smokev == 1 & r12smoken == 0
replace smoking_2014 = 3 if r12smokev == 1 & r12smoken == 1

tab smoking_2014, missing
tab smoking_2014 

save, replace

*Alcohol driking:(abstinent, 1-3 days per month, 1-2 days per week, ≥3 days per week) *2014* n=173 missing/


tab r12drink, missing
tab r12drinkd, missing


capture drop alcohol_2014
gen alcohol_2014 = .
replace alcohol_2014 = 1 if r12drink == 0
replace alcohol_2014 = 2 if r12drink == 1 & r12drinkd == 0
replace alcohol_2014 = 3 if r12drink == 1 & (r12drinkd == 1 | r12drinkd == 2)
replace alcohol_2014 = 4 if r12drink == 1 & (r12drinkd > 3 & r12drinkd ~= . & r12drinkd ~= .d & r12drinkd ~= .m & r12drinkd ~= .r)

tab alcohol_2014, missing


**PHYSICAL ACTIVITY (2014):
tab r12vgactx, missing
tab r12mdactx, missing

capture drop physic_act_2014
gen physic_act_2014 = .
replace physic_act_2014 = 1 if (r12vgactx ==  5 & r12mdactx == 5)
replace physic_act_2014 = 2 if (r12vgactx ==  3 | r12mdactx == 3 | r12vgactx ==  4 | r12mdactx == 4)
replace physic_act_2014 = 3 if (r12vgactx ==  1 | r12mdactx == 1 | r12vgactx ==  2 | r12mdactx == 2)

tab physic_act_2014, missing
tab physic_act_2014


**SELF-RATED HEALTH (2014):


/*   Excellent/very good/good
    Fair/poor 
*/


tab r12shlt, missing

capture drop srh_2014
gen srh_2014 = .
replace srh_2014 = 1 if (r12shlt == 1 | r12shlt == 2 | r12shlt == 3)
replace srh_2014 = 2 if (r12shlt == 4 | r12shlt == 5)

tab srh_2014, missing
tab srh_2014 

save, replace


**WEIGTH STATUS, 2014**
/*body mass index*/

/*2014*/

*<25 
**  25-29.9
**  ≥30


tab r12pmbmi, missing
tab r12bmi, missing
tab r12bmi , missing
tab r12bmi 
su r12bmi ,det


capture drop bmi_2014
gen bmi_2014 = r12pmbmi if r12pmbmi < 100
else replace bmi_2014 = r12bmi if r12bmi < 100

tab bmi_2014, missing
tab bmi_2014 , missing
tab bmi_2014 
su bmi_2014 , det



capture drop bmibr_2014
gen bmibr_2014 = 1 if bmi_2014 < 25
replace bmibr_2014 = 2 if bmi_2014 >= 25 & bmi_2014 < 30
replace bmibr_2014 = 3 if bmi_2014 >= 30 & bmi_2014 ~= .

tab bmibr_2014, missing


/*cardiometabolic risk factors and chronic conditions, 2014*/

/*HYPERTENSION*/

tab r12hibpe, missing

capture drop hbp_ever_2014
gen hbp_ever_2014 = .
replace hbp_ever_2014 = 0 if r12hibpe == 0
replace hbp_ever_2014 = 1 if r12hibpe == 1

tab hbp_ever_2014, missing
tab hbp_ever_2014 


/*DIABETES*/

tab r12diabe, missing

capture drop diab_ever_2014
gen diab_ever_2014 = .
replace diab_ever_2014 = 0 if r12diabe == 0
replace diab_ever_2014 = 1 if r12diabe == 1

tab diab_ever_2014, missing
tab diab_ever_2014 


/*HEART PROBLEMS*/

tab r12hearte, missing

capture drop heart_ever_2014
gen heart_ever_2014 = .
replace heart_ever_2014 = 0 if r12hearte == 0
replace heart_ever_2014 = 1 if r12hearte == 1

tab heart_ever_2014, missing
tab heart_ever_2014 


/*STROKE*/

tab r12stroke, missing

capture drop stroke_ever_2014
gen stroke_ever_2014 = .
replace stroke_ever_2014 = 0 if r12stroke == 0
replace stroke_ever_2014 = 1 if r12stroke == 1

tab stroke_ever_2014, missing
tab stroke_ever_2014 , missing
tab stroke_ever_2014 


/*NUMBER OF CONDITIONS*/
**  0
**    1-2
**    ≥ 3


capture drop cardiometcond_2014
gen cardiometcond_2014 = .
replace cardiometcond_2014 = hbp_ever_2014 + diab_ever_2014 + heart_ever_2014 + stroke_ever_2014

tab cardiometcond_2014, missing
tab cardiometcond_2014 , missing
tab cardiometcond_2014 


capture drop cardiometcondbr_2014
gen cardiometcondbr_2014 = .
replace cardiometcondbr_2014 = 1 if cardiometcond_2014 ==0
replace cardiometcondbr_2014 = 2 if (cardiometcond_2014 == 1 | cardiometcond_2014 == 2)
replace cardiometcondbr_2014 = 3 if (cardiometcond_2014 == 3 | cardiometcond_2014 == 4)

tab cardiometcondbr_2014, missing
tab cardiometcondbr_2014 

**2014 CESD**
capture drop cesd_2014
gen cesd_2014=r12cesd


save, replace


**INW VARIABLES FROM TRACKER FILE (2014-2018):

tab1 inw*

save, replace

**PSU, STRATUM AND WEIGHT VARIABLES (NOT NEEDED FOR THIS ANALYSIS):
tab1 secu stratum 

save,replace


**************************************************2016************************************************************


**INCOME VARIABLE (2016):

tab h13itot, missing

 /*< 25,000*/ 
/*25,000–124,999*/ 
/*125,000–299,999*/ 
/*300,000–649,999*/ 
/*≥ 650,000*/


capture drop totwealth_2016
gen totwealth_2016 = .
replace totwealth_2016 = 1 if h13itot < 25000
replace totwealth_2016 = 2 if h13itot >= 25000 & h13itot < 125000
replace totwealth_2016 = 3 if h13itot >= 125000 & h13itot < 300000
replace totwealth_2016 = 4 if h13itot >= 300000 & h13itot < 650000
replace totwealth_2016 = 5 if h13itot >= 650000 & h13itot ~= .


tab totwealth_2016 , missing
tab totwealth_2016 

save, replace

**MARITAL STATUS (2016)**

tab r13mstat, missing

capture drop marital_2016
gen marital_2016 = .
replace marital_2016 = 1 if r13mstat == 8 /*never married*/
replace marital_2016 = 2 if (r13mstat == 1 | r13mstat == 2 | r13mstat == 3) /*married / partnered*/
replace marital_2016 = 3 if (r13mstat == 4 | r13mstat == 5 | r13mstat == 6) /*separated / divorced*/
replace marital_2016 = 4 if (r13mstat == 7) /*widowed*/

tab marital_2016, missing
tab marital_2016

**EMPLOYMENT (2016):

tab r13work, missing

capture drop work_st_2016
gen work_st_2016 = .
replace work_st_2016 = 0 if r13work == 0
replace work_st_2016 = 1 if r13work == 1

tab work_st_2016, missing
tab work_st_2016


**CIGARETTE SMOKING (2016): 
tab r13smokev, missing
tab r13smoken, missing

capture drop smoking_2016
gen smoking_2016 = .
replace smoking_2016 = 1 if r13smokev == 0
replace smoking_2016 = 2 if r13smokev == 1 & r13smoken == 0
replace smoking_2016 = 3 if r13smokev == 1 & r13smoken == 1

tab smoking_2016, missing
tab smoking_2016 

save, replace

*Alcohol driking:(abstinent, 1-3 days per month, 1-2 days per week, ≥3 days per week) *2016* n=173 missing/


tab r13drink, missing
tab r13drinkd, missing


capture drop alcohol_2016
gen alcohol_2016 = .
replace alcohol_2016 = 1 if r13drink == 0
replace alcohol_2016 = 2 if r13drink == 1 & r13drinkd == 0
replace alcohol_2016 = 3 if r13drink == 1 & (r13drinkd == 1 | r13drinkd == 2)
replace alcohol_2016 = 4 if r13drink == 1 & (r13drinkd > 3 & r13drinkd ~= . & r13drinkd ~= .d & r13drinkd ~= .m & r13drinkd ~= .r)

tab alcohol_2016, missing


**PHYSICAL ACTIVITY (2016):
tab r13vgactx, missing
tab r13mdactx, missing

capture drop physic_act_2016
gen physic_act_2016 = .
replace physic_act_2016 = 1 if (r13vgactx ==  5 & r13mdactx == 5)
replace physic_act_2016 = 2 if (r13vgactx ==  3 | r13mdactx == 3 | r13vgactx ==  4 | r13mdactx == 4)
replace physic_act_2016 = 3 if (r13vgactx ==  1 | r13mdactx == 1 | r13vgactx ==  2 | r13mdactx == 2)

tab physic_act_2016, missing
tab physic_act_2016


**SELF-RATED HEALTH (2016):


/*   Excellent/very good/good
    Fair/poor 
*/


tab r13shlt, missing

capture drop srh_2016
gen srh_2016 = .
replace srh_2016 = 1 if (r13shlt == 1 | r13shlt == 2 | r13shlt == 3)
replace srh_2016 = 2 if (r13shlt == 4 | r13shlt == 5)

tab srh_2016, missing
tab srh_2016 

save, replace


**WEIGTH STATUS, 2016**
/*body mass index*/

/*2016*/

*<25 
**  25-29.9
**  ≥30


tab r13pmbmi, missing
tab r13bmi, missing
tab r13bmi , missing
tab r13bmi 
su r13bmi ,det


capture drop bmi_2016
gen bmi_2016 = r13pmbmi if r13pmbmi < 100
else replace bmi_2016 = r13bmi if r13bmi < 100

tab bmi_2016, missing
tab bmi_2016 , missing
tab bmi_2016 
su bmi_2016 , det



capture drop bmibr_2016
gen bmibr_2016 = 1 if bmi_2016 < 25
replace bmibr_2016 = 2 if bmi_2016 >= 25 & bmi_2016 < 30
replace bmibr_2016 = 3 if bmi_2016 >= 30 & bmi_2016 ~= .

tab bmibr_2016, missing


/*cardiometabolic risk factors and chronic conditions, 2016*/

/*HYPERTENSION*/

tab r13hibpe, missing

capture drop hbp_ever_2016
gen hbp_ever_2016 = .
replace hbp_ever_2016 = 0 if r13hibpe == 0
replace hbp_ever_2016 = 1 if r13hibpe == 1

tab hbp_ever_2016, missing
tab hbp_ever_2016 


/*DIABETES*/

tab r13diabe, missing

capture drop diab_ever_2016
gen diab_ever_2016 = .
replace diab_ever_2016 = 0 if r13diabe == 0
replace diab_ever_2016 = 1 if r13diabe == 1

tab diab_ever_2016, missing
tab diab_ever_2016 


/*HEART PROBLEMS*/

tab r13hearte, missing

capture drop heart_ever_2016
gen heart_ever_2016 = .
replace heart_ever_2016 = 0 if r13hearte == 0
replace heart_ever_2016 = 1 if r13hearte == 1

tab heart_ever_2016, missing
tab heart_ever_2016 


/*STROKE*/

tab r13stroke, missing

capture drop stroke_ever_2016
gen stroke_ever_2016 = .
replace stroke_ever_2016 = 0 if r13stroke == 0
replace stroke_ever_2016 = 1 if r13stroke == 1

tab stroke_ever_2016, missing
tab stroke_ever_2016 , missing
tab stroke_ever_2016 


/*NUMBER OF CONDITIONS*/
**  0
**    1-2
**    ≥ 3


capture drop cardiometcond_2016
gen cardiometcond_2016 = .
replace cardiometcond_2016 = hbp_ever_2016 + diab_ever_2016 + heart_ever_2016 + stroke_ever_2016

tab cardiometcond_2016, missing
tab cardiometcond_2016 , missing
tab cardiometcond_2016 


capture drop cardiometcondbr_2016
gen cardiometcondbr_2016 = .
replace cardiometcondbr_2016 = 1 if cardiometcond_2016 ==0
replace cardiometcondbr_2016 = 2 if (cardiometcond_2016 == 1 | cardiometcond_2016 == 2)
replace cardiometcondbr_2016 = 3 if (cardiometcond_2016 == 3 | cardiometcond_2016 == 4)

tab cardiometcondbr_2016, missing
tab cardiometcondbr_2016 

**2016 CESD**
capture drop cesd_2016
gen cesd_2016=r13cesd


save, replace


**INW VARIABLES FROM TRACKER FILE (2016-2018):

tab1 inw*

save, replace

**PSU, STRATUM AND WEIGHT VARIABLES (NOT NEEDED FOR THIS ANALYSIS):
tab1 secu stratum 

save,replace

*******************************************STEP 5: MERGE WITH TELOMERE LENGTH DATA**************************************************************

use "D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_DIET_FRAILTY_COG\FINAL_DATA\randhrs1992_2020v2_resp_tracker",clear

sort HHIDPN
capture drop _merge

save "D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_DIET_FRAILTY_COG\FINAL_DATA\randhrs1992_2020v2_resp_tracker",replace


use "D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_DIET_FRAILTY_COG\FINAL_DATA\TELOMERESA_R",clear
 
destring HHID, replace
destring PN, replace

capture drop HHIDPN
egen HHIDPN = concat(HHID PN)

destring HHIDPN, replace
sort HHIDPN

save, replace

merge HHIDPN using "D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_DIET_FRAILTY_COG\FINAL_DATA\randhrs1992_2020v2_resp_tracker"

save "D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_DIET_FRAILTY_COG\FINAL_DATA\HRS_TLHEIFRAILEPIGENMORT.dta", replace 


******************************************


capture log close

capture log using "D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_DIET_FRAILTY_COG\OUTPUT\HEI2015.txt",text replace

************************************************HEI 2015********************

**STEP A: RUN STATA SCRIPTS FOR LEGUMES:

use "D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_DIET_FRAILTY_COG\FINAL_DATA\HCNS13_R_NT",clear
save "D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_DIET_FRAILTY_COG\FINAL_DATA\HEI2015", replace


**STEP A: RUN STATA SCRIPTS FOR LEGUMES:

capture drop m_mpf m_egg m_nutsd m_soy m_fish_hi m_fish_lo legumes kcal v_total v_drkgr 
  
gen m_mpf=C6D_FF_13+C6E_FF_13+C6F_FF_13+C6G_FF_13+C6H_FF_13+C6I_FF_13+C6J_FF_13+C6K_FF_13+C6L_FF_13+C6M_FF_13+C6N_FF_13+C6O_FF_13+C6P_FF_13+C6R_FF_13+C6S_FF_13+C6T_FF_13+C6U_FF_13+C6V_FF_13+C6W_FF_13+C6Q_FF_13
gen m_egg=C6A_FF_13+C6B_FF_13+C6C_FF_13
gen m_nutsd=C9V_FF_13+C9W_FF_13+C9X_FF_13+C9F_FF_13 
gen m_soy=C5E_FF_13+C3D_FF_13
gen m_fish_hi=C6V_FF_13+C6S_FF_13
gen m_fish_lo=C6T_FF_13+C6U_FF_13+C6W_FF_13
gen legumes=C5N_FF_13+C5P_FF_13 
gen kcal=CALOR_SUM
gen v_total = C5A_FF_13+C5B_FF_13+C5C_FF_13+C5D_FF_13+ C5F_FF_13+C5G_FF_13+C5H_FF_13+C5I_FF_13+C5J_FF_13+C5K_FF_13+C5L_FF_13+C5M_FF_13+C5N_FF_13+C5O_FF_13+C5P_FF_13+C5Q_FF_13+C5R_FF_13+ C5S_FF_13+C5T_FF_13+C5U_FF_13+C5V_FF_13+C5W_FF_13+C5X_FF_13+C5Y_FF_13+C5Z_FF_13+C5AA_FF_13+C5AB_FF_13 
gen v_drkgr=C5T_FF_13+C5U_FF_13+C5V_FF_13
 



**pf_mps_total: m_mpf
**pf_eggs: m_egg 
**pf_nutsds: m_nutsd
*pf_soy: m_soy

/* This program calculates legumes that get counted as meat and those that get
counted as veggies*/
/** This macro gets called into the program that calculates HEI 2015 scores**/

capture drop allmeat 
capture drop seaplant
capture drop mbmax
capture drop meatleg
capture drop legume_added_*
capture drop meatveg
capture drop extrmeat
capture drop extrleg


gen allmeat=m_mpf+m_egg+m_nutsd+m_soy
gen seaplant=m_fish_hi+m_fish_lo+m_nutsd + m_soy
gen mbmax=2.5*(kcal/1000)
gen needmeat=mbmax-allmeat if allmeat<mbmax
gen meatleg=4*legumes
/*Needs more meat, and all beans go to meat*/
gen all2meat=1 if meatleg<=needmeat /*folks who don't meet meat max and the amount
of legumes they consume is less than the amount they need to reach mbmax*/
foreach var in allmeat seaplant {
gen legume_added_`var'=`var'+meatleg if all2meat==1
}
foreach var in v_total v_drkgr {
gen legume_added_`var'=`var' if all2meat==1
}
/*Needs more meat, and some beans go to meat, some go to veggies*/
gen meatveg=1 if meatleg>needmeat
gen extrmeat=meatleg-needmeat
gen extrleg=extrmeat/4
foreach var in allmeat seaplant {
replace legume_added_`var'=`var'+needmeat if meatveg==1 /*folks who don't meet
meat max and the amount of legumes they consume is more than the amount they need
to reach mbmax--rest go to veggies*/
}
foreach var in v_total v_drkgr {
replace legume_added_`var'=`var'+extrleg if meatveg==1
}
gen all2veg=1 if allmeat>=mbmax /*Folks who meet the meat requirement so all
legumes count as veggies*/
foreach var in allmeat seaplant {
replace legume_added_`var'=`var' if all2veg==1
}
foreach var in v_total v_drkgr {
replace legume_added_`var'=`var'+legumes if all2veg==1
}

save "D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_DIET_FRAILTY_COG\FINAL_DATA\HEI2015", replace


**STEP B: RUN STATA SCRIPT FOR HEI-2015


use "D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_DIET_FRAILTY_COG\FINAL_DATA\HEI2015", clear

capture drop monofat 
capture drop polyfat 
capture drop add_sug 
capture drop discfat_sol 
capture drop alcohol 
capture drop f_total 
capture drop frtjuice 
capture drop wholefrt 
capture drop g_whl 
capture drop d_total 
capture drop Satfat 
capture drop sodi 
capture drop g_nwhl 
capture drop sfat 

gen monofat=MONFAT_SUM
gen polyfat=POLY_SUM
gen add_sug=C9AH_FF_13 
gen discfat_sol=ADDFAT_SOL_SUM
gen alcohol=ALCO_SUM
gen f_total= C4A_FF_13+C4B_FF_13+C4C_FF_13+C4D_FF_13+C4E_FF_13+C4F_FF_13+C4G_FF_13+C4H_FF_13+C4I_FF_13+C4J_FF_13+C4K_FF_13+C4L_FF_13+C4M_FF_13+C4N_FF_13+C4O_FF_13+C4P_FF_13+C4Q_FF_13+C4R_FF_13+ C4S_FF_13+C4C_FF_13 
gen frtjuice=C4I_FF_13+C4K_FF_13+C4L_FF_13+C4N_FF_13+C4O_FF_13
gen wholefrt=f_total-frtjuice
gen g_whl=C7B_FF_13+C7F_FF_13+C7G_FF_13+C7J_FF_13+C7SA_FF_13+C9AB_FF_13+C9AC_FF_13+C9AD_FF_13+C9G_FF_13+C9H_FF_13 
gen d_total= C3A_FF_13+C3B_FF_13+C3C_FF_13 + C3E_FF_13+C3G_FF_13+C3H_FF_13+C3I_FF_13+C3J_FF_13+C3L_FF_13+ C3M_FF_13+C3N_FF_13+C3D_FF_13 
gen Satfat=SATFAT_SUM 
gen sodi=SODIUM_SUM
gen g_nwhl=C7A_FF_13+C7C_FF_13+C7E_FF_13+C7H_FF_13+C7I_FF_13+C7K_FF_13+C7L_FF_13+C7M_FF_13+C7N_FF_13+C7O_FF_13+C7SB_FF_13+C7T_FF_13+C9J_FF_13+C9K_FF_13+C9L_FF_13+C9M_FF_13+C9N_FF_13+C9O_FF_13+C9P_FF_13+C9Q_FF_13+C9R_FF_13+C9S_FF_13+C9T_FF_13+C9U_FF_13+C9Y_FF_13+C9Z_FF_13+C9AA_FF_13
gen sfat=SATFAT_SUM 
gen SatFat=SATFAT_SUM

save "D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_DIET_FRAILTY_COG\FINAL_DATA\HEI2015", replace

capture drop monopoly
capture drop addsugc
capture drop solfatc
capture drop maxalcgr
capture drop ethcal
capture drop exalccal
capture drop emptycal10
capture drop vegden
capture drop hei*
capture drop grbnden
capture drop frtden
capture drop wholefrt
capture drop whfrden
capture drop wgrnden
capture drop monopoly
capture drop farmin
capture drop farmax
capture drop sodden
capture drop sodmin
capture drop sodmax
capture drop rgden
capture drop rgmin
capture drop rgmax
capture drop sofa*
capture drop addedsugar_perc 
capture drop addsugmin 
capture dorp addsugmax 
capture drop heix12_addedsugar
capture drop saturatedfat_perc 
capture drop saturatedfatmin 
capture drop saturatedfatmax 
capture drop heix13_saturatedfat



/*This do file creates HEI-2015 component densities and scores*/
gen monopoly=monofat+polyfat
gen addsugc=16*add_sug
gen solfatc=9*discfat_sol
gen maxalcgr=13*(kcal/1000)
gen ethcal=7*alcohol
gen exalccal=7*(alcohol-maxalcgr)
replace exalccal=0 if alcohol<=maxalcgr
gen emptycal10=addsugc+solfatc+exalccal
gen vegden=legume_added_v_total/(kcal/1000)
gen heix1_totalveg=5*(vegden/1.1)
replace heix1_totalveg=5 if heix1_totalveg>5
replace heix1_totalveg=0 if heix1_totalveg<0
gen grbnden=legume_added_v_drkgr/(kcal/1000)
gen heix2_greens_and_bean=5*(grbnden/.2)
replace heix2_greens_and_bean=5 if heix2_greens_and_bean>5
replace heix2_greens_and_bean=0 if heix2_greens_and_bean<0
gen frtden=f_total/(kcal/1000)
gen heix3_totalfruit=5*(frtden/.8)
replace heix3_totalfruit=5 if heix3_totalfruit>5
replace heix3_totalfruit=0 if heix3_totalfruit<0
gen wholefrt=f_total-frtjuice
gen whfrden=wholefrt/(kcal/1000)
gen heix4_wholefruit=5*(whfrden/.4)
replace heix4_wholefruit=5 if heix4_wholefruit>5
replace heix4_wholefruit=0 if heix4_wholefruit<0
gen wgrnden=g_whl/(kcal/1000)
gen heix5_wholegrain=10*(wgrnden/1.5)
replace heix5_wholegrain=10 if heix5_wholegrain>10
replace heix5_wholegrain=0 if heix5_wholegrain<0
gen dairyden=d_total/(kcal/1000)
gen heix6_totaldairy=10*(dairyden/1.3)
replace heix6_totaldairy=10 if heix6_totaldairy>10
replace heix6_totaldairy=0 if heix6_totaldairy<0
gen meatden=legume_added_allmeat/(kcal/1000)
gen heix7_totprot=5*(meatden/2.5)
replace heix7_totprot=5 if heix7_totprot>5
replace heix7_totprot=0 if heix7_totprot<0
gen seaplden=legume_added_seaplant/(kcal/1000)
gen heix8_seaplant_prot=5*(seaplden/.8)
replace heix8_seaplant_prot=5 if heix8_seaplant_prot>5
replace heix8_seaplant_prot=0 if heix8_seaplant_prot<0
gen faratio=monopoly/SatFat if SatFat>0




gen farmin=1.2
gen farmax=2.5
gen heix9_fattyacid=0 if SatFat==0 & monopoly==0
replace heix9_fattyacid=10 if SatFat==0 & monopoly>0
replace heix9_fattyacid=10 if faratio>=farmax & faratio !=.
replace heix9_fattyacid=0 if faratio<=farmin & faratio !=.
replace heix9_fattyacid=10*((faratio-farmin)/(farmax-farmin)) if faratio !=.
gen sodden=sodi/kcal
gen sodmin=1.1
gen sodmax=2
gen heix10_sodium=10
replace heix10_sodium=0 if sodden>=sodmax
replace heix10_sodium=10-(10*(sodden-sodmin)/(sodmax-sodmin))
gen rgden=g_nwhl/(kcal/1000)
gen rgmin=1.8
gen rgmax=4.3
gen heix11_refinedgrain=10
replace heix11_refinedgrain=0 if rgden>=rgmax
replace heix11_refinedgrain=10-(10*(rgden-rgmin)/(rgmax-rgmin))


gen addedsugar_perc=100*add_sug*16/kcal
gen addsugmin=6.5
gen addsugmax=26
gen heix12_addedsugar=0 if addedsugar_perc>=addsugmax
replace heix12_addedsugar=10 if addedsugar_perc<=addsugmin
replace heix12_addedsugar=10-(10*(addedsugar_perc-addsugmin)/(addsugmax-addsugmin))



gen saturatedfat_perc=100*sfat*9/kcal
gen saturatedfatmin=7
gen saturatedfatmax=15
gen heix13_saturatedfat=0 if saturatedfat_perc>=saturatedfatmax
replace heix13_saturatedfat=10 if saturatedfat_perc<=saturatedfatmin
replace heix13_saturatedfat=10-(10*(saturatedfat_perc-saturatedfatmin)/(saturatedfatmax-saturatedfatmin))


foreach var in vegden grbnden frtden whfrden wgrnden dairyden meatden seaplden faratio sodden rgden {
replace `var'=0 if `var'==.
}




foreach var in 1_totalveg 2_greens_and_bean 3_totalfruit 4_wholefruit 5_wholegrain 6_totaldairy 7_totprot 8_seaplant 9_fattyacid 10_sodium 11_refinedgrain 12_addedsugar 13_saturatedfat {
replace heix`var'=0 if kcal==0
}
foreach var in 1_totalveg 2_greens_and_bean 3_totalfruit 4_wholefruit 5_wholegrain 6_totaldairy 7_totprot 8_seaplant 9_fattyacid 10_sodium 11_refinedgrain 12_addedsugar 13_saturatedfat {
replace heix`var'=0 if heix`var'<0 & heix`var'!=.
}
foreach var in 9_fattyacid 10_sodium 11_refinedgrain {
replace heix`var'=10 if heix`var'>10 & heix`var'!=.
}
replace heix12_addedsugar=10 if heix12_addedsugar>10 & heix12_addedsugar!=.
replace heix13_saturatedfat=10 if heix13_saturatedfat>10 & heix13_saturatedfat!=.


gen hei2015_total_score=heix1_totalveg+heix2_greens_and_bean+heix3_totalfruit+ ///
heix4_wholefruit+heix5_wholegrain+heix6_totaldairy+heix7_totprot+heix8_seaplant ///
+heix9_fattyacid+heix10_sodium+heix11_refinedgrain+heix12_addedsugar+heix13_saturatedfat



label var hei2015_total_score "total hei-2015 score"
label var heix1_totalveg "hei-2015 component 1 total vegetables"
label var heix2_greens_and_bean "hei-2015 component 2 greens and beans"
label var heix3_totalfruit "hei-2015 component 3 total fruit"
label var heix4_wholefruit "hei-2015 component 4 whole fruit"
label var heix5_wholegrain "hei-2015 component 5 whole grains"
label var heix6_totaldairy "hei-2015 component 6 dairy"
label var heix7_totprot "hei-2015 component 7 total protein foods"

label var heix8_seaplant_prot "hei-2015 component 8 seafood and plant protein"
label var heix9_fattyacid "hei-2015 component 9 fatty acid ratio"
label var heix10_sodium "hei-2015 component 10 sodium"
label var heix11_refinedgrain "hei-2015 component 11 refined grains"
label var heix12_addedsugar "hei-2015 component 12 added sugar"
label var heix13_saturatedfat "hei-2015 component 13 saturated fat"

label var vegden "density of mped total vegetables per 1000 kcal"
label var grbnden "density of mped of dark green veg and beans per 1000 kcal"
label var frtden "density of mped total fruit per 1000 kcal"
label var whfrden "density of mped whole fruit per 1000 kcal"
label var wgrnden "density of mped of whole grain per 1000 kcal"
label var dairyden "density of mped of dairy per 1000 kcal"
label var meatden "density of mped total meat/protein per 1000 kcal"
label var seaplden "denstiy of mped of seafood and plant protein per 1000 kcal"
label var faratio "fatty acid ratio"
label var sodden "density of sodium per 1000 kcal"
label var rgden "density of mped of refined grains per 1000 kcal"
label var addedsugar_perc "percent of calories from added sugar"
label var saturatedfat_perc "percent of calories from saturated fat"

save "D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_DIET_FRAILTY_COG\FINAL_DATA\HEI2015", replace

destring HHID, replace
destring PN, replace

capture drop HHIDPN
egen HHIDPN = concat(HHID PN)

destring HHIDPN, replace
sort HHIDPN

su hei*

save "D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_DIET_FRAILTY_COG\FINAL_DATA\HEI2015", replace
capture drop _merge
sort HHIDPN
save "D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_DIET_FRAILTY_COG\FINAL_DATA\HEI2015", replace

use "D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_DIET_FRAILTY_COG\FINAL_DATA\HEI2015",clear
su HHIDPN,det



capture log close
capture log using "D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_DIET_FRAILTY_COG\OUTPUT\FRAILTY.txt",text replace

***************Step 0: Extract RAND file variables needed**********************


use "D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_DIET_FRAILTY_COG\FINAL_DATA\randhrs1992_2020v2_resp_tracker",clear

sort HHIDPN
capture drop _merge

keep HHIDPN HHID PN r13agey_e  ragender r13bmi  r13vgactx r13mdactx r12agey_e   r12bmi r13walksa

su HHID

**    Variable |        Obs        Mean    Std. dev.       Min        Max
**-------------+---------------------------------------------------------
**        HHID |     46,850      310929    252815.4          1     959738

su PN


**    Variable |        Obs        Mean    Std. dev.       Min        Max
**-------------+---------------------------------------------------------
**          PN |     46,850    14.88907    7.343958         10         43

su HHIDPN

**    Variable |        Obs        Mean    Std. dev.       Min        Max
**-------------+---------------------------------------------------------
**      HHIDPN |     46,851    3.11e+07    2.53e+07        110   9.60e+07


save "D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_DIET_FRAILTY_COG\FINAL_DATA\rand2016.dta",replace
 

********************************************************************************
* Step 1: Define directories and datasets

***********Physical measures, 2016*********

use "D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_DIET_FRAILTY_COG\FINAL_DATA\H16I_R",clear

destring HHID, replace
destring PN, replace


capture drop HHIDPN
egen HHIDPN = concat(HHID PN)

destring HHIDPN, replace
sort HHIDPN

su HHID


**    Variable |        Obs        Mean    Std. dev.       Min        Max
**-------------+---------------------------------------------------------
**        HHID |     20,912    386529.5    276018.4      10001     959738


su PN


**    Variable |        Obs        Mean    Std. dev.       Min        Max
**-------------+---------------------------------------------------------
**          PN |     20,912    14.94606    7.209694         10         43

su HHIDPN

**   Variable |        Obs        Mean    Std. dev.       Min        Max
**-------------+---------------------------------------------------------
**      HHIDPN |     20,912    3.87e+07    2.76e+07    1000110   9.60e+07

codebook

****Hand Grip strength: Average of right/left, first and second trial****

keep HHIDPN HHID PN PI816 PI851  PI852  PI853  

capture drop pm16gripmax
foreach var in PI816 PI851 PI852 PI853 {
    replace `var' = . if inlist(`var', 993, 998, 999)
}
egen pm16gripmax = rowmean(PI816 PI851 PI852 PI853)


su pm16gripmax
histogram pm16gripmax


**HAND STRENGTH VARIABLES:  PI816 PI851  PI852  PI853  (TAKE AVERAGE FOR L/R HAND, FIRST/SECOND TRIAL)
sort HHIDPN

save "D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_DIET_FRAILTY_COG\FINAL_DATA\pm16.dta",replace



**https://hrs.isr.umich.edu/sites/default/files/meta/2016/core/codebook/h16lb_ri.htm**

use "D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_DIET_FRAILTY_COG\FINAL_DATA\H16LB_R",clear

destring HHID, replace
destring PN, replace

capture drop HHIDPN
egen HHIDPN = concat(HHID PN)

destring HHIDPN, replace
sort HHIDPN

su HHID


**    Variable |        Obs        Mean    Std. dev.       Min        Max
**-------------+---------------------------------------------------------
**        HHID |     20,912    386529.5    276018.4      10001     959738


su PN


**    Variable |        Obs        Mean    Std. dev.       Min        Max
**-------------+---------------------------------------------------------
**          PN |     20,912    14.94606    7.209694         10         43


su HHIDPN


**    Variable |        Obs        Mean    Std. dev.       Min        Max
**-------------+---------------------------------------------------------
**      HHIDPN |     20,912    3.87e+07    2.76e+07    1000110   9.60e+07




tab1 PLB018* PLB019*


**PLB018G: Corresponds to "I felt that everything I did was an effort." (18G: IMPOSSIBLE TO REACH GOALS)
***PLB018J: Corresponds to "I could not get going."​ ( 18J: NO USE IN TRYING TO GET SOMETHING)

tab1 PLB018G PLB018J, miss


**PLB018G                       Q18G. IMPOSSIBLE TO REACH GOALS
**         Section: LB    Level: Respondent      TypD: Numeric    Width: 1   Decimals: 0

**         Please say how much you agree or disagree with each of the following statements.
**         (Mark (X) one box for each line.)
**         
**         I feel it is impossible for me to reach the goals that I would like to strive
**         for.
**
**         .................................................................................
**          2147           1.  STRONGLY DISAGREE
**          1399           2.  SOMEWHAT DISAGREE
**           803           3.  SLIGHTLY DISAGREE
**           735           4.  SLIGHTLY AGREE
**           610           5.  SOMEWHAT AGREE
**           482           6.  STRONGLY AGREE
**         14736       Blank.  INAP (Inapplicable); Partial Interview




**PLB018J                       Q18J. NO USE IN TRYING TO GET SOMETHING
**         Section: LB    Level: Respondent      TypD: Numeric    Width: 1   Decimals: 0

**         Please say how much you agree or disagree with each of the following statements.
**         (Mark (X) one box for each line.)
**         
**         There's no use in really trying to get something I want because I probably won't
**         get it.
**
**         .................................................................................
**          3355           1.  STRONGLY DISAGREE
**          1129           2.  SOMEWHAT DISAGREE
**           712           3.  SLIGHTLY DISAGREE
**           444           4.  SLIGHTLY AGREE
**           305           5.  SOMEWHAT AGREE
**           247           6.  STRONGLY AGREE
**         14720       Blank.  INAP (Inapplicable); Partial Interview


capture drop r13cesd4
gen r13cesd4=.
replace r13cesd4=1 if PLB018G>=4 & PLB018G~=.
replace r13cesd4=0 if r13cesd4~=1 & PLB018G~=.

tab r13cesd4

capture drop r13cesd6
gen r13cesd6=.
replace r13cesd6=1 if PLB018J>=4 & PLB018J~=.
replace r13cesd6=0 if r13cesd6~=1 & PLB018J~=.

tab r13cesd6


capture drop cycle
gen cycle=2016

keep HHIDPN  HHID PN cycle PLB018G PLB018J r13cesd4 r13cesd6

save "D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_DIET_FRAILTY_COG\FINAL_DATA\ces2016.dta",replace


********************************************************************************
global rand_file "D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_DIET_FRAILTY_COG\FINAL_DATA\rand2016.dta"
global pm_file   "D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_DIET_FRAILTY_COG\FINAL_DATA\pm16.dta"
global ces_file   "D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_DIET_FRAILTY_COG\FINAL_DATA\ces2016.dta"
global output_folder "D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_DIET_FRAILTY_COG\FINAL_DATA\"




********************************************************************************
* Step 2: Load RAND and PM 2016 files
********************************************************************************
* Load RAND file
use "$rand_file", clear

save $rand_file, replace

* If you have date variables for BMI measures (e.g., date14 and date16)
capture drop time_years
gen time_years = (r13agey_e-r12agey_e) 
gen delta_bmi_annual = (r12bmi - r13bmi) / time_years

* Apply the annual threshold: assuming 175 cm average height, 10 lb loss per year
capture drop weightloss
gen weightloss = .
replace weightloss = 1 if delta_bmi_annual >=1.48 & r12bmi~=. & r13bmi~=.
replace weightloss = 0 if delta_bmi_annual < 1.48 & r12bmi~=. & r13bmi~=.

tab weightloss

capture drop underweight
gen underweight=.
replace underweight=1 if r13bmi<18.5 & r13bmi~=.
replace underweight=0 if underweight~=1 & r13bmi~=.

tab underweight


****Difficulty walking several blocks: Proxy for walking speed***
tab r13walksa

**      r13walksa:w13 r any |
**     diff-walk sev blocks |      Freq.     Percent        Cum.
**--------------------------+-----------------------------------
**                     0.no |     13,593       68.04       68.04
**                    1.yes |      6,386       31.96      100.00
**--------------------------+-----------------------------------
**                    Total |     19,979      100.00

capture drop r13walkspeed
gen r13walkspeed=r13walksa

tab r13walkspeed

tab r13vgactx



**     r13vgactx:w13 r freq |
**      vigorous phys activ |
**            {finer scale} |      Freq.     Percent        Cum.
**--------------------------+-----------------------------------
**              1.every day |        478        2.38        2.38
**            2.>1 per week |      4,362       21.76       24.14
**             3.1 per week |      2,139       10.67       34.81
**            4.l-3 per mon |      1,963        9.79       44.61
**                  5.never |     11,104       55.39      100.00
**--------------------------+-----------------------------------
**                    Total |     20,046      100.00

tab r13mdactx

**    r13mdactx:w13 r freq |
**      moderate phys activ |
**            {finer scale} |      Freq.     Percent        Cum.
**--------------------------+-----------------------------------
**              1.every day |      1,619        7.77        7.77
**            2.>1 per week |      8,444       40.54       48.31
**             3.1 per week |      3,672       17.63       65.94
**            4.l-3 per mon |      2,569       12.33       78.27
**                  5.never |      4,526       21.73      100.00
**--------------------------+-----------------------------------
**                    Total |     20,830      100.00


destring HHIDPN,replace
su HHIDPN

save "D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_DIET_FRAILTY_COG\FINAL_DATA\rand2016.dta",replace

global rand_file_small "D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_DIET_FRAILTY_COG\FINAL_DATA\rand2016.dta"



*Load small RAND file**
use $rand_file_small,clear
capture drop HHIDPN
egen HHIDPN = concat(HHID PN)
keep if HHIDPN~=".."
destring HHIDPN, replace
sort HHIDPN
save $rand_file_small, replace



* Load 2016 Physical Measures
use "$pm_file", clear
destring HHIDPN,replace
sort HHIDPN
save $pm_file, replace

*Load  2016 CES-D scores**/

use "$ces_file", clear
sort HHIDPN
destring HHIDPN,replace
sort HHIDPN
save $ces_file, replace




********************************************************************************
* Step 3: Merge RAND WITH CES and PM files
********************************************************************************
use $rand_file_small,clear
destring HHIDPN, replace
sort HHIDPN
save $rand_file_small,replace
use $pm_file, clear
sort HHIDPN
save $pm_file,replace
use $ces_file,clear
sort HHIDPN
save $ces_file,replace

use $rand_file_small, clear
capture drop _merge 
merge HHIDPN using $pm_file
sort HHIDPN
tab _merge
capture drop _merge
merge HHIDPN using $ces_file
tab _merge


keep if _merge==3
capture drop _merge

save "D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_DIET_FRAILTY_COG\FINAL_DATA\FRAILTY_MERGEED_FILE_HRS", replace

********************************************************************************
* Step 4: Define Fried Frailty Components
********************************************************************************
* 1. Shrinking: unintentional weight loss >10 lbs
capture drop shrinking
gen shrinking =.
replace shrinking=1 if weightloss == 1 | underweight==1
replace shrinking=0 if shrinking~=1 & weightloss~=. & underweight~=.
 
tab shrinking

* 2. Weakness: low grip strength (sex-specific)

capture drop female
gen female = (ragender == 2)


tab pm16gripmax if female==0
**find 20th percentile**
capture drop male20
gen male20 =  27.125

tab pm16gripmax if female==1
**find 20th percentile**
capture drop female20
gen female20 = 16.625

capture drop weakness
gen weakness = .
replace weakness = 1 if (female==0 & pm16gripmax <= male20)
replace weakness = 1 if (female==1 & pm16gripmax <= female20)
replace weakness = 0 if weakness~=1 & pm16gripmax~=.

tab weakness

* 3. Slowness: low walking speed
capture drop slowness
gen slowness = ( r13walkspeed ==1)

tab slowness

* 4. Exhaustion: using CES-D fatigue items
capture drop exhaustion
gen exhaustion =.
replace exhaustion=1 if r13cesd4==1 & r13cesd4~=. | r13cesd6==1 & r13cesd6~=.
replace exhaustion=0 if exhaustion~=1 &  r13cesd4~=. & r13cesd6~=.

tab exhaustion

* 5. Low physical activity: low vigorous activity
capture drop low_pa
gen low_pa =.
replace low_pa=1 if r13vgactx >= 4 & r13vgactx~=.  | r13mdactx>=4 &  r13mdactx~=. // 4=1-3x/month or 5=hardly ever/never
replace low_pa=0 if low_pa~=1 & r13vgactx~=. & r13mdactx~=.

tab low_pa

********************************************************************************
* Step 5: Calculate Fried Frailty Score
********************************************************************************
capture drop fried_sum
capture drop fried_status

gen fried_sum = shrinking+weakness+slowness+exhaustion+low_pa

gen fried_status = .
replace fried_status = 0 if fried_sum == 0 
replace fried_status = 1 if inlist(fried_sum,1,2) 
replace fried_status = 2 if fried_sum >= 3 & fried_sum~=.

capture label drop friedlbl
label define friedlbl 0 "Robust" 1 "Pre-frail" 2 "Frail"
label values fried_status friedlbl

tab fried_status
su fried_sum
histogram fried_sum


********************************************************************************
* Step 6: Save final dataset
********************************************************************************
save "$output_folder/hrs2016_friedfrailty_final.dta", replace

capture drop ragender r12agey_e r13agey_e r13vgactx r13mdactx r12bmi  r13bmi r13walksa

save "D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_DIET_FRAILTY_COG\FINAL_DATA\HRS_FRAILTY.dta", replace

capture log close
capture log using "D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_DIET_FRAILTY_COG\OUTPUT\MERGING_CODE.txt",text replace


****************************************STEP 7: MERGE WITH EPIGENETIC,  DIETARY DATA AND FRAILTY DATA *******************************************************************************

use "D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_DIET_FRAILTY_COG\FINAL_DATA\HRS_TLHEIFRAILEPIGENMORT.dta",clear
capture rename hhidpn HHIDPN
sort HHIDPN
capture drop _merge
su HHIDPN

save "D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_DIET_FRAILTY_COG\FINAL_DATA\HRS_TLHEIFRAILEPIGENMORT.dta", replace 


use "D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_DIET_FRAILTY_COG\FINAL_DATA\EPICLOCKA_R.dta",clear
destring HHID, replace
destring PN, replace

capture drop HHIDPN
egen HHIDPN = concat(HHID PN)

destring HHIDPN, replace
sort HHIDPN

su HHIDPN

**    Variable |        Obs        Mean    Std. dev.       Min        Max
**-------------+---------------------------------------------------------
**      HHIDPN |      4,018    3.34e+07    2.95e+07    1003810   9.53e+07


capture drop _merge
save "D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_DIET_FRAILTY_COG\FINAL_DATA\EPICLOCKA_R.dta",replace




use "D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_DIET_FRAILTY_COG\FINAL_DATA\HRS_FRAILTY",clear
sort HHIDPN
capture drop _merge
save "D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_DIET_FRAILTY_COG\FINAL_DATA\HRS_FRAILTY",replace


**Start the merging here**
use "D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_DIET_FRAILTY_COG\FINAL_DATA\HRS_TLHEIFRAILEPIGENMORT.dta", replace 
merge HHIDPN using "D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_DIET_FRAILTY_COG\FINAL_DATA\EPICLOCKA_R.dta"
tab _merge
capture drop _merge
sort HHIDPN
merge HHIDPN using "D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_DIET_FRAILTY_COG\FINAL_DATA\HEI2015"
tab _merge
capture drop _merge
sort HHIDPN
merge HHIDPN using "D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_DIET_FRAILTY_COG\FINAL_DATA\HRS_FRAILTY"
tab _merge
capture drop _merge
sort HHIDPN
save "D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_DIET_FRAILTY_COG\FINAL_DATA\HRS_TLHEIFRAILEPIGENMORTfin.dta", replace



**STEP 8: DEMENTIA PROBABILITY DATA 2006 THROUGH 2016**

cd "D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_DIET_FRAILTY_COG\FINAL_DATA\"

use HRS_TLHEIFRAILEPIGENMORTfin,clear

sort HHIDPN
capture drop _merge

use Dementia_prob2000_2016,clear

destring HHID, replace
destring PN, replace

capture rename HHID-HRS_year,lower
save, replace

capture drop HHID PN
gen HHID=hhid
gen PN=pn
destring HHID, replace
destring PN, replace


capture drop HHIDPN
egen HHIDPN = concat(HHID PN)

destring HHIDPN, replace
sort HHIDPN



sort HHIDPN
save, replace

**HRS year 2016**
keep if hrs_year==2016

save Dementia_prob2016, replace


use HRS_TLHEIFRAILEPIGENMORTfin,clear
sort HHIDPN
capture drop _merge
save, replace


merge HHIDPN using Dementia_prob2016

save HRS_TLHEIFRAILEPIGENMORTfinLONG, replace


***STEP 9: NEUROPATHOLOGICAL MARKERS

*-----------------------------*
* Prepare HCAPBIOPILOTA_R
*-----------------------------*
use HCAPBIOPILOTA_R, clear

capture drop _merge

* Ensure source IDs are numeric
capture confirm numeric variable hhid
if _rc {
    destring hhid, replace force
}

capture confirm numeric variable pn
if _rc {
    destring pn, replace force
}

* Recreate numeric HHIDPN using HRS convention
capture drop HHIDPN
gen double HHIDPN = hhid*100 + pn

sort HHIDPN
save HCAPBIOPILOTA_Rfin, replace


*------------------------------------------*
* Prepare HRS_TLHEIFRAILEPIGENMORTfinLONG
*------------------------------------------*
use HRS_TLHEIFRAILEPIGENMORTfinLONG, clear

capture drop _merge

* If lowercase variables exist, use them
capture confirm variable hhid
if !_rc {
    capture confirm numeric variable hhid
    if _rc destring hhid, replace force
}

capture confirm variable pn
if !_rc {
    capture confirm numeric variable pn
    if _rc destring pn, replace force
}

* If uppercase variables exist instead, use them
capture confirm variable HHID
if !_rc {
    capture confirm numeric variable HHID
    if _rc destring HHID, replace force
}

capture confirm variable PN
if !_rc {
    capture confirm numeric variable PN
    if _rc destring PN, replace force
}

capture drop HHIDPN

* Create HHIDPN from whichever pair exists
capture confirm variable hhid
if !_rc {
    gen double HHIDPN = hhid*100 + pn
}
else {
    gen double HHIDPN = HHID*100 + PN
}

sort HHIDPN
save HRS_TLHEIFRAILEPIGENMORTfinLONG, replace


*-----------------------------*
* Merge files
*-----------------------------*
use HRS_TLHEIFRAILEPIGENMORTfinLONG, clear

capture drop dup
duplicates tag HHIDPN, gen(dup)
keep if dup==0 

save HRS_TLHEIFRAILEPIGENMORTfinLONG,replace

merge 1:1 HHIDPN using HCAPBIOPILOTA_Rfin



tab _merge
capture drop _merge


save HRS_TLHEIFRAILEPIGENMORTfinLONG,replace



***STEP 10: GENERATE LN-TRANSFORMED BIOMARKERS, REMOVE OUTLIERS****
use HRS_TLHEIFRAILEPIGENMORTfinLONG,clear


**REMOVE OUTLIERS****

* List of variables
local vars pNfL pGFAP pAbeta42 pAB42_40_ratio pptau181 pGDF_15 puPAR pTSH pT3 pT4

foreach v of local vars {
    
    quietly summarize `v', detail
    
    local p25 = r(p25)
    local p75 = r(p75)
    local iqr = `p75' - `p25'
    
    local lb = `p25' - 1.5*`iqr'
    local ub = `p75' + 1.5*`iqr'
    
    * Set outliers to missing
    replace `v' = . if `v' < `lb' | `v' > `ub'
}


local vars pNfL pGFAP pAbeta42 pAB42_40_ratio pptau181 pGDF_15 puPAR pTSH pT3 pT4

foreach v of local vars {
    capture drop Ln`v'
    gen Ln`v' = . 
    replace Ln`v' = ln(`v') if `v' > 0
}

save HRS_TLHEIFRAILEPIGENMORTfinLONG_final,replace

su Ln*

histogram LnpNfL
graph save HIST_NFL.gph,replace

histogram LnpGDF_15
graph save HIST_pGDF_15.gph,replace


histogram LnpGFAP
graph save HIST_GFAP.gph,replace

save HRS_TLHEIFRAILEPIGENMORTfinLONG_final,replace

***STEP 11: LANGA-WEIR DATASET**

*-----------------------------*
* Prepare cogfinalimp_9522wide
*-----------------------------*
use cogfinalimp_9522wide, clear

capture drop _merge

* Ensure source IDs are numeric
capture confirm numeric variable hhid
if _rc {
    destring hhid, replace force
}

capture confirm numeric variable pn
if _rc {
    destring pn, replace force
}

* Recreate numeric HHIDPN using HRS convention
capture drop HHIDPN
gen double HHIDPN = hhid*100 + pn

* Check for duplicates in cogfinalimp_9522wide by HHIDPN
capture drop dup
duplicates tag HHIDPN, gen(dup)
tab dup

* Keep only unique HHIDPN values before merge
keep if dup==0 | missing(dup)
drop dup

sort HHIDPN
save cogfinalimp_9522wide_fin, replace


*------------------------------------------*
* Prepare HRS_TLHEIFRAILEPIGENMORTfinLONG_final
*------------------------------------------*
use HRS_TLHEIFRAILEPIGENMORTfinLONG_final, clear

capture drop _merge

* If lowercase variables exist, use them
capture confirm variable hhid
if !_rc {
    capture confirm numeric variable hhid
    if _rc destring hhid, replace force
}

capture confirm variable pn
if !_rc {
    capture confirm numeric variable pn
    if _rc destring pn, replace force
}

* If uppercase variables exist instead, use them
capture confirm variable HHID
if !_rc {
    capture confirm numeric variable HHID
    if _rc destring HHID, replace force
}

capture confirm variable PN
if !_rc {
    capture confirm numeric variable PN
    if _rc destring PN, replace force
}

capture drop HHIDPN

* Create HHIDPN from whichever pair exists
capture confirm variable hhid
if !_rc {
    gen double HHIDPN = hhid*100 + pn
}
else {
    gen double HHIDPN = HHID*100 + PN
}

sort HHIDPN
save HRS_TLHEIFRAILEPIGENMORTfinLONG_final, replace


*-----------------------------*
* Deduplicate master file
*-----------------------------*
use HRS_TLHEIFRAILEPIGENMORTfinLONG_final, clear

capture drop dup
duplicates tag HHIDPN, gen(dup)
tab dup

keep if dup==0 | missing(dup)
drop dup

sort HHIDPN
save HRS_TLHEIFRAILEPIGENMORTfinLONG_final, replace


*-----------------------------*
* Merge files
*-----------------------------*
merge 1:1 HHIDPN using cogfinalimp_9522wide_fin

tab _merge
capture drop _merge

save HRS_TLHEIFRAILEPIGENMORTfinLONG_final, replace

				 
capture log close

********************************************************************************
** STEP X: STUDY SAMPLE SELECTION / PARTICIPANT FLOWCHART (MANUSCRIPT-ALIGNED)
********************************************************************************

capture log close
capture log using ///
"D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_DIET_FRAILTY_COG\OUTPUT\SAMPLE_SELECTION_FLOWCHART.txt", ///
text replace

use ///
"D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_DIET_FRAILTY_COG\FINAL_DATA\HRS_TLHEIFRAILEPIGENMORTfinLONG_final.dta", ///
clear

********************************************************************************
** 0. HOUSEKEEPING
********************************************************************************

* Keep one record per respondent
capture drop dup
duplicates tag HHIDPN, gen(dup)
tab dup
keep if dup==0 | missing(dup)
drop dup

* Optional: save a clean copy before sample construction
save ///
"D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_DIET_FRAILTY_COG\FINAL_DATA\HRS_HEI_FRAIL_ANALYTIC_BASE.dta", ///
replace

********************************************************************************
** 1. DEFINE CORE 2016 ELIGIBILITY
********************************************************************************

capture drop elig_age50
gen elig_age50 = .
replace elig_age50 = 1 if r13agey_e >= 50 & r13agey_e < .
replace elig_age50 = 0 if r13agey_e < 50 & r13agey_e < .
label var elig_age50 "Age >=50 years in 2016"

capture drop elig_alive2016
gen elig_alive2016 = .
replace elig_alive2016 = 1 if inw13 == 1
replace elig_alive2016 = 0 if inw13 != 1 & inw13 < .
label var elig_alive2016 "Interviewed/alive in 2016 wave"

capture drop sample_step1
gen sample_step1 = 0
replace sample_step1 = 1 if elig_age50 == 1 & elig_alive2016 == 1
label var sample_step1 "Eligible 2016 age/alive sample"

tab sample_step1

********************************************************************************
** 2. COMPLETE EXPOSURE + FRAILTY DATA AT 2016 BASELINE
********************************************************************************

* HEI exposure
capture drop complete_hei2016
gen complete_hei2016 = !missing(hei2015_total_score)
label var complete_hei2016 "Non-missing HEI score in 2016"

* Fried frailty status
capture drop complete_frailty2016
gen complete_frailty2016 = !missing(fried_status)
label var complete_frailty2016 "Non-missing Fried frailty status in 2016"

capture drop sample_step2
gen sample_step2 = 0
replace sample_step2 = 1 if sample_step1 == 1 & ///
                           complete_hei2016 == 1 & ///
                           complete_frailty2016 == 1
label var sample_step2 "Eligible + complete HEI and frailty data"

tab sample_step2

********************************************************************************
** 3. EXCLUDE PREVALENT CIND / PROBABLE DEMENTIA BEFORE OR AT 2016 BASELINE
********************************************************************************

* Assumption:
* cogfunction2016 coding is:
*   1 = normal cognition
*   2 = CIND
*   3 = probable dementia
* If your coding differs, modify this block.

tab cogfunction2016, missing

capture drop baseline_cognitively_normal
gen baseline_cognitively_normal = .
replace baseline_cognitively_normal = 1 if cogfunction2016 == 1
replace baseline_cognitively_normal = 0 if inlist(cogfunction2016,2,3)
label var baseline_cognitively_normal "Normal cognition at baseline (2016)"

capture drop sample_step3
gen sample_step3 = 0
replace sample_step3 = 1 if sample_step2 == 1 & baseline_cognitively_normal == 1
label var sample_step3 "Analytic risk set after excluding prevalent CIND/dementia"

tab sample_step3

********************************************************************************
** 4. COMPLETE COVARIATE DATA
********************************************************************************


* Core covariates based on manuscript
capture drop complete_covars2016
egen nmiss_covars2012 = rowmiss(r13agey_e ragender RACE_ETHN totwealth_2012 marital_2012 education ///
                                smoking_2012 alcohol_2012 ///
                                physic_act_2012 srh_2012 bmibr_2012 ///
                                hbp_ever_2012 diab_ever_2012 stroke_ever_2012 heart_ever_2012)

gen complete_covars2012 = (nmiss_covars2012 == 0)
label var complete_covars2012 "Complete covariate data in 2012"

capture drop sample_final
gen sample_final = 0
replace sample_final = 1 if sample_step3 == 1 & complete_covars2012 == 1
label var sample_final "Final analytic sample"

tab sample_final

********************************************************************************
** 5. OPTIONAL: FOLLOW-UP AVAILABILITY / OUTCOME VARIABLES
********************************************************************************

* Keep this separate from flowchart unless you explicitly want to mention it in Figure 1
* Example outcome variables already merged from Langa-Weir wide filD:
tab cogfunction2018 if sample_final==1, missing
tab cogfunction2020 if sample_final==1, missing
tab cogfunction2022 if sample_final==1, missing

* Incident cognitive impairment by 2022 (modify if your coding differs)
capture drop incident_cogimp_2016_2022
gen incident_cogimp_2016_2022 = .
replace incident_cogimp_2016_2022 = 1 if sample_final==1 & ///
    (cogfunction2018>1 & cogfunction2018<. | ///
     cogfunction2020>1 & cogfunction2020<. | ///
     cogfunction2022>1 & cogfunction2022<.)
replace incident_cogimp_2016_2022 = 0 if sample_final==1 & ///
    incident_cogimp_2016_2022 != 1
label var incident_cogimp_2016_2022 "Incident CIND/probable dementia by 2022"

tab incident_cogimp_2016_2022 if sample_final==1, missing

save ///
"D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_DIET_FRAILTY_COG\FINAL_DATA\HRS_HEI_FRAIL_ANALYTIC_FINAL.dta", ///
replace




********************************************************************************
** 6. DISPLAY COUNTS FOR FIGURE 1
********************************************************************************

display "------------------------------------------------------------"
count
display "Total records in merged analytic file = " r(N)

count if sample_step1==1
display "Step 1: Age >=50 and alive/interviewed in 2016 = " r(N)

count if sample_step1==1 & complete_hei2016==0
display "Excluded for missing HEI in 2016 = " r(N)

count if sample_step1==1 & complete_frailty2016==0
display "Excluded for missing Fried frailty status in 2016 = " r(N)

count if sample_step2==1
display "Step 2: Complete HEI + frailty data = " r(N)

count if sample_step2==1 & baseline_cognitively_normal==0
display "Excluded for prevalent CIND/probable dementia at baseline = " r(N)

count if sample_step3==1
display "Step 3: Cognitively normal at baseline = " r(N)

count if sample_step3==1 & complete_covars2012==0
display "Excluded for missing covariates = " r(N)

count if sample_final==1
display "Final analytic sample = " r(N)
display "------------------------------------------------------------"

********************************************************************************
** 7. CREATE FLOWCHART DATASET FOR EXPORT
********************************************************************************

tempname memhold
postfile `memhold' str70 flow_step N using ///
"D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_DIET_FRAILTY_COG\OUTPUT\flowchart_counts.dta", ///
replace

quietly count
post `memhold' ("Merged 2016 analytic file") (`r(N)')

quietly count if sample_step1==1
post `memhold' ("Age >=50 and alive/interviewed in 2016") (`r(N)')

quietly count if sample_step1==1 & complete_hei2016==0
post `memhold' ("Excluded: missing HEI in 2016") (`r(N)')

quietly count if sample_step1==1 & complete_frailty2016==0
post `memhold' ("Excluded: missing Fried frailty status in 2016") (`r(N)')

quietly count if sample_step2==1
post `memhold' ("Complete HEI and frailty data") (`r(N)')

quietly count if sample_step2==1 & baseline_cognitively_normal==0
post `memhold' ("Excluded: prevalent CIND/probable dementia at baseline") (`r(N)')

quietly count if sample_step3==1
post `memhold' ("Cognitively normal at baseline") (`r(N)')

quietly count if sample_step3==1 & complete_covars2012==0
post `memhold' ("Excluded: missing covariates") (`r(N)')

quietly count if sample_final==1
post `memhold' ("Final analytic sample") (`r(N)')

postclose `memhold'

use ///
"D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_DIET_FRAILTY_COG\OUTPUT\flowchart_counts.dta", ///
clear
list, noobs abbreviate(40)

export excel using ///
"D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_DIET_FRAILTY_COG\OUTPUT\flowchart_counts.xlsx", ///
firstrow(variables) replace

********************************************************************************
** 8. SAVE FINAL ANALYTIC DATASET
********************************************************************************

use ///
"D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_DIET_FRAILTY_COG\FINAL_DATA\HRS_HEI_FRAIL_ANALYTIC_FINAL.dta", ///
clear

capture drop dup
duplicates tag HHIDPN, gen(dup)
keep if dup==0 | missing(dup)
drop dup

* Recreate sample flags
capture drop elig_age50 elig_alive2016 sample_step1 complete_hei2016 ///
             complete_frailty2016 sample_step2 ///
             baseline_cognitively_normal sample_step3 nmiss_covars2012 ///
             complete_covars2012 sample_final incident_cogimp_2016_2022

gen elig_age50 = (r13agey_e >= 50 & r13agey_e < .)
gen elig_alive2016 = (inw13 == 1)
gen sample_step1 = (elig_age50 == 1 & elig_alive2016 == 1)

gen complete_hei2016 = !missing(hei2015_total_score)
gen complete_frailty2016 = !missing(fried_status)

gen sample_step2 = (sample_step1 == 1 & complete_hei2016 == 1 & ///
                    complete_frailty2016 == 1)

gen baseline_cognitively_normal = .
replace baseline_cognitively_normal = 1 if cogfunction2016 == 1
replace baseline_cognitively_normal = 0 if inlist(cogfunction2016,2,3)

gen sample_step3 = (sample_step2 == 1 & baseline_cognitively_normal == 1)

capture drop complete_covars2012
egen nmiss_covars2012 = rowmiss(r13agey_e ragender RACE_ETHN totwealth_2012 marital_2012 education ///
                                smoking_2012 alcohol_2012 ///
                                physic_act_2012 srh_2012 bmibr_2012 ///
                                hbp_ever_2012 diab_ever_2012 stroke_ever_2012 heart_ever_2012)

gen complete_covars2012 = (nmiss_covars2012 == 0)

gen sample_final = (sample_step3 == 1 & complete_covars2012 == 1)

gen incident_cogimp_2016_2022 = .
replace incident_cogimp_2016_2022 = 1 if sample_final==1 & ///
    (cogfunction2018>1 & cogfunction2018<. | ///
     cogfunction2020>1 & cogfunction2020<. | ///
     cogfunction2022>1 & cogfunction2022<.)
replace incident_cogimp_2016_2022 = 0 if sample_final==1 & ///
    incident_cogimp_2016_2022 != 1

save ///
"D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_DIET_FRAILTY_COG\FINAL_DATA\HRS_HEI_FRAIL_ANALYTIC_FINAL.dta", ///
replace



capture log close
capture log using "D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_DIET_FRAILTY_COG\OUTPUT\TIMETOEVENTSETUP.txt", text replace

***********************TIME TO EVENT SET UP*********************************************

use ///
"D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_DIET_FRAILTY_COG\FINAL_DATA\HRS_HEI_FRAIL_ANALYTIC_FINAL.dta", ///
clear

********************************************************************************
** STEP 1. RESTRICT TO FINAL ANALYTIC SAMPLE
********************************************************************************

keep if sample_final==1
tab sample_final, missing
count

save "D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_DIET_FRAILTY_COG\FINAL_DATA\HRS_HEI_FRAIL_ANALYTIC_FINALfin.dta", ///
replace



********************************************************************************
** STEP 2. CONFIRM BASELINE COGNITIVE STATUS AND FOLLOW-UP VARIABLES
********************************************************************************

tab cogfunction2016, missing
tab cogfunction2018, missing
tab cogfunction2020, missing
tab cogfunction2022, missing

* Optional safeguard: baseline should be cognitively normal
keep if cogfunction2016==1
count

********************************************************************************
** STEP 3. CREATE DEATH DATE FROM TRACKER FILE
********************************************************************************

* Death indicator from tracker file
capture drop died
gen died=.
replace died=1 if knowndeceasedyr<.
replace died=0 if knowndeceasedyr==.
label var died "Died during follow-up according to tracker file"

tab died, missing
tab knowndeceasedmo if died==1, missing
tab knowndeceasedyr if died==1, missing

* Death month / year
capture drop deathmonth
gen deathmonth=knowndeceasedmo
replace deathmonth=. if inlist(deathmonth, 0, 98, 99)

capture drop deathyear
gen deathyear=knowndeceasedyr
replace deathyear=. if inlist(deathyear, 0, 9998, 9999)

* If death month missing but death year known, assign June
replace deathmonth=6 if deathyear<. & deathmonth==.

capture drop deathday
gen deathday=15 if deathyear<.

capture drop dod
gen dod=mdy(deathmonth, deathday, deathyear)
format dod %td
label var dod "Date of death from tracker file (mid-month imputed if needed)"

summ dod if died==1, detail

********************************************************************************
** STEP 4. CREATE INTERVIEW DATES FOR 2016, 2018, 2020, 2022
********************************************************************************

* If exact interview month/year variables are not available in the merged file,
* use mid-year dates for each wave. Replace these with exact interview dates if present.

capture drop doenter
gen doenter=mdy(7,1,2016)
format doenter %td
label var doenter "Baseline date (mid-2016 proxy)"

capture drop doiw2018
gen doiw2018=mdy(7,1,2018)
format doiw2018 %td
label var doiw2018 "2018 interview date (mid-year proxy)"

capture drop doiw2020
gen doiw2020=mdy(7,1,2020)
format doiw2020 %td
label var doiw2020 "2020 interview date (mid-year proxy)"

capture drop doiw2022
gen doiw2022=mdy(7,1,2022)
format doiw2022 %td
label var doiw2022 "2022 interview date (mid-year proxy)"

capture drop doadmin
gen doadmin=mdy(12,31,2022)
format doadmin %td
label var doadmin "Administrative end of follow-up"

********************************************************************************
** STEP 5. INCIDENT COGNITIVE IMPAIRMENT FLAGS AT EACH FOLLOW-UP WAVE
********************************************************************************

* Incident event at each wave among those normal at baseline
capture drop event2018
gen event2018=0
replace event2018=1 if cogfunction2016==1 & cogfunction2018>1 & cogfunction2018<.
label var event2018 "Incident CIND/probable dementia by 2018"

capture drop event2020
gen event2020=0
replace event2020=1 if cogfunction2016==1 & ///
                         ( (cogfunction2018==1 & cogfunction2020>1 & cogfunction2020<.) | ///
                           (missing(cogfunction2018) & cogfunction2020>1 & cogfunction2020<.) )
label var event2020 "Incident CIND/probable dementia by 2020"

capture drop event2022
gen event2022=0
replace event2022=1 if cogfunction2016==1 & ///
                         ( (cogfunction2018==1 | missing(cogfunction2018)) & ///
                           (cogfunction2020==1 | missing(cogfunction2020)) & ///
                           cogfunction2022>1 & cogfunction2022<. )
label var event2022 "Incident CIND/probable dementia by 2022"

tab event2018
tab event2020
tab event2022

********************************************************************************
** STEP 6. FIRST EVENT DATE FOR INCIDENT COGNITIVE IMPAIRMENT
********************************************************************************

* Use midpoint between last known normal wave and first impaired wave
capture drop docogevent
gen docogevent=.

* 2016 -> 2018 transition
replace docogevent = doenter + floor((doiw2018-doenter)/2) ///
    if event2018==1

* 2018 -> 2020 transition
replace docogevent = doiw2018 + floor((doiw2020-doiw2018)/2) ///
    if event2020==1

* 2020 -> 2022 transition
replace docogevent = doiw2020 + floor((doiw2022-doiw2020)/2) ///
    if event2022==1

format docogevent %td
label var docogevent "Estimated date of first incident cognitive impairment"

summ docogevent, detail

********************************************************************************
** STEP 7. LAST KNOWN COGNITIVELY NORMAL DATE / LOSS TO FOLLOW-UP DATE
********************************************************************************

capture drop dolastnormal
gen dolastnormal=doenter if cogfunction2016==1

replace dolastnormal=doiw2018 if cogfunction2018==1
replace dolastnormal=doiw2020 if cogfunction2020==1
replace dolastnormal=doiw2022 if cogfunction2022==1

format dolastnormal %td
label var dolastnormal "Last date observed cognitively normal"

* Censoring date for those without incident impairment:
* earliest of death date, administrative end date, or last known normal date
capture drop docensor
gen docensor=doadmin

replace docensor=dolastnormal if dolastnormal<docensor & dolastnormal<.
replace docensor=dod        if dod<docensor & dod<.

format docensor %td
label var docensor "Censoring date"

********************************************************************************
** STEP 8. FINAL FOLLOW-UP DATE AND EVENT INDICATOR
********************************************************************************

* fail_cog = 1 if incident cognitive impairment occurs before death and before admin censoring
capture drop fail_cog
gen fail_cog=0

replace fail_cog=1 if docogevent<. & ///
    (dod==. | docogevent<=dod) & ///
    docogevent<=doadmin

label var fail_cog "Incident CIND/probable dementia during follow-up"

* Overall analysis end date
capture drop doevent
gen doevent=docensor
replace doevent=docogevent if fail_cog==1

format doevent %td
label var doevent "End of follow-up date"

tab fail_cog, missing
summ doenter doevent if sample_final==1

********************************************************************************
** STEP 9. PERSON-TIME VARIABLES
********************************************************************************

capture drop fu_days
gen fu_days = doevent - doenter
replace fu_days = . if fu_days<0
label var fu_days "Follow-up time in days"

capture drop fu_yrs
gen fu_yrs = fu_days/365.25
label var fu_yrs "Follow-up time in years"

summ fu_days fu_yrs, detail
summ fu_yrs if fail_cog==1, detail
summ fu_yrs if fail_cog==0, detail

********************************************************************************
** STEP 10. COMPETING DEATH INDICATOR (OPTIONAL)
********************************************************************************

* This is useful if later you want Fine-Gray or cause-specific competing-risk models
capture drop death_before_cog
gen death_before_cog=0
replace death_before_cog=1 if died==1 & ///
    (docogevent==. | dod<docogevent) & ///
    dod<=doadmin

label var death_before_cog "Death before incident cognitive impairment"

tab death_before_cog, missing

* Combined follow-up status
capture drop fu_status
gen fu_status=.
replace fu_status=1 if fail_cog==1
replace fu_status=2 if fail_cog==0 & death_before_cog==1
replace fu_status=0 if fail_cog==0 & death_before_cog==0

label define fu_status 0 "censored" 1 "incident cog imp" 2 "death before cog imp"
label values fu_status fu_status
tab fu_status, missing

********************************************************************************
** STEP 11. AGE-AT-ENTRY / AGE-AT-EVENT VARIABLES
********************************************************************************

capture drop dob
gen dob=mdy(birthmo,15,birthyr)
format dob %td
label var dob "Date of birth (mid-month imputed)"

capture drop ageenter
gen ageenter=(doenter-dob)/365.25
label var ageenter "Age at baseline"

capture drop ageevent
gen ageevent=(doevent-dob)/365.25
label var ageevent "Age at event/censoring"

summ ageenter ageevent, detail

********************************************************************************
** STEP 12. STSET FOR MAIN COX / WEIBULL MODELS
********************************************************************************

* Main analysis: death is censoring
stset ageevent, origin(time ageenter) enter(time ageenter) failure(fail_cog==1) id(HHIDPN)

stsum
sts list, by(fail_cog)

* If you want time-on-study directly:
capture drop _t_yrs
gen _t_yrs = _t/365.25
summ _t_yrs

********************************************************************************
** STEP 13. OPTIONAL CHECKS
********************************************************************************

* Number of incident events
count if fail_cog==1

* Number censored by death
count if death_before_cog==1

* Number administratively censored / lost before event
count if fu_status==0

* Crude incidence rate per 1,000 person-years
quietly summarize fu_yrs if sample_final==1
scalar total_py = r(sum)

quietly count if fail_cog==1
scalar total_events = r(N)

display "Total person-years = " total_py
display "Total incident events = " total_events
display "Incidence rate per 1,000 PY = " (total_events/total_py)*1000

********************************************************************************
** STEP 14. SAVE ANALYTIC FILE WITH SURVIVAL VARIABLES
********************************************************************************

save ///
"D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_DIET_FRAILTY_COG\FINAL_DATA\HRS_HEI_FRAIL_ANALYTIC_FINALfin.dta", ///
replace



***********************************************************
capture log close
capture log using ///
"D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_DIET_FRAILTY_COG\OUTPUT\SVYSETUP.txt", text replace



**********************SVY SET UP*********************************************
********************************************************************************
** SURVEY DESIGN SETUP FOR HRS
********************************************************************************

use "D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_DIET_FRAILTY_COG\FINAL_DATA\HRS_HEI_FRAIL_ANALYTIC_FINALfin.dta", clear

* restrict to analytic sample
keep if sample_final==1


* check survey variables
describe secu stratum HCNSWGTR_NT

* set survey design
svyset secu [pweight=HCNSWGTR_NT], strata(stratum) vce(linearized) singleunit(centered)

svydes


save "D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_DIET_FRAILTY_COG\FINAL_DATA\HRS_HEI_FRAIL_ANALYTIC_FINALfin.dta", replace


capture log close

*******************************************DATA MANAGEMENT FOR MAIN TABLES AND FIGURES**************************************************************************************************
capture log close
capture log using ///
"D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_DIET_FRAILTY_COG\OUTPUT\DATA_MANAGEMENT_TABLES_FIGURES.txt", ///
text replace

clear all
set more off
set linesize 255
set maxvar 30000

********************************************************************************
** 0. OPEN FINAL ANALYTIC FILE
********************************************************************************

use ///
"D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_DIET_FRAILTY_COG\FINAL_DATA\HRS_HEI_FRAIL_ANALYTIC_FINALfin.dta", ///
clear

keep if sample_final==1

********************************************************************************
** 1. SURVEY SETUP
********************************************************************************

svyset secu [pweight=HCNSWGTR_NT], strata(stratum) singleunit(centered)
svydes

********************************************************************************
** 2. VARIABLE PREPARATION
********************************************************************************

* HEI-2015 categories for Table 1 / Figure S2
capture drop hei_cat
gen hei_cat=.
replace hei_cat=1 if hei2015_total_score>=0  & hei2015_total_score<51
replace hei_cat=2 if hei2015_total_score>=51 & hei2015_total_score<81
replace hei_cat=3 if hei2015_total_score>=81 & hei2015_total_score<.

capture label drop hei_cat
label define hei_cat 1 "Poor (<51)" 2 "Needs improvement (51-80)" 3 "Good (>=81)"
label values hei_cat hei_cat
tab hei_cat, missing


**LnpNfL LnpGFAP LnpAB42_40_ratio Lnpptau181  LnpGDF_15 LnpuPAR

* Standardized log biomarkers if not already created
foreach v in pGDF_15 pNfL pGFAP pAbeta42 pAB42_40_ratio pptau181 puPAR {
    capture confirm variable Ln`v'
    if _rc==0 {
        capture drop zLn`v'
        egen zLn`v' = std(Ln`v')
    }
}

* Quartiles for Figure 2
foreach v in zLnpGDF_15 zLnpNfL zLnpGFAP zLnpAbeta42 zLnpAB42_40_ratio zLnpptau181 zLnpuPAR {
    capture drop q_`v'
    xtile q_`v' = `v', nq(4)
    label define q4 1 "Q1 (lowest)" 2 "Q2" 3 "Q3" 4 "Q4 (highest)", replace
    label values q_`v' q4
}


**Frailty status**

tab fried_status


*************Z-SCORING OF DIETARY VARIABLES AND FRAILTY SCORE WITHIN FINAL ANALYTIC SAMPLE******


foreach y of varlist  hei2015_total_score heix* C3A_FF_13-C9AP_FF_13 fried_sum {
   egen z`y'=std(`y') if sample_final==1	
}
	


save "D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_DIET_FRAILTY_COG\FINAL_DATA\HRS_HEI_FRAIL_ANALYTIC_FINALfin.dta", replace

capture log close

*********************************
capture log using ///
"D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_DIET_FRAILTY_COG\OUTPUT\TABLE1.txt", ///
text replace

use "D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_DIET_FRAILTY_COG\FINAL_DATA\HRS_HEI_FRAIL_ANALYTIC_FINALfin.dta",clear

********************************************************************************
** 3. TABLE 1: SURVEY-WEIGHTED BASELINE CHARACTERISTICS
********************************************************************************

************************BY HEI CATEGORIES**********************

* Continuous variables
foreach x of varlist r13agey_e  ///
             hei2015_total_score heix* C3A_FF_13-C9AP_FF_13  fried_sum {
    svy: mean `x'
    svy: mean `x', over(hei_cat)
}

* Categorical variables
foreach x of varlist ragender RACE_ETHN totwealth_2012 marital_2012 education ///
                                smoking_2012 alcohol_2012 ///
                                physic_act_2012 srh_2012 bmibr_2012 hbp_ever_2012 diab_ever_2012 stroke_ever_2012 heart_ever_2012 fried_status {
    svy: tab hei_cat `x', row percent se
}

* Design-adjusted p-values

foreach y of varlist r13agey_e  ///
             hei2015_total_score heix* C3A_FF_13-C9AP_FF_13 fried_sum {
    svy: regress `y' i.hei_cat 
	testparm i.hei_cat
}


foreach x  of varlist ragender RACE_ETHN totwealth_2012 marital_2012 education ///
                                smoking_2012 alcohol_2012 ///
                                physic_act_2012 srh_2012 bmibr_2012 hbp_ever_2012 diab_ever_2012 stroke_ever_2012 heart_ever_2012 fried_status {
    svy: tab hei_cat `x', row percent pearson
}


**************************BY FRAILTY STATUS************************************


* Continuous variables
foreach x of varlist r13agey_e  ///
             hei2015_total_score heix* C3A_FF_13-C9AP_FF_13  fried_sum {
    svy: mean `x'
    svy: mean `x', over(fried_status)
}

* Categorical variables
foreach x in ragender RACE_ETHN totwealth_2012 marital_2012 education ///
                                smoking_2012 alcohol_2012 ///
                                physic_act_2012 srh_2012 bmibr_2012 hbp_ever_2012 diab_ever_2012 stroke_ever_2012 heart_ever_2012 {
    svy: tab fried_status `x', row percent se
}

* Design-adjusted p-values

foreach y of varlist r13agey_e hei2015_total_score heix* C3A_FF_13-C9AP_FF_13 fried_sum {
    svy: regress `y' i.fried_status 
	testparm i.fried_status
}


foreach x in ragender RACE_ETHN totwealth_2012 marital_2012 education ///
                                smoking_2012 alcohol_2012 ///
                                physic_act_2012 srh_2012 bmibr_2012 hbp_ever_2012 diab_ever_2012 stroke_ever_2012 heart_ever_2012 {
    svy: tab fried_status `x', row percent pearson
}

************Quartile boundaries*************

tabstat hei2015_total_score if sample_final == 1, statistics(p25 p50 p75)

save ///
"D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_DIET_FRAILTY_COG\FINAL_DATA\HRS_HEI_FRAIL_ANALYTIC_FINALfin.dta", ///
replace

capture log close




capture log close
capture log using ///
"D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_DIET_FRAILTY_COG\OUTPUT\TABLE2.txt", ///
text replace

********************************************************************************
** TABLE 2: DIET -> FRAILTY
** Survey-weighted multivariable linear regression models
********************************************************************************

use ///
"D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_DIET_FRAILTY_COG\FINAL_DATA\HRS_HEI_FRAIL_ANALYTIC_FINALfin.dta", ///
clear

keep if sample_final==1

* survey design
svyset secu [pweight=HCNSWGTR_NT], strata(stratum) singleunit(centered)


* covariate blocks matching revised manuscript
global M1 "c.r13agey_e i.ragender"
global M2 "c.r13agey_e i.ragender i.RACE_ETHN i.marital_2012 i.education i.totwealth_2012"
global M3 "c.r13agey_e i.ragender i.RACE_ETHN i.marital_2012 i.education i.totwealth_2012 i.smoking_2012 i.alcohol_2012 i.physic_act_2012 i.bmibr_2012           i.hbp_ever_2012 i.diab_ever_2012 i.stroke_ever_2012 i.heart_ever_2012 i.srh_2012 "


display "=============================================================="
display "TABLE 2. DIET QUALITY -> FRAILTY"
display "Beta = Change in FRAILTY SCORE"
display "per 1-unit increase in DIET QUALITY"
display "=============================================================="

foreach y of varlist fried_sum {
foreach x of varlist zhei2015_total_score zheix* zC3A_FF_13-zC9AP_FF_13  {

    display " "
    display "--------------------------------------------------------------"
    display "`: variable label `y''"
    display "--------------------------------------------------------------"

    * Model 1
    svy: regress `y' c.`x' $M1
    lincom c.`x'

    * Model 2
    svy: regress `y' c.`x' $M2
    lincom c.`x'

    * Model 3
    svy: regress `y' c.`x' $M3
    lincom c.`x'
}
}

********************************************************************************
** OPTIONAL: clean table-ready extraction to dataset
********************************************************************************

tempname memhold
postfile `memhold' ///
    str40 outcome ///
    str20 model ///
    double beta ll ul p ///
    using "D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_DIET_FRAILTY_COG\OUTPUT\TABLE2_results.dta", replace

foreach y of varlist fried_sum {
    foreach x of varlist zhei2015_total_score zheix* zC3A_FF_13-zC9AP_FF_13 {

        local ylab : variable label `y'
        if "`ylab'" == "" local ylab "`y'"

        local xlab : variable label `x'
        if "`xlab'" == "" local xlab "`x'"

        quietly svy: regress `y' `x' $M1
        quietly lincom `x'
        post `memhold' ("`ylab' : `xlab'") ("Model 1") ///
            (r(estimate)) (r(lb)) (r(ub)) (r(p))

        quietly svy: regress `y' `x' $M2
        quietly lincom `x'
        post `memhold' ("`ylab' : `xlab'") ("Model 2") ///
            (r(estimate)) (r(lb)) (r(ub)) (r(p))

        quietly svy: regress `y' `x' $M3
        quietly lincom `x'
        post `memhold' ("`ylab' : `xlab'") ("Model 3") ///
            (r(estimate)) (r(lb)) (r(ub)) (r(p))
    }
}

postclose `memhold'
use ///
"D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_DIET_FRAILTY_COG\OUTPUT\TABLE2_results.dta", ///
clear

format beta ll ul %9.3f
format p %9.4f
list, noobs abbreviate(30)



use "D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_DIET_FRAILTY_COG\FINAL_DATA\HRS_HEI_FRAIL_ANALYTIC_FINALfin.dta", clear ///

capture log close

log using ///
"D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_DIET_FRAILTY_COG\OUTPUT\TABLE3_COGIMP_MCI_DEM.txt", ///
text replace

********************************************************************************
** TABLE 3: FRAILTY -> INCIDENT COGNITIVE IMPAIRMENT
** ADDITIONAL ANALYSES: INCIDENT MCI/CIND ONLY AND INCIDENT DEMENTIA ONLY
********************************************************************************

use ///
"D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_DIET_FRAILTY_COG\FINAL_DATA\HRS_HEI_FRAIL_ANALYTIC_FINALfin.dta", ///
clear

keep if sample_final==1

********************************************************************************
** SURVEY DESIGN
********************************************************************************

svyset secu [pweight=HCNSWGTR_NT], strata(stratum) singleunit(centered)

********************************************************************************
** FRAILTY CATEGORY
********************************************************************************

capture drop frail_cat
gen frail_cat = .
replace frail_cat = 1 if fried_sum==0
replace frail_cat = 2 if inrange(fried_sum,1,2)
replace frail_cat = 3 if fried_sum>=3 & fried_sum<.

capture label drop frail_cat
label define frail_cat 1 "Robust (0)" 2 "Pre-frail (1-2)" 3 "Frail (>=3)"
label values frail_cat frail_cat
label var frail_cat "Frailty category"

********************************************************************************
** COVARIATE BLOCKS
********************************************************************************

global M1 "c.r13agey_e i.ragender"
global M2 "c.r13agey_e i.ragender i.RACE_ETHN i.marital_2012 i.education i.totwealth_2012"
global M3 "c.r13agey_e i.ragender i.RACE_ETHN i.marital_2012 i.education i.totwealth_2012 i.smoking_2012 i.alcohol_2012 i.physic_act_2012 i.bmibr_2012 i.hbp_ever_2012 i.diab_ever_2012 i.stroke_ever_2012 i.heart_ever_2012 i.srh_2012 hei2015_total_score"

********************************************************************************
** HELPER PROGRAM: POST ALL FRAIL_CAT PARAMETERS
********************************************************************************

capture program drop post_frailcat_results
program define post_frailcat_results
    syntax , POSTNAME(name) OUTCOME(string) MODEL(string)

    quietly lincom 2.frail_cat, eform
    post `postname' ("`outcome'") ("Pre-frail (1-2) vs Robust (0)") ("`model'") ///
        (r(estimate)) (r(lb)) (r(ub)) (r(p))

    quietly lincom 3.frail_cat, eform
    post `postname' ("`outcome'") ("Frail (>=3) vs Robust (0)") ("`model'") ///
        (r(estimate)) (r(lb)) (r(ub)) (r(p))
end

********************************************************************************
** PART A. INCIDENT COGNITIVE IMPAIRMENT (CIND OR PROBABLE DEMENTIA)
********************************************************************************

stset ageevent, origin(time ageenter) enter(time ageenter) ///
    failure(fail_cog==1) id(HHIDPN)

display "=============================================================="
display "TABLE 3A. Frailty -> Incident cognitive impairment"
display "Outcome: first incident CIND or probable dementia"
display "=============================================================="

svy: stcox i.frail_cat $M1
svy: stcox i.frail_cat $M2
svy: stcox i.frail_cat $M3

tempname memhold1
postfile `memhold1' str30 outcome str40 predictor str20 model ///
    double hr ll ul p using ///
    "D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_DIET_FRAILTY_COG\OUTPUT\TABLE3_results_cogimp.dta", replace

quietly svy: stcox i.frail_cat $M1
post_frailcat_results, postname(`memhold1') outcome("CIND/probable dementia") model("Model 1")

quietly svy: stcox i.frail_cat $M2
post_frailcat_results, postname(`memhold1') outcome("CIND/probable dementia") model("Model 2")

quietly svy: stcox i.frail_cat $M3
post_frailcat_results, postname(`memhold1') outcome("CIND/probable dementia") model("Model 3")

postclose `memhold1'

********************************************************************************
** PART B. INCIDENT MCI/CIND ONLY
********************************************************************************

capture drop eventmci2018 eventmci2020 eventmci2022
gen eventmci2018 = 0
replace eventmci2018 = 1 if cogfunction2016==1 & cogfunction2018==2
label var eventmci2018 "Incident MCI/CIND by 2018"

gen eventmci2020 = 0
replace eventmci2020 = 1 if cogfunction2016==1 & ///
    ((cogfunction2018==1 & cogfunction2020==2) | ///
     (missing(cogfunction2018) & cogfunction2020==2))
label var eventmci2020 "Incident MCI/CIND by 2020"

gen eventmci2022 = 0
replace eventmci2022 = 1 if cogfunction2016==1 & ///
    ((cogfunction2018==1 | missing(cogfunction2018)) & ///
     (cogfunction2020==1 | missing(cogfunction2020)) & ///
      cogfunction2022==2)
label var eventmci2022 "Incident MCI/CIND by 2022"

capture drop domcievent
gen domcievent = .
replace domcievent = doenter + floor((doiw2018-doenter)/2) if eventmci2018==1
replace domcievent = doiw2018 + floor((doiw2020-doiw2018)/2) if eventmci2020==1
replace domcievent = doiw2020 + floor((doiw2022-doiw2020)/2) if eventmci2022==1
format domcievent %td
label var domcievent "Estimated date of first incident MCI/CIND"

capture drop fail_mci
gen fail_mci = 0
replace fail_mci = 1 if domcievent<. & ///
    (dod==. | domcievent<=dod) & ///
    domcievent<=doadmin
label var fail_mci "Incident MCI/CIND during follow-up"

capture drop doevent_mci
gen doevent_mci = docensor
replace doevent_mci = domcievent if fail_mci==1
format doevent_mci %td
label var doevent_mci "End of follow-up date for MCI/CIND analysis"

capture drop ageevent_mci
gen ageevent_mci = (doevent_mci - dob)/365.25 if doevent_mci<. & dob<.
label var ageevent_mci "Age at MCI/CIND event or censoring"

stset ageevent_mci, origin(time ageenter) enter(time ageenter) ///
    failure(fail_mci==1) id(HHIDPN)

display "=============================================================="
display "TABLE 3B. Frailty -> Incident MCI/CIND alone"
display "Outcome: first incident MCI/CIND only"
display "=============================================================="

svy: stcox i.frail_cat $M1
svy: stcox i.frail_cat $M2
svy: stcox i.frail_cat $M3

tempname memhold2
postfile `memhold2' str30 outcome str40 predictor str20 model ///
    double hr ll ul p using ///
    "D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_DIET_FRAILTY_COG\OUTPUT\TABLE3_results_mci.dta", replace

quietly svy: stcox i.frail_cat $M1
post_frailcat_results, postname(`memhold2') outcome("MCI/CIND only") model("Model 1")

quietly svy: stcox i.frail_cat $M2
post_frailcat_results, postname(`memhold2') outcome("MCI/CIND only") model("Model 2")

quietly svy: stcox i.frail_cat $M3
post_frailcat_results, postname(`memhold2') outcome("MCI/CIND only") model("Model 3")

postclose `memhold2'

********************************************************************************
** PART C. INCIDENT PROBABLE DEMENTIA ONLY
********************************************************************************

capture drop eventdem2018 eventdem2020 eventdem2022
gen eventdem2018 = 0
replace eventdem2018 = 1 if cogfunction2016==1 & cogfunction2018==3
label var eventdem2018 "Incident probable dementia by 2018"

gen eventdem2020 = 0
replace eventdem2020 = 1 if cogfunction2016==1 & ///
    ((cogfunction2018==1 & cogfunction2020==3) | ///
     (missing(cogfunction2018) & cogfunction2020==3))
label var eventdem2020 "Incident probable dementia by 2020"

gen eventdem2022 = 0
replace eventdem2022 = 1 if cogfunction2016==1 & ///
    ((cogfunction2018==1 | missing(cogfunction2018)) & ///
     (cogfunction2020==1 | missing(cogfunction2020)) & ///
      cogfunction2022==3)
label var eventdem2022 "Incident probable dementia by 2022"

capture drop dodementiaevent
gen dodementiaevent = .
replace dodementiaevent = doenter + floor((doiw2018-doenter)/2) if eventdem2018==1
replace dodementiaevent = doiw2018 + floor((doiw2020-doiw2018)/2) if eventdem2020==1
replace dodementiaevent = doiw2020 + floor((doiw2022-doiw2020)/2) if eventdem2022==1
format dodementiaevent %td
label var dodementiaevent "Estimated date of first incident probable dementia"

capture drop fail_dem
gen fail_dem = 0
replace fail_dem = 1 if dodementiaevent<. & ///
    (dod==. | dodementiaevent<=dod) & ///
    dodementiaevent<=doadmin
label var fail_dem "Incident probable dementia during follow-up"

capture drop doevent_dem
gen doevent_dem = docensor
replace doevent_dem = dodementiaevent if fail_dem==1
format doevent_dem %td
label var doevent_dem "End of follow-up date for dementia analysis"

capture drop ageevent_dem
gen ageevent_dem = (doevent_dem - dob)/365.25 if doevent_dem<. & dob<.
label var ageevent_dem "Age at probable dementia event or censoring"

stset ageevent_dem, origin(time ageenter) enter(time ageenter) ///
    failure(fail_dem==1) id(HHIDPN)

display "=============================================================="
display "TABLE 3C. Frailty -> Incident probable dementia alone"
display "Outcome: first incident probable dementia only"
display "=============================================================="

svy: stcox i.frail_cat $M1
svy: stcox i.frail_cat $M2
svy: stcox i.frail_cat $M3

tempname memhold3
postfile `memhold3' str30 outcome str40 predictor str20 model ///
    double hr ll ul p using ///
    "D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_DIET_FRAILTY_COG\OUTPUT\TABLE3_results_dem.dta", replace

quietly svy: stcox i.frail_cat $M1
post_frailcat_results, postname(`memhold3') outcome("Probable dementia only") model("Model 1")

quietly svy: stcox i.frail_cat $M2
post_frailcat_results, postname(`memhold3') outcome("Probable dementia only") model("Model 2")

quietly svy: stcox i.frail_cat $M3
post_frailcat_results, postname(`memhold3') outcome("Probable dementia only") model("Model 3")

postclose `memhold3'

********************************************************************************
** PART D. COMBINE RESULTS
********************************************************************************

use ///
"D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_DIET_FRAILTY_COG\OUTPUT\TABLE3_results_cogimp.dta", ///
clear

append using ///
"D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_DIET_FRAILTY_COG\OUTPUT\TABLE3_results_mci.dta"

append using ///
"D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_DIET_FRAILTY_COG\OUTPUT\TABLE3_results_dem.dta"

format hr ll ul %9.3f
format p %9.4f
order outcome predictor model hr ll ul p
sort outcome model predictor
list, noobs abbreviate(30)

save ///
"D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_DIET_FRAILTY_COG\OUTPUT\TABLE3_results_all.dta", ///
replace

export delimited using ///
"D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_DIET_FRAILTY_COG\OUTPUT\TABLE3_results_all.csv", ///
replace

capture log close


***********************************************************************************************************************************
capture log close

log using ///
"D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_DIET_FRAILTY_COG\OUTPUT\TABLE4_DIET_COGIMP_MCI_DEM.txt", ///
text replace

********************************************************************************
** TABLE 4: DIET QUALITY / FOOD VARIABLES -> INCIDENT COGNITIVE IMPAIRMENT
** ADDITIONAL ANALYSES: INCIDENT MCI/CIND ONLY AND INCIDENT DEMENTIA ONLY
********************************************************************************

use ///
"D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_DIET_FRAILTY_COG\FINAL_DATA\HRS_HEI_FRAIL_ANALYTIC_FINALfin.dta", ///
clear

keep if sample_final==1

********************************************************************************
** SURVEY DESIGN
********************************************************************************

svyset secu [pweight=HCNSWGTR_NT], strata(stratum) singleunit(centered)

********************************************************************************
** OPTIONAL LABELS
********************************************************************************

capture label var zhei2015_total_score "HEI-2015 total score (z)"
capture label var fried_sum "Frailty score"
capture label var fried_status "Frailty status"

********************************************************************************
** COVARIATE BLOCKS
** Keep frailty as covariate here if Table 4 is intended to estimate the
** independent association of diet variables with cognitive outcomes
********************************************************************************

global M1 "c.r13agey_e i.ragender"
global M2 "c.r13agey_e i.ragender i.RACE_ETHN i.marital_2012 i.education i.totwealth_2012"
global M3 "c.r13agey_e i.ragender i.RACE_ETHN i.marital_2012 i.education i.totwealth_2012 i.smoking_2012 i.alcohol_2012 i.physic_act_2012 i.bmibr_2012 i.hbp_ever_2012 i.diab_ever_2012 i.stroke_ever_2012 i.heart_ever_2012 i.srh_2012 i.frail_cat"

********************************************************************************
** OPTIONAL: create frailty category if not already present
********************************************************************************

capture confirm variable frail_cat
if _rc {
    capture drop frail_cat
    gen frail_cat = .
    replace frail_cat = 1 if fried_sum==0
    replace frail_cat = 2 if inrange(fried_sum,1,2)
    replace frail_cat = 3 if fried_sum>=3 & fried_sum<.
    capture label drop frail_cat
    label define frail_cat 1 "Robust (0)" 2 "Pre-frail (1-2)" 3 "Frail (>=3)"
    label values frail_cat frail_cat
    label var frail_cat "Frailty category"
}

********************************************************************************
** PREDICTOR LIST
** Main predictors:
**   zhei2015_total_score
**   zheix*
**   zC3A_FF_13-zC9AP_FF_13
********************************************************************************

unab dietvars : zhei2015_total_score zheix* zC3A_FF_13-zC9AP_FF_13
display "`dietvars'"

********************************************************************************
** HELPER PROGRAM: POST ONE CONTINUOUS PREDICTOR
********************************************************************************

capture program drop post_continuous_result
program define post_continuous_result
    syntax varname , POSTNAME(name) OUTCOME(string) MODEL(string)

    quietly lincom `varlist', eform
    post `postname' ("`outcome'") ("`varlist'") ("`: variable label `varlist''") ("`model'") ///
        (r(estimate)) (r(lb)) (r(ub)) (r(p))
end

********************************************************************************
** PART A. INCIDENT COGNITIVE IMPAIRMENT (CIND OR PROBABLE DEMENTIA)
********************************************************************************

stset ageevent, origin(time ageenter) enter(time ageenter) ///
    failure(fail_cog==1) id(HHIDPN)

display "=============================================================="
display "TABLE 4A. Diet variables -> Incident cognitive impairment"
display "Outcome: first incident CIND or probable dementia"
display "=============================================================="

tempname memhold1
postfile `memhold1' str30 outcome str40 predictor str120 predictor_label str20 model ///
    double hr ll ul p using ///
    "D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_DIET_FRAILTY_COG\OUTPUT\TABLE4_results_cogimp.dta", replace

foreach x of varlist `dietvars' {

    display " "
    display "--------------------------------------------------------------"
    display "Predictor: `x'"
    display "Label: `: variable label `x''"
    display "--------------------------------------------------------------"

    quietly svy: stcox c.`x' $M1
    post_continuous_result `x', postname(`memhold1') ///
        outcome("CIND/probable dementia") model("Model 1")

    quietly svy: stcox c.`x' $M2
    post_continuous_result `x', postname(`memhold1') ///
        outcome("CIND/probable dementia") model("Model 2")

    quietly svy: stcox c.`x' $M3
    post_continuous_result `x', postname(`memhold1') ///
        outcome("CIND/probable dementia") model("Model 3")
}

postclose `memhold1'

********************************************************************************
** PART B. INCIDENT MCI/CIND ONLY
********************************************************************************

capture drop eventmci2018 eventmci2020 eventmci2022
gen eventmci2018 = 0
replace eventmci2018 = 1 if cogfunction2016==1 & cogfunction2018==2
label var eventmci2018 "Incident MCI/CIND by 2018"

gen eventmci2020 = 0
replace eventmci2020 = 1 if cogfunction2016==1 & ///
    ((cogfunction2018==1 & cogfunction2020==2) | ///
     (missing(cogfunction2018) & cogfunction2020==2))
label var eventmci2020 "Incident MCI/CIND by 2020"

gen eventmci2022 = 0
replace eventmci2022 = 1 if cogfunction2016==1 & ///
    ((cogfunction2018==1 | missing(cogfunction2018)) & ///
     (cogfunction2020==1 | missing(cogfunction2020)) & ///
      cogfunction2022==2)
label var eventmci2022 "Incident MCI/CIND by 2022"

capture drop domcievent
gen domcievent = .
replace domcievent = doenter + floor((doiw2018-doenter)/2) if eventmci2018==1
replace domcievent = doiw2018 + floor((doiw2020-doiw2018)/2) if eventmci2020==1
replace domcievent = doiw2020 + floor((doiw2022-doiw2020)/2) if eventmci2022==1
format domcievent %td
label var domcievent "Estimated date of first incident MCI/CIND"

capture drop fail_mci
gen fail_mci = 0
replace fail_mci = 1 if domcievent<. & ///
    (dod==. | domcievent<=dod) & ///
    domcievent<=doadmin
label var fail_mci "Incident MCI/CIND during follow-up"

capture drop doevent_mci
gen doevent_mci = docensor
replace doevent_mci = domcievent if fail_mci==1
format doevent_mci %td
label var doevent_mci "End of follow-up date for MCI/CIND analysis"

capture drop ageevent_mci
gen ageevent_mci = (doevent_mci - dob)/365.25 if doevent_mci<. & dob<.
label var ageevent_mci "Age at MCI/CIND event or censoring"

stset ageevent_mci, origin(time ageenter) enter(time ageenter) ///
    failure(fail_mci==1) id(HHIDPN)

display "=============================================================="
display "TABLE 4B. Diet variables -> Incident MCI/CIND alone"
display "Outcome: first incident MCI/CIND only"
display "=============================================================="

tempname memhold2
postfile `memhold2' str30 outcome str40 predictor str120 predictor_label str20 model ///
    double hr ll ul p using ///
    "D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_DIET_FRAILTY_COG\OUTPUT\TABLE4_results_mci.dta", replace

foreach x of varlist `dietvars' {

    display " "
    display "--------------------------------------------------------------"
    display "Predictor: `x'"
    display "Label: `: variable label `x''"
    display "--------------------------------------------------------------"

    quietly svy: stcox c.`x' $M1
    post_continuous_result `x', postname(`memhold2') ///
        outcome("MCI/CIND only") model("Model 1")

    quietly svy: stcox c.`x' $M2
    post_continuous_result `x', postname(`memhold2') ///
        outcome("MCI/CIND only") model("Model 2")

    quietly svy: stcox c.`x' $M3
    post_continuous_result `x', postname(`memhold2') ///
        outcome("MCI/CIND only") model("Model 3")
}

postclose `memhold2'

********************************************************************************
** PART C. INCIDENT PROBABLE DEMENTIA ONLY
********************************************************************************

capture drop eventdem2018 eventdem2020 eventdem2022
gen eventdem2018 = 0
replace eventdem2018 = 1 if cogfunction2016==1 & cogfunction2018==3
label var eventdem2018 "Incident probable dementia by 2018"

gen eventdem2020 = 0
replace eventdem2020 = 1 if cogfunction2016==1 & ///
    ((cogfunction2018==1 & cogfunction2020==3) | ///
     (missing(cogfunction2018) & cogfunction2020==3))
label var eventdem2020 "Incident probable dementia by 2020"

gen eventdem2022 = 0
replace eventdem2022 = 1 if cogfunction2016==1 & ///
    ((cogfunction2018==1 | missing(cogfunction2018)) & ///
     (cogfunction2020==1 | missing(cogfunction2020)) & ///
      cogfunction2022==3)
label var eventdem2022 "Incident probable dementia by 2022"

capture drop dodementiaevent
gen dodementiaevent = .
replace dodementiaevent = doenter + floor((doiw2018-doenter)/2) if eventdem2018==1
replace dodementiaevent = doiw2018 + floor((doiw2020-doiw2018)/2) if eventdem2020==1
replace dodementiaevent = doiw2020 + floor((doiw2022-doiw2020)/2) if eventdem2022==1
format dodementiaevent %td
label var dodementiaevent "Estimated date of first incident probable dementia"

capture drop fail_dem
gen fail_dem = 0
replace fail_dem = 1 if dodementiaevent<. & ///
    (dod==. | dodementiaevent<=dod) & ///
    dodementiaevent<=doadmin
label var fail_dem "Incident probable dementia during follow-up"

capture drop doevent_dem
gen doevent_dem = docensor
replace doevent_dem = dodementiaevent if fail_dem==1
format doevent_dem %td
label var doevent_dem "End of follow-up date for dementia analysis"

capture drop ageevent_dem
gen ageevent_dem = (doevent_dem - dob)/365.25 if doevent_dem<. & dob<.
label var ageevent_dem "Age at probable dementia event or censoring"

stset ageevent_dem, origin(time ageenter) enter(time ageenter) ///
    failure(fail_dem==1) id(HHIDPN)

display "=============================================================="
display "TABLE 4C. Diet variables -> Incident probable dementia alone"
display "Outcome: first incident probable dementia only"
display "=============================================================="

tempname memhold3
postfile `memhold3' str30 outcome str40 predictor str120 predictor_label str20 model ///
    double hr ll ul p using ///
    "D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_DIET_FRAILTY_COG\OUTPUT\TABLE4_results_dem.dta", replace

foreach x of varlist `dietvars' {

    display " "
    display "--------------------------------------------------------------"
    display "Predictor: `x'"
    display "Label: `: variable label `x''"
    display "--------------------------------------------------------------"

    quietly svy: stcox c.`x' $M1
    post_continuous_result `x', postname(`memhold3') ///
        outcome("Probable dementia only") model("Model 1")

    quietly svy: stcox c.`x' $M2
    post_continuous_result `x', postname(`memhold3') ///
        outcome("Probable dementia only") model("Model 2")

    quietly svy: stcox c.`x' $M3
    post_continuous_result `x', postname(`memhold3') ///
        outcome("Probable dementia only") model("Model 3")
}

postclose `memhold3'

********************************************************************************
** PART D. COMBINE RESULTS
********************************************************************************

use ///
"D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_DIET_FRAILTY_COG\OUTPUT\TABLE4_results_cogimp.dta", ///
clear

append using ///
"D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_DIET_FRAILTY_COG\OUTPUT\TABLE4_results_mci.dta"

append using ///
"D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_DIET_FRAILTY_COG\OUTPUT\TABLE4_results_dem.dta"

format hr ll ul %9.3f
format p %9.4f
order outcome predictor predictor_label model hr ll ul p
sort outcome predictor model
list, noobs abbreviate(32)

save ///
"D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_DIET_FRAILTY_COG\OUTPUT\TABLE4_results_all.dta", ///
replace

export delimited using ///
"D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_DIET_FRAILTY_COG\OUTPUT\TABLE4_results_all.csv", ///
replace

capture log close

***********************FOREST PLOT R CODE***************************

# Forest plot for Table 4
# Assumes a CSV exported from Stata with one row per estimate and columns similar to:
# outcome, predictor, label, model, hr, ll, ul, p
# The code below is flexible and will try to detect common column-name variants.

setwd("D://16GBBACKUPUSB//BACKUP_USB_SEPTEMBER2014//SUMMER_STUDENT_2026//HRS_DIET_FRAILTY_COG//OUTPUT//")
library(readr)
library(dplyr)
library(stringr)
library(forcats)
library(ggplot2)

# ============================================================
# 1. Read Table 4 results
# ============================================================
dat <- read_csv("TABLE4_results_all.csv", show_col_types = FALSE)
names(dat) <- tolower(names(dat))

# expected columns:
# outcome, predictor, predictor_label, model, hr, ll, ul, p

# ============================================================
# 2. Keep only the composite outcome: MCI/CIND + probable dementia
# ============================================================
dat1 <- dat %>%
  filter(outcome == "CIND/probable dementia")

# ============================================================
# 3. Create clean labels and panel groups
# ============================================================
hei_map <- c(
  "zhei2015_total_score" = "HEI-2015 total score",
  "zheix1_totalveg"      = "Total vegetables",
  "zheix2_greens_and_bean" = "Greens and beans",
  "zheix3_totalfruit"    = "Total fruit",
  "zheix4_wholefruit"    = "Whole fruit",
  "zheix5_wholegrain"    = "Whole grains",
  "zheix6_totaldairy"    = "Dairy",
  "zheix7_totprot"       = "Total protein foods",
  "zheix8_seaplant_prot" = "Seafood and plant proteins",
  "zheix9_fattyacid"     = "Fatty acid ratio",
  "zheix10_sodium"       = "Sodium",
  "zheix11_refinedgrain" = "Refined grains",
  "zheix12_addedsugar"   = "Added sugar",
  "zheix13_saturatedfat" = "Saturated fat"
)

dat1 <- dat1 %>%
  mutate(
    panel_group = case_when(
      predictor %in% names(hei_map) ~ "HEI-2015 total score and components",
      str_detect(predictor, "^zC3") ~ "C3: Dairy, dairy alternatives, and spreads/fats",
      str_detect(predictor, "^zC4") ~ "C4: Fruits and fruit juices",
      str_detect(predictor, "^zC5") ~ "C5: Vegetables, legumes, and soy foods",
      str_detect(predictor, "^zC6") ~ "C6: Eggs, meats, and seafood/protein foods",
      str_detect(predictor, "^zC7") ~ "C7: Grains, breads, starches, and savory snacks",
      str_detect(predictor, "^zC8") ~ "C8: Beverages and alcohol",
      str_detect(predictor, "^zC9") ~ "C9: Sweets, snacks, condiments, and added fats",
      TRUE ~ "Other"
    ),
    label_clean = case_when(
      predictor %in% names(hei_map) ~ unname(hei_map[predictor]),
      TRUE ~ predictor
    ),
    model = factor(model, levels = c("Model 1", "Model 2", "Model 3"))
  ) %>%
  filter(panel_group != "Other")

# ============================================================
# 4. Function to plot one panel family at a time
# ============================================================
make_forest_panel <- function(data_sub, panel_title, file_stub) {
  
  d <- data_sub %>%
    mutate(
      label_clean = fct_reorder(label_clean, hr, .desc = FALSE)
    )
  
  p <- ggplot(d, aes(x = hr, y = label_clean)) +
    geom_vline(xintercept = 1, linetype = 2, linewidth = 0.4) +
    geom_errorbarh(aes(xmin = ll, xmax = ul), height = 0.18, linewidth = 0.4) +
    geom_point(size = 2) +
    facet_wrap(~ model, ncol = 3, scales = "free_y") +
    scale_x_log10() +
    labs(
      title = panel_title,
      subtitle = "Outcome: Incident CIND/probable dementia",
      x = "Hazard ratio (log scale)",
      y = NULL
    ) +
    theme_bw(base_size = 10) +
    theme(
      strip.text = element_text(face = "bold"),
      panel.grid.minor = element_blank(),
      panel.grid.major.y = element_blank(),
      axis.text.y = element_text(size = 8)
    )
  
  print(p)
  
  ggsave(
    paste0(file_stub, ".png"),
    p, width = 11, height = 8, dpi = 300
  )
  ggsave(
    paste0(file_stub, ".pdf"),
    p, width = 11, height = 8
  )
}

# ============================================================
# 5. Produce separate figures
# ============================================================

# HEI total + components
make_forest_panel(
  data_sub   = dat1 %>% filter(panel_group == "HEI-2015 total score and components"),
  panel_title = "Forest plot: HEI-2015 total score and component scores",
  file_stub   = "Table4_forest_HEI_components"
)

# C3 dairy/fats
make_forest_panel(
  data_sub   = dat1 %>% filter(panel_group == "C3: Dairy, dairy alternatives, and spreads/fats"),
  panel_title = "Forest plot: C3 food-group variables",
  file_stub   = "Table4_forest_C3_dairy_fats"
)

# C4 fruits
make_forest_panel(
  data_sub   = dat1 %>% filter(panel_group == "C4: Fruits and fruit juices"),
  panel_title = "Forest plot: C4 food-group variables",
  file_stub   = "Table4_forest_C4_fruits"
)

# C5 vegetables/legumes/soy
make_forest_panel(
  data_sub   = dat1 %>% filter(panel_group == "C5: Vegetables, legumes, and soy foods"),
  panel_title = "Forest plot: C5 food-group variables",
  file_stub   = "Table4_forest_C5_vegetables"
)

# C6 proteins
make_forest_panel(
  data_sub   = dat1 %>% filter(panel_group == "C6: Eggs, meats, and seafood/protein foods"),
  panel_title = "Forest plot: C6 food-group variables",
  file_stub   = "Table4_forest_C6_proteins"
)

# C7 grains/starches/snacks
make_forest_panel(
  data_sub   = dat1 %>% filter(panel_group == "C7: Grains, breads, starches, and savory snacks"),
  panel_title = "Forest plot: C7 food-group variables",
  file_stub   = "Table4_forest_C7_grains"
)

# C8 beverages/alcohol
make_forest_panel(
  data_sub   = dat1 %>% filter(panel_group == "C8: Beverages and alcohol"),
  panel_title = "Forest plot: C8 food-group variables",
  file_stub   = "Table4_forest_C8_beverages"
)

# C9 sweets/snacks/condiments/fats
make_forest_panel(
  data_sub   = dat1 %>% filter(panel_group == "C9: Sweets, snacks, condiments, and added fats"),
  panel_title = "Forest plot: C9 food-group variables",
  file_stub   = "Table4_forest_C9_sweets_snacks"
)

clear all
set more off
capture log close

capture log using "D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_DIET_FRAILTY_COG\OUTPUT\TABLEX_MED4WAY_ABN_DATAMANAGEMENT.txt", ///
text replace


********************************************************************************
** MASTER DO-FILE: TABLE 5 / TABLE S2 / FIGURE S2 / ABN DATA MANAGEMENT
** HRS diet quality, frailty, MCI/CIND, and probable dementia
**
** REVISED VERSION:
**   - uses 2012 covariates only where requested
**   - uses z-scored dietary variables in med4way
**   - uses z-scored dietary variable in ABN data management
********************************************************************************

********************************************************************************
** PATHS
********************************************************************************

global PROJ    "D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_DIET_FRAILTY_COG"
global DATA    "$PROJ\FINAL_DATA"
global OUT     "$PROJ\OUTPUT"

********************************************************************************
** SECTION 1. LOAD ANALYTIC FILE
********************************************************************************

use "$DATA\HRS_HEI_FRAIL_ANALYTIC_FINALfin.dta", clear
keep if sample_final==1

********************************************************************************
** SECTION 2. CREATE EXPOSURE / MEDIATOR VARIABLES
********************************************************************************

capture label var hei2015_total_score "HEI-2015 total score"

capture drop hei_cat
gen hei_cat = .
replace hei_cat = 1 if hei2015_total_score >= 0  & hei2015_total_score < 51
replace hei_cat = 2 if hei2015_total_score >= 51 & hei2015_total_score < 81
replace hei_cat = 3 if hei2015_total_score >= 81 & hei2015_total_score < .
capture label drop hei_cat
label define hei_cat 1 "Poor (<51)" 2 "Needs improvement (51-80)" 3 "Good (>=81)"
label values hei_cat hei_cat
label var hei_cat "HEI-2015 category"

capture label var fried_sum "Frailty score"

capture drop frail_cat
gen frail_cat = .
replace frail_cat = 1 if fried_sum == 0
replace frail_cat = 2 if inrange(fried_sum,1,2)
replace frail_cat = 3 if fried_sum >= 3 & fried_sum < .
capture label drop frail_cat
label define frail_cat 1 "Robust (0)" 2 "Pre-frail (1-2)" 3 "Frail (>=3)"
label values frail_cat frail_cat
label var frail_cat "Frailty category"

********************************************************************************
** SECTION 3. CREATE Z-SCORED DIETARY VARIABLES DEFENSIVELY
********************************************************************************

capture program drop make_zdietvars
program define make_zdietvars, rclass
    version 18.0

    local rawdietvars

    capture confirm variable hei2015_total_score
    if !_rc local rawdietvars `rawdietvars' hei2015_total_score

    capture unab heicomp : heix*
    if !_rc local rawdietvars `rawdietvars' `heicomp'

    capture unab ffqvars : C3A_FF_13-C9AP_FF_13
    if !_rc local rawdietvars `rawdietvars' `ffqvars'

    local rawdietvars : list uniq rawdietvars

    di as text "Raw dietary variables found:"
    di as result "`rawdietvars'"

    local zdietvars
    foreach v of local rawdietvars {
        capture confirm variable `v'
        if _rc continue

        local zv = "z`v'"
        capture drop `zv'
        quietly egen `zv' = std(`v')
        capture label var `zv' "Standardized values of `v'"
        local zdietvars `zdietvars' `zv'
    }

    local zdietvars : list uniq zdietvars

    return local rawdietvars "`rawdietvars'"
    return local zdietvars  "`zdietvars'"
end

quietly make_zdietvars
global ZDIETVARS "`r(zdietvars)'"

display as text "Z-scored dietary mediators:"
display as result "$ZDIETVARS"

********************************************************************************
** SECTION 4. CREATE PLAIN COVARIATE VARIABLES FOR med4way
********************************************************************************

capture drop age_2012
gen age_2012 = r11agey_e
label var age_2012 "Age in years, 2012"

capture drop female
gen byte female = .
replace female = 1 if ragender == 2
replace female = 0 if ragender == 1
label var female "Female"

capture drop race_2 race_3 race_4
gen byte race_2 = (RACE_ETHN == 2) if RACE_ETHN < .
gen byte race_3 = (RACE_ETHN == 3) if RACE_ETHN < .
gen byte race_4 = (RACE_ETHN == 4) if RACE_ETHN < .

capture drop mar_2 mar_3 mar_4
gen byte mar_2 = (marital_2012 == 2) if marital_2012 < .
gen byte mar_3 = (marital_2012 == 3) if marital_2012 < .
gen byte mar_4 = (marital_2012 == 4) if marital_2012 < .

capture drop edu_2 edu_3 edu_4 edu_5
gen byte edu_2 = (education == 2) if education < .
gen byte edu_3 = (education == 3) if education < .
gen byte edu_4 = (education == 4) if education < .
gen byte edu_5 = (education == 5) if education < .

capture drop wealth_2 wealth_3 wealth_4 wealth_5
gen byte wealth_2 = (totwealth_2012 == 2) if totwealth_2012 < .
gen byte wealth_3 = (totwealth_2012 == 3) if totwealth_2012 < .
gen byte wealth_4 = (totwealth_2012 == 4) if totwealth_2012 < .
gen byte wealth_5 = (totwealth_2012 == 5) if totwealth_2012 < .

capture drop smoke_2 smoke_3
gen byte smoke_2 = (smoking_2012 == 2) if smoking_2012 < .
gen byte smoke_3 = (smoking_2012 == 3) if smoking_2012 < .

capture drop alcohol_2 alcohol_3 alcohol_4
gen byte alcohol_2 = (alcohol_2012 == 2) if alcohol_2012 < .
gen byte alcohol_3 = (alcohol_2012 == 3) if alcohol_2012 < .
gen byte alcohol_4 = (alcohol_2012 == 4) if alcohol_2012 < .

capture drop phys_2 phys_3
gen byte phys_2 = (physic_act_2012 == 2) if physic_act_2012 < .
gen byte phys_3 = (physic_act_2012 == 3) if physic_act_2012 < .

capture drop bmi_2 bmi_3
gen byte bmi_2 = (bmibr_2012 == 2) if bmibr_2012 < .
gen byte bmi_3 = (bmibr_2012 == 3) if bmibr_2012 < .

capture drop srh_2
gen byte srh_2 = (srh_2012 == 2) if srh_2012 < .

capture drop hbp_yes diab_yes stroke_yes heart_yes
gen byte hbp_yes    = hbp_ever_2012    if hbp_ever_2012    < .
gen byte diab_yes   = diab_ever_2012   if diab_ever_2012   < .
gen byte stroke_yes = stroke_ever_2012 if stroke_ever_2012 < .
gen byte heart_yes  = heart_ever_2012  if heart_ever_2012  < .

********************************************************************************
** SECTION 5. COVARIATE MACROS
********************************************************************************

global COV4 age_2012 female ///
            race_2 race_3 race_4 ///
            mar_2 mar_3 mar_4 ///
            edu_2 edu_3 edu_4 edu_5 ///
            wealth_2 wealth_3 wealth_4 wealth_5 ///
            smoke_2 smoke_3 ///
            alcohol_2 alcohol_3 alcohol_4 ///
            phys_2 phys_3 ///
            bmi_2 bmi_3 ///
            hbp_yes diab_yes stroke_yes heart_yes ///
            srh_2

global COVS2 age_2012 female ///
             race_2 race_3 race_4 ///
             edu_2 edu_3 edu_4 edu_5 ///
             wealth_2 wealth_3 wealth_4 wealth_5

global COVS2_AGESEX age_2012 female

********************************************************************************
** SECTION 6. CREATE ADDITIONAL OUTCOMES
********************************************************************************

capture drop eventmci2018 eventmci2020 eventmci2022
gen eventmci2018 = 0
replace eventmci2018 = 1 if cogfunction2016 == 1 & cogfunction2018 == 2
label var eventmci2018 "Incident MCI/CIND by 2018"

gen eventmci2020 = 0
replace eventmci2020 = 1 if cogfunction2016 == 1 & ///
    ((cogfunction2018 == 1 & cogfunction2020 == 2) | ///
     (missing(cogfunction2018) & cogfunction2020 == 2))
label var eventmci2020 "Incident MCI/CIND by 2020"

gen eventmci2022 = 0
replace eventmci2022 = 1 if cogfunction2016 == 1 & ///
    ((cogfunction2018 == 1 | missing(cogfunction2018)) & ///
     (cogfunction2020 == 1 | missing(cogfunction2020)) & ///
      cogfunction2022 == 2)
label var eventmci2022 "Incident MCI/CIND by 2022"

capture drop domcievent
gen domcievent = .
replace domcievent = doenter + floor((doiw2018 - doenter)/2) if eventmci2018 == 1
replace domcievent = doiw2018 + floor((doiw2020 - doiw2018)/2) if eventmci2020 == 1
replace domcievent = doiw2020 + floor((doiw2022 - doiw2020)/2) if eventmci2022 == 1
format domcievent %td
label var domcievent "Estimated date of first incident MCI/CIND"

capture drop fail_mci
gen fail_mci = 0
replace fail_mci = 1 if domcievent < . & ///
    (dod == . | domcievent <= dod) & ///
    domcievent <= doadmin
label var fail_mci "Incident MCI/CIND during follow-up"

capture drop doevent_mci
gen doevent_mci = docensor
replace doevent_mci = domcievent if fail_mci == 1
format doevent_mci %td
label var doevent_mci "End of follow-up date for MCI/CIND analysis"

capture drop eventdem2018 eventdem2020 eventdem2022
gen eventdem2018 = 0
replace eventdem2018 = 1 if cogfunction2016 == 1 & cogfunction2018 == 3
label var eventdem2018 "Incident probable dementia by 2018"

gen eventdem2020 = 0
replace eventdem2020 = 1 if cogfunction2016 == 1 & ///
    ((cogfunction2018 == 1 & cogfunction2020 == 3) | ///
     (missing(cogfunction2018) & cogfunction2020 == 3))
label var eventdem2020 "Incident probable dementia by 2020"

gen eventdem2022 = 0
replace eventdem2022 = 1 if cogfunction2016 == 1 & ///
    ((cogfunction2018 == 1 | missing(cogfunction2018)) & ///
     (cogfunction2020 == 1 | missing(cogfunction2020)) & ///
      cogfunction2022 == 3)
label var eventdem2022 "Incident probable dementia by 2022"

capture drop dodementiaevent
gen dodementiaevent = .
replace dodementiaevent = doenter + floor((doiw2018 - doenter)/2) if eventdem2018 == 1
replace dodementiaevent = doiw2018 + floor((doiw2020 - doiw2018)/2) if eventdem2020 == 1
replace dodementiaevent = doiw2020 + floor((doiw2022 - doiw2020)/2) if eventdem2022 == 1
format dodementiaevent %td
label var dodementiaevent "Estimated date of first incident probable dementia"

capture drop fail_dem
gen fail_dem = 0
replace fail_dem = 1 if dodementiaevent < . & ///
    (dod == . | dodementiaevent <= dod) & ///
    dodementiaevent <= doadmin
label var fail_dem "Incident probable dementia during follow-up"

capture drop doevent_dem
gen doevent_dem = docensor
replace doevent_dem = dodementiaevent if fail_dem == 1
format doevent_dem %td
label var doevent_dem "End of follow-up date for dementia analysis"

save "$DATA\HRS_HEI_FRAIL_ANALYTIC_FINALfin.dta", replace

********************************************************************************
** SECTION 7. HELPERS TO EXTRACT med4way RETURNS
********************************************************************************

capture program drop _get_m4_term_from_mats
program define _get_m4_term_from_mats, rclass
    version 18.0
    syntax , TERM(string) BTMAT(name) SEMAT(name) [TABLEMAT(name)]

    if "`tablemat'" != "" {
        capture confirm matrix `tablemat'
        if !_rc {
            local c = colnumb(`tablemat', "`term'")
            if `c' < . {
                return scalar b  = `tablemat'[1,`c']
                return scalar se = `tablemat'[2,`c']
                return scalar z  = `tablemat'[3,`c']
                return scalar p  = `tablemat'[4,`c']
                return scalar ll = `tablemat'[5,`c']
                return scalar ul = `tablemat'[6,`c']
                return scalar found = 1
                exit
            }
        }
    }

    capture confirm matrix `btmat'
    if !_rc {
        local c = colnumb(`btmat', "`term'")
        if `c' < . {
            return scalar b = `btmat'[1,`c']

            capture confirm matrix `semat'
            if !_rc {
                return scalar se = `semat'[1,`c']
            }
            else {
                return scalar se = .
            }

            return scalar z  = .
            return scalar p  = .
            return scalar ll = .
            return scalar ul = .
            return scalar found = 1
            exit
        }
    }

    return scalar b  = .
    return scalar se = .
    return scalar z  = .
    return scalar p  = .
    return scalar ll = .
    return scalar ul = .
    return scalar found = 0
end

********************************************************************************
** SECTION 8. HELPER PROGRAM FOR med4way BLOCKS + EXTRACTION
********************************************************************************

capture program drop run_med4way_block
program define run_med4way_block
    version 18.0
    syntax , OUTCOME(string) STFAIL(string) EVENTDATE(string) LOGFILE(string) ///
             COVARS(string) TITLE(string) MODELTAG(string) OUTPREFIX(string)

    preserve

    capture log close
    log using `"`logfile'"', text replace

    use "$DATA\HRS_HEI_FRAIL_ANALYTIC_FINALfin.dta", clear
    keep if sample_final == 1

    quietly make_zdietvars
    local dietvars `r(zdietvars)'

    stset `eventdate', origin(time doenter) enter(time doenter) ///
        failure(`stfail') id(HHIDPN)

    display "=============================================================="
    display "`title'"
    display "Exposure: Frailty score"
    display "Outcome: `outcome'"
    display "Outcome model: Cox proportional hazards"
    display "Mediator model: linear regression"
    display "2012 covariates only"
    display "=============================================================="

    tempfile blockres
    tempname posth

    postfile `posth' ///
        str30  modeltag ///
        str50  outcome ///
        str80  mediator ///
        str140 mediator_label ///
        double mediator_m ///
        double N_subj ///
        double N_fail ///
        double rc_cmd ///
        double converged ///
        ///
        double tereri_b tereri_se tereri_z tereri_p tereri_ll tereri_ul ///
        double ereri_cde_b ereri_cde_se ereri_cde_z ereri_cde_p ereri_cde_ll ereri_cde_ul ///
        double ereri_intref_b ereri_intref_se ereri_intref_z ereri_intref_p ereri_intref_ll ereri_intref_ul ///
        double ereri_intmed_b ereri_intmed_se ereri_intmed_z ereri_intmed_p ereri_intmed_ll ereri_intmed_ul ///
        double ereri_pie_b ereri_pie_se ereri_pie_z ereri_pie_p ereri_pie_ll ereri_pie_ul ///
        double terira_b terira_se terira_z terira_p terira_ll terira_ul ///
        double p_cde_b p_cde_se p_cde_z p_cde_p p_cde_ll p_cde_ul ///
        double p_intref_b p_intref_se p_intref_z p_intref_p p_intref_ll p_intref_ul ///
        double p_intmed_b p_intmed_se p_intmed_z p_intmed_p p_intmed_ll p_intmed_ul ///
        double p_pie_b p_pie_se p_pie_z p_pie_p p_pie_ll p_pie_ul ///
        double op_m_b op_m_se op_m_z op_m_p op_m_ll op_m_ul ///
        double op_ati_b op_ati_se op_ati_z op_ati_p op_ati_ll op_ati_ul ///
        double op_e_b op_e_se op_e_z op_e_p op_e_ll op_e_ul ///
        using `blockres', replace

    foreach m of local dietvars {

        capture confirm variable `m'
        if _rc continue

        quietly count if !missing(`m')
        if r(N) == 0 continue

        quietly summarize `m' if `m' < ., detail
        local m0 = r(p50)

        local mlab : variable label `m'
        if `"`mlab'"' == "" local mlab "`m'"

        display " "
        display "--------------------------------------------------------------"
        display "Mediator/moderator: `m'"
        display "Label: `mlab'"
        display "--------------------------------------------------------------"

        capture noisily med4way fried_sum `m' `covars', ///
            a0(0) a1(1) m(`m0') ///
            yreg(cox) mreg(linear) ///
            fulloutput

        local rc_cmd = _rc
        local converged = (`rc_cmd' == 0)

        local N_subj = .
        local N_fail = .
        capture scalar __Nsubj = e(N)
        if !_rc local N_subj = scalar(__Nsubj)
        capture scalar __Nfail = e(N_fail)
        if !_rc local N_fail = scalar(__Nfail)

        foreach x in ///
            tereri_b tereri_se tereri_z tereri_p tereri_ll tereri_ul ///
            ereri_cde_b ereri_cde_se ereri_cde_z ereri_cde_p ereri_cde_ll ereri_cde_ul ///
            ereri_intref_b ereri_intref_se ereri_intref_z ereri_intref_p ereri_intref_ll ereri_intref_ul ///
            ereri_intmed_b ereri_intmed_se ereri_intmed_z ereri_intmed_p ereri_intmed_ll ereri_intmed_ul ///
            ereri_pie_b ereri_pie_se ereri_pie_z ereri_pie_p ereri_pie_ll ereri_pie_ul ///
            terira_b terira_se terira_z terira_p terira_ll terira_ul ///
            p_cde_b p_cde_se p_cde_z p_cde_p p_cde_ll p_cde_ul ///
            p_intref_b p_intref_se p_intref_z p_intref_p p_intref_ll p_intref_ul ///
            p_intmed_b p_intmed_se p_intmed_z p_intmed_p p_intmed_ll p_intmed_ul ///
            p_pie_b p_pie_se p_pie_z p_pie_p p_pie_ll p_pie_ul ///
            op_m_b op_m_se op_m_z op_m_p op_m_ll op_m_ul ///
            op_ati_b op_ati_se op_ati_z op_ati_p op_ati_ll op_ati_ul ///
            op_e_b op_e_se op_e_z op_e_p op_e_ll op_e_ul {
            local `x' = .
        }

        if `rc_cmd' == 0 {

            tempname M4TAB M4B M4SE
            capture matrix `M4TAB' = r(table)
            capture matrix `M4B'    = r(b)
            capture matrix `M4SE'   = r(se)

            quietly _get_m4_term_from_mats, term(tereri) btmat(`M4B') semat(`M4SE') tablemat(`M4TAB')
            local tereri_b  = r(b)
            local tereri_se = r(se)
            local tereri_z  = r(z)
            local tereri_p  = r(p)
            local tereri_ll = r(ll)
            local tereri_ul = r(ul)

            quietly _get_m4_term_from_mats, term(ereri_cde) btmat(`M4B') semat(`M4SE') tablemat(`M4TAB')
            local ereri_cde_b  = r(b)
            local ereri_cde_se = r(se)
            local ereri_cde_z  = r(z)
            local ereri_cde_p  = r(p)
            local ereri_cde_ll = r(ll)
            local ereri_cde_ul = r(ul)

            quietly _get_m4_term_from_mats, term(ereri_intref) btmat(`M4B') semat(`M4SE') tablemat(`M4TAB')
            local ereri_intref_b  = r(b)
            local ereri_intref_se = r(se)
            local ereri_intref_z  = r(z)
            local ereri_intref_p  = r(p)
            local ereri_intref_ll = r(ll)
            local ereri_intref_ul = r(ul)

            quietly _get_m4_term_from_mats, term(ereri_intmed) btmat(`M4B') semat(`M4SE') tablemat(`M4TAB')
            local ereri_intmed_b  = r(b)
            local ereri_intmed_se = r(se)
            local ereri_intmed_z  = r(z)
            local ereri_intmed_p  = r(p)
            local ereri_intmed_ll = r(ll)
            local ereri_intmed_ul = r(ul)

            quietly _get_m4_term_from_mats, term(ereri_pie) btmat(`M4B') semat(`M4SE') tablemat(`M4TAB')
            local ereri_pie_b  = r(b)
            local ereri_pie_se = r(se)
            local ereri_pie_z  = r(z)
            local ereri_pie_p  = r(p)
            local ereri_pie_ll = r(ll)
            local ereri_pie_ul = r(ul)

            quietly _get_m4_term_from_mats, term(terira) btmat(`M4B') semat(`M4SE') tablemat(`M4TAB')
            local terira_b  = r(b)
            local terira_se = r(se)
            local terira_z  = r(z)
            local terira_p  = r(p)
            local terira_ll = r(ll)
            local terira_ul = r(ul)

            quietly _get_m4_term_from_mats, term(p_cde) btmat(`M4B') semat(`M4SE') tablemat(`M4TAB')
            local p_cde_b  = r(b)
            local p_cde_se = r(se)
            local p_cde_z  = r(z)
            local p_cde_p  = r(p)
            local p_cde_ll = r(ll)
            local p_cde_ul = r(ul)

            quietly _get_m4_term_from_mats, term(p_intref) btmat(`M4B') semat(`M4SE') tablemat(`M4TAB')
            local p_intref_b  = r(b)
            local p_intref_se = r(se)
            local p_intref_z  = r(z)
            local p_intref_p  = r(p)
            local p_intref_ll = r(ll)
            local p_intref_ul = r(ul)

            quietly _get_m4_term_from_mats, term(p_intmed) btmat(`M4B') semat(`M4SE') tablemat(`M4TAB')
            local p_intmed_b  = r(b)
            local p_intmed_se = r(se)
            local p_intmed_z  = r(z)
            local p_intmed_p  = r(p)
            local p_intmed_ll = r(ll)
            local p_intmed_ul = r(ul)

            quietly _get_m4_term_from_mats, term(p_pie) btmat(`M4B') semat(`M4SE') tablemat(`M4TAB')
            local p_pie_b  = r(b)
            local p_pie_se = r(se)
            local p_pie_z  = r(z)
            local p_pie_p  = r(p)
            local p_pie_ll = r(ll)
            local p_pie_ul = r(ul)

            quietly _get_m4_term_from_mats, term(op_m) btmat(`M4B') semat(`M4SE') tablemat(`M4TAB')
            local op_m_b  = r(b)
            local op_m_se = r(se)
            local op_m_z  = r(z)
            local op_m_p  = r(p)
            local op_m_ll = r(ll)
            local op_m_ul = r(ul)

            quietly _get_m4_term_from_mats, term(op_ati) btmat(`M4B') semat(`M4SE') tablemat(`M4TAB')
            local op_ati_b  = r(b)
            local op_ati_se = r(se)
            local op_ati_z  = r(z)
            local op_ati_p  = r(p)
            local op_ati_ll = r(ll)
            local op_ati_ul = r(ul)

            quietly _get_m4_term_from_mats, term(op_e) btmat(`M4B') semat(`M4SE') tablemat(`M4TAB')
            local op_e_b  = r(b)
            local op_e_se = r(se)
            local op_e_z  = r(z)
            local op_e_p  = r(p)
            local op_e_ll = r(ll)
            local op_e_ul = r(ul)
        }

        post `posth' ///
            ("`modeltag'") ///
            ("`outcome'") ///
            ("`m'") ///
            (`"`mlab'"') ///
            (`m0') ///
            (`N_subj') ///
            (`N_fail') ///
            (`rc_cmd') ///
            (`converged') ///
            ///
            (`tereri_b') (`tereri_se') (`tereri_z') (`tereri_p') (`tereri_ll') (`tereri_ul') ///
            (`ereri_cde_b') (`ereri_cde_se') (`ereri_cde_z') (`ereri_cde_p') (`ereri_cde_ll') (`ereri_cde_ul') ///
            (`ereri_intref_b') (`ereri_intref_se') (`ereri_intref_z') (`ereri_intref_p') (`ereri_intref_ll') (`ereri_intref_ul') ///
            (`ereri_intmed_b') (`ereri_intmed_se') (`ereri_intmed_z') (`ereri_intmed_p') (`ereri_intmed_ll') (`ereri_intmed_ul') ///
            (`ereri_pie_b') (`ereri_pie_se') (`ereri_pie_z') (`ereri_pie_p') (`ereri_pie_ll') (`ereri_pie_ul') ///
            (`terira_b') (`terira_se') (`terira_z') (`terira_p') (`terira_ll') (`terira_ul') ///
            (`p_cde_b') (`p_cde_se') (`p_cde_z') (`p_cde_p') (`p_cde_ll') (`p_cde_ul') ///
            (`p_intref_b') (`p_intref_se') (`p_intref_z') (`p_intref_p') (`p_intref_ll') (`p_intref_ul') ///
            (`p_intmed_b') (`p_intmed_se') (`p_intmed_z') (`p_intmed_p') (`p_intmed_ll') (`p_intmed_ul') ///
            (`p_pie_b') (`p_pie_se') (`p_pie_z') (`p_pie_p') (`p_pie_ll') (`p_pie_ul') ///
            (`op_m_b') (`op_m_se') (`op_m_z') (`op_m_p') (`op_m_ll') (`op_m_ul') ///
            (`op_ati_b') (`op_ati_se') (`op_ati_z') (`op_ati_p') (`op_ati_ll') (`op_ati_ul') ///
            (`op_e_b') (`op_e_se') (`op_e_z') (`op_e_p') (`op_e_ll') (`op_e_ul')
    }

    postclose `posth'
    capture log close

    use `blockres', clear
    sort outcome mediator

    save "`outprefix'.dta", replace
    export delimited using "`outprefix'.csv", replace
    export excel using "`outprefix'.xlsx", firstrow(variables) replace

    restore
end

********************************************************************************
** SECTION 9. RUN ALL BLOCKS
********************************************************************************

run_med4way_block, ///
    outcome("Incident CIND / probable dementia") ///
    stfail("fail_cog==1") ///
    eventdate("doevent") ///
    logfile("$OUT\TABLE5.txt") ///
    covars("$COV4") ///
    title("TABLE 5. Four-way decomposition") ///
    modeltag("TABLE5_FULL") ///
    outprefix("$OUT\TABLE5_full_extracted")

run_med4way_block, ///
    outcome("Incident MCI / CIND only") ///
    stfail("fail_mci==1") ///
    eventdate("doevent_mci") ///
    logfile("$OUT\TABLE5_MCIONLY.txt") ///
    covars("$COV4") ///
    title("TABLE 5. Four-way decomposition") ///
    modeltag("TABLE5_FULL") ///
    outprefix("$OUT\TABLE5_MCIONLY_full_extracted")

run_med4way_block, ///
    outcome("Incident probable dementia only") ///
    stfail("fail_dem==1") ///
    eventdate("doevent_dem") ///
    logfile("$OUT\TABLE5_DEMONLY.txt") ///
    covars("$COV4") ///
    title("TABLE 5. Four-way decomposition") ///
    modeltag("TABLE5_FULL") ///
    outprefix("$OUT\TABLE5_DEMONLY_full_extracted")

run_med4way_block, ///
    outcome("Incident CIND / probable dementia") ///
    stfail("fail_cog==1") ///
    eventdate("doevent") ///
    logfile("$OUT\TABLE_S2.txt") ///
    covars("$COVS2") ///
    title("TABLE S2. Four-way decomposition (reduced model)") ///
    modeltag("TABLES2_REDUCED") ///
    outprefix("$OUT\TABLES2_reduced_extracted")

run_med4way_block, ///
    outcome("Incident MCI / CIND only") ///
    stfail("fail_mci==1") ///
    eventdate("doevent_mci") ///
    logfile("$OUT\TABLE_S2_MCIONLY.txt") ///
    covars("$COVS2") ///
    title("TABLE S2. Four-way decomposition (reduced model)") ///
    modeltag("TABLES2_REDUCED") ///
    outprefix("$OUT\TABLES2_MCIONLY_reduced_extracted")

run_med4way_block, ///
    outcome("Incident probable dementia only") ///
    stfail("fail_dem==1") ///
    eventdate("doevent_dem") ///
    logfile("$OUT\TABLE_S2_DEMONLY.txt") ///
    covars("$COVS2") ///
    title("TABLE S2. Four-way decomposition (reduced model)") ///
    modeltag("TABLES2_REDUCED") ///
    outprefix("$OUT\TABLES2_DEMONLY_reduced_extracted")

run_med4way_block, ///
    outcome("Incident CIND / probable dementia") ///
    stfail("fail_cog==1") ///
    eventdate("doevent") ///
    logfile("$OUT\TABLE_S2_AGESEX.txt") ///
    covars("$COVS2_AGESEX") ///
    title("TABLE S2. Four-way decomposition (age- and sex-adjusted model)") ///
    modeltag("TABLES2_AGESEX") ///
    outprefix("$OUT\TABLES2_AGESEX_extracted")

run_med4way_block, ///
    outcome("Incident MCI / CIND only") ///
    stfail("fail_mci==1") ///
    eventdate("doevent_mci") ///
    logfile("$OUT\TABLE_S2_AGESEX_MCIONLY.txt") ///
    covars("$COVS2_AGESEX") ///
    title("TABLE S2. Four-way decomposition (age- and sex-adjusted model)") ///
    modeltag("TABLES2_AGESEX") ///
    outprefix("$OUT\TABLES2_AGESEX_MCIONLY_extracted")

run_med4way_block, ///
    outcome("Incident probable dementia only") ///
    stfail("fail_dem==1") ///
    eventdate("doevent_dem") ///
    logfile("$OUT\TABLE_S2_AGESEX_DEMONLY.txt") ///
    covars("$COVS2_AGESEX") ///
    title("TABLE S2. Four-way decomposition (age- and sex-adjusted model)") ///
    modeltag("TABLES2_AGESEX") ///
    outprefix("$OUT\TABLES2_AGESEX_DEMONLY_extracted")

********************************************************************************
** SECTION 10. APPEND ALL EXTRACTED RESULTS INTO ONE MASTER FILE
********************************************************************************

use "$OUT\TABLE5_full_extracted.dta", clear
append using "$OUT\TABLE5_MCIONLY_full_extracted.dta"
append using "$OUT\TABLE5_DEMONLY_full_extracted.dta"
append using "$OUT\TABLES2_reduced_extracted.dta"
append using "$OUT\TABLES2_MCIONLY_reduced_extracted.dta"
append using "$OUT\TABLES2_DEMONLY_reduced_extracted.dta"
append using "$OUT\TABLES2_AGESEX_extracted.dta"
append using "$OUT\TABLES2_AGESEX_MCIONLY_extracted.dta"
append using "$OUT\TABLES2_AGESEX_DEMONLY_extracted.dta"

order modeltag outcome mediator mediator_label mediator_m N_subj N_fail rc_cmd converged
sort modeltag outcome mediator

save "$OUT\med4way_all_parameters.dta", replace
export delimited using "$OUT\med4way_all_parameters.csv", replace
export excel using "$OUT\med4way_all_parameters.xlsx", firstrow(variables) replace

********************************************************************************
** SECTION 11. OPTIONAL: KEEP ONLY SUCCESSFUL med4way RUNS
********************************************************************************

preserve
keep if converged == 1 & rc_cmd == 0
save "$OUT\med4way_all_parameters_successonly.dta", replace
export delimited using "$OUT\med4way_all_parameters_successonly.csv", replace
export excel using "$OUT\med4way_all_parameters_successonly.xlsx", firstrow(variables) replace
restore

***********************************************************************************************

################################################################################
# Heatmaps for MCI + dementia outcome only (PDF OUTPUT)
# Separate plots for:
#   - Reduced
#   - Full
#   - Age & Sex
################################################################################

library(tidyverse)
setwd("D://16GBBACKUPUSB//BACKUP_USB_SEPTEMBER2014//SUMMER_STUDENT_2026//HRS_DIET_FRAILTY_COG//OUTPUT")


#------------------------------------------------------------------------------
# 1. Read data
#------------------------------------------------------------------------------
dat <- read_csv("med4way_all_parameters.csv", show_col_types = FALSE)

#------------------------------------------------------------------------------
# 2. Restrict to MCI + dementia outcome
#------------------------------------------------------------------------------
d_outcome <- dat %>%
  filter(str_detect(outcome, regex("mci.*dementia|cind.*dementia", ignore_case = TRUE)))

#------------------------------------------------------------------------------
# 3. Model definitions
#------------------------------------------------------------------------------
model_map <- tribble(
  ~modeltag,           ~model_label,
  "TABLES2_REDUCED",   "Reduced",
  "TABLE5_FULL",       "Full",
  "TABLES2_AGESEX",    "AgeSex"
)

#------------------------------------------------------------------------------
# 4. Parameter mapping
#------------------------------------------------------------------------------
param_map <- tribble(
  ~prefix,          ~parameter,
  "tereri",         "te",
  "ereri_cde",      "cde",
  "ereri_intref",   "intref",
  "ereri_intmed",   "intmed",
  "ereri_pie",      "pie",
  "op_m",           "m",
  "op_ati",         "ati",
  "op_e",           "e"
)

#------------------------------------------------------------------------------
# 5. Convert to long format
#------------------------------------------------------------------------------
make_long <- function(df) {
  
  bind_rows(lapply(seq_len(nrow(param_map)), function(i) {
    
    pref <- param_map$prefix[i]
    parm <- param_map$parameter[i]
    
    tibble(
      mediator  = df$mediator,
      parameter = parm,
      estimate  = df[[paste0(pref, "_b")]],
      p_value   = df[[paste0(pref, "_p")]]
    )
  })) %>%
    mutate(
      sig = case_when(
        is.na(p_value)  ~ "",
        p_value < 0.001 ~ "***",
        p_value < 0.01  ~ "**",
        p_value < 0.05  ~ "*",
        TRUE            ~ ""
      ),
      parameter = factor(parameter,
                         levels = c("te","cde","intref","intmed","pie","m","ati","e")),
      diet_var = mediator %>%
        str_remove("^z") %>%
        str_remove("_FF_13$")
    )
}

#------------------------------------------------------------------------------
# 6. Plot function (journal-style)
#------------------------------------------------------------------------------
plot_heatmap <- function(df, title) {
  
  if (nrow(df) == 0) return(NULL)
  
  lim <- max(abs(df$estimate), na.rm = TRUE)
  
  ggplot(df, aes(parameter, diet_var, fill = estimate)) +
    geom_tile(color = "white", linewidth = 0.25) +
    geom_text(aes(label = sig), size = 3.5) +
    scale_fill_gradient2(
      low = "#2166AC",
      mid = "white",
      high = "#B2182B",
      midpoint = 0,
      limits = c(-lim, lim),
      name = "β"
    ) +
    labs(
      title = title,
      x = "Parameter",
      y = "Dietary variable"
    ) +
    theme_minimal(base_size = 12) +
    theme(
      panel.grid = element_blank(),
      axis.text.x = element_text(angle = 45, hjust = 1),
      plot.title = element_text(face = "bold")
    )
}

#------------------------------------------------------------------------------
# 7. Main loop
#------------------------------------------------------------------------------
results <- list()

for (i in seq_len(nrow(model_map))) {
  
  tag  <- model_map$modeltag[i]
  name <- model_map$model_label[i]
  
  df_model <- d_outcome %>% filter(modeltag == tag)
  d_long   <- make_long(df_model)
  
  # Selection rules
  interaction_vars <- d_long %>%
    filter(parameter %in% c("intref","intmed","ati"),
           !is.na(p_value), p_value < 0.05) %>%
    distinct(diet_var) %>%
    pull()
  
  mediation_vars <- d_long %>%
    filter(parameter %in% c("pie","intmed","m"),
           !is.na(p_value), p_value < 0.05) %>%
    distinct(diet_var) %>%
    pull()
  
  # Keep ALL parameters after selection
  fig4 <- d_long %>% filter(diet_var %in% interaction_vars)
  figS1 <- d_long %>% filter(diet_var %in% mediation_vars)
  
  p4 <- plot_heatmap(
    fig4,
    paste0("Figure 4 (", name, "): Interaction-selected dietary variables\nMCI + dementia outcome")
  )
  
  pS1 <- plot_heatmap(
    figS1,
    paste0("Figure S1 (", name, "): Mediation-selected dietary variables\nMCI + dementia outcome")
  )
  
  results[[name]] <- list(p4 = p4, pS1 = pS1)
}

#------------------------------------------------------------------------------
# 8. SAVE AS PDFs (journal-ready)
#------------------------------------------------------------------------------
save_pdf <- function(plot, filename) {
  if (!is.null(plot)) {
    ggsave(
      filename,
      plot,
      device = cairo_pdf,   # ensures high-quality fonts
      width = 12,
      height = 8
    )
  }
}

# Reduced
save_pdf(results$Reduced$p4,  "Figure4_MCI_Dementia_Reduced.pdf")
save_pdf(results$Reduced$pS1, "FigureS1_MCI_Dementia_Reduced.pdf")

# Full
save_pdf(results$Full$p4,     "Figure4_MCI_Dementia_Full.pdf")
save_pdf(results$Full$pS1,    "FigureS1_MCI_Dementia_Full.pdf")

# Age & Sex
save_pdf(results$AgeSex$p4,   "Figure4_MCI_Dementia_AgeSex.pdf")
save_pdf(results$AgeSex$pS1,  "FigureS1_MCI_Dementia_AgeSex.pdf")

################################################################################
# DONE
################################################################################


*****************************FIGURE S2***************************************

********************************************************************************
** SECTION 11. HELPER PROGRAM FOR FIGURE S2
********************************************************************************

capture program drop make_cumhaz_2panel
program define make_cumhaz_2panel
    syntax , STFAIL(string) EVENTDATE(string) LOGFILE(string) ///
             PNGFILE(string) PDFFILE(string) FIGTITLE(string)

    capture log close
    log using `"`logfile'"', text replace

    use "$DATA\HRS_HEI_FRAIL_ANALYTIC_FINALfin.dta", clear
    keep if sample_final==1

    stset `eventdate', origin(time doenter) enter(time doenter) ///
          failure(`stfail') id(HHIDPN) scale(365.25)

    capture drop hei_q
    xtile hei_q = hei2015_total_score if hei2015_total_score < ., nq(4)
    capture label drop hei_q
    label define hei_q 1 "Q1 (lowest)" 2 "Q2" 3 "Q3" 4 "Q4 (highest)"
    label values hei_q hei_q

    capture drop frail_cat
    gen frail_cat = .
    replace frail_cat = 1 if fried_sum==0
    replace frail_cat = 2 if inrange(fried_sum,1,2)
    replace frail_cat = 3 if fried_sum>=3 & fried_sum<.
    capture label drop frail_cat
    label define frail_cat 1 "Robust (0)" 2 "Pre-frail (1-2)" 3 "Frail (>=3)"
    label values frail_cat frail_cat

    local c1 navy
    local c2 teal
    local c3 orange
    local c4 maroon

    local f1 "navy%16"
    local f2 "teal%16"
    local f3 "orange%16"
    local f4 "maroon%16"

    global GOPT ///
        xlabel(0(1)6, labsize(small) nogrid) ///
        xscale(range(0 6)) ///
        xtitle("Years since baseline", size(small)) ///
        legend(rows(1) ring(0) pos(2) size(vsmall) region(lcolor(none))) ///
        graphregion(color(white)) ///
        plotregion(color(white) margin(small))

    preserve
        keep if !missing(hei_q)
        capture drop ch lo hi
        sts generate ch = na, by(hei_q)
        sts generate lo = lb(na), by(hei_q)
        sts generate hi = ub(na), by(hei_q)
        keep if inrange(_t, 0, 6)
        replace lo = 0 if lo < 0

        quietly summarize hi
        local ymax = r(max)
        if `ymax' < . {
            local ymax = ceil(`ymax'*10)/10
        }
        else local ymax = 0.5

        twoway ///
            (rarea hi lo _t if hei_q==1, sort fcolor(`f1') lcolor(none)) ///
            (rarea hi lo _t if hei_q==2, sort fcolor(`f2') lcolor(none)) ///
            (rarea hi lo _t if hei_q==3, sort fcolor(`f3') lcolor(none)) ///
            (rarea hi lo _t if hei_q==4, sort fcolor(`f4') lcolor(none)) ///
            (lowess ch _t if hei_q==1, bwidth(.30) lcolor(`c1') lpattern(solid) lwidth(medthick)) ///
            (lowess ch _t if hei_q==2, bwidth(.30) lcolor(`c2') lpattern(solid) lwidth(medthick)) ///
            (lowess ch _t if hei_q==3, bwidth(.30) lcolor(`c3') lpattern(solid) lwidth(medthick)) ///
            (lowess ch _t if hei_q==4, bwidth(.30) lcolor(`c4') lpattern(solid) lwidth(medthick)) ///
            , ///
            title("A. HEI-2015 quartiles", size(medsmall)) ///
            ytitle("Cumulative hazard", size(small)) ///
            ylabel(, labsize(small) angle(horizontal)) ///
            yscale(range(0 `ymax')) ///
            legend(order(5 "Q1" 6 "Q2" 7 "Q3" 8 "Q4") cols(2)) ///
            $GOPT ///
            name(fig_hei, replace)
    restore

    preserve
        keep if !missing(frail_cat)
        capture drop ch lo hi
        sts generate ch = na, by(frail_cat)
        sts generate lo = lb(na), by(frail_cat)
        sts generate hi = ub(na), by(frail_cat)
        keep if inrange(_t, 0, 6)
        replace lo = 0 if lo < 0

        quietly summarize hi
        local ymax = r(max)
        if `ymax' < . {
            local ymax = ceil(`ymax'*10)/10
        }
        else local ymax = 0.5

        twoway ///
            (rarea hi lo _t if frail_cat==1, sort fcolor(`f1') lcolor(none)) ///
            (rarea hi lo _t if frail_cat==2, sort fcolor(`f2') lcolor(none)) ///
            (rarea hi lo _t if frail_cat==3, sort fcolor(`f3') lcolor(none)) ///
            (lowess ch _t if frail_cat==1, bwidth(.30) lcolor(`c1') lpattern(solid) lwidth(medthick)) ///
            (lowess ch _t if frail_cat==2, bwidth(.30) lcolor(`c2') lpattern(solid) lwidth(medthick)) ///
            (lowess ch _t if frail_cat==3, bwidth(.30) lcolor(`c3') lpattern(solid) lwidth(medthick)) ///
            , ///
            title("B. Frailty categories", size(medsmall)) ///
            ytitle("Cumulative hazard", size(small)) ///
            ylabel(, labsize(small) angle(horizontal)) ///
            yscale(range(0 `ymax')) ///
            legend(order(4 "Robust" 5 "Pre-frail" 6 "Frail") cols(2)) ///
            $GOPT ///
            name(fig_frail, replace)
    restore

    graph combine ///
        fig_hei fig_frail, ///
        cols(2) ///
        imargin(vsmall) ///
        title("`figtitle'", size(medsmall)) ///
        graphregion(color(white)) ///
        xsize(10) ysize(5) ///
        name(FigureS2_smooth_cumhaz, replace)

    graph export `"`pngfile'"', replace width(3200)
    graph export `"`pdffile'"', replace

    capture log close
end

********************************************************************************
** SECTION 12. FIGURES
********************************************************************************

make_cumhaz_2panel, ///
    stfail("fail_cog==1") ///
    eventdate("doevent") ///
    logfile("$OUT\FIGURE_S2_SMOOTHED_CUMHAZ.txt") ///
    pngfile("$OUT\FIGURE_S2_SMOOTHED_CUMHAZ.png") ///
    pdffile("$OUT\FIGURE_S2_SMOOTHED_CUMHAZ.pdf") ///
    figtitle("Combined outcome")

make_cumhaz_2panel, ///
    stfail("fail_mci==1") ///
    eventdate("doevent_mci") ///
    logfile("$OUT\FIGURE_S2_MCIONLY_SMOOTHED_CUMHAZ.txt") ///
    pngfile("$OUT\FIGURE_S2_MCIONLY_SMOOTHED_CUMHAZ.png") ///
    pdffile("$OUT\FIGURE_S2_MCIONLY_SMOOTHED_CUMHAZ.pdf") ///
    figtitle("MCI/CIND only")

make_cumhaz_2panel, ///
    stfail("fail_dem==1") ///
    eventdate("doevent_dem") ///
    logfile("$OUT\FIGURE_S2_DEMONLY_SMOOTHED_CUMHAZ.txt") ///
    pngfile("$OUT\FIGURE_S2_DEMONLY_SMOOTHED_CUMHAZ.png") ///
    pdffile("$OUT\FIGURE_S2_DEMONLY_SMOOTHED_CUMHAZ.pdf") ///
    figtitle("Probable dementia only")

capture log close

********************************************************************************
** SECTION 13. HELPER PROGRAM FOR WEIGHTED COX-BASED GLOBAL TESTS
********************************************************************************

capture program drop run_weighted_group_tests
program define run_weighted_group_tests
    syntax , STFAIL(string) EVENTDATE(string) LOGFILE(string) OUTCOME(string)

    capture log close
    log using `"`logfile'"', text replace

    use "$DATA\HRS_HEI_FRAIL_ANALYTIC_FINALfin.dta", clear
    keep if sample_final==1

    svyset secu [pweight=HCNSWGTR_NT], strata(stratum) singleunit(centered)

    stset `eventdate', origin(time doenter) enter(time doenter) ///
          failure(`stfail') id(HHIDPN) scale(365.25)

    capture drop hei_q
    xtile hei_q = hei2015_total_score if hei2015_total_score < ., nq(4)
    capture label drop hei_q
    label define hei_q 1 "Q1 (lowest)" 2 "Q2" 3 "Q3" 4 "Q4 (highest)"
    label values hei_q hei_q
    label var hei_q "HEI-2015 quartiles"

    capture drop frail_cat
    gen frail_cat = .
    replace frail_cat = 1 if fried_sum==0
    replace frail_cat = 2 if inrange(fried_sum,1,2)
    replace frail_cat = 3 if fried_sum>=3 & fried_sum<.
    capture label drop frail_cat
    label define frail_cat 1 "Robust (0)" 2 "Pre-frail (1-2)" 3 "Frail (>=3)"
    label values frail_cat frail_cat
    label var frail_cat "Frailty categories"

    display "=============================================================="
    display "WEIGHTED COX-BASED GLOBAL TESTS FOR FIGURE S2"
    display "Outcome: `outcome'"
    display "Reference group for each categorical variable = lowest-risk group"
    display "=============================================================="

    display " "
    display "--------------------------------------------------------------"
    display "HEI-2015 quartiles"
    display "--------------------------------------------------------------"
    svy: stcox i.hei_q
    testparm i.hei_q
    display "Trend test:"
    svy: stcox c.hei_q
    lincom hei_q, eform

    display " "
    display "--------------------------------------------------------------"
    display "Frailty categories"
    display "--------------------------------------------------------------"
    svy: stcox i.frail_cat
    testparm i.frail_cat
    display "Trend test:"
    svy: stcox c.frail_cat
    lincom frail_cat, eform

	
	
	
	
    capture log close
end

********************************************************************************
** SECTION 14. WEIGHTED COX-BASED TESTS FOR ALL 3 OUTCOMES
********************************************************************************

run_weighted_group_tests, ///
    stfail("fail_cog==1") ///
    eventdate("doevent") ///
    logfile("$OUT\FIGURE_S2_TESTS_COGIMP.txt") ///
    outcome("Incident CIND / probable dementia")

run_weighted_group_tests, ///
    stfail("fail_mci==1") ///
    eventdate("doevent_mci") ///
    logfile("$OUT\FIGURE_S2_TESTS_MCIONLY.txt") ///
    outcome("Incident MCI / CIND only")

run_weighted_group_tests, ///
    stfail("fail_dem==1") ///
    eventdate("doevent_dem") ///
    logfile("$OUT\FIGURE_S2_TESTS_DEMONLY.txt") ///
    outcome("Incident probable dementia only")

capture log close


capture log close
capture log using "$OUT\DISCRETE_TIME_ABN_DATA_MANAGEMENT.log", text replace


********************************************************************************
********************************************************************************
*********************** ABN DATA MANAGEMENT ************************************
********************************************************************************
** DISCRETE-TIME ABN DATA MANAGEMENT
** Z-SCORED DIET QUALITY + FRAILTY + COGNITIVE IMPAIRMENT
**
** FIXED VERSION:
**   - 2012 covariates
**   - creates z-scores for:
**         hei2015_total_score
**         all heix* variables
**         all C*_FF_13 variables
**         fried_sum
**   - creates _pm versions for all dietary z-score variables
**   - uses GLOBAL macros for dietary lists so programs can see them
**   - carries all dietary _pm variables into ABN-ready files
********************************************************************************


********************************************************************************
** STEP 1. OPEN FINAL ANALYTIC FILE
********************************************************************************

use "$DATA\HRS_HEI_FRAIL_ANALYTIC_FINALfin.dta", clear

capture confirm variable sample_final
if !_rc {
    keep if sample_final==1
}

compress

********************************************************************************
** STEP 2. CREATE CORE ABN-ORDERED BASELINE VARIABLES
********************************************************************************

capture drop id
gen id = HHIDPN
label var id "Unique respondent ID"

capture drop AGE
gen AGE = r11agey_e if r11agey_e < .
label var AGE "Age in years, 2012"

capture drop SEX
gen SEX = .
replace SEX = 1 if ragender==2
replace SEX = 0 if ragender==1
label define sexlbl 0 "Male" 1 "Female", replace
label values SEX sexlbl
label var SEX "Female"

capture drop NHB HISP OTHER
gen NHB   = (RACE_ETHN==2) if RACE_ETHN < .
gen HISP  = (RACE_ETHN==3) if RACE_ETHN < .
gen OTHER = (RACE_ETHN==4) if RACE_ETHN < .
label var NHB   "Non-Hispanic Black"
label var HISP  "Hispanic"
label var OTHER "Other race/ethnicity"

capture drop married_2012
gen married_2012 = .
replace married_2012 = 1 if marital_2012==2
replace married_2012 = 0 if inlist(marital_2012,1,3,4)
label define married_bin 0 "Not married" 1 "Married/partnered", replace
label values married_2012 married_bin
label var married_2012 "Married/partnered vs not, 2012"

********************************************************************************
** STEP 3. CHECK REQUIRED MAIN VARIABLES
********************************************************************************

capture confirm variable hei2015_total_score
if _rc {
    di as error "Variable hei2015_total_score not found."
    exit 111
}
label var hei2015_total_score "HEI-2015 total score"

capture confirm variable fried_sum
if _rc {
    di as error "Variable fried_sum not found."
    exit 111
}
label var fried_sum "Frailty score"

********************************************************************************
** STEP 4. BUILD RAW DIET VARIABLE LIST
** Includes:
**   - hei2015_total_score
**   - heix*
**   - C*_FF_13
********************************************************************************

global RAWDIETVARS hei2015_total_score

capture unab HEI_RAW : heix*
if !_rc global RAWDIETVARS $RAWDIETVARS `HEI_RAW'

capture unab FOOD_RAW : C*_FF_13
if !_rc global RAWDIETVARS $RAWDIETVARS `FOOD_RAW'

local tmp : list uniq global(RAWDIETVARS)
global RAWDIETVARS `tmp'

di as txt "Raw diet variables identified:"
di as result "$RAWDIETVARS"

foreach v of global RAWDIETVARS {
    capture confirm variable `v'
    if _rc {
        di as error "Expected raw dietary variable not found: `v'"
        exit 111
    }
}

********************************************************************************
** STEP 5. CREATE Z-SCORES FOR ALL DIET VARIABLES + FRAILTY
********************************************************************************

foreach v of global RAWDIETVARS {
    capture drop z`v'
    egen z`v' = std(`v')
    label var z`v' "`v' (z-score)"
}

capture drop zfried_sum
egen zfried_sum = std(fried_sum)
label var zfried_sum "Fried frailty score (z-score)"

********************************************************************************
** STEP 6. BUILD Z-SCORED DIET VARIABLE LIST
********************************************************************************

global DIETVARS
foreach v of global RAWDIETVARS {
    capture confirm variable z`v'
    if !_rc global DIETVARS $DIETVARS z`v'
}

local tmp : list uniq global(DIETVARS)
global DIETVARS `tmp'

di as txt "Z-scored dietary variables identified for ABN:"
di as result "$DIETVARS"

foreach v of global DIETVARS {
    capture confirm variable `v'
    if _rc {
        di as error "Expected z-scored dietary variable not found: `v'"
        exit 111
    }
}

********************************************************************************
** STEP 7. CREATE SES FACTOR SCORE USING 2012 WEALTH
********************************************************************************

capture drop zeduc zwealth ses_2012_raw zses_2012

egen zeduc   = std(education)
egen zwealth = std(totwealth_2012)

factor zeduc zwealth, pcf factors(1)

capture drop ses_2012_raw
predict ses_2012_raw if e(sample)

egen zses_2012 = std(ses_2012_raw)
label var zses_2012 "SES factor score from education and 2012 wealth (z-score)"

********************************************************************************
** STEP 8. LABEL / CHECK 2012 COVARIATES
********************************************************************************

label var smoking_2012      "Smoking status, 2012"
label var alcohol_2012      "Alcohol use, 2012"
label var bmibr_2012        "BMI category, 2012"
label var physic_act_2012   "Physical activity, 2012"
label var hbp_ever_2012     "Hypertension, 2012"
label var diab_ever_2012    "Diabetes, 2012"
label var heart_ever_2012   "Heart disease, 2012"
label var stroke_ever_2012  "Stroke, 2012"
label var srh_2012          "Self-rated health, 2012"
label var fried_sum         "Fried frailty score"

********************************************************************************
** STEP 9. PERCENTILE-MEDIAN DISCRETIZATION
** Applied to:
**   AGE
**   zses_2012
**   all dietary z-score variables
**   fried_sum
********************************************************************************

global PMVARS AGE zses_2012 $DIETVARS fried_sum
local tmp : list uniq global(PMVARS)
global PMVARS `tmp'

di as txt "Variables to percentile-median discretize:"
di as result "$PMVARS"

foreach x of global PMVARS {

    capture confirm variable `x'
    if _rc {
        di as error "Cannot discretize missing variable: `x'"
        exit 111
    }

    capture drop `x'br `x'_median `x'_pm

    xtile `x'br = `x' if `x' < ., nq(100)
    bysort `x'br: egen `x'_median = median(`x')
    gen `x'_pm = round(`x'_median, 0.01) if `x' < .

    label var `x'_pm "`x' percentile-median discretized"
}

********************************************************************************
** STEP 10. BUILD LIST OF ALL DIETARY _PM VARIABLES
********************************************************************************

global DIETPMVARS
foreach v of global DIETVARS {
    capture confirm variable `v'_pm
    if !_rc global DIETPMVARS $DIETPMVARS `v'_pm
}

local tmp : list uniq global(DIETPMVARS)
global DIETPMVARS `tmp'

di as txt "Dietary _pm variables identified:"
di as result "$DIETPMVARS"

foreach v of global DIETPMVARS {
    capture confirm variable `v'
    if _rc {
        di as error "Expected dietary _pm variable not found: `v'"
        exit 111
    }
}

********************************************************************************
** STEP 11. SAVE BASELINE WORKING FILE
********************************************************************************

save "$DATA\HRS_DIET_FRAILTY_BASELINE_FOR_DISCRETE_ABN.dta", replace

********************************************************************************
** PROGRAM TO CREATE PERSON-PERIOD DATASET
********************************************************************************

capture program drop make_discrete_file
program define make_discrete_file
    syntax , OUTCOME(string) OUTFILE(string)

    use "$DATA\HRS_DIET_FRAILTY_BASELINE_FOR_DISCRETE_ABN.dta", clear

    keep if cogfunction2016==1

    capture drop ev18 ev20 ev22 d_outcome

    if "`outcome'"=="mcidem" {
        gen ev18 = (cogfunction2018>1 & cogfunction2018<.) if cogfunction2016==1

        gen ev20 = 0 if cogfunction2016==1
        replace ev20 = 1 if ///
            (cogfunction2018==1 | missing(cogfunction2018)) & ///
             cogfunction2020>1 & cogfunction2020<.

        gen ev22 = 0 if cogfunction2016==1
        replace ev22 = 1 if ///
            (cogfunction2018==1 | missing(cogfunction2018)) & ///
            (cogfunction2020==1 | missing(cogfunction2020)) & ///
             cogfunction2022>1 & cogfunction2022<.

        local dlabel "Incident MCI/CIND or dementia"
    }

    if "`outcome'"=="mci" {
        gen ev18 = (cogfunction2018==2) if cogfunction2016==1

        gen ev20 = 0 if cogfunction2016==1
        replace ev20 = 1 if ///
            (cogfunction2018==1 | missing(cogfunction2018)) & ///
             cogfunction2020==2

        gen ev22 = 0 if cogfunction2016==1
        replace ev22 = 1 if ///
            (cogfunction2018==1 | missing(cogfunction2018)) & ///
            (cogfunction2020==1 | missing(cogfunction2020)) & ///
             cogfunction2022==2

        local dlabel "Incident MCI/CIND only"
    }

    if "`outcome'"=="dem" {
        gen ev18 = (cogfunction2018==3) if cogfunction2016==1

        gen ev20 = 0 if cogfunction2016==1
        replace ev20 = 1 if ///
            (cogfunction2018<3 | missing(cogfunction2018)) & ///
             cogfunction2020==3

        gen ev22 = 0 if cogfunction2016==1
        replace ev22 = 1 if ///
            (cogfunction2018<3 | missing(cogfunction2018)) & ///
            (cogfunction2020<3 | missing(cogfunction2020)) & ///
             cogfunction2022==3

        local dlabel "Incident dementia only"
    }

    expand 3
    bysort id: gen period = _n

    gen d_outcome = 0
    replace d_outcome = 1 if period==1 & ev18==1
    replace d_outcome = 1 if period==2 & ev20==1
    replace d_outcome = 1 if period==3 & ev22==1
    label var d_outcome "`dlabel'"

    bysort id (period): gen cum_event = sum(d_outcome)
    drop if _n>1 & cum_event[_n-1]>0
    drop cum_event

    capture drop t2 t3
    gen t2 = (period==2)
    gen t3 = (period==3)
    label var t2 "2018-2020 interval"
    label var t3 "2020-2022 interval"

    save "`outfile'", replace
end

********************************************************************************
** STEP 12. CREATE THREE DISCRETE-TIME FILES
********************************************************************************

make_discrete_file, outcome(mcidem) ///
    outfile("$DATA\HRS_DISCRETE_MCIDEM_FULL.dta")

make_discrete_file, outcome(mci) ///
    outfile("$DATA\HRS_DISCRETE_MCI_FULL.dta")

make_discrete_file, outcome(dem) ///
    outfile("$DATA\HRS_DISCRETE_DEM_FULL.dta")

********************************************************************************
** PROGRAM TO SAVE ABN-READY FILE
********************************************************************************

capture program drop save_abn_ready
program define save_abn_ready
    syntax , INFILE(string) OUTFILE(string)

    use "`infile'", clear

    keep id HHIDPN period t2 t3 d_outcome ///
         AGE_pm SEX NHB HISP OTHER ///
         zses_2012_pm married_2012 ///
         smoking_2012 alcohol_2012 ///
         bmibr_2012 physic_act_2012 ///
         hbp_ever_2012 diab_ever_2012 heart_ever_2012 stroke_ever_2012 srh_2012 ///
         $DIETPMVARS fried_sum_pm

    order id HHIDPN period t2 t3 d_outcome ///
          AGE_pm SEX NHB HISP OTHER ///
          zses_2012_pm married_2012 ///
          smoking_2012 alcohol_2012 ///
          bmibr_2012 physic_act_2012 ///
          hbp_ever_2012 diab_ever_2012 heart_ever_2012 stroke_ever_2012 srh_2012 ///
          $DIETPMVARS fried_sum_pm

    compress
    save "`outfile'", replace
end

********************************************************************************
** STEP 13. SAVE ABN-READY FILES
********************************************************************************

save_abn_ready, ///
    infile("$DATA\HRS_DISCRETE_MCIDEM_FULL.dta") ///
    outfile("$DATA\HRS_ABN_MCIDEM_READY.dta")

save_abn_ready, ///
    infile("$DATA\HRS_DISCRETE_MCI_FULL.dta") ///
    outfile("$DATA\HRS_ABN_MCI_READY.dta")

save_abn_ready, ///
    infile("$DATA\HRS_DISCRETE_DEM_FULL.dta") ///
    outfile("$DATA\HRS_ABN_DEM_READY.dta")

********************************************************************************
** STEP 14. QUICK CHECKS
********************************************************************************

use "$DATA\HRS_DIET_FRAILTY_BASELINE_FOR_DISCRETE_ABN.dta", clear
describe $DIETVARS
describe $DIETPMVARS
summ AGE_pm zses_2012_pm fried_sum_pm $DIETPMVARS

use "$DATA\HRS_ABN_MCIDEM_READY.dta", clear
tab period
tab d_outcome
describe $DIETPMVARS
summ AGE_pm zses_2012_pm fried_sum_pm $DIETPMVARS

use "$DATA\HRS_ABN_MCI_READY.dta", clear
tab period
tab d_outcome
describe $DIETPMVARS
summ AGE_pm zses_2012_pm fried_sum_pm $DIETPMVARS

use "$DATA\HRS_ABN_DEM_READY.dta", clear
tab period
tab d_outcome
describe $DIETPMVARS
summ AGE_pm zses_2012_pm fried_sum_pm $DIETPMVARS

capture log close

###############################################################################
# ABN SCRIPT: HRS z-scored HEI total score, HEI components, and food groups
# FIXED VERSION:
#   - 2012 covariates only
#   - loops over all z-scored dietary variables:
#       * zhei2015_total_score_pm
#       * zheix*_pm
#       * zC*_FF_13_pm
#   - EXCLUDES any variable containing:
#       * 16BM1
#       * 16BM2
#       * 16BM3
#   - separate output folder for each dietary variable
#   - separate outcome folders retained (DEMMCI / DEM / MCI)
#   - robust data.dists construction
###############################################################################

rm(list = ls())

suppressPackageStartupMessages({
  library(abn)
  library(haven)
  library(Rgraphviz)
  library(graph)
  library(grid)
  library(grDevices)
})

###############################################################################
# 1. HELPERS
###############################################################################

make_numeric <- function(x, varname = NULL) {
  out <- suppressWarnings(as.numeric(as.character(x)))
  if (all(is.na(out)) && any(!is.na(x))) {
    stop("Could not convert ", varname, " to numeric.")
  }
  out
}

make_bin_factor <- function(x, varname) {
  x_chr <- as.character(x)
  x_chr[x_chr %in% c("", "NA", "<NA>")] <- NA
  
  ux <- sort(unique(x_chr[!is.na(x_chr)]))
  if (length(ux) != 2) {
    stop(
      "Variable ", varname,
      " assigned as binomial but has ", length(ux),
      " unique non-missing values: ",
      paste(ux, collapse = ", ")
    )
  }
  
  message("Binary recode for ", varname, ": ", ux[1], " | ", ux[2])
  factor(x_chr, levels = ux)
}

extract_dag_matrix <- function(x) {
  if (is.matrix(x)) return(x)
  
  nms <- names(x)
  if (!is.null(nms)) {
    for (nm in c("dag", "dag.m", "dagM", "network", "amat")) {
      if (nm %in% nms) {
        obj <- x[[nm]]
        if (is.matrix(obj)) return(obj)
      }
    }
  }
  
  recurse_find_matrix <- function(obj) {
    if (is.matrix(obj)) return(obj)
    if (is.list(obj)) {
      for (i in seq_along(obj)) {
        ans <- recurse_find_matrix(obj[[i]])
        if (!is.null(ans)) return(ans)
      }
    }
    NULL
  }
  
  ans <- recurse_find_matrix(x)
  if (!is.null(ans)) return(ans)
  
  stop("Could not extract a DAG matrix from the ABN object.")
}

extract_scalar_score <- function(x) {
  if (!is.null(names(x))) {
    for (nm in c("score", "mlik", "loglik", "bic", "aic")) {
      if (nm %in% names(x)) {
        val <- x[[nm]]
        if (is.numeric(val) && length(val) == 1) return(as.numeric(val))
      }
    }
  }
  
  recurse_find_scalar <- function(obj) {
    if (is.numeric(obj) && length(obj) == 1) return(as.numeric(obj))
    if (is.list(obj)) {
      for (i in seq_along(obj)) {
        ans <- recurse_find_scalar(obj[[i]])
        if (!is.null(ans)) return(ans)
      }
    }
    NULL
  }
  
  ans <- recurse_find_scalar(x)
  if (!is.null(ans)) return(ans)
  
  NA_real_
}

sanitize_dag_matrix <- function(m, target_names) {
  if (!is.matrix(m)) stop("DAG object is not a matrix.")
  if (nrow(m) != ncol(m)) stop("DAG matrix is not square.")
  
  m <- as.matrix(m)
  
  if (is.null(rownames(m)) && !is.null(colnames(m))) rownames(m) <- colnames(m)
  if (is.null(colnames(m)) && !is.null(rownames(m))) colnames(m) <- rownames(m)
  
  if (is.null(rownames(m)) || is.null(colnames(m))) {
    stop("DAG matrix must have row and column names.")
  }
  
  if (!all(target_names %in% rownames(m)) || !all(target_names %in% colnames(m))) {
    stop("DAG matrix names do not match expected node names.")
  }
  
  m <- m[target_names, target_names, drop = FALSE]
  storage.mode(m) <- "numeric"
  m[m != 0] <- 1
  diag(m) <- 0
  m
}

get_abn_dag <- function(learned_obj, node_names) {
  amat_raw <- extract_dag_matrix(learned_obj)
  sanitize_dag_matrix(amat_raw, node_names)
}

get_parents <- function(amat_abn, child) {
  colnames(amat_abn)[amat_abn[child, ] == 1]
}

fit_local_model <- function(data, child, parents, dist_name) {
  if (length(parents) == 0) return(NULL)
  
  fml <- as.formula(paste(child, "~", paste(parents, collapse = " + ")))
  
  if (dist_name == "gaussian") {
    lm(fml, data = data)
  } else if (dist_name == "binomial") {
    glm(fml, data = data, family = binomial())
  } else {
    stop("Distribution not yet supported in local fit: ", dist_name)
  }
}

extract_parent_coef <- function(fit, parent) {
  cf <- coef(fit)
  nm <- names(cf)
  
  if (parent %in% nm) return(unname(cf[parent]))
  
  idx <- grep(
    paste0("^", gsub("([.|()\\^{}+$*?]|\\[|\\]|\\\\)", "\\\\\\1", parent)),
    nm
  )
  idx <- idx[nm[idx] != "(Intercept)"]
  
  if (length(idx) >= 1) return(unname(cf[idx[1]]))
  
  NA_real_
}

make_arc_df <- function(amat_abn) {
  arc_idx <- which(amat_abn == 1, arr.ind = TRUE)
  
  if (length(arc_idx) == 0 || nrow(arc_idx) == 0) {
    return(data.frame(
      from = character(0),
      to   = character(0),
      stringsAsFactors = FALSE
    ))
  }
  
  data.frame(
    from = colnames(amat_abn)[arc_idx[, 2]],
    to   = rownames(amat_abn)[arc_idx[, 1]],
    stringsAsFactors = FALSE
  )
}

build_edge_labels <- function(data, amat_abn, dist.list) {
  nodes <- rownames(amat_abn)
  out_list <- list()
  k <- 1
  
  for (child in nodes) {
    parents <- get_parents(amat_abn, child)
    if (length(parents) == 0) next
    
    dist_name <- dist.list[[child]]
    fit <- fit_local_model(data = data, child = child, parents = parents, dist_name = dist_name)
    
    for (parent in parents) {
      beta <- extract_parent_coef(fit, parent)
      lbl  <- if (is.na(beta)) "" else sprintf("%+.2f", beta)
      
      out_list[[k]] <- data.frame(
        from  = parent,
        to    = child,
        beta  = beta,
        label = lbl,
        stringsAsFactors = FALSE
      )
      k <- k + 1
    }
  }
  
  if (length(out_list) == 0) {
    return(data.frame(
      from  = character(0),
      to    = character(0),
      beta  = numeric(0),
      label = character(0),
      stringsAsFactors = FALSE
    ))
  }
  
  do.call(rbind, out_list)
}

make_graphNEL_from_abn <- function(amat_abn) {
  node_names <- rownames(amat_abn)
  gNEL <- new("graphNEL", nodes = node_names, edgemode = "directed")
  
  arc_df <- make_arc_df(amat_abn)
  
  if (nrow(arc_df) > 0) {
    for (i in seq_len(nrow(arc_df))) {
      gNEL <- addEdge(arc_df$from[i], arc_df$to[i], gNEL, 1)
    }
  }
  
  gNEL
}

plot_rgraphviz_abn <- function(amat_abn, edge_df, dist.list, file, main_title = NULL) {
  gNEL <- make_graphNEL_from_abn(amat_abn)
  node_names <- nodes(gNEL)
  
  shape_vec <- sapply(node_names, function(v) {
    if (dist.list[[v]] == "binomial") "box" else "ellipse"
  }, USE.NAMES = TRUE)
  
  fill_vec <- rep("white", length(node_names))
  names(fill_vec) <- node_names
  
  font_vec <- rep("Helvetica", length(node_names))
  names(font_vec) <- node_names
  
  fontsize_vec <- rep("16", length(node_names))
  names(fontsize_vec) <- node_names
  
  width_vec <- rep("1.40", length(node_names))
  names(width_vec) <- node_names
  
  height_vec <- rep("0.90", length(node_names))
  names(height_vec) <- node_names
  
  nAttrs <- list(
    shape     = as.list(shape_vec),
    fillcolor = as.list(fill_vec),
    fontname  = as.list(font_vec),
    fontsize  = as.list(fontsize_vec),
    width     = as.list(width_vec),
    height    = as.list(height_vec)
  )
  
  eAttrs <- list()
  if (nrow(edge_df) > 0) {
    edge_key <- paste(edge_df$from, edge_df$to, sep = "~")
    
    label_vec <- edge_df$label
    names(label_vec) <- edge_key
    
    edge_fontsize_vec <- rep("13", length(edge_key))
    names(edge_fontsize_vec) <- edge_key
    
    edge_fontname_vec <- rep("Helvetica", length(edge_key))
    names(edge_fontname_vec) <- edge_key
    
    eAttrs <- list(
      label    = as.list(label_vec),
      fontsize = as.list(edge_fontsize_vec),
      fontname = as.list(edge_fontname_vec)
    )
  }
  
  attrs <- list(
    graph = list(rankdir = "LR", fontsize = 20),
    node  = list(fixedsize = FALSE),
    edge  = list(arrowsize = 1.0)
  )
  
  pdf(file, width = 18, height = 12)
  
  plot_obj <- layoutGraph(
    gNEL,
    attrs     = attrs,
    nodeAttrs = nAttrs,
    edgeAttrs = eAttrs
  )
  
  renderGraph(plot_obj)
  
  if (!is.null(main_title)) {
    grid.text(main_title, y = unit(0.98, "npc"), gp = gpar(fontsize = 18))
  }
  
  dev.off()
}

check_parent_limit_plus2 <- function(amat_abn, default_max, outcome_node = "d_outcome") {
  n_parents <- rowSums(amat_abn)
  
  allowed <- setNames(rep(default_max, length(n_parents)), names(n_parents))
  if (outcome_node %in% names(allowed)) {
    allowed[outcome_node] <- default_max + 2
  }
  
  bad_nodes <- names(n_parents)[n_parents > allowed[names(n_parents)]]
  
  list(
    n_parents = n_parents,
    allowed   = allowed,
    max_found = max(n_parents),
    bad_nodes = bad_nodes
  )
}

sanitize_name <- function(x) {
  gsub("[^A-Za-z0-9_]+", "_", x)
}

###############################################################################
# 2. MAIN RUNNER
###############################################################################

run_abn_analysis <- function(data_file, out_dir, suffix, diet_var) {
  
  if (!dir.exists(out_dir)) dir.create(out_dir, recursive = TRUE)
  
  dat <- read_dta(data_file)
  dat <- as.data.frame(dat)
  dat <- zap_labels(dat)
  
  vars_use <- c(
    "d_outcome", "t2", "t3",
    "AGE_pm", "SEX", "NHB", "HISP", "OTHER",
    "zses_2012_pm", "married_2012",
    "smoking_2012", "alcohol_2012", "physic_act_2012",
    "bmibr_2012",
    "hbp_ever_2012", "diab_ever_2012", "heart_ever_2012", "stroke_ever_2012", "srh_2012",
    diet_var,
    "fried_sum_pm"
  )
  
  missing_vars <- setdiff(vars_use, names(dat))
  if (length(missing_vars) > 0) {
    stop("Missing variables in ", basename(data_file), ": ", paste(missing_vars, collapse = ", "))
  }
  
  dat2 <- dat[, vars_use, drop = FALSE]
  names(dat2) <- vars_use
  
  factor_vars <- c(
    "d_outcome", "t2", "t3",
    "SEX", "NHB", "HISP", "OTHER",
    "married_2012",
    "hbp_ever_2012", "diab_ever_2012", "heart_ever_2012", "stroke_ever_2012", "srh_2012"
  )
  
  numeric_vars <- c(
    "AGE_pm", "zses_2012_pm",
    "smoking_2012", "alcohol_2012", "physic_act_2012",
    "bmibr_2012",
    diet_var,
    "fried_sum_pm"
  )
  
  for (v in intersect(factor_vars, names(dat2))) {
    dat2[[v]] <- make_bin_factor(dat2[[v]], v)
  }
  
  for (v in intersect(numeric_vars, names(dat2))) {
    dat2[[v]] <- make_numeric(dat2[[v]], v)
  }
  
  dat2 <- dat2[complete.cases(dat2), , drop = FALSE]
  
  cat("Complete-case N for", diet_var, "and", suffix, "=", nrow(dat2), "\n")
  if (nrow(dat2) == 0) stop("No complete cases remain.")
  
  abndata <- as.data.frame(dat2)
  var_names <- colnames(abndata)
  
  if (anyDuplicated(var_names)) {
    stop("Duplicate variable names in abndata: ",
         paste(var_names[duplicated(var_names)], collapse = ", "))
  }
  
  data.dists <- setNames(as.list(rep(NA_character_, length(var_names))), var_names)
  
  bin_vars <- c(
    "d_outcome", "t2", "t3",
    "SEX", "NHB", "HISP", "OTHER",
    "married_2012",
    "hbp_ever_2012", "diab_ever_2012", "heart_ever_2012", "stroke_ever_2012", "srh_2012"
  )
  
  gauss_vars <- c(
    "AGE_pm", "zses_2012_pm",
    "smoking_2012", "alcohol_2012", "physic_act_2012",
    "bmibr_2012",
    diet_var,
    "fried_sum_pm"
  )
  
  bin_vars   <- intersect(bin_vars, var_names)
  gauss_vars <- intersect(gauss_vars, var_names)
  
  for (v in bin_vars)   data.dists[[v]] <- "binomial"
  for (v in gauss_vars) data.dists[[v]] <- "gaussian"
  
  missing_dist <- names(data.dists)[is.na(unlist(data.dists))]
  if (length(missing_dist) > 0) {
    stop("No distribution assigned for: ", paste(missing_dist, collapse = ", "))
  }
  
  data.dists <- data.dists[var_names]
  
  if (!identical(names(data.dists), var_names)) {
    stop(
      "data.dists names do not exactly match abndata columns.\n",
      "abndata: ", paste(var_names, collapse = ", "), "\n",
      "data.dists: ", paste(names(data.dists), collapse = ", ")
    )
  }
  
  banned <- matrix(0, nrow = ncol(abndata), ncol = ncol(abndata))
  rownames(banned) <- colnames(banned) <- names(abndata)
  
  demo_vars      <- c("AGE_pm", "SEX", "NHB", "HISP", "OTHER")
  ses_vars       <- c("zses_2012_pm")
  marital_vars   <- c("married_2012")
  lifestyle_vars <- c("smoking_2012", "alcohol_2012", "physic_act_2012")
  health_vars    <- c("bmibr_2012", "hbp_ever_2012", "diab_ever_2012",
                      "heart_ever_2012", "stroke_ever_2012", "srh_2012")
  exposure_vars  <- c(diet_var)
  frailty_vars   <- c("fried_sum_pm")
  time_vars      <- c("t2", "t3")
  outcome_vars   <- c("d_outcome")
  all_vars       <- names(abndata)
  
  for (v in demo_vars) {
    banned[v, setdiff(all_vars, v)] <- 1
  }
  
  banned[setdiff(all_vars, "d_outcome"), "d_outcome"] <- 1
  
  for (v in ses_vars) {
    banned[v, c(marital_vars, lifestyle_vars, health_vars, exposure_vars, frailty_vars, time_vars, outcome_vars)] <- 1
  }
  
  for (v in marital_vars) {
    banned[v, c(lifestyle_vars, health_vars, exposure_vars, frailty_vars, time_vars, outcome_vars)] <- 1
  }
  
  for (v in exposure_vars) {
    banned[v, c(frailty_vars, time_vars, outcome_vars)] <- 1
  }
  
  for (v in lifestyle_vars) {
    banned[v, c(frailty_vars, time_vars, outcome_vars)] <- 1
  }
  
  for (v in health_vars) {
    banned[v, c(frailty_vars, time_vars, outcome_vars)] <- 1
  }
  
  for (v in frailty_vars) {
    banned[v, c(time_vars, outcome_vars)] <- 1
  }
  
  for (v in time_vars) {
    banned[v, c(demo_vars, ses_vars, marital_vars, lifestyle_vars, health_vars,
                exposure_vars, frailty_vars, time_vars, outcome_vars)] <- 1
  }
  
  if (all(c("t2", "t3") %in% all_vars)) {
    banned["t2", "t3"] <- 1
  }
  
  for (tv in time_vars) {
    banned[tv, outcome_vars] <- 1
  }
  
  diag(banned) <- 0
  
  write.csv(
    banned,
    file = file.path(out_dir, paste0("ABN_banned_matrix_", suffix, "_", sanitize_name(diet_var), ".csv"))
  )
  
  max.parents.vec <- 1:4
  outcome_node <- "d_outcome"
  
  score.cache.list <- list()
  learned.list     <- list()
  fit.list         <- list()
  dag.list         <- list()
  arc_tables       <- list()
  edge_tables      <- list()
  parentcheck.list <- list()
  retain.list      <- list()
  maxparent.list   <- list()
  
  score.summary <- data.frame(
    max_parents_non_outcome = integer(0),
    max_parents_outcome     = integer(0),
    score                   = numeric(0),
    mlik                    = numeric(0),
    max_found               = integer(0),
    outcome_n_parents       = integer(0),
    n_retained              = integer(0),
    stringsAsFactors = FALSE
  )
  
  for (mp in max.parents.vec) {
    
    outcome_parent_cap <- mp + 2
    
    cat("\n====================================================\n")
    cat("Running ABN with diet =", diet_var,
        "| outcome =", suffix,
        "| non-outcome max.parents =", mp,
        "| d_outcome max.parents =", outcome_parent_cap, "\n")
    cat("====================================================\n")
    
    max.parents.use <- as.list(setNames(rep(mp, length(var_names)), var_names))
    max.parents.use[[outcome_node]] <- outcome_parent_cap
    
    retain_use <- matrix(0, nrow = ncol(abndata), ncol = ncol(abndata))
    rownames(retain_use) <- colnames(retain_use) <- names(abndata)
    
    for (tv in time_vars) {
      retain_use[outcome_node, tv] <- 1
    }
    
    diag(retain_use) <- 0
    
    conflicts <- which(banned == 1 & retain_use == 1, arr.ind = TRUE)
    if (nrow(conflicts) > 0) {
      retain_use[conflicts] <- 0
    }
    
    bayes_ctrl <- build.control(method = "bayes", max.mode.error = 0, ncores = 4)
    
    mycache <- buildScoreCache(
      data.df      = as.data.frame(abndata),
      data.dists   = data.dists,
      dag.banned   = banned,
      dag.retained = retain_use,
      max.parents  = max.parents.use,
      method       = "bayes",
      control      = bayes_ctrl
    )
    
    mydag <- searchHillClimber(score.cache = mycache)
    
    fabn <- fitAbn(
      object  = mydag,
      method  = "bayes",
      control = bayes_ctrl
    )
    
    dag_mat <- get_abn_dag(
      learned_obj = mydag,
      node_names  = colnames(abndata)
    )
    
    parent_check <- check_parent_limit_plus2(
      amat_abn     = dag_mat,
      default_max  = mp,
      outcome_node = outcome_node
    )
    
    if (length(parent_check$bad_nodes) > 0) {
      stop(
        "Parent limit exceeded. Offending nodes: ",
        paste(parent_check$bad_nodes, collapse = ", ")
      )
    }
    
    arc_df <- make_arc_df(dag_mat)
    
    edge_df <- build_edge_labels(
      data      = abndata,
      amat_abn  = dag_mat,
      dist.list = data.dists
    )
    
    score.cache.list[[paste0("mp", mp)]] <- mycache
    learned.list[[paste0("mp", mp)]]     <- mydag
    fit.list[[paste0("mp", mp)]]         <- fabn
    dag.list[[paste0("mp", mp)]]         <- dag_mat
    arc_tables[[paste0("mp", mp)]]       <- arc_df
    edge_tables[[paste0("mp", mp)]]      <- edge_df
    parentcheck.list[[paste0("mp", mp)]] <- parent_check
    retain.list[[paste0("mp", mp)]]      <- retain_use
    maxparent.list[[paste0("mp", mp)]]   <- max.parents.use
    
    current.score <- extract_scalar_score(mydag)
    current.mlik  <- if (!is.null(fabn$mlik)) as.numeric(fabn$mlik) else NA_real_
    
    score.summary <- rbind(
      score.summary,
      data.frame(
        max_parents_non_outcome = mp,
        max_parents_outcome     = outcome_parent_cap,
        score                   = current.score,
        mlik                    = current.mlik,
        max_found               = parent_check$max_found,
        outcome_n_parents       = unname(parent_check$n_parents[outcome_node]),
        n_retained              = sum(retain_use != 0),
        stringsAsFactors = FALSE
      )
    )
    
    write.csv(
      retain_use,
      file = file.path(out_dir, paste0("ABN_retain_matrix_", suffix, "_", sanitize_name(diet_var), "_mp", mp, "_OUTCOME_PLUS2.csv"))
    )
    
    write.csv(
      stack(max.parents.use),
      file = file.path(out_dir, paste0("ABN_nodewise_maxparents_", suffix, "_", sanitize_name(diet_var), "_mp", mp, "_OUTCOME_PLUS2.csv")),
      row.names = FALSE
    )
    
    pdf(
      file.path(out_dir, paste0("ABN_plotAbn_", suffix, "_", sanitize_name(diet_var), "_mp", mp, "_OUTCOME_PLUS2.pdf")),
      width = 14, height = 10
    )
    plotAbn(dag = mydag, labels = TRUE)
    dev.off()
    
    plot_rgraphviz_abn(
      amat_abn   = dag_mat,
      edge_df    = edge_df,
      dist.list  = data.dists,
      file       = file.path(out_dir, paste0("ABN_Rgraphviz_labeled_", suffix, "_", sanitize_name(diet_var), "_mp", mp, "_OUTCOME_PLUS2.pdf")),
      main_title = paste("ABN:", suffix, "|", diet_var, "| non-outcome max.parents =", mp,
                         "; d_outcome max.parents =", outcome_parent_cap)
    )
    
    write.csv(
      arc_df,
      file = file.path(out_dir, paste0("ABN_arcs_", suffix, "_", sanitize_name(diet_var), "_mp", mp, "_OUTCOME_PLUS2_parent_to_child.csv")),
      row.names = FALSE
    )
    
    write.csv(
      edge_df,
      file = file.path(out_dir, paste0("ABN_arcs_", suffix, "_", sanitize_name(diet_var), "_mp", mp, "_OUTCOME_PLUS2_with_effects.csv")),
      row.names = FALSE
    )
    
    write.csv(
      data.frame(
        child       = names(parent_check$n_parents),
        n_parents   = as.integer(parent_check$n_parents),
        allowed_max = as.integer(parent_check$allowed[names(parent_check$n_parents)]),
        stringsAsFactors = FALSE
      ),
      file = file.path(out_dir, paste0("ABN_parent_counts_", suffix, "_", sanitize_name(diet_var), "_mp", mp, "_OUTCOME_PLUS2.csv")),
      row.names = FALSE
    )
    
    save(
      mycache, mydag, fabn, retain_use, max.parents.use,
      file = file.path(out_dir, paste0("ABN_", suffix, "_", sanitize_name(diet_var), "_mp", mp, "_OUTCOME_PLUS2.RData"))
    )
  }
  
  print(score.summary)
  
  write.csv(
    score.summary,
    file = file.path(out_dir, paste0("ABN_score_summary_", suffix, "_", sanitize_name(diet_var), "_OUTCOME_PLUS2.csv")),
    row.names = FALSE
  )
  
  if (all(is.na(score.summary$mlik))) {
    best.idx <- if (all(is.na(score.summary$score))) 1 else which.max(score.summary$score)
  } else {
    best.idx <- which.max(score.summary$mlik)
  }
  
  best.mp <- score.summary$max_parents_non_outcome[best.idx]
  
  cat("\nBest model selected at non-outcome max.parents =", best.mp, "\n")
  
  best.amat    <- dag.list[[paste0("mp", best.mp)]]
  best.arc_df  <- arc_tables[[paste0("mp", best.mp)]]
  best.edge_df <- edge_tables[[paste0("mp", best.mp)]]
  best.pcheck  <- parentcheck.list[[paste0("mp", best.mp)]]
  best.retain  <- retain.list[[paste0("mp", best.mp)]]
  
  write.csv(
    best.arc_df,
    file = file.path(out_dir, paste0("ABN_best_arcs_", suffix, "_", sanitize_name(diet_var), "_mp", best.mp, "_OUTCOME_PLUS2_parent_to_child.csv")),
    row.names = FALSE
  )
  
  write.csv(
    best.edge_df,
    file = file.path(out_dir, paste0("ABN_best_arcs_", suffix, "_", sanitize_name(diet_var), "_mp", best.mp, "_OUTCOME_PLUS2_with_effects.csv")),
    row.names = FALSE
  )
  
  write.csv(
    data.frame(
      child       = names(best.pcheck$n_parents),
      n_parents   = as.integer(best.pcheck$n_parents),
      allowed_max = as.integer(best.pcheck$allowed[names(best.pcheck$n_parents)]),
      stringsAsFactors = FALSE
    ),
    file = file.path(out_dir, paste0("ABN_best_parent_counts_", suffix, "_", sanitize_name(diet_var), "_mp", best.mp, "_OUTCOME_PLUS2.csv")),
    row.names = FALSE
  )
  
  write.csv(
    best.retain,
    file = file.path(out_dir, paste0("ABN_best_retain_matrix_", suffix, "_", sanitize_name(diet_var), "_mp", best.mp, "_OUTCOME_PLUS2.csv"))
  )
  
  saveRDS(abndata,          file = file.path(out_dir, paste0("ABN_analysis_dataset_", suffix, "_", sanitize_name(diet_var), ".rds")))
  saveRDS(data.dists,       file = file.path(out_dir, paste0("ABN_dist_list_", suffix, "_", sanitize_name(diet_var), ".rds")))
  saveRDS(banned,           file = file.path(out_dir, paste0("ABN_banned_matrix_", suffix, "_", sanitize_name(diet_var), ".rds")))
  saveRDS(retain.list,      file = file.path(out_dir, paste0("ABN_retain_list_", suffix, "_", sanitize_name(diet_var), ".rds")))
  saveRDS(score.cache.list, file = file.path(out_dir, paste0("ABN_score_cache_list_", suffix, "_", sanitize_name(diet_var), ".rds")))
  saveRDS(learned.list,     file = file.path(out_dir, paste0("ABN_learned_list_", suffix, "_", sanitize_name(diet_var), ".rds")))
  saveRDS(fit.list,         file = file.path(out_dir, paste0("ABN_fit_list_", suffix, "_", sanitize_name(diet_var), ".rds")))
  saveRDS(dag.list,         file = file.path(out_dir, paste0("ABN_native_dag_list_", suffix, "_", sanitize_name(diet_var), ".rds")))
  saveRDS(arc_tables,       file = file.path(out_dir, paste0("ABN_arc_tables_", suffix, "_", sanitize_name(diet_var), ".rds")))
  saveRDS(edge_tables,      file = file.path(out_dir, paste0("ABN_edge_tables_", suffix, "_", sanitize_name(diet_var), ".rds")))
  saveRDS(parentcheck.list, file = file.path(out_dir, paste0("ABN_parentcheck_list_", suffix, "_", sanitize_name(diet_var), ".rds")))
  
  capture.output(
    str(score.cache.list),
    file = file.path(out_dir, paste0("ABN_cache_structure_", suffix, "_", sanitize_name(diet_var), ".txt"))
  )
  
  capture.output(
    str(learned.list),
    file = file.path(out_dir, paste0("ABN_learned_structure_", suffix, "_", sanitize_name(diet_var), ".txt"))
  )
  
  capture.output(
    str(fit.list),
    file = file.path(out_dir, paste0("ABN_fit_structure_", suffix, "_", sanitize_name(diet_var), ".txt"))
  )
  
  capture.output(
    str(dag.list),
    file = file.path(out_dir, paste0("ABN_native_dag_structure_", suffix, "_", sanitize_name(diet_var), ".txt"))
  )
  
  cat("\nAll outputs saved to:\n", out_dir, "\n")
  cat("Best model non-outcome max.parents =", best.mp, "\n")
  cat("Best model maximum observed parents =", max(rowSums(best.amat)), "\n")
  
  cat("\nArcs pointing INTO d_outcome in best model:\n")
  print(best.arc_df[best.arc_df$to == "d_outcome", , drop = FALSE])
  
  cat("\nArcs pointing INTO fried_sum_pm in best model:\n")
  print(best.arc_df[best.arc_df$to == "fried_sum_pm", , drop = FALSE])
  
  cat("\nArcs pointing INTO", diet_var, "in best model:\n")
  print(best.arc_df[best.arc_df$to == diet_var, , drop = FALSE])
  
  invisible(list(
    score.summary = score.summary,
    best.mp       = best.mp,
    best.amat     = best.amat,
    best.arc_df   = best.arc_df,
    best.edge_df  = best.edge_df
  ))
}

###############################################################################
# 3. DISCOVER ALL Z-SCORED DIET VARIABLES
###############################################################################

discover_diet_vars <- function(data_file) {
  dat0 <- read_dta(data_file)
  nm <- names(dat0)
  
  hei_total <- if ("zhei2015_total_score_pm" %in% nm) "zhei2015_total_score_pm" else character(0)
  hei_components <- grep("^zheix.*_pm$", nm, value = TRUE, ignore.case = TRUE)
  food_groups <- grep("^zC[A-Za-z0-9]+_FF_13_pm$", nm, value = TRUE)
  
  diet_vars <- unique(c(hei_total, hei_components, food_groups))
  diet_vars <- sort(diet_vars)
  
  cat("\nDiscovered dietary variables before exclusion:\n")
  print(diet_vars)
  
  diet_vars
}

###############################################################################
# 4. FILTER DIET VARIABLES
###############################################################################

filter_diet_vars <- function(diet_vars) {
  
  keep_main <- grepl("^zhei2015_total_score_pm$", diet_vars) |
    grepl("^zheix.*_pm$", diet_vars, ignore.case = TRUE) |
    grepl("^zC[A-Za-z0-9]+_FF_13_pm$", diet_vars)
  
  exclude_bad <- grepl("16BM1|16BM2|16BM3", diet_vars, ignore.case = TRUE)
  
  out <- diet_vars[keep_main & !exclude_bad]
  out <- sort(unique(out))
  
  cat("\nDietary variables after excluding 16BM1, 16BM2, 16BM3:\n")
  print(out)
  
  out
}

###############################################################################
# 5. RUN ANALYSES
###############################################################################

out_dir_main <- "D:/16GBBACKUPUSB/BACKUP_USB_SEPTEMBER2014/SUMMER_STUDENT_2026/HRS_DIET_FRAILTY_COG/OUTPUT/ABN_ZDIET_2012COV"

data_file_mcidem <- "D:/16GBBACKUPUSB/BACKUP_USB_SEPTEMBER2014/SUMMER_STUDENT_2026/HRS_DIET_FRAILTY_COG/FINAL_DATA/HRS_ABN_MCIDEM_READY.dta"
data_file_dem    <- "D:/16GBBACKUPUSB/BACKUP_USB_SEPTEMBER2014/SUMMER_STUDENT_2026/HRS_DIET_FRAILTY_COG/FINAL_DATA/HRS_ABN_DEM_READY.dta"
data_file_mci    <- "D:/16GBBACKUPUSB/BACKUP_USB_SEPTEMBER2014/SUMMER_STUDENT_2026/HRS_DIET_FRAILTY_COG/FINAL_DATA/HRS_ABN_MCI_READY.dta"

diet_vars <- discover_diet_vars(data_file_mcidem)
diet_vars <- filter_diet_vars(diet_vars)

cat("\nFinal diet variable list used in analysis:\n")
print(diet_vars)

if (length(diet_vars) == 0) {
  stop("No eligible z-scored dietary variables remained after exclusions.")
}

all_results <- list()

for (dv in diet_vars) {
  
  dv_safe <- sanitize_name(dv)
  dv_dir  <- file.path(out_dir_main, dv_safe)
  
  if (!dir.exists(dv_dir)) dir.create(dv_dir, recursive = TRUE)
  
  cat("\n############################################################\n")
  cat("Running all outcomes for diet variable:", dv, "\n")
  cat("Output folder:", dv_dir, "\n")
  cat("############################################################\n")
  
  res_DEMMCI <- run_abn_analysis(
    data_file = data_file_mcidem,
    out_dir   = file.path(dv_dir, "DEMMCI"),
    suffix    = "DEMMCI",
    diet_var  = dv
  )
  
  res_DEM <- run_abn_analysis(
    data_file = data_file_dem,
    out_dir   = file.path(dv_dir, "DEM"),
    suffix    = "DEM",
    diet_var  = dv
  )
  
  res_MCI <- run_abn_analysis(
    data_file = data_file_mci,
    out_dir   = file.path(dv_dir, "MCI"),
    suffix    = "MCI",
    diet_var  = dv
  )
  
  all_results[[dv]] <- list(
    DEMMCI = res_DEMMCI,
    DEM    = res_DEM,
    MCI    = res_MCI
  )
}

saveRDS(
  all_results,
  file = file.path(out_dir_main, "ABN_all_dietvars_all_outcomes_results_excluding_16BM1_16BM2_16BM3.rds")
)

cat("\nFinished all ABN runs.\n")
cat("Master output folder:\n", out_dir_main, "\n")

*******************GSEM STATA CODE AFTER ABN: 4 PARENTS/CHILD************************************************

********************************************************************************
* PROJECT: HRS diet quality, frailty, cognition
* PURPOSE: Build continuous-variable dataset from full analytic file and fit
*          ABN-informed GSEM models using Weibull survival
* NOTES:
*   1) Uses FULL analytic dataset, not ABN discretized file
*   2) Keeps continuous age, SES, HEI-2015, and frailty for GSEM
*   3) Uses 2012 covariates from revised do file
*   4) Removes neuropathological biomarker nodes
*   5) Keeps 2016 cognitively normal risk set and same cognitive outcomes
********************************************************************************

clear all
set more off
version 17.0

capture log close
log using ///
"D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_DIET_FRAILTY_COG\OUTPUT\GSEM_WEIBULL_DIET_FRAILTY_ABN.txt", ///
text replace

********************************************************************************
* 0. PATHS
********************************************************************************

global PROJ "D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_DIET_FRAILTY_COG"
global DATA "$PROJ\FINAL_DATA"
global OUT  "$PROJ\OUTPUT"

********************************************************************************
* 1. OPEN FULL ANALYTIC FILE
********************************************************************************

use "$DATA\HRS_HEI_FRAIL_ANALYTIC_FINALfin.dta", clear

capture confirm variable sample_final
if !_rc {
    keep if sample_final==1
}

compress

********************************************************************************
* 2. RESTRICT TO BASELINE COGNITIVELY NORMAL RISK SET
********************************************************************************

keep if cogfunction2016==1

capture drop id
gen id = HHIDPN
label var id "Unique respondent ID"

********************************************************************************
* 3. RECREATE ABN VARIABLES FOR GSEM
*    Keep continuous variables continuous
********************************************************************************

*-------------------------------*
* 3A. AGE (continuous)
*-------------------------------*
capture drop AGE_cont
gen AGE_cont = r13agey_e if r13agey_e < .
label var AGE_cont "Age in years at 2016 baseline"

*-------------------------------*
* 3B. SEX
*-------------------------------*
capture confirm variable SEX
if _rc {
    gen SEX = ragender if ragender < .
}
label var SEX "Sex"

*-------------------------------*
* 3C. RACE/ETHNICITY DUMMIES
* Assumes:
*   1 = NH White
*   2 = NH Black
*   3 = Hispanic
*   4 = Other
*-------------------------------*
capture drop NHB HISP OTHER
gen NHB   = (RACE_ETHN==2) if RACE_ETHN < .
gen HISP  = (RACE_ETHN==3) if RACE_ETHN < .
gen OTHER = (RACE_ETHN==4) if RACE_ETHN < .
label var NHB   "Non-Hispanic Black"
label var HISP  "Hispanic"
label var OTHER "Other race/ethnicity"

*-------------------------------*
* 3D. MARITAL STATUS
* Married/partnered vs not, from 2012 marital variable
*-------------------------------*
capture drop married_2012
gen married_2012 = .
replace married_2012 = 1 if marital_2012 == 2
replace married_2012 = 0 if inlist(marital_2012,1,3,4)
capture label drop married_bin
label define married_bin 0 "Not married" 1 "Married/partnered"
label values married_2012 married_bin
label var married_2012 "Married/partnered vs not, 2012"

*-------------------------------*
* 3E. SES FACTOR SCORE (continuous)
* Based on education + 2012 wealth
*-------------------------------*
capture drop zeduc zwealth ses_2012_raw zses_2012_cont
egen zeduc   = std(education)
egen zwealth = std(totwealth_2012)

factor zeduc zwealth, pcf factors(1)
predict ses_2012_raw if e(sample)
egen zses_2012_cont = std(ses_2012_raw)
label var zses_2012_cont "SES factor score, 2012 (continuous z-score)"

*-------------------------------*
* 3F. CONTINUOUS HEI-2015 AND FRAILTY NODES
*-------------------------------*
capture drop zhei2015_total_score_cont fried_sum_cont
gen zhei2015_total_score_cont = zhei2015_total_score if zhei2015_total_score < .
gen fried_sum_cont            = fried_sum            if fried_sum < .

label var zhei2015_total_score_cont "HEI-2015 total score (z-score, continuous)"
label var fried_sum_cont            "Fried frailty sum (continuous)"

*-------------------------------*
* 3G. LABEL OTHER BASELINE VARIABLES
*-------------------------------*
label var smoking_2012      "Smoking status, 2012"
label var alcohol_2012      "Alcohol use, 2012"
label var physic_act_2012   "Physical activity, 2012"
label var bmibr_2012        "BMI category, 2012"
label var hbp_ever_2012     "Hypertension, 2012"
label var diab_ever_2012    "Diabetes, 2012"
label var heart_ever_2012   "Heart disease, 2012"
label var stroke_ever_2012  "Stroke, 2012"
label var srh_2012          "Self-rated health, 2012"

save "$DATA\HRS_GSEM_WEIBULL_DIET_FRAILTY_WORKING.dta", replace

********************************************************************************
* 4. DATE VARIABLES FOR SURVIVAL SETUP
********************************************************************************

use "$DATA\HRS_GSEM_WEIBULL_DIET_FRAILTY_WORKING.dta", clear

*-------------------------------*
* 4A. DATE OF DEATH
*-------------------------------*
capture drop deathmonth
gen deathmonth = knowndeceasedmo
replace deathmonth = . if inlist(deathmonth,0,98,99)

capture drop deathyear
gen deathyear = knowndeceasedyr
replace deathyear = . if inlist(deathyear,0,9998,9999)

replace deathmonth = 6 if deathyear < . & missing(deathmonth)

capture drop deathday
gen deathday = 15 if deathyear < .

capture drop dod
gen dod = mdy(deathmonth, deathday, deathyear)
format dod %td
label var dod "Date of death"

*-------------------------------*
* 4B. BASELINE AND ADMINISTRATIVE CENSORING DATES
*-------------------------------*
capture drop doenter
gen doenter = mdy(7,1,2016)
format doenter %td
label var doenter "Baseline date"

capture drop doadmin
gen doadmin = mdy(12,31,2022)
format doadmin %td
label var doadmin "Administrative censoring date"

*-------------------------------*
* 4C. INTERVIEW DATES
* Uses same mid-year proxies as revised do file
*-------------------------------*
capture confirm variable doiw2018
if _rc {
    gen doiw2018 = mdy(7,1,2018)
}
capture confirm variable doiw2020
if _rc {
    gen doiw2020 = mdy(7,1,2020)
}
capture confirm variable doiw2022
if _rc {
    gen doiw2022 = mdy(7,1,2022)
}
format doiw2018 doiw2020 doiw2022 %td

********************************************************************************
* 5. OUTCOME 1: INCIDENT COGNITIVE IMPAIRMENT (MCI/CIND OR DEMENTIA)
********************************************************************************

capture drop event2018 event2020 event2022
gen event2018 = 0
replace event2018 = 1 if cogfunction2018 > 1 & cogfunction2018 < .

gen event2020 = 0
replace event2020 = 1 if ///
    (cogfunction2018==1 | missing(cogfunction2018)) & ///
     cogfunction2020 > 1 & cogfunction2020 < .

gen event2022 = 0
replace event2022 = 1 if ///
    (cogfunction2018==1 | missing(cogfunction2018)) & ///
    (cogfunction2020==1 | missing(cogfunction2020)) & ///
     cogfunction2022 > 1 & cogfunction2022 < .

capture drop docogevent
gen docogevent = .
replace docogevent = doenter + floor((doiw2018-doenter)/2) if event2018==1
replace docogevent = doiw2018 + floor((doiw2020-doiw2018)/2) if event2020==1
replace docogevent = doiw2020 + floor((doiw2022-doiw2020)/2) if event2022==1
format docogevent %td
label var docogevent "Estimated date of first incident cognitive impairment"

capture drop dolastnormal
gen dolastnormal = doenter
replace dolastnormal = doiw2018 if cogfunction2018==1
replace dolastnormal = doiw2020 if cogfunction2020==1
replace dolastnormal = doiw2022 if cogfunction2022==1
format dolastnormal %td
label var dolastnormal "Last observed normal cognition date"

capture drop docensor
gen docensor = doadmin
replace docensor = dolastnormal if dolastnormal < docensor & dolastnormal < .
replace docensor = dod if dod < docensor & dod < .
format docensor %td
label var docensor "Censoring date"

capture drop fail_cog
gen fail_cog = 0
replace fail_cog = 1 if docogevent < . & ///
    (dod==. | docogevent <= dod) & ///
    docogevent <= doadmin
label var fail_cog "Incident cognitive impairment"

capture drop doevent_cog
gen doevent_cog = docensor
replace doevent_cog = docogevent if fail_cog==1
format doevent_cog %td
label var doevent_cog "Event/censoring date: cognitive impairment"

********************************************************************************
* 6. OUTCOME 2: INCIDENT MCI/CIND ONLY
********************************************************************************

capture drop eventmci2018 eventmci2020 eventmci2022
gen eventmci2018 = 0
replace eventmci2018 = 1 if cogfunction2018 == 2

gen eventmci2020 = 0
replace eventmci2020 = 1 if ///
    (cogfunction2018==1 | missing(cogfunction2018)) & ///
     cogfunction2020 == 2

gen eventmci2022 = 0
replace eventmci2022 = 1 if ///
    (cogfunction2018==1 | missing(cogfunction2018)) & ///
    (cogfunction2020==1 | missing(cogfunction2020)) & ///
     cogfunction2022 == 2

capture drop domcievent
gen domcievent = .
replace domcievent = doenter + floor((doiw2018-doenter)/2) if eventmci2018==1
replace domcievent = doiw2018 + floor((doiw2020-doiw2018)/2) if eventmci2020==1
replace domcievent = doiw2020 + floor((doiw2022-doiw2020)/2) if eventmci2022==1
format domcievent %td
label var domcievent "Estimated date of first incident MCI/CIND"

capture drop fail_mci
gen fail_mci = 0
replace fail_mci = 1 if domcievent < . & ///
    (dod==. | domcievent <= dod) & ///
    domcievent <= doadmin
label var fail_mci "Incident MCI/CIND"

capture drop doevent_mci
gen doevent_mci = docensor
replace doevent_mci = domcievent if fail_mci==1
format doevent_mci %td
label var doevent_mci "Event/censoring date: MCI/CIND"

********************************************************************************
* 7. OUTCOME 3: INCIDENT DEMENTIA ONLY
********************************************************************************

capture drop eventdem2018 eventdem2020 eventdem2022
gen eventdem2018 = 0
replace eventdem2018 = 1 if cogfunction2018 == 3

gen eventdem2020 = 0
replace eventdem2020 = 1 if ///
    (cogfunction2018==1 | missing(cogfunction2018)) & ///
     cogfunction2020 == 3

gen eventdem2022 = 0
replace eventdem2022 = 1 if ///
    (cogfunction2018==1 | missing(cogfunction2018)) & ///
    (cogfunction2020==1 | missing(cogfunction2020)) & ///
     cogfunction2022 == 3

capture drop dodementiaevent
gen dodementiaevent = .
replace dodementiaevent = doenter + floor((doiw2018-doenter)/2) if eventdem2018==1
replace dodementiaevent = doiw2018 + floor((doiw2020-doiw2018)/2) if eventdem2020==1
replace dodementiaevent = doiw2020 + floor((doiw2022-doiw2020)/2) if eventdem2022==1
format dodementiaevent %td
label var dodementiaevent "Estimated date of first incident probable dementia"

capture drop fail_dem
gen fail_dem = 0
replace fail_dem = 1 if dodementiaevent < . & ///
    (dod==. | dodementiaevent <= dod) & ///
    dodementiaevent <= doadmin
label var fail_dem "Incident probable dementia"

capture drop doevent_dem
gen doevent_dem = docensor
replace doevent_dem = dodementiaevent if fail_dem==1
format doevent_dem %td
label var doevent_dem "Event/censoring date: dementia"

********************************************************************************
* 8. AGE TIME SCALE
********************************************************************************

capture confirm variable dob
if _rc {
    di as error "Variable dob not found. Replace dob with your date-of-birth variable."
    exit 198
}

capture drop ageenter 
capture drop ageevent_cog 
capture drop ageevent_mci 
capture drop ageevent_dem
gen ageenter     = (doenter     - dob)/365.25
gen ageevent_cog = (doevent_cog - dob)/365.25
gen ageevent_mci = (doevent_mci - dob)/365.25
gen ageevent_dem = (doevent_dem - dob)/365.25

label var ageenter     "Age at baseline"
label var ageevent_cog "Age at cognitive impairment event/censoring"
label var ageevent_mci "Age at MCI/CIND event/censoring"
label var ageevent_dem "Age at dementia event/censoring"

save "$DATA\HRS_GSEM_WEIBULL_DIET_FRAILTY_FINAL.dta", replace

********************************************************************************
* 9. SHARED ABN-INFORMED STRUCTURAL EQUATIONS
* Based on the revised ABN sheet, translated to continuous-node GSEM
********************************************************************************

local eqs ///
    (zses_2012_cont <- AGE_cont SEX NHB HISP, ///
        family(gaussian) link(identity)) ///
    (married_2012 <- AGE_cont SEX NHB zses_2012_cont, ///
        family(binomial) link(logit)) ///
    (zhei2015_total_score_cont <- AGE_cont SEX OTHER zses_2012_cont, ///
        family(gaussian) link(identity)) ///
    (smoking_2012 <- AGE_cont SEX zses_2012_cont zhei2015_total_score_cont, ///
        family(ordinal) link(logit)) ///
    (alcohol_2012 <- SEX zses_2012_cont smoking_2012 diab_ever_2012, ///
        family(ordinal) link(logit)) ///
    (srh_2012 <- HISP zses_2012_cont smoking_2012 heart_ever_2012, ///
        family(ordinal) link(logit)) ///
    (physic_act_2012 <- SEX alcohol_2012 srh_2012 zhei2015_total_score_cont, ///
        family(ordinal) link(logit)) ///
    (diab_ever_2012 <- AGE_cont NHB heart_ever_2012 srh_2012, ///
        family(binomial) link(logit)) ///
    (heart_ever_2012 <- AGE_cont SEX OTHER smoking_2012, ///
        family(binomial) link(logit)) ///
    (hbp_ever_2012 <- AGE_cont NHB diab_ever_2012 heart_ever_2012, ///
        family(binomial) link(logit)) ///
    (bmibr_2012 <- AGE_cont physic_act_2012 hbp_ever_2012 diab_ever_2012, ///
        family(ordinal) link(logit)) ///
    (stroke_ever_2012 <- AGE_cont zses_2012_cont heart_ever_2012 srh_2012, ///
        family(binomial) link(logit)) ///
    (fried_sum_cont <- AGE_cont zses_2012_cont physic_act_2012 srh_2012, ///
        family(gaussian) link(identity))

********************************************************************************
* 10. MODEL 1: INCIDENT COGNITIVE IMPAIRMENT (MCI/CIND OR DEMENTIA)
* Direct ABN parents of d_outcome after omitting t2/t3:
* AGE_pm, NHB, srh_2012
********************************************************************************

use "$DATA\HRS_GSEM_WEIBULL_DIET_FRAILTY_FINAL.dta", clear

stset ageevent_cog, origin(time ageenter) enter(time ageenter) ///
    failure(fail_cog==1) id(HHIDPN)

gsem ///
    (_t <- AGE_cont NHB srh_2012, ///
        family(weibull, failure(_d)) link(log)) ///
    `eqs' ///
    , nocapslatent method(ml)

estimates store gsem_weib_cog_abn

********************************************************************************
* 11. MODEL 2: INCIDENT MCI/CIND ONLY
* Using same structural network, different survival outcome
********************************************************************************

use "$DATA\HRS_GSEM_WEIBULL_DIET_FRAILTY_FINAL.dta", clear

stset ageevent_mci, origin(time ageenter) enter(time ageenter) ///
    failure(fail_mci==1) id(HHIDPN)

gsem ///
    (_t <- AGE_cont NHB srh_2012, ///
        family(weibull, failure(_d)) link(log)) ///
    `eqs' ///
    , nocapslatent method(ml)

estimates store gsem_weib_mci_abn

********************************************************************************
* 12. MODEL 3: INCIDENT DEMENTIA ONLY
* Using same structural network, different survival outcome
********************************************************************************

use "$DATA\HRS_GSEM_WEIBULL_DIET_FRAILTY_FINAL.dta", clear

stset ageevent_dem, origin(time ageenter) enter(time ageenter) ///
    failure(fail_dem==1) id(HHIDPN)

gsem ///
    (_t <- AGE_cont NHB srh_2012, ///
        family(weibull, failure(_d)) link(log)) ///
    `eqs' ///
    , nocapslatent method(ml)

estimates store gsem_weib_dem_abn

********************************************************************************
* 13. OPTIONAL: DISPLAY STORED MODELS
********************************************************************************

estimates dir

********************************************************************************
* 14. OPTIONAL: RE-RUN WITH ROBUST SEs AFTER CONFIRMING CONVERGENCE
********************************************************************************
* Example:
* use "$DATA\HRS_GSEM_WEIBULL_DIET_FRAILTY_FINAL.dta", clear
* stset ageevent_cog, origin(time ageenter) enter(time ageenter) ///
*     failure(fail_cog==1) id(HHIDPN)
* gsem ///
*     (_t <- AGE_cont NHB srh_2012, family(weibull, failure(_d)) link(log)) ///
*     `eqs' ///
*     , nocapslatent method(ml) vce(robust)

capture log close


capture log close

capture log using ///
"D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_DIET_FRAILTY_COG\OUTPUT\COMPETING_RISK_REG_DIET_FRAILTY_DEMMCI_OUTCOMES.txt", ///
text replace

**********************************************SENSITIIVTY ANALYSIS 1: COMPETING RISK REGRESSION******************************


********************************************************************************
* COMPETING RISKS AND MULTISTATE MODELS
* Outcomes: MCI/CIND, dementia, MCI+dementia, death
* Time scale: same as main Cox models in manuscript
********************************************************************************

clear
set more off

********************************************************************************
* 0. Install required user-written packages
********************************************************************************

cap which msset
if _rc ssc install multistate, replace

cap which msboxes
if _rc ssc install multistate, replace

cap which stpm2
if _rc ssc install stpm2, replace

cap which esttab
if _rc ssc install estout, replace

********************************************************************************
* 1. Open final analytic data
********************************************************************************

use ///
"D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_DIET_FRAILTY_COG\FINAL_DATA\HRS_HEI_FRAIL_ANALYTIC_FINALfin.dta", ///
clear

keep if sample_final==1
keep if cogfunction2016==1

svyset secu [pweight=HCNSWGTR_NT], strata(stratum) singleunit(centered)

********************************************************************************
* 2. Frailty category and covariate blocks
********************************************************************************

cap drop frail_cat
gen frail_cat = .
replace frail_cat = 1 if fried_sum==0
replace frail_cat = 2 if inrange(fried_sum,1,2)
replace frail_cat = 3 if fried_sum>=3 & fried_sum<.

cap label drop frail_cat
label define frail_cat 1 "Robust" 2 "Pre-frail" 3 "Frail"
label values frail_cat frail_cat

global M1 "c.r13agey_e i.ragender"
global M2 "c.r13agey_e i.ragender i.RACE_ETHN i.marital_2012 i.education i.totwealth_2012"
global M3 "c.r13agey_e i.ragender i.RACE_ETHN i.marital_2012 i.education i.totwealth_2012 i.smoking_2012 i.alcohol_2012 i.physic_act_2012 i.bmibr_2012 i.hbp_ever_2012 i.diab_ever_2012 i.stroke_ever_2012 i.heart_ever_2012 i.srh_2012 hei2015_total_score"

********************************************************************************
* 3. Ensure dates exist
********************************************************************************

cap drop doenter 
capture drop doiw2018 
capture drop doiw2020 
capture drop doiw2022 
capture drop doadmin
gen doenter  = mdy(7,1,2016)
gen doiw2018 = mdy(7,1,2018)
gen doiw2020 = mdy(7,1,2020)
gen doiw2022 = mdy(7,1,2022)
gen doadmin  = mdy(12,31,2022)
format doenter doiw2018 doiw2020 doiw2022 doadmin %td

cap drop dob
gen dob = mdy(birthmo,15,birthyr)
format dob %td

cap drop ageenter
gen ageenter = (doenter-dob)/365.25

********************************************************************************
* 4. Death date
********************************************************************************

cap drop died deathmonth deathyear deathday dod
gen died = knowndeceasedyr < .
gen deathmonth = knowndeceasedmo
replace deathmonth = . if inlist(deathmonth,0,98,99)
gen deathyear = knowndeceasedyr
replace deathyear = . if inlist(deathyear,0,9998,9999)
replace deathmonth = 6 if deathyear < . & deathmonth == .
gen deathday = 15 if deathyear < .
gen dod = mdy(deathmonth, deathday, deathyear)
format dod %td

********************************************************************************
* 5. Earliest MCI/CIND, dementia, and combined cognitive impairment dates
********************************************************************************

capture drop domci 
capture drop dodem 
capture drop docog

gen domci = .
replace domci = doenter  + floor((doiw2018-doenter)/2)   if cogfunction2018==2
replace domci = doiw2018 + floor((doiw2020-doiw2018)/2)  if domci==. & cogfunction2020==2
replace domci = doiw2020 + floor((doiw2022-doiw2020)/2)  if domci==. & cogfunction2022==2
format domci %td
label var domci "Estimated date of first MCI/CIND"

gen dodem = .
replace dodem = doenter  + floor((doiw2018-doenter)/2)   if cogfunction2018==3
replace dodem = doiw2018 + floor((doiw2020-doiw2018)/2)  if dodem==. & cogfunction2020==3
replace dodem = doiw2020 + floor((doiw2022-doiw2020)/2)  if dodem==. & cogfunction2022==3
format dodem %td
label var dodem "Estimated date of first probable dementia"

egen docog = rowmin(domci dodem)
format docog %td
label var docog "Estimated date of first MCI/CIND or dementia"

********************************************************************************
* 6. General censoring date
********************************************************************************

cap drop dolastobs 
capture drop docensor
egen dolastobs = rowmax(doenter doiw2018 doiw2020 doiw2022)
format dolastobs %td

gen docensor = doadmin
replace docensor = dolastobs if dolastobs < docensor & dolastobs < .
replace docensor = dod      if dod      < docensor & dod      < .
format docensor %td

********************************************************************************
* 7. Fine-Gray competing-risk models using stcrreg
* Death is the competing event.
********************************************************************************

program drop _all
program define run_fg
    syntax, outcome(string) eventdate(varname) outfile(string)

    cap drop fg_status fg_enddate fg_ageend

    gen fg_status = 0
    replace fg_status = 1 if `eventdate' < . & `eventdate' <= doadmin & ///
        (dod==. | `eventdate' <= dod)

    replace fg_status = 2 if dod < . & dod <= doadmin & ///
        (fg_status != 1) & (dod <= docensor)

    gen fg_enddate = docensor
    replace fg_enddate = `eventdate' if fg_status==1
    replace fg_enddate = dod if fg_status==2

    gen fg_ageend = (fg_enddate-dob)/365.25

    stset fg_ageend [pweight=HCNSWGTR_NT], ///
        origin(time ageenter) enter(time ageenter) ///
        failure(fg_status==1) id(HHIDPN)

    di "Fine-Gray model for `outcome'"
    tab fg_status, missing

    stcrreg i.frail_cat $M1, compete(fg_status==2) vce(cluster secu)
    estimates store FG_`outfile'_M1

    stcrreg i.frail_cat $M2, compete(fg_status==2) vce(cluster secu)
    estimates store FG_`outfile'_M2

    stcrreg i.frail_cat $M3, compete(fg_status==2) vce(cluster secu)
    estimates store FG_`outfile'_M3
end

run_fg, outcome("MCI/CIND or dementia") eventdate(docog) outfile(cog)
run_fg, outcome("MCI/CIND only") eventdate(domci) outfile(mci)
run_fg, outcome("Probable dementia") eventdate(dodem) outfile(dem)

esttab FG_cog_M1 FG_cog_M2 FG_cog_M3 ///
       FG_mci_M1 FG_mci_M2 FG_mci_M3 ///
       FG_dem_M1 FG_dem_M2 FG_dem_M3 ///
using ///
"D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_DIET_FRAILTY_COG\OUTPUT\FG_stcrreg_results.rtf", ///
replace eform ci label
capture log close

capture log close
capture log using ///
"D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_DIET_FRAILTY_COG\OUTPUT\MULTISTATE_DIET_FRAILTY_DEMMCI_OUTCOMES.txt", ///
text replace

********************************************SENSITIVITY ANALYSIS 2: MULTISTATE MODELS: FULLY ADJUSTED********************************************

********************************************************************************
* Install packages
********************************************************************************

cap which msset
if _rc ssc install multistate, replace

cap which msboxes
if _rc ssc install multistate, replace

cap which msaj
if _rc ssc install multistate, replace

cap which esttab
if _rc ssc install estout, replace

********************************************************************************
* 1. Reconstruct earliest event dates
********************************************************************************

capture drop domci
gen domci = .
replace domci = doenter  + floor((doiw2018-doenter)/2)  if cogfunction2018==2
replace domci = doiw2018 + floor((doiw2020-doiw2018)/2) if domci==. & cogfunction2020==2
replace domci = doiw2020 + floor((doiw2022-doiw2020)/2) if domci==. & cogfunction2022==2
format domci %td

capture drop dodem
gen dodem = .
replace dodem = doenter  + floor((doiw2018-doenter)/2)  if cogfunction2018==3
replace dodem = doiw2018 + floor((doiw2020-doiw2018)/2) if dodem==. & cogfunction2020==3
replace dodem = doiw2020 + floor((doiw2022-doiw2020)/2) if dodem==. & cogfunction2022==3
format dodem %td

capture drop dodeath
gen dodeath = dod
replace dodeath = . if dodeath>doadmin
format dodeath %td

capture drop docens_final
gen docens_final = doadmin
replace docens_final = dodeath if dodeath<docens_final & dodeath<.
format docens_final %td

********************************************************************************
* 2. Convert event dates to attained-age time scale
* This matches the Cox models using attained age as analysis time.
********************************************************************************

capture drop age_mci
gen age_mci = (domci-dob)/365.25 if domci<.

capture drop age_dem
gen age_dem = (dodem-dob)/365.25 if dodem<.

capture drop age_death
gen age_death = (dodeath-dob)/365.25 if dodeath<.

capture drop age_censor_ms
gen age_censor_ms = (docens_final-dob)/365.25

********************************************************************************
* 3. Define event indicators for msset
********************************************************************************

capture drop mci_ind
gen mci_ind = domci<. & domci<=doadmin & domci>=doenter & ///
              (dodeath==. | domci<=dodeath)

capture drop dem_ind
gen dem_ind = dodem<. & dodem<=doadmin & dodem>=doenter & ///
              (dodeath==. | dodem<=dodeath)

capture drop death_ind
gen death_ind = dodeath<. & dodeath<=doadmin & dodeath>=doenter

********************************************************************************
* 4. Define msset time variables
* If event did not occur, time equals censoring age.
********************************************************************************

capture drop t_mci_age
gen t_mci_age = age_censor_ms
replace t_mci_age = age_mci if mci_ind==1

capture drop t_dem_age
gen t_dem_age = age_censor_ms
replace t_dem_age = age_dem if dem_ind==1

capture drop t_death_age
gen t_death_age = age_censor_ms
replace t_death_age = age_death if death_ind==1

replace t_mci_age   = ageenter + 0.001 if t_mci_age<=ageenter & t_mci_age<.
replace t_dem_age   = ageenter + 0.001 if t_dem_age<=ageenter & t_dem_age<.
replace t_death_age = ageenter + 0.001 if t_death_age<=ageenter & t_death_age<.

********************************************************************************
* 5. Check event counts before msset
********************************************************************************

tab mci_ind, missing
tab dem_ind, missing
tab death_ind, missing

summ ageenter t_mci_age t_dem_age t_death_age age_censor_ms

********************************************************************************
* 6. Raw covariates for msset covariates() option
********************************************************************************

local M3_raw ///
    r13agey_e ///
    ragender ///
    RACE_ETHN ///
    marital_2012 ///
    education ///
    totwealth_2012 ///
    smoking_2012 ///
    alcohol_2012 ///
    physic_act_2012 ///
    bmibr_2012 ///
    hbp_ever_2012 ///
    diab_ever_2012 ///
    stroke_ever_2012 ///
    heart_ever_2012 ///
    srh_2012 ///
    hei2015_total_score

********************************************************************************
* 7. Multistate setup using msset, following working UKB structure
********************************************************************************

preserve

msset if sample_final==1, ///
    id(HHIDPN) ///
    states(mci_ind dem_ind death_ind) ///
    times(t_mci_age t_dem_age t_death_age) ///
    covariates(frail_cat fried_sum `M3_raw')

matrix tmat = r(transmatrix)
matrix list tmat

tab _trans _status, missing
tab _status, missing


save ///
"D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_DIET_FRAILTY_COG\FINAL_DATA\HRS_multistate_msset_FINAL.dta", ///
replace

********************************************************************************
* 8. Figure 1: multistate boxes
********************************************************************************

capture drop _trans

gen _trans = .
replace _trans = 1 if _trans1==1
replace _trans = 2 if _trans2==1
replace _trans = 3 if _trans3==1
replace _trans = 4 if _trans4==1
replace _trans = 5 if _trans5==1
replace _trans = 6 if _trans6==1

tab _trans _status, missing

msboxes, transmatrix(tmat) id(HHIDPN) ///
    xvalues(0.15 0.45 0.75 0.45) ///
    yvalues(0.70 0.70 0.70 0.35) ///
    statenames("Normal cognition" "MCI/CIND" "Probable dementia" "Death")

graph save ///
"D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_DIET_FRAILTY_COG\OUTPUT\Figure_MS1_msboxes.gph", ///
replace

********************************************************************************
* 9. stset using attained age
* IMPORTANT: Do NOT use id(HHIDPN) here.
* The msset file has multiple transition records per person.
* Cluster by HHIDPN later in streg instead.
********************************************************************************

use ///
"D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_DIET_FRAILTY_COG\FINAL_DATA\HRS_multistate_msset_FINAL.dta", ///
clear

capture drop _time
gen _time = _stop - _start

drop if _start==.
drop if _stop==.
drop if _stop<=_start

stset _stop [pweight=HCNSWGTR_NT] if sample_final==1, ///
    enter(time _start) ///
    failure(_status==1) ///
    scale(1)

tab _trans _d if _st==1, missing
tab _trans1 _d if _st==1, missing
tab _trans2 _d if _st==1, missing
tab _trans3 _d if _st==1, missing
tab _trans4 _d if _st==1, missing
tab _trans5 _d if _st==1, missing
tab _trans6 _d if _st==1, missing

save "D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_DIET_FRAILTY_COG\FINAL_DATA\HRS_multistate_msset_FINAL.dta", ///
replace


********************************************************************************
* 10. Figure 2: Aalen-Johansen transition probabilities, truncated at age 95
********************************************************************************

capture drop P_AJ*
msaj, transmat(tmat) ci

line P_AJ_1* _t if _t <= 95, sort connect(stairstep stairstep stairstep) ///
    title("From normal cognition") ///
    ytitle("Transition probability") ///
    xtitle("Attained age") ///
    xlabel(50(5)95) ///
    xscale(range(50 95))
graph save ///
"D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_DIET_FRAILTY_COG\OUTPUT\Figure_MS2A_AJ_from_normal.gph", ///
replace

line P_AJ_2* _t if _t <= 95, sort connect(stairstep stairstep stairstep) ///
    title("From MCI/CIND") ///
    ytitle("Transition probability") ///
    xtitle("Attained age") ///
    xlabel(50(5)95) ///
    xscale(range(50 95))
graph save ///
"D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_DIET_FRAILTY_COG\OUTPUT\Figure_MS2B_AJ_from_MCI.gph", ///
replace

line P_AJ_3* _t if _t <= 95, sort connect(stairstep stairstep stairstep) ///
    title("From probable dementia") ///
    ytitle("Transition probability") ///
    xtitle("Attained age") ///
    xlabel(50(5)95) ///
    xscale(range(50 95))
graph save ///
"D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_DIET_FRAILTY_COG\OUTPUT\Figure_MS2C_AJ_from_dementia.gph", ///
replace

line P_AJ_4* _t if _t <= 95, sort connect(stairstep stairstep stairstep) ///
    title("Death state") ///
    ytitle("Transition probability") ///
    xtitle("Attained age") ///
    xlabel(50(5)95) ///
    xscale(range(50 95))
graph save ///
"D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_DIET_FRAILTY_COG\OUTPUT\Figure_MS2D_AJ_death_state.gph", ///
replace
graph combine ///
"D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_DIET_FRAILTY_COG\OUTPUT\Figure_MS2A_AJ_from_normal.gph" ///
"D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_DIET_FRAILTY_COG\OUTPUT\Figure_MS2B_AJ_from_MCI.gph" ///
"D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_DIET_FRAILTY_COG\OUTPUT\Figure_MS2C_AJ_from_dementia.gph" ///
"D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_DIET_FRAILTY_COG\OUTPUT\Figure_MS2D_AJ_death_state.gph", ///
col(2)

graph save ///
"D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_DIET_FRAILTY_COG\OUTPUT\Figure_MS2_AJ_combined.gph", ///
replace

graph export ///
"D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_DIET_FRAILTY_COG\OUTPUT\Figure_MS2_AJ_combined.png", ///
replace width(3000)

use ///
"D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_DIET_FRAILTY_COG\FINAL_DATA\HRS_multistate_msset_FINAL.dta", ///
clear

********************************************************************************
* 11. Transition-specific Weibull models
* Models M1, M2, and M3
* Skip transitions with <40 usable failures
********************************************************************************

local stored_weibull ""

forvalues tr = 1/6 {

    quietly count if _trans`tr'==1 & _st==1
    local nrisk = r(N)

    quietly count if _trans`tr'==1 & _st==1 & _d==1
    local nfail = r(N)

    di "Transition `tr': risk set N = `nrisk'; failures = `nfail'"

    if `nrisk'>0 & `nfail'>=40 {

        foreach m in M1 M2 M3 {

            di "Running transition `tr', model `m'"

            capture noisily streg i.frail_cat $`m' if _trans`tr'==1 & _st==1, ///
                distribution(weibull) ///
                vce(cluster HHIDPN)

            if _rc==0 {
                estimates store MS_weibull_t`tr'_`m'
                local stored_weibull "`stored_weibull' MS_weibull_t`tr'_`m'"
            }
            else {
                di as error "Weibull model failed for transition `tr', model `m'. Return code = " _rc
            }
        }

        ********************************************************************************
        * Figure 3: transition-specific survival by frailty category
        * Based on fully adjusted model M3
        ********************************************************************************

        capture noisily streg i.frail_cat $M3 if _trans`tr'==1 & _st==1, ///
            distribution(weibull) ///
            vce(cluster HHIDPN)

        if _rc==0 {

            stcurve, survival ///
                at1(frail_cat=1) ///
                at2(frail_cat=2) ///
                at3(frail_cat=3) ///
                title("Transition `tr': Weibull survival by frailty, M3") ///
                ytitle("Survival probability") ///
                xtitle("Attained age") ///
                legend(order(1 "Robust" 2 "Pre-frail" 3 "Frail"))

            graph save ///
            "D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_DIET_FRAILTY_COG\OUTPUT\Figure_MS3_transition`tr'_weibull_survival_M3.gph", ///
            replace

            graph export ///
            "D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_DIET_FRAILTY_COG\OUTPUT\Figure_MS3_transition`tr'_weibull_survival_M3.png", ///
            replace width(2400)
        }
    }
    else {
        di as text "Skipped transition `tr': fewer than 40 usable failures."
    }
}

if "`stored_weibull'" != "" {

    esttab `stored_weibull' using ///
    "D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_DIET_FRAILTY_COG\OUTPUT\Multistate_transition_weibull_M1_M2_M3_results.rtf", ///
    replace eform ci label ///
    title("Transition-specific Weibull multistate models, M1-M3; transitions with <40 failures skipped")
}

save ///
"D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_DIET_FRAILTY_COG\FINAL_DATA\HRS_multistate_msset_FINAL_modeled.dta", ///
replace

capture log close

******************************************SENSITIVITY ANALYSIS 3: ABN AND GSEM WITH REDUCED SET OF COVARIATES: SOCIO-DEMOGRAHPIC AND SOCIO-ECONOMIC****


###############################################################################
# ABN SENSITIVITY SCRIPT: HRS HEI-2015 total score only
# DEMOGRAPHIC + SOCIOECONOMIC ADJUSTMENT ONLY
#
# Changes from the broader ABN script:
#   - Runs only zhei2015_total_score_pm
#   - Keeps the same three outcome files/folders: DEMMCI / DEM / MCI
#   - Keeps d_outcome, t2, t3, HEI-2015, and fried_sum_pm
#   - Keeps only demographic and socioeconomic covariates:
#       AGE_pm, SEX, NHB, HISP, OTHER, zses_2012_pm, married_2012
#   - Excludes lifestyle, BMI, clinical diagnoses, and self-rated health variables
#   - Uses distinct sensitivity output folder and file names
###############################################################################

rm(list = ls())

suppressPackageStartupMessages({
  library(abn)
  library(haven)
  library(Rgraphviz)
  library(graph)
  library(grid)
  library(grDevices)
})

###############################################################################
# 1. HELPERS
###############################################################################

make_numeric <- function(x, varname = NULL) {
  out <- suppressWarnings(as.numeric(as.character(x)))
  if (all(is.na(out)) && any(!is.na(x))) {
    stop("Could not convert ", varname, " to numeric.")
  }
  out
}

make_bin_factor <- function(x, varname) {
  x_chr <- as.character(x)
  x_chr[x_chr %in% c("", "NA", "<NA>")] <- NA
  
  ux <- sort(unique(x_chr[!is.na(x_chr)]))
  if (length(ux) != 2) {
    stop(
      "Variable ", varname,
      " assigned as binomial but has ", length(ux),
      " unique non-missing values: ",
      paste(ux, collapse = ", ")
    )
  }
  
  message("Binary recode for ", varname, ": ", ux[1], " | ", ux[2])
  factor(x_chr, levels = ux)
}

extract_dag_matrix <- function(x) {
  if (is.matrix(x)) return(x)
  
  nms <- names(x)
  if (!is.null(nms)) {
    for (nm in c("dag", "dag.m", "dagM", "network", "amat")) {
      if (nm %in% nms) {
        obj <- x[[nm]]
        if (is.matrix(obj)) return(obj)
      }
    }
  }
  
  recurse_find_matrix <- function(obj) {
    if (is.matrix(obj)) return(obj)
    if (is.list(obj)) {
      for (i in seq_along(obj)) {
        ans <- recurse_find_matrix(obj[[i]])
        if (!is.null(ans)) return(ans)
      }
    }
    NULL
  }
  
  ans <- recurse_find_matrix(x)
  if (!is.null(ans)) return(ans)
  
  stop("Could not extract a DAG matrix from the ABN object.")
}

extract_scalar_score <- function(x) {
  if (!is.null(names(x))) {
    for (nm in c("score", "mlik", "loglik", "bic", "aic")) {
      if (nm %in% names(x)) {
        val <- x[[nm]]
        if (is.numeric(val) && length(val) == 1) return(as.numeric(val))
      }
    }
  }
  
  recurse_find_scalar <- function(obj) {
    if (is.numeric(obj) && length(obj) == 1) return(as.numeric(obj))
    if (is.list(obj)) {
      for (i in seq_along(obj)) {
        ans <- recurse_find_scalar(obj[[i]])
        if (!is.null(ans)) return(ans)
      }
    }
    NULL
  }
  
  ans <- recurse_find_scalar(x)
  if (!is.null(ans)) return(ans)
  
  NA_real_
}

sanitize_dag_matrix <- function(m, target_names) {
  if (!is.matrix(m)) stop("DAG object is not a matrix.")
  if (nrow(m) != ncol(m)) stop("DAG matrix is not square.")
  
  m <- as.matrix(m)
  
  if (is.null(rownames(m)) && !is.null(colnames(m))) rownames(m) <- colnames(m)
  if (is.null(colnames(m)) && !is.null(rownames(m))) colnames(m) <- rownames(m)
  
  if (is.null(rownames(m)) || is.null(colnames(m))) {
    stop("DAG matrix must have row and column names.")
  }
  
  if (!all(target_names %in% rownames(m)) || !all(target_names %in% colnames(m))) {
    stop("DAG matrix names do not match expected node names.")
  }
  
  m <- m[target_names, target_names, drop = FALSE]
  storage.mode(m) <- "numeric"
  m[m != 0] <- 1
  diag(m) <- 0
  m
}

get_abn_dag <- function(learned_obj, node_names) {
  amat_raw <- extract_dag_matrix(learned_obj)
  sanitize_dag_matrix(amat_raw, node_names)
}

get_parents <- function(amat_abn, child) {
  colnames(amat_abn)[amat_abn[child, ] == 1]
}

fit_local_model <- function(data, child, parents, dist_name) {
  if (length(parents) == 0) return(NULL)
  
  fml <- as.formula(paste(child, "~", paste(parents, collapse = " + ")))
  
  if (dist_name == "gaussian") {
    lm(fml, data = data)
  } else if (dist_name == "binomial") {
    glm(fml, data = data, family = binomial())
  } else {
    stop("Distribution not yet supported in local fit: ", dist_name)
  }
}

extract_parent_coef <- function(fit, parent) {
  cf <- coef(fit)
  nm <- names(cf)
  
  if (parent %in% nm) return(unname(cf[parent]))
  
  idx <- grep(
    paste0("^", gsub("([.|()\\^{}+$*?]|\\[|\\]|\\\\)", "\\\\\\1", parent)),
    nm
  )
  idx <- idx[nm[idx] != "(Intercept)"]
  
  if (length(idx) >= 1) return(unname(cf[idx[1]]))
  
  NA_real_
}

make_arc_df <- function(amat_abn) {
  arc_idx <- which(amat_abn == 1, arr.ind = TRUE)
  
  if (length(arc_idx) == 0 || nrow(arc_idx) == 0) {
    return(data.frame(
      from = character(0),
      to   = character(0),
      stringsAsFactors = FALSE
    ))
  }
  
  data.frame(
    from = colnames(amat_abn)[arc_idx[, 2]],
    to   = rownames(amat_abn)[arc_idx[, 1]],
    stringsAsFactors = FALSE
  )
}

build_edge_labels <- function(data, amat_abn, dist.list) {
  nodes <- rownames(amat_abn)
  out_list <- list()
  k <- 1
  
  for (child in nodes) {
    parents <- get_parents(amat_abn, child)
    if (length(parents) == 0) next
    
    dist_name <- dist.list[[child]]
    fit <- fit_local_model(data = data, child = child, parents = parents, dist_name = dist_name)
    
    for (parent in parents) {
      beta <- extract_parent_coef(fit, parent)
      lbl  <- if (is.na(beta)) "" else sprintf("%+.2f", beta)
      
      out_list[[k]] <- data.frame(
        from  = parent,
        to    = child,
        beta  = beta,
        label = lbl,
        stringsAsFactors = FALSE
      )
      k <- k + 1
    }
  }
  
  if (length(out_list) == 0) {
    return(data.frame(
      from  = character(0),
      to    = character(0),
      beta  = numeric(0),
      label = character(0),
      stringsAsFactors = FALSE
    ))
  }
  
  do.call(rbind, out_list)
}

make_graphNEL_from_abn <- function(amat_abn) {
  node_names <- rownames(amat_abn)
  gNEL <- new("graphNEL", nodes = node_names, edgemode = "directed")
  
  arc_df <- make_arc_df(amat_abn)
  
  if (nrow(arc_df) > 0) {
    for (i in seq_len(nrow(arc_df))) {
      gNEL <- addEdge(arc_df$from[i], arc_df$to[i], gNEL, 1)
    }
  }
  
  gNEL
}

plot_rgraphviz_abn <- function(amat_abn, edge_df, dist.list, file, main_title = NULL) {
  gNEL <- make_graphNEL_from_abn(amat_abn)
  node_names <- nodes(gNEL)
  
  shape_vec <- sapply(node_names, function(v) {
    if (dist.list[[v]] == "binomial") "box" else "ellipse"
  }, USE.NAMES = TRUE)
  
  fill_vec <- rep("white", length(node_names))
  names(fill_vec) <- node_names
  
  font_vec <- rep("Helvetica", length(node_names))
  names(font_vec) <- node_names
  
  fontsize_vec <- rep("16", length(node_names))
  names(fontsize_vec) <- node_names
  
  width_vec <- rep("1.40", length(node_names))
  names(width_vec) <- node_names
  
  height_vec <- rep("0.90", length(node_names))
  names(height_vec) <- node_names
  
  nAttrs <- list(
    shape     = as.list(shape_vec),
    fillcolor = as.list(fill_vec),
    fontname  = as.list(font_vec),
    fontsize  = as.list(fontsize_vec),
    width     = as.list(width_vec),
    height    = as.list(height_vec)
  )
  
  eAttrs <- list()
  if (nrow(edge_df) > 0) {
    edge_key <- paste(edge_df$from, edge_df$to, sep = "~")
    
    label_vec <- edge_df$label
    names(label_vec) <- edge_key
    
    edge_fontsize_vec <- rep("13", length(edge_key))
    names(edge_fontsize_vec) <- edge_key
    
    edge_fontname_vec <- rep("Helvetica", length(edge_key))
    names(edge_fontname_vec) <- edge_key
    
    eAttrs <- list(
      label    = as.list(label_vec),
      fontsize = as.list(edge_fontsize_vec),
      fontname = as.list(edge_fontname_vec)
    )
  }
  
  attrs <- list(
    graph = list(rankdir = "LR", fontsize = 20),
    node  = list(fixedsize = FALSE),
    edge  = list(arrowsize = 1.0)
  )
  
  pdf(file, width = 18, height = 12)
  
  plot_obj <- layoutGraph(
    gNEL,
    attrs     = attrs,
    nodeAttrs = nAttrs,
    edgeAttrs = eAttrs
  )
  
  renderGraph(plot_obj)
  
  if (!is.null(main_title)) {
    grid.text(main_title, y = unit(0.98, "npc"), gp = gpar(fontsize = 18))
  }
  
  dev.off()
}

check_parent_limit_plus2 <- function(amat_abn, default_max, outcome_node = "d_outcome") {
  n_parents <- rowSums(amat_abn)
  
  allowed <- setNames(rep(default_max, length(n_parents)), names(n_parents))
  if (outcome_node %in% names(allowed)) {
    allowed[outcome_node] <- default_max + 2
  }
  
  bad_nodes <- names(n_parents)[n_parents > allowed[names(n_parents)]]
  
  list(
    n_parents = n_parents,
    allowed   = allowed,
    max_found = max(n_parents),
    bad_nodes = bad_nodes
  )
}

sanitize_name <- function(x) {
  gsub("[^A-Za-z0-9_]+", "_", x)
}

###############################################################################
# 2. MAIN RUNNER
###############################################################################

run_abn_analysis <- function(data_file, out_dir, suffix, diet_var = "zhei2015_total_score_pm") {
  
  if (!dir.exists(out_dir)) dir.create(out_dir, recursive = TRUE)
  
  dat <- read_dta(data_file)
  dat <- as.data.frame(dat)
  dat <- zap_labels(dat)
  
  vars_use <- c(
    "d_outcome", "t2", "t3",
    "AGE_pm", "SEX", "NHB", "HISP", "OTHER",
    "zses_2012_pm", "married_2012",
    diet_var,
    "fried_sum_pm"
  )
  
  missing_vars <- setdiff(vars_use, names(dat))
  if (length(missing_vars) > 0) {
    stop("Missing variables in ", basename(data_file), ": ", paste(missing_vars, collapse = ", "))
  }
  
  dat2 <- dat[, vars_use, drop = FALSE]
  names(dat2) <- vars_use
  
  factor_vars <- c(
    "d_outcome", "t2", "t3",
    "SEX", "NHB", "HISP", "OTHER",
    "married_2012"
  )
  
  numeric_vars <- c(
    "AGE_pm", "zses_2012_pm",
    diet_var,
    "fried_sum_pm"
  )
  
  for (v in intersect(factor_vars, names(dat2))) {
    dat2[[v]] <- make_bin_factor(dat2[[v]], v)
  }
  
  for (v in intersect(numeric_vars, names(dat2))) {
    dat2[[v]] <- make_numeric(dat2[[v]], v)
  }
  
  dat2 <- dat2[complete.cases(dat2), , drop = FALSE]
  
  cat("Complete-case N for", diet_var, "and", suffix, "=", nrow(dat2), "\n")
  if (nrow(dat2) == 0) stop("No complete cases remain.")
  
  abndata <- as.data.frame(dat2)
  var_names <- colnames(abndata)
  
  if (anyDuplicated(var_names)) {
    stop("Duplicate variable names in abndata: ",
         paste(var_names[duplicated(var_names)], collapse = ", "))
  }
  
  data.dists <- setNames(as.list(rep(NA_character_, length(var_names))), var_names)
  
  bin_vars <- c(
    "d_outcome", "t2", "t3",
    "SEX", "NHB", "HISP", "OTHER",
    "married_2012"
  )
  
  gauss_vars <- c(
    "AGE_pm", "zses_2012_pm",
    diet_var,
    "fried_sum_pm"
  )
  
  bin_vars   <- intersect(bin_vars, var_names)
  gauss_vars <- intersect(gauss_vars, var_names)
  
  for (v in bin_vars)   data.dists[[v]] <- "binomial"
  for (v in gauss_vars) data.dists[[v]] <- "gaussian"
  
  missing_dist <- names(data.dists)[is.na(unlist(data.dists))]
  if (length(missing_dist) > 0) {
    stop("No distribution assigned for: ", paste(missing_dist, collapse = ", "))
  }
  
  data.dists <- data.dists[var_names]
  
  if (!identical(names(data.dists), var_names)) {
    stop(
      "data.dists names do not exactly match abndata columns.\n",
      "abndata: ", paste(var_names, collapse = ", "), "\n",
      "data.dists: ", paste(names(data.dists), collapse = ", ")
    )
  }
  
  banned <- matrix(0, nrow = ncol(abndata), ncol = ncol(abndata))
  rownames(banned) <- colnames(banned) <- names(abndata)
  
  demo_vars     <- c("AGE_pm", "SEX", "NHB", "HISP", "OTHER")
  ses_vars      <- c("zses_2012_pm")
  marital_vars  <- c("married_2012")
  exposure_vars <- c(diet_var)
  frailty_vars  <- c("fried_sum_pm")
  time_vars     <- c("t2", "t3")
  outcome_vars  <- c("d_outcome")
  all_vars      <- names(abndata)
  
  # Directional ordering retained from the main ABN logic, but restricted to
  # demographic/SES nodes, HEI-2015, frailty, time indicators, and outcome.
  for (v in demo_vars) {
    banned[v, setdiff(all_vars, v)] <- 1
  }
  
  banned[setdiff(all_vars, "d_outcome"), "d_outcome"] <- 1
  
  for (v in ses_vars) {
    banned[v, c(marital_vars, exposure_vars, frailty_vars, time_vars, outcome_vars)] <- 1
  }
  
  for (v in marital_vars) {
    banned[v, c(exposure_vars, frailty_vars, time_vars, outcome_vars)] <- 1
  }
  
  for (v in exposure_vars) {
    banned[v, c(frailty_vars, time_vars, outcome_vars)] <- 1
  }
  
  for (v in frailty_vars) {
    banned[v, c(time_vars, outcome_vars)] <- 1
  }
  
  for (v in time_vars) {
    banned[tv <- v, c(demo_vars, ses_vars, marital_vars,
                      exposure_vars, frailty_vars, time_vars, outcome_vars)] <- 1
  }
  
  if (all(c("t2", "t3") %in% all_vars)) {
    banned["t2", "t3"] <- 1
  }
  
  for (tv in time_vars) {
    banned[tv, outcome_vars] <- 1
  }
  
  diag(banned) <- 0
  
  sensitivity_tag <- paste0(suffix, "_DEMOSES_HEI2015_TOTAL")
  
  write.csv(
    banned,
    file = file.path(out_dir, paste0("ABN_banned_matrix_", sensitivity_tag, ".csv"))
  )
  
  max.parents.vec <- 1:4
  outcome_node <- "d_outcome"
  
  score.cache.list <- list()
  learned.list     <- list()
  fit.list         <- list()
  dag.list         <- list()
  arc_tables       <- list()
  edge_tables      <- list()
  parentcheck.list <- list()
  retain.list      <- list()
  maxparent.list   <- list()
  
  score.summary <- data.frame(
    max_parents_non_outcome = integer(0),
    max_parents_outcome     = integer(0),
    score                   = numeric(0),
    mlik                    = numeric(0),
    max_found               = integer(0),
    outcome_n_parents       = integer(0),
    n_retained              = integer(0),
    stringsAsFactors = FALSE
  )
  
  for (mp in max.parents.vec) {
    
    outcome_parent_cap <- mp + 2
    
    cat("\n====================================================\n")
    cat("Running DEMO/SES ABN with HEI-2015 total score",
        "| outcome =", suffix,
        "| non-outcome max.parents =", mp,
        "| d_outcome max.parents =", outcome_parent_cap, "\n")
    cat("====================================================\n")
    
    max.parents.use <- as.list(setNames(rep(mp, length(var_names)), var_names))
    max.parents.use[[outcome_node]] <- outcome_parent_cap
    
    retain_use <- matrix(0, nrow = ncol(abndata), ncol = ncol(abndata))
    rownames(retain_use) <- colnames(retain_use) <- names(abndata)
    
    for (tv in time_vars) {
      retain_use[outcome_node, tv] <- 1
    }
    
    diag(retain_use) <- 0
    
    conflicts <- which(banned == 1 & retain_use == 1, arr.ind = TRUE)
    if (nrow(conflicts) > 0) {
      retain_use[conflicts] <- 0
    }
    
    bayes_ctrl <- build.control(method = "bayes", max.mode.error = 0, ncores = 4)
    
    mycache <- buildScoreCache(
      data.df      = as.data.frame(abndata),
      data.dists   = data.dists,
      dag.banned   = banned,
      dag.retained = retain_use,
      max.parents  = max.parents.use,
      method       = "bayes",
      control      = bayes_ctrl
    )
    
    mydag <- searchHillClimber(score.cache = mycache)
    
    fabn <- fitAbn(
      object  = mydag,
      method  = "bayes",
      control = bayes_ctrl
    )
    
    dag_mat <- get_abn_dag(
      learned_obj = mydag,
      node_names  = colnames(abndata)
    )
    
    parent_check <- check_parent_limit_plus2(
      amat_abn     = dag_mat,
      default_max  = mp,
      outcome_node = outcome_node
    )
    
    if (length(parent_check$bad_nodes) > 0) {
      stop(
        "Parent limit exceeded. Offending nodes: ",
        paste(parent_check$bad_nodes, collapse = ", ")
      )
    }
    
    arc_df <- make_arc_df(dag_mat)
    
    edge_df <- build_edge_labels(
      data      = abndata,
      amat_abn  = dag_mat,
      dist.list = data.dists
    )
    
    list_name <- paste0("mp", mp)
    
    score.cache.list[[list_name]] <- mycache
    learned.list[[list_name]]     <- mydag
    fit.list[[list_name]]         <- fabn
    dag.list[[list_name]]         <- dag_mat
    arc_tables[[list_name]]       <- arc_df
    edge_tables[[list_name]]      <- edge_df
    parentcheck.list[[list_name]] <- parent_check
    retain.list[[list_name]]      <- retain_use
    maxparent.list[[list_name]]   <- max.parents.use
    
    current.score <- extract_scalar_score(mydag)
    current.mlik  <- if (!is.null(fabn$mlik)) as.numeric(fabn$mlik) else NA_real_
    
    score.summary <- rbind(
      score.summary,
      data.frame(
        max_parents_non_outcome = mp,
        max_parents_outcome     = outcome_parent_cap,
        score                   = current.score,
        mlik                    = current.mlik,
        max_found               = parent_check$max_found,
        outcome_n_parents       = unname(parent_check$n_parents[outcome_node]),
        n_retained              = sum(retain_use != 0),
        stringsAsFactors = FALSE
      )
    )
    
    write.csv(
      retain_use,
      file = file.path(out_dir, paste0("ABN_retain_matrix_", sensitivity_tag, "_mp", mp, "_OUTCOME_PLUS2.csv"))
    )
    
    write.csv(
      stack(max.parents.use),
      file = file.path(out_dir, paste0("ABN_nodewise_maxparents_", sensitivity_tag, "_mp", mp, "_OUTCOME_PLUS2.csv")),
      row.names = FALSE
    )
    
    pdf(
      file.path(out_dir, paste0("ABN_plotAbn_", sensitivity_tag, "_mp", mp, "_OUTCOME_PLUS2.pdf")),
      width = 14, height = 10
    )
    plotAbn(dag = mydag, labels = TRUE)
    dev.off()
    
    plot_rgraphviz_abn(
      amat_abn   = dag_mat,
      edge_df    = edge_df,
      dist.list  = data.dists,
      file       = file.path(out_dir, paste0("ABN_Rgraphviz_labeled_", sensitivity_tag, "_mp", mp, "_OUTCOME_PLUS2.pdf")),
      main_title = paste("ABN sensitivity:", suffix,
                         "| HEI-2015 total score | demographics + SES only | non-outcome max.parents =", mp,
                         "; d_outcome max.parents =", outcome_parent_cap)
    )
    
    write.csv(
      arc_df,
      file = file.path(out_dir, paste0("ABN_arcs_", sensitivity_tag, "_mp", mp, "_OUTCOME_PLUS2_parent_to_child.csv")),
      row.names = FALSE
    )
    
    write.csv(
      edge_df,
      file = file.path(out_dir, paste0("ABN_arcs_", sensitivity_tag, "_mp", mp, "_OUTCOME_PLUS2_with_effects.csv")),
      row.names = FALSE
    )
    
    write.csv(
      data.frame(
        child       = names(parent_check$n_parents),
        n_parents   = as.integer(parent_check$n_parents),
        allowed_max = as.integer(parent_check$allowed[names(parent_check$n_parents)]),
        stringsAsFactors = FALSE
      ),
      file = file.path(out_dir, paste0("ABN_parent_counts_", sensitivity_tag, "_mp", mp, "_OUTCOME_PLUS2.csv")),
      row.names = FALSE
    )
    
    save(
      mycache, mydag, fabn, retain_use, max.parents.use,
      file = file.path(out_dir, paste0("ABN_", sensitivity_tag, "_mp", mp, "_OUTCOME_PLUS2.RData"))
    )
  }
  
  print(score.summary)
  
  write.csv(
    score.summary,
    file = file.path(out_dir, paste0("ABN_score_summary_", sensitivity_tag, "_OUTCOME_PLUS2.csv")),
    row.names = FALSE
  )
  
  if (all(is.na(score.summary$mlik))) {
    best.idx <- if (all(is.na(score.summary$score))) 1 else which.max(score.summary$score)
  } else {
    best.idx <- which.max(score.summary$mlik)
  }
  
  best.mp <- score.summary$max_parents_non_outcome[best.idx]
  
  cat("\nBest model selected at non-outcome max.parents =", best.mp, "\n")
  
  best.amat    <- dag.list[[paste0("mp", best.mp)]]
  best.arc_df  <- arc_tables[[paste0("mp", best.mp)]]
  best.edge_df <- edge_tables[[paste0("mp", best.mp)]]
  best.pcheck  <- parentcheck.list[[paste0("mp", best.mp)]]
  best.retain  <- retain.list[[paste0("mp", best.mp)]]
  
  write.csv(
    best.arc_df,
    file = file.path(out_dir, paste0("ABN_best_arcs_", sensitivity_tag, "_mp", best.mp, "_OUTCOME_PLUS2_parent_to_child.csv")),
    row.names = FALSE
  )
  
  write.csv(
    best.edge_df,
    file = file.path(out_dir, paste0("ABN_best_arcs_", sensitivity_tag, "_mp", best.mp, "_OUTCOME_PLUS2_with_effects.csv")),
    row.names = FALSE
  )
  
  write.csv(
    data.frame(
      child       = names(best.pcheck$n_parents),
      n_parents   = as.integer(best.pcheck$n_parents),
      allowed_max = as.integer(best.pcheck$allowed[names(best.pcheck$n_parents)]),
      stringsAsFactors = FALSE
    ),
    file = file.path(out_dir, paste0("ABN_best_parent_counts_", sensitivity_tag, "_mp", best.mp, "_OUTCOME_PLUS2.csv")),
    row.names = FALSE
  )
  
  write.csv(
    best.retain,
    file = file.path(out_dir, paste0("ABN_best_retain_matrix_", sensitivity_tag, "_mp", best.mp, "_OUTCOME_PLUS2.csv"))
  )
  
  saveRDS(abndata,          file = file.path(out_dir, paste0("ABN_analysis_dataset_", sensitivity_tag, ".rds")))
  saveRDS(data.dists,       file = file.path(out_dir, paste0("ABN_dist_list_", sensitivity_tag, ".rds")))
  saveRDS(banned,           file = file.path(out_dir, paste0("ABN_banned_matrix_", sensitivity_tag, ".rds")))
  saveRDS(retain.list,      file = file.path(out_dir, paste0("ABN_retain_list_", sensitivity_tag, ".rds")))
  saveRDS(score.cache.list, file = file.path(out_dir, paste0("ABN_score_cache_list_", sensitivity_tag, ".rds")))
  saveRDS(learned.list,     file = file.path(out_dir, paste0("ABN_learned_list_", sensitivity_tag, ".rds")))
  saveRDS(fit.list,         file = file.path(out_dir, paste0("ABN_fit_list_", sensitivity_tag, ".rds")))
  saveRDS(dag.list,         file = file.path(out_dir, paste0("ABN_native_dag_list_", sensitivity_tag, ".rds")))
  saveRDS(arc_tables,       file = file.path(out_dir, paste0("ABN_arc_tables_", sensitivity_tag, ".rds")))
  saveRDS(edge_tables,      file = file.path(out_dir, paste0("ABN_edge_tables_", sensitivity_tag, ".rds")))
  saveRDS(parentcheck.list, file = file.path(out_dir, paste0("ABN_parentcheck_list_", sensitivity_tag, ".rds")))
  
  capture.output(
    str(score.cache.list),
    file = file.path(out_dir, paste0("ABN_cache_structure_", sensitivity_tag, ".txt"))
  )
  
  capture.output(
    str(learned.list),
    file = file.path(out_dir, paste0("ABN_learned_structure_", sensitivity_tag, ".txt"))
  )
  
  capture.output(
    str(fit.list),
    file = file.path(out_dir, paste0("ABN_fit_structure_", sensitivity_tag, ".txt"))
  )
  
  capture.output(
    str(dag.list),
    file = file.path(out_dir, paste0("ABN_native_dag_structure_", sensitivity_tag, ".txt"))
  )
  
  cat("\nAll outputs saved to:\n", out_dir, "\n")
  cat("Best model non-outcome max.parents =", best.mp, "\n")
  cat("Best model maximum observed parents =", max(rowSums(best.amat)), "\n")
  
  cat("\nArcs pointing INTO d_outcome in best model:\n")
  print(best.arc_df[best.arc_df$to == "d_outcome", , drop = FALSE])
  
  cat("\nArcs pointing INTO fried_sum_pm in best model:\n")
  print(best.arc_df[best.arc_df$to == "fried_sum_pm", , drop = FALSE])
  
  cat("\nArcs pointing INTO", diet_var, "in best model:\n")
  print(best.arc_df[best.arc_df$to == diet_var, , drop = FALSE])
  
  invisible(list(
    score.summary = score.summary,
    best.mp       = best.mp,
    best.amat     = best.amat,
    best.arc_df   = best.arc_df,
    best.edge_df  = best.edge_df
  ))
}

###############################################################################
# 3. RUN HEI-2015 TOTAL SCORE ONLY
###############################################################################

out_dir_main <- "D:/16GBBACKUPUSB/BACKUP_USB_SEPTEMBER2014/SUMMER_STUDENT_2026/HRS_DIET_FRAILTY_COG/OUTPUT/ABN_HEI2015_TOTAL_DEMOSES_SENSITIVITY"

data_file_mcidem <- "D:/16GBBACKUPUSB/BACKUP_USB_SEPTEMBER2014/SUMMER_STUDENT_2026/HRS_DIET_FRAILTY_COG/FINAL_DATA/HRS_ABN_MCIDEM_READY.dta"
data_file_dem    <- "D:/16GBBACKUPUSB/BACKUP_USB_SEPTEMBER2014/SUMMER_STUDENT_2026/HRS_DIET_FRAILTY_COG/FINAL_DATA/HRS_ABN_DEM_READY.dta"
data_file_mci    <- "D:/16GBBACKUPUSB/BACKUP_USB_SEPTEMBER2014/SUMMER_STUDENT_2026/HRS_DIET_FRAILTY_COG/FINAL_DATA/HRS_ABN_MCI_READY.dta"

diet_var <- "zhei2015_total_score_pm"

cat("\nFinal dietary variable used in this sensitivity analysis:\n")
print(diet_var)
cat("\nCovariates retained: AGE_pm, SEX, NHB, HISP, OTHER, zses_2012_pm, married_2012\n")
cat("Excluded: smoking, alcohol, physical activity, BMI, hypertension, diabetes, heart disease, stroke, and self-rated health.\n")

if (!dir.exists(out_dir_main)) dir.create(out_dir_main, recursive = TRUE)

all_results <- list()

res_DEMMCI <- run_abn_analysis(
  data_file = data_file_mcidem,
  out_dir   = file.path(out_dir_main, "DEMMCI_HEI2015_TOTAL_DEMOSES"),
  suffix    = "DEMMCI",
  diet_var  = diet_var
)

res_DEM <- run_abn_analysis(
  data_file = data_file_dem,
  out_dir   = file.path(out_dir_main, "DEM_HEI2015_TOTAL_DEMOSES"),
  suffix    = "DEM",
  diet_var  = diet_var
)

res_MCI <- run_abn_analysis(
  data_file = data_file_mci,
  out_dir   = file.path(out_dir_main, "MCI_HEI2015_TOTAL_DEMOSES"),
  suffix    = "MCI",
  diet_var  = diet_var
)

all_results[[diet_var]] <- list(
  DEMMCI = res_DEMMCI,
  DEM    = res_DEM,
  MCI    = res_MCI
)

saveRDS(
  all_results,
  file = file.path(out_dir_main, "ABN_HEI2015_TOTAL_DEMOSES_all_outcomes_results.rds")
)

cat("\nFinished HEI-2015 total score demographic/SES sensitivity ABN runs.\n")
cat("Master output folder:\n", out_dir_main, "\n")


***********************************************************
capture log close
capture log using "D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_DIET_FRAILTY_COG\OUTPUT\GSEM_REDUCED_FROMABN.txt",text replace


global PROJ    "D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_DIET_FRAILTY_COG"
global DATA    "$PROJ\FINAL_DATA"
global OUT     "$PROJ\OUTPUT"


********************REDUCED GSEM**************************

********************************************************************************
* SENSITIVITY ANALYSIS 3B:
* REDUCED ABN-INFORMED GSEM
* Outcome: incident MCI/CIND or dementia only
* Reduced ABN: demographic/SES + HEI-2015 + frailty
********************************************************************************

use "$DATA\HRS_GSEM_WEIBULL_DIET_FRAILTY_FINAL.dta", clear

stset ageevent_cog, origin(time ageenter) enter(time ageenter) ///
    failure(fail_cog==1) id(HHIDPN)

********************************************************************************
* Reduced ABN-derived structural equations
* Based on 4-parent-per-child reduced DEMMCI ABN
********************************************************************************

local eqs_reduced ///
    (zses_2012_cont <- AGE_cont SEX NHB HISP, ///
        family(gaussian) link(identity)) ///
    (married_2012 <- AGE_cont SEX zses_2012_cont, ///
        family(binomial) link(logit)) ///
    (zhei2015_total_score_cont <- AGE_cont SEX OTHER zses_2012_cont, ///
        family(gaussian) link(identity)) ///
    (fried_sum_cont <- AGE_cont SEX zses_2012_cont zhei2015_total_score_cont, ///
        family(gaussian) link(identity))

********************************************************************************
* Reduced ABN-informed GSEM
* Direct parents of cognitive outcome after omitting t2/t3:
* AGE_cont, NHB, fried_sum_cont
********************************************************************************

gsem ///
    (_t <- AGE_cont NHB fried_sum_cont, ///
        family(weibull, failure(_d)) link(log)) ///
    `eqs_reduced' ///
    , nocapslatent method(ml) vce(robust)

estimates store gsem_weib_abn_demSES_HEI

estat eform

capture log close



*********************UPDATED TABLE 1 WITH HEI QUARTILES************************

*********************************
capture log using ///
"D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_DIET_FRAILTY_COG\OUTPUT\TABLE1_UPDATED.txt", ///
text replace

use "D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_DIET_FRAILTY_COG\FINAL_DATA\HRS_HEI_FRAIL_ANALYTIC_FINALfin.dta",clear



capture drop hei_q
xtile hei_q = hei2015_total_score if hei2015_total_score < ., nq(4)
capture label drop hei_q
label define hei_q 1 "Q1 (lowest)" 2 "Q2" 3 "Q3" 4 "Q4 (highest)"
label values hei_q hei_q


********************************************************************************
** 3. TABLE 1: SURVEY-WEIGHTED BASELINE CHARACTERISTICS
********************************************************************************

************************BY HEI CATEGORIES**********************

* Continuous variables
foreach x of varlist r13agey_e  ///
             hei2015_total_score heix* C3A_FF_13-C9AP_FF_13  fried_sum {
    svy: mean `x'
    svy: mean `x', over(hei_q)
}

* Categorical variables
foreach x of varlist ragender RACE_ETHN totwealth_2012 marital_2012 education ///
                                smoking_2012 alcohol_2012 ///
                                physic_act_2012 srh_2012 bmibr_2012 hbp_ever_2012 diab_ever_2012 stroke_ever_2012 heart_ever_2012 fried_status {
    svy: tab hei_q `x', row percent se
}

* Design-adjusted p-values

foreach y of varlist r13agey_e  ///
             hei2015_total_score heix* C3A_FF_13-C9AP_FF_13 fried_sum {
    svy: regress `y' i.hei_q 
	testparm i.hei_q
}


foreach x  of varlist ragender RACE_ETHN totwealth_2012 marital_2012 education ///
                                smoking_2012 alcohol_2012 ///
                                physic_act_2012 srh_2012 bmibr_2012 hbp_ever_2012 diab_ever_2012 stroke_ever_2012 heart_ever_2012 fried_status {
    svy: tab hei_q `x', row percent pearson
}


**************************BY FRAILTY STATUS************************************


* Continuous variables
foreach x of varlist r13agey_e  ///
             hei2015_total_score heix* C3A_FF_13-C9AP_FF_13  fried_sum {
    svy: mean `x'
    svy: mean `x', over(fried_status)
}

* Categorical variables
foreach x in ragender RACE_ETHN totwealth_2012 marital_2012 education ///
                                smoking_2012 alcohol_2012 ///
                                physic_act_2012 srh_2012 bmibr_2012 hbp_ever_2012 diab_ever_2012 stroke_ever_2012 heart_ever_2012 {
    svy: tab fried_status `x', row percent se
}

* Design-adjusted p-values

foreach y of varlist r13agey_e hei2015_total_score heix* C3A_FF_13-C9AP_FF_13 fried_sum {
    svy: regress `y' i.fried_status 
	testparm i.fried_status
}


foreach x in ragender RACE_ETHN totwealth_2012 marital_2012 education ///
                                smoking_2012 alcohol_2012 ///
                                physic_act_2012 srh_2012 bmibr_2012 hbp_ever_2012 diab_ever_2012 stroke_ever_2012 heart_ever_2012 {
    svy: tab fried_status `x', row percent pearson
}

************Quartile boundaries*************

tabstat hei2015_total_score if sample_final == 1, statistics(p25 p50 p75)

save ///
"D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_DIET_FRAILTY_COG\FINAL_DATA\HRS_HEI_FRAIL_ANALYTIC_FINALfin.dta", ///
replace

capture log close



   