* --- Q4 setup: load Card & Krueger data ---
clear all
set more off

* Set the working directory
cd "/Users/yuanhaining/Desktop/"

* Load the dataset
 use cardnj.dta, clear
 
* part c:  Table 2 from Card & Krueger (1994)
* Verify data structure
describe
* ️1 Distribution of store types (Burger King, KFC, Roy Rogers, Wendy's)
tab CHAIN STATE, col

* 2 Create full-time-equivalent (FTE) employment for Wave 1
gen FTE1 = EMPFT + 0.5*EMPPT

* 3 Calculate summary statistics for Wave 1 (Pre-treatment)
bysort STATE: summarize FTE1 EMPFT EMPPT NMGRS WAGE_ST PSODA PFRY PENTREE HRSOPEN

* 4 Create FTE for Wave 2
gen FTE2 = EMPFT2 + 0.5*EMPPT2

* 5 Summary statistics for Wave 2 (Post-treatment)
bysort STATE: summarize FTE2 EMPFT2 EMPPT2 NMGRS2 WAGE_ST2 PSODA2 PFRY2 PENTREE2 HRSOPEN2

* 6 t-tests comparing NJ vs. PA
ttest FTE1, by(STATE)
ttest FTE2, by(STATE)
ttest WAGE_ST, by(STATE)
ttest WAGE_ST2, by(STATE)
ttest PSODA2, by(STATE)
ttest PFRY2, by(STATE)
ttest PENTREE2, by(STATE)

*------------------------------------------------------------*
* d)Figure 1: Distribution of Starting Wage Rates (CK 1994)
*------------------------------------------------------------*

* bar color black-and-white
set scheme s2mono

* Bin settings to match the paper's x-axis: 4.25 to ~5.55 in $0.10 steps
local start 4.25
local width 0.10

*----------------------------*
* Panel A: February 1992
*----------------------------*
twoway ///
 (histogram WAGE_ST if STATE==1 & !missing(WAGE_ST), ///
     start(`start') width(`width') percent ///
     fcolor(black%60) lcolor(black)) ///
 (histogram WAGE_ST if STATE==0 & !missing(WAGE_ST), ///
     start(`start') width(`width') percent ///
     fcolor(none) lcolor(black) lpattern(dash)), ///
 legend(order(1 "New Jersey" 2 "Pennsylvania") pos(11) ring(0) cols(1)) ///
 title("February 1992") ///
 ytitle("Percent of Stores") xtitle("Wage Range") ///
 graphregion(color(white)) plotregion(margin(zero))

graph save "fig_wave1.gph", replace
graph export "fig_wave1.png", replace

*----------------------------*
* Panel B: November 1992
*----------------------------*
twoway ///
 (histogram WAGE_ST2 if STATE==1 & !missing(WAGE_ST2), ///
     start(`start') width(`width') percent ///
     fcolor(black%60) lcolor(black)) ///
 (histogram WAGE_ST2 if STATE==0 & !missing(WAGE_ST2), ///
     start(`start') width(`width') percent ///
     fcolor(none) lcolor(black) lpattern(dash)), ///
 legend(order(1 "New Jersey" 2 "Pennsylvania") pos(11) ring(0) cols(1)) ///
 title("November 1992") ///
 ytitle("Percent of Stores") xtitle("Wage Range") ///
 graphregion(color(white)) plotregion(margin(zero))

graph save "fig_wave2.gph", replace
graph export "fig_wave2.png", replace

*----------------------------*
* Combine vertically (like the paper)
*----------------------------*
graph combine "fig_wave1.gph" "fig_wave2.gph", ///
    col(1) imargin(zero) ///
    title("Distribution of Starting Wage Rates") ///
    name(fig_all, replace)
graph export "figure1_replication.png", replace

*============================*
* e)TABLE 3 (replication)
*============================*
* Card & Krueger (1994) — Tables 3 and 4
* --- Reset / (re)build helper variables safely ---
foreach v in FTE1 FTE2 FTE2z dFTE dFTEz balanced closed2 nj_low nj_mid nj_high wagegap NJ sample {
    capture drop `v'
}

* Full-time-equivalent employment in each wave
gen FTE1 = EMPFT  + 0.5*EMPPT
gen FTE2 = EMPFT2 + 0.5*EMPPT2

* Balanced panel: employment observed in both waves
gen balanced = !missing(FTE1) & !missing(FTE2)

* Wave-2 temporarily closed: handle gracefully if STATUS2 exists
capture confirm variable STATUS2
if _rc==0 {
    * Common coding: 1=open. Adjust here if your coding differs.
    gen closed2 = (STATUS2!=. & STATUS2!=1)
}
else {
    di as text "NOTE: STATUS2 not found; treating all wave-2 stores as open."
    gen closed2 = 0
}

* Set FTE2=0 for closed stores (used in Table 3 row 5)
gen FTE2z = FTE2
replace FTE2z = 0 if closed2

* Changes
gen dFTE  = FTE2  - FTE1
gen dFTEz = FTE2z - FTE1

* New Jersey wage groups based on Wave-1 starting wage (exactly as in CK)
gen nj_low  = (STATE==1 & WAGE_ST==4.25)
gen nj_mid  = (STATE==1 & WAGE_ST>4.25 & WAGE_ST<5)
gen nj_high = (STATE==1 & WAGE_ST>=5)

* =============================== TABLE 3 ========================================
di as txt "================  TABLE 3 (replication)  ================"

* --- PA vs NJ means and changes ---
quietly summarize FTE1 if STATE==0
local pa_fte1 = r(mean)
quietly summarize FTE1 if STATE==1
local nj_fte1 = r(mean)

quietly summarize FTE2 if STATE==0
local pa_fte2 = r(mean)
quietly summarize FTE2 if STATE==1
local nj_fte2 = r(mean)

local diff_fte1 = `nj_fte1' - `pa_fte1'
local diff_fte2 = `nj_fte2' - `pa_fte2'

local pa_chg3   = `pa_fte2' - `pa_fte1'
local nj_chg3   = `nj_fte2' - `nj_fte1'
local diff_chg3 = `nj_chg3' - `pa_chg3'

quietly summarize dFTE if STATE==0 & balanced
local pa_chg4 = r(mean)
quietly summarize dFTE if STATE==1 & balanced
local nj_chg4 = r(mean)
local diff_chg4 = `nj_chg4' - `pa_chg4'

quietly summarize dFTEz if STATE==0 & balanced
local pa_chg5 = r(mean)
quietly summarize dFTEz if STATE==1 & balanced
local nj_chg5 = r(mean)
local diff_chg5 = `nj_chg5' - `pa_chg5'

* --- Within-NJ means/changes by W1 wage group ---
quietly summarize FTE1 if nj_low
local l_fte1 = r(mean)
quietly summarize FTE1 if nj_mid
local m_fte1 = r(mean)
quietly summarize FTE1 if nj_high
local h_fte1 = r(mean)

quietly summarize FTE2 if nj_low
local l_fte2 = r(mean)
quietly summarize FTE2 if nj_mid
local m_fte2 = r(mean)
quietly summarize FTE2 if nj_high
local h_fte2 = r(mean)

local l_chg3 = `l_fte2' - `l_fte1'
local m_chg3 = `m_fte2' - `m_fte1'
local h_chg3 = `h_fte2' - `h_fte1'

quietly summarize dFTE if nj_low  & balanced
local l_chg4 = r(mean)
quietly summarize dFTE if nj_mid  & balanced
local m_chg4 = r(mean)
quietly summarize dFTE if nj_high & balanced
local h_chg4 = r(mean)

quietly summarize dFTEz if nj_low  & balanced
local l_chg5 = r(mean)
quietly summarize dFTEz if nj_mid  & balanced
local m_chg5 = r(mean)
quietly summarize dFTEz if nj_high & balanced
local h_chg5 = r(mean)

* Differences within NJ (low–high, mid–high)
local d1_lowhigh = `l_fte1' - `h_fte1'
local d1_midhigh = `m_fte1' - `h_fte1'
local d2_lowhigh = `l_fte2' - `h_fte2'
local d2_midhigh = `m_fte2' - `h_fte2'
local d3_lowhigh = `l_chg3' - `h_chg3'
local d3_midhigh = `m_chg3' - `h_chg3'
local d4_lowhigh = `l_chg4' - `h_chg4'
local d4_midhigh = `m_chg4' - `h_chg4'
local d5_lowhigh = `l_chg5' - `h_chg5'
local d5_midhigh = `m_chg5' - `h_chg5'

* --- Print Table 3 as a grid ---
matrix T3 = J(5,8,.)
matrix rownames T3 = "FTE before (W1)" "FTE after (W2)" "Δ mean (unbal.)" "Δ mean (balanced)" "Δ mean (bal., closed=0)"
matrix colnames T3 = "PA (i)" "NJ (ii)" "NJ-PA (iii)" "NJ<=4.25 (iv)" "NJ 4.26-4.99 (v)" "NJ>=5 (vi)" "Low-High (vii)" "Mid-High (viii)"
matrix T3[1,1] = `pa_fte1', `nj_fte1', `diff_fte1', `l_fte1', `m_fte1', `h_fte1', `d1_lowhigh', `d1_midhigh'
matrix T3[2,1] = `pa_fte2', `nj_fte2', `diff_fte2', `l_fte2', `m_fte2', `h_fte2', `d2_lowhigh', `d2_midhigh'
matrix T3[3,1] = `pa_chg3', `nj_chg3', `diff_chg3', `l_chg3', `m_chg3', `h_chg3', `d3_lowhigh', `d3_midhigh'
matrix T3[4,1] = `pa_chg4', `nj_chg4', `diff_chg4', `l_chg4', `m_chg4', `h_chg4', `d4_lowhigh', `d4_midhigh'
matrix T3[5,1] = `pa_chg5', `nj_chg5', `diff_chg5', `l_chg5', `m_chg5', `h_chg5', `d5_lowhigh', `d5_midhigh'

matlist T3, names format(%6.2f)
di as txt "=========================================================="


* =============================== TABLE 4 ========================================
di as txt "================  TABLE 4 (replication)  ================"

* Treatment intensity: proportional raise needed in Wave 1 to reach $5.05
gen wagegap = 0
replace wagegap = (5.05 - WAGE_ST)/WAGE_ST if STATE==1 & WAGE_ST<5 & !missing(WAGE_ST)

* NJ dummy & sample as in CK
gen NJ = (STATE==1)
gen sample = balanced & !missing(WAGE_ST)

* Build control lists only if variables exist (prevents aborts)
local C1
capture confirm variable CHAIN
if _rc==0 local C1 "`C1' i.CHAIN"
capture confirm variable CO_OWNED
if _rc==0 local C1 "`C1' CO_OWNED"

local C2 "`C1'"
foreach v in SOUTHJ CENTRLJ PA1 PA2 {
    capture confirm variable `v'
    if _rc==0 local C2 "`C2' `v'"
}

* Four columns (prints regression output)
estimates clear
reg dFTE NJ if sample
estimates store m1

reg dFTE NJ wagegap if sample
estimates store m2

reg dFTE NJ wagegap `C1' if sample
estimates store m3

reg dFTE NJ wagegap `C2' if sample
estimates store m4

* Side-by-side model table (built-in)
estimates table m1 m2 m3 m4, b se stats(N r2)

di as txt "=========================================================="
* ========================== End of Tables 3 & 4 ===============================
