* HRS HCNS HEI-2015 comparison; Stata 16+
* Run from raw HCNS13_R_NT.dta. No original files overwritten.
* V2 is an adapted FFQ estimate, NOT a validated FPED reconstruction.
* Legacy logic retained, except typo and explicit component 8 name.
* Edit paths if needed. Existing HHIDPN is preserved.
version 16
set more off
local root "E:/16GBBACKUPUSB/BACKUP_USB_SEPTEMBER2014/SUMMER_STUDENT_2025/HRS_NHANES_HEI_EPICLOCKS_MORT"
local out "`root'/OUTPUT/HRS/HEI2015_V2"
capture mkdir "`out'"
use "`root'/FINAL_DATA/HRS/HCNS13_R_NT.dta", clear
isid HHID PN
isid HHIDPN
assert HCNSVERSION==5
assert HHIDPN==HHID*100+PN

**STEP A: RUN STATA SCRIPTS FOR LEGUMES:



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



**STEP B: RUN STATA SCRIPT FOR HEI-2015



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


capture drop monopoly
capture drop addsugc
capture drop solfatc
capture drop maxalcgr
capture drop ethcal
capture drop exalccal
capture drop emptycal10
capture drop vegden
* Legacy scores generated from raw data
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
capture drop addsugmax 
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




foreach var in 1_totalveg 2_greens_and_bean 3_totalfruit 4_wholefruit 5_wholegrain 6_totaldairy 7_totprot 8_seaplant_prot 9_fattyacid 10_sodium 11_refinedgrain 12_addedsugar 13_saturatedfat {
replace heix`var'=0 if kcal==0
}
foreach var in 1_totalveg 2_greens_and_bean 3_totalfruit 4_wholefruit 5_wholegrain 6_totaldairy 7_totprot 8_seaplant_prot 9_fattyacid 10_sodium 11_refinedgrain 12_addedsugar 13_saturatedfat {
replace heix`var'=0 if heix`var'<0 & heix`var'!=.
}
foreach var in 9_fattyacid 10_sodium 11_refinedgrain {
replace heix`var'=10 if heix`var'>10 & heix`var'!=.
}
replace heix12_addedsugar=10 if heix12_addedsugar>10 & heix12_addedsugar!=.
replace heix13_saturatedfat=10 if heix13_saturatedfat>10 & heix13_saturatedfat!=.


gen hei2015_total_score=heix1_totalveg+heix2_greens_and_bean+heix3_totalfruit+ ///
heix4_wholefruit+heix5_wholegrain+heix6_totaldairy+heix7_totprot+heix8_seaplant_prot ///
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






su hei*



* ===== V2: adapted HEI-2015, all new variables use h15v2_ prefix =====
* Food coefficients below are provisional analyst assumptions per FFQ serving,
* not supplied by the codebook or validated against USDA FPED.
* Mixed dishes are approximate; other write-in foods not decomposed.
* Peas/lima beans treated as starchy vegetables; fortified soy milk assumed.
* Crackers use split items only, not aggregate C7S.
* Whole grain dry ingredient grams / 16 is an approximate ounce-equivalent conversion.
* For publication, replace provisional coefficients with validated food-level crosswalk.
gen double h15v2_kcal = CALOR_SUM if CALOR_SUM>0 & CALOR_SUM<.
gen double h15v2_wholefruit = 0.5*C4A_FF_13 + 0.5*C4B_FF_13 + 0.75*C4D_FF_13 + 0.5*C4E_FF_13 + 0.25*C4F_FF_13 + ///
    0.5*C4G_FF_13 + 1*C4H_FF_13 + 0.75*C4J_FF_13 + 0.5*C4M_FF_13 + 0.5*C4P_FF_13 + ///
    0.5*C4Q_FF_13 + 0.5*C4R_FF_13 + 0.5*C4S_FF_13
gen double h15v2_juice = 0.75*C4C_FF_13 + 0.75*C4I_FF_13 + 0.75*C4K_FF_13 + 0.75*C4L_FF_13 + 0.75*C4N_FF_13 + ///
    0.75*C4O_FF_13
gen double h15v2_vegbase = 0.5*C5A_FF_13 + 0.5*C5F_FF_13 + 0.5*C5G_FF_13 + 0.5*C5H_FF_13 + 0.5*C5I_FF_13 + ///
    0.5*C5J_FF_13 + 0.5*C5K_FF_13 + 0.5*C5L_FF_13 + 0.5*C5M_FF_13 + 0.5*C5N_FF_13 + ///
    0.5*C5O_FF_13 + 0.5*C5Q_FF_13 + 0.5*C5R_FF_13 + 0.5*C5S_FF_13 + 0.5*C5T_FF_13 + ///
    0.5*C5V_FF_13 + 0.5*C5W_FF_13 + 0.5*C5X_FF_13 + 0.5*C5Y_FF_13 + 0.5*C5Z_FF_13 + ///
    0.5*C5AB_FF_13 + 0.5*C7P_FF_13 + 0.75*C5B_FF_13 + 0.5*C5C_FF_13 + 0.125*C5D_FF_13 + ///
    0.5*C5U_FF_13 + 0.25*C5AA_FF_13 + 0.75*C7Q_FF_13 + 0.25*C7R_FF_13 + 0.25*C7T_FF_13 + ///
    0.0625*C9AF_FF_13
gen double h15v2_darkgreen = 0.5*C5G_FF_13 + 0.5*C5T_FF_13 + 0.5*C5U_FF_13 + 0.5*C5V_FF_13 + 0.5*C5X_FF_13
gen double h15v2_pulse = 0.5*C5P_FF_13
gen double h15v2_dairy = 1*C3A_FF_13 + 1*C3B_FF_13 + 1*C3C_FF_13 + 1*C3D_FF_13 + 0.3*C3G_FF_13 + ///
    0.3*C3H_FF_13 + 0.75*C3I_FF_13 + 0.75*C3J_FF_13 + 0.5*C3L_FF_13 + 0.67*C3N_FF_13 + ///
    1*C7T_FF_13 + 0.5*C8P_FF_13
gen double h15v2_animal = 1*C6A_FF_13 + 1*C6B_FF_13 + 1*C6C_FF_13 + 0.5*C6D_FF_13 + 3*C6E_FF_13 + ///
    3*C6F_FF_13 + 3*C6G_FF_13 + 1.5*C6H_FF_13 + 1.5*C6I_FF_13 + 2*C6J_FF_13 + ///
    2*C6K_FF_13 + 3*C6L_FF_13 + 3*C6M_FF_13 + 2*C6N_FF_13 + 4*C6O_FF_13 + ///
    4*C6P_FF_13 + 3*C6Q_FF_13 + 3*C6R_FF_13 + 0.5*C7T_FF_13
gen double h15v2_fish = 3*C6S_FF_13 + 2*C6T_FF_13 + 4*C6U_FF_13 + 4*C6V_FF_13 + 4*C6W_FF_13
gen double h15v2_plant = 2*C5E_FF_13 + 2*C9F_FF_13 + 2*C9V_FF_13 + 2*C9W_FF_13 + 2*C9X_FF_13
gen double h15v2_refined = 0.75*C7A_FF_13 + 1*C7C_FF_13 + 1*C7E_FF_13 + 0.75*C7F_FF_13 + 0.25*C7G_FF_13 + ///
    3*C7H_FF_13 + 1.5*C7I_FF_13 + 1*C7K_FF_13 + 2*C7L_FF_13 + 1*C7M_FF_13 + ///
    0.5*C7N_FF_13 + 2*C7O_FF_13 + 0.25*C7SA_FF_13 + 1*C7SB_FF_13 + 3*C7T_FF_13 + ///
    0.5*C6T_FF_13 + 1*C9I_FF_13 + 0.5*C9J_FF_13 + 0.5*C9K_FF_13 + 0.5*C9L_FF_13 + ///
    1*C9M_FF_13 + 1.5*C9N_FF_13 + 1*C9O_FF_13 + 1*C9P_FF_13 + 1*C9Q_FF_13 + ///
    1*C9R_FF_13 + 1.5*C9S_FF_13 + 1.5*C9T_FF_13 + 1.5*C9U_FF_13 + 0.5*C9Y_FF_13 + ///
    0.5*C9Z_FF_13 + 0.25*C9AA_FF_13
gen double h15v2_totalveg = h15v2_vegbase+h15v2_pulse
gen double h15v2_greens = h15v2_darkgreen+h15v2_pulse
gen double h15v2_totalfruit = h15v2_wholefruit+h15v2_juice
gen double h15v2_wholegrain = WHSUB_SUM/16
gen double h15v2_seaplant = h15v2_fish+h15v2_plant+4*h15v2_pulse
gen double h15v2_protein = h15v2_animal+h15v2_seaplant
gen double h15v2_fatratio = (MONFAT_SUM+POLY_SUM)/SATFAT_SUM if SATFAT_SUM>0 & SATFAT_SUM<.
gen double h15v2_sodium = SODIUM_SUM/h15v2_kcal
gen double h15v2_addsugar = 400*ADDSUG_SUM/h15v2_kcal
gen double h15v2_satfat = 900*SATFAT_SUM/h15v2_kcal
gen double h15v2_d01 = 1000*h15v2_totalveg/h15v2_kcal
gen double h15v2_s01 = max(0,min(5,5*h15v2_d01/1.1)) if h15v2_d01>=0 & h15v2_d01<. & h15v2_kcal<.
label var h15v2_s01 "Adapted HEI-2015 V2: totalveg"
assert inrange(h15v2_s01,0,5) if !missing(h15v2_s01)
gen double h15v2_d02 = 1000*h15v2_greens/h15v2_kcal
gen double h15v2_s02 = max(0,min(5,5*h15v2_d02/0.2)) if h15v2_d02>=0 & h15v2_d02<. & h15v2_kcal<.
label var h15v2_s02 "Adapted HEI-2015 V2: greens"
assert inrange(h15v2_s02,0,5) if !missing(h15v2_s02)
gen double h15v2_d03 = 1000*h15v2_totalfruit/h15v2_kcal
gen double h15v2_s03 = max(0,min(5,5*h15v2_d03/0.8)) if h15v2_d03>=0 & h15v2_d03<. & h15v2_kcal<.
label var h15v2_s03 "Adapted HEI-2015 V2: totalfruit"
assert inrange(h15v2_s03,0,5) if !missing(h15v2_s03)
gen double h15v2_d04 = 1000*h15v2_wholefruit/h15v2_kcal
gen double h15v2_s04 = max(0,min(5,5*h15v2_d04/0.4)) if h15v2_d04>=0 & h15v2_d04<. & h15v2_kcal<.
label var h15v2_s04 "Adapted HEI-2015 V2: wholefruit"
assert inrange(h15v2_s04,0,5) if !missing(h15v2_s04)
gen double h15v2_d05 = 1000*h15v2_wholegrain/h15v2_kcal
gen double h15v2_s05 = max(0,min(10,10*h15v2_d05/1.5)) if h15v2_d05>=0 & h15v2_d05<. & h15v2_kcal<.
label var h15v2_s05 "Adapted HEI-2015 V2: wholegrain"
assert inrange(h15v2_s05,0,10) if !missing(h15v2_s05)
gen double h15v2_d06 = 1000*h15v2_dairy/h15v2_kcal
gen double h15v2_s06 = max(0,min(10,10*h15v2_d06/1.3)) if h15v2_d06>=0 & h15v2_d06<. & h15v2_kcal<.
label var h15v2_s06 "Adapted HEI-2015 V2: dairy"
assert inrange(h15v2_s06,0,10) if !missing(h15v2_s06)
gen double h15v2_d07 = 1000*h15v2_protein/h15v2_kcal
gen double h15v2_s07 = max(0,min(5,5*h15v2_d07/2.5)) if h15v2_d07>=0 & h15v2_d07<. & h15v2_kcal<.
label var h15v2_s07 "Adapted HEI-2015 V2: protein"
assert inrange(h15v2_s07,0,5) if !missing(h15v2_s07)
gen double h15v2_d08 = 1000*h15v2_seaplant/h15v2_kcal
gen double h15v2_s08 = max(0,min(5,5*h15v2_d08/0.8)) if h15v2_d08>=0 & h15v2_d08<. & h15v2_kcal<.
label var h15v2_s08 "Adapted HEI-2015 V2: seaplant"
assert inrange(h15v2_s08,0,5) if !missing(h15v2_s08)
gen double h15v2_s09 = max(0,min(10,10*(h15v2_fatratio-1.2)/1.3)) if h15v2_fatratio>=0 & h15v2_fatratio<. & h15v2_kcal<.
label var h15v2_s09 "Adapted HEI-2015 V2: fatratio"
assert inrange(h15v2_s09,0,10) if !missing(h15v2_s09)
gen double h15v2_s10 = max(0,min(10,10*(2-h15v2_sodium)/0.9)) if h15v2_sodium>=0 & h15v2_sodium<. & h15v2_kcal<.
label var h15v2_s10 "Adapted HEI-2015 V2: sodium"
assert inrange(h15v2_s10,0,10) if !missing(h15v2_s10)
gen double h15v2_d11 = 1000*h15v2_refined/h15v2_kcal
gen double h15v2_s11 = max(0,min(10,10*(4.3-h15v2_d11)/2.5)) if h15v2_d11>=0 & h15v2_d11<. & h15v2_kcal<.
label var h15v2_s11 "Adapted HEI-2015 V2: refined"
assert inrange(h15v2_s11,0,10) if !missing(h15v2_s11)
gen double h15v2_s12 = max(0,min(10,10*(26-h15v2_addsugar)/19.5)) if h15v2_addsugar>=0 & h15v2_addsugar<. & h15v2_kcal<.
label var h15v2_s12 "Adapted HEI-2015 V2: addsugar"
assert inrange(h15v2_s12,0,10) if !missing(h15v2_s12)
gen double h15v2_s13 = max(0,min(10,10*(15-h15v2_satfat)/8)) if h15v2_satfat>=0 & h15v2_satfat<. & h15v2_kcal<.
label var h15v2_s13 "Adapted HEI-2015 V2: satfat"
assert inrange(h15v2_s13,0,10) if !missing(h15v2_s13)
gen double hei2015_total_score_v2 = h15v2_s01+h15v2_s02+h15v2_s03+h15v2_s04+h15v2_s05+h15v2_s06+h15v2_s07+h15v2_s08+h15v2_s09+h15v2_s10+h15v2_s11+h15v2_s12+h15v2_s13
assert inrange(hei2015_total_score_v2,0,100.000001) if !missing(hei2015_total_score_v2)
label var hei2015_total_score_v2 "Adapted FFQ HEI-2015 V2 (provisional)"

* ===== Paired comparisons, unweighted; no exclusions imposed =====
local oldvars heix1_totalveg heix2_greens_and_bean heix3_totalfruit heix4_wholefruit heix5_wholegrain heix6_totaldairy heix7_totprot heix8_seaplant_prot heix9_fattyacid heix10_sodium heix11_refinedgrain heix12_addedsugar heix13_saturatedfat hei2015_total_score
local newvars h15v2_s01 h15v2_s02 h15v2_s03 h15v2_s04 h15v2_s05 h15v2_s06 h15v2_s07 h15v2_s08 h15v2_s09 h15v2_s10 h15v2_s11 h15v2_s12 h15v2_s13 hei2015_total_score_v2
local labels totalveg greens totalfruit wholefruit wholegrain dairy protein seaplant fatratio sodium refined addsugar satfat total
 tempname h15post
postfile `h15post' str24 component long N double pearson spearman oldmean newmean difference using "`out'/correlations.dta", replace
forvalues j=1/14 {
    local a : word `j' of `oldvars'
    local b : word `j' of `newvars'
    local lab : word `j' of `labels'
    quietly count if !missing(`a',`b')
    local n=r(N)
    local r=.
    local rho=.
    local ma=.
    local mb=.
    if `n'>0 {
        quietly summarize `a' if !missing(`a',`b')
        local ma=r(mean)
        quietly summarize `b' if !missing(`a',`b')
        local mb=r(mean)
    }
    if `n'>1 {
        capture quietly correlate `a' `b'
        if !_rc local r=r(rho)
        capture quietly spearman `a' `b'
        if !_rc local rho=r(rho)
    }
    post `h15post' ("`lab'") (`n') (`r') (`rho') (`ma') (`mb') (`mb'-`ma')
    local lim=10
    if inlist(`j',1,2,3,4,7,8) local lim=5
    if `j'==14 local lim=100
    if `n'>0 {
        twoway (scatter `b' `a', msize(tiny) mcolor(navy%25)) ///
            (function y=x, range(0 `lim') lcolor(maroon) lpattern(dash)), ///
            title("`lab'") xtitle("Original score") ytitle("Adapted V2 score") ///
            legend(off) name(h15g`j', replace)
        graph export "`out'/scatter_`lab'.png", width(1800) replace
    }
}
postclose `h15post'
gen double h15v2_diff=hei2015_total_score_v2-hei2015_total_score
gen double h15v2_avg=(hei2015_total_score_v2+hei2015_total_score)/2
quietly summarize h15v2_diff
local bias=r(mean)
local lo=r(mean)-1.96*r(sd)
local hi=r(mean)+1.96*r(sd)
twoway scatter h15v2_diff h15v2_avg, msize(tiny) yline(`bias' `lo' `hi') ///
    xtitle("Mean of scores") ytitle("V2 minus original") title("Bland-Altman: total HEI")
graph export "`out'/bland_altman.png", width(1800) replace
xtile h15v2_qold=hei2015_total_score if !missing(h15v2_diff), nq(5)
xtile h15v2_qnew=hei2015_total_score_v2 if !missing(h15v2_diff), nq(5)
tab h15v2_qold h15v2_qnew, row
pwcorr `oldvars' `newvars', obs
save "`out'/HEI2015_comparison.dta", replace
preserve
use "`out'/correlations.dta", clear
list, noobs
export delimited using "`out'/correlations.csv", replace
restore
