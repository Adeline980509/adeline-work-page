// Replication of David Card and Alan B. Krueger - Min Wage

use cardnj, clear

rename STATE state

* Setting restaurants from CHAIN variable
gen bk = 0
replace bk=1 if CHAIN==1
gen kfc = 0
replace kfc=1 if CHAIN==2
gen roys = 0
replace roys=1 if CHAIN==3
gen wendys = 0
replace wendys=1 if CHAIN==4

* High vs Low Minimum Wage Indicators - page 778
gen wage425=0
replace wage425=1 if WAGE_ST==4.25

gen wage4to5=0
replace wage4to5=1 if WAGE_ST>=4.26 & WAGE_ST<=4.99

gen wage5_=0
replace wage5_=1 if WAGE_ST>=5.00

gen wage425_2=0
replace wage425_2=1 if WAGE_ST2==4.25


* wage==5.05
* Due to rounding, refer to 5.05 as between 5.04 and 5.06 
gen wage5_2=0
replace wage5_2=1 if WAGE_ST2>=5.039 & WAGE_ST2<5.06


* Full-time Employment creation [taken directly from paper]
gen fte = EMPFT + 0.5*EMPPT + NMGRS 
gen fte2 = EMPFT2 + 0.5*EMPPT2 + NMGRS2


* Percentage of Full-time Employees 
gen ftper = (EMPFT)/(EMPFT + EMPPT) 
gen ftper2 = (EMPFT2)/(EMPFT2 + EMPPT2) 

***** Try this _ a bit closer to paper:
gen full_perc = (EMPFT+NMGRS)/(EMPFT + EMPPT + NMGRS)
gen full_perc2 = (EMPFT2+NMGRS2)/(EMPFT2 + EMPPT2 + NMGRS2)


* Price of meals as calculated by Card and Krueger - page 775
gen mealp = PSODA + PFRY + PENTREE
gen mealp2 = PSODA2 + PFRY2 + PENTREE2

********END of Variables Creation Needed*********************



		******** REPLICATING TABLE 2 ************
* Table 2 - Mean of Key Variables

* NEW JERSEY MEANS
estpost sum bk kfc roys wendys CO_OWNED fte ftper WAGE_ST wage425 mealp ///
HRSOPEN BONUS fte2 ftper2 WAGE_ST2 wage425_2 wage5_2 mealp2 HRSOPEN2 ///
SPECIAL2 if state==1
esttab using T1.csv, replace cells("mean sd") ///
title(Mean of Key Variables\label{all}) noobs nomti

* PENNSYLVANIA MEANS
estpost sum bk kfc roys wendys CO_OWNED fte ftper WAGE_ST wage425 mealp ///
HRSOPEN BONUS fte2 ftper2 WAGE_ST2 wage425_2 wage5_2 mealp2 HRSOPEN2 ///
SPECIAL2 if state==0
esttab using T1.csv, append cells("mean sd") ///
title(Mean of Key Variables\label{all}) noobs nomti


* IF WE WANT TO SEE THE DIFFERENCES (t^a) - use ttest
*panel 1
ttest bk, by(state) reverse
ttest kfc, by(state) reverse
ttest roys, by(state) reverse
ttest wendys, by(state) reverse
ttest CO_OWNED, by(state) reverse


*panel 2
ttest fte, by(state) reverse
ttest ftper, by(state) reverse
ttest WAGE_ST, by(state) reverse
ttest wage425, by(state) reverse
ttest mealp, by(state) reverse
ttest HRSOPEN, by(state) reverse
ttest BONUS, by(state) reverse
****************************************************





***********Replicating Figure 1 of Card and Krueger****

twoway (histogram WAGE_ST if state==1, width(0.1) start(4.15) percent ///
lcolor(green))(histogram WAGE_ST if state==0, width(0.1) start(4.15) ///
percent fcolor(none) lcolor(blue)), ytitle(Percent of Stores) ///
xtitle(Wage Range) xlabel(4.25(0.15)5.70) title(February 1992) ///
legend(order(1 "NJ" 2 "PA"))

twoway (histogram WAGE_ST2 if state==1, width(0.1) start(4.15) percent ///
lcolor(green))(histogram WAGE_ST2 if state==0, width(0.1) start(4.15) ///
percent fcolor(none) lcolor(blue)), ytitle(Percent of Stores) ///
xtitle(Wage Range) xlabel(4.25(0.15)5.70) title(November 1992) ///
legend(order(1 "NJ" 2 "PA"))



*******Replicating Table 3 of Card and Krueger*****

*Columns (vii) and (viii) can be manually calculated


// 1st ROW- full time employment before
*Column i ii and iii
ttest fte, by(state) unequal

*Column iv
estpost sum fte if state==1 & wage425==1
esttab using T3.csv, replace cells("mean sd") ///
title(M\label{all}) noobs nomti

*Column v
estpost sum fte if state==1 & wage4to5==1
esttab using T3.csv, append cells("mean sd") ///
title(M\label{all}) noobs nomti

*Column vi
estpost sum fte if state==1 & wage5_==1
esttab using T3.csv, append cells("mean sd") ///
title(M\label{all}) noobs nomti


// 2nd ROW- full time employment after
*Column i ii and iii
ttest fte2, by(state) unequal

*Column iv
estpost sum fte2 if state==1 & wage425==1
esttab using T3.csv, replace cells("mean sd") ///
title(M\label{all}) noobs nomti

*Column v
estpost sum fte2 if state==1 & wage4to5==1
esttab using T3.csv, append cells("mean sd") ///
title(M\label{all}) noobs nomti

*Column vi
estpost sum fte2 if state==1 & wage5_==1
esttab using T3.csv, append cells("mean sd") ///
title(M\label{all}) noobs nomti


// 3rd ROW- change in mean full time employment
*Column 1
ttest fte==fte2 if state==0, unpaired

*Column 2
ttest fte==fte2 if state==1, unpaired

*Column 3
* Can be manually calculated Col2 - Col1



*--------------------------------------------------------*
* COLUMNS 4, 5 AND 6  - ROWS 1, 2 AND 3
*Columns 4-6 is just the difference between row2 and row1 - NJ state==1
* You can run the ttest syntax to get standard errors
*Column 4
ttest fte==fte2 if state==1 & wage425==1, unpaired
*Column 5
ttest fte==fte2 if state==1 & wage4to5==1, unpaired
*Column 6
ttest fte==fte2 if state==1 & wage5_==1, unpaired


// 4th ROW- change in mean full time employment
*Column 1
ttest fte==fte2 if state==0
*Column 2
ttest fte==fte2 if state==1

* Column 3 = Col2 - Col1



*Columns 4-6 is just the difference between row2 and row1.
*Run the ttest syntax to get standard errors
*Column 4
ttest fte==fte2 if state==1 & wage425==1
*Column 5
ttest fte==fte2 if state==1 & wage4to5==1
*Column 6
ttest fte==fte2 if state==1 & wage5_==1

*************************************************************



***********Replicating Table 4 of Card and Krueger********
*Generating the dependent variable 'change in FTE'
* see page 779 of paper
gen asample=0
replace asample=1 if fte!=. & fte2!=. & WAGE_ST!=. & WAGE_ST2!=.
gen chgfte = fte2 - fte
ttest chgfte if asample==1, by(state) unequal

*Generating wage gap variable
gen gap=0
replace gap = (5.05 - WAGE_ST)/ (WAGE_ST) if state==1 & WAGE_ST<5.05

* Restricting sample to stores with available data in both waves
gen rsample=0
replace rsample = 1 if (chgfte!=.) & (WAGE_ST!=.) & (WAGE_ST2!=.)
sum chgfte if rsample==1


// Regression for reduced form models for change in employment


// NOTE THAT EQUATIONS ON PAGE 779 INCLUDES X_i - STORE CHARACTERISTICS

* For this exercise - we did not include any - hence do not expect exactness

* Row1 Column1
reg chgfte state if asample==1

* Row1 Column2
reg chgfte state bk kfc roys wendys CO_OWNED if rsample==1

* Row2 Column3
reg chgfte gap if rsample==1

* Row2 Column4
reg chgfte gap bk kfc roys wendys CO_OWNED if rsample==1


* Row2 Column5 - Here, expect the estimates to be way off. Why:
* 1. Indicators for the two regions in NJ and of eastern PA & 3 for NJ and 2 for PA??????
reg chgfte state gap bk kfc roys wendys CO_OWNED SOUTHJ CENTRALJ NORTHJ ///
PA1 PA2 if asample==1
********************************************************************************


log close


