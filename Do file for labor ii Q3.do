*Q3
*a) 
* Set the working directory
cd "/Users/yuanhaining/Desktop/"

* Load the dataset
use laborHW1_cps_1984-2010.dta, clear

* Get summary statistics for all variables
summarize

* Get detailed percentiles (25th, 50th, 75th) for hours worked last week
summarize hrswork, detail
*------------------------------------------------------------*
* PART (b): Labor force participation and number of children
*------------------------------------------------------------*
* (i) Overall labor force participation rate
summarize emp_ind
display "Overall labor force participation rate = " r(mean)

* (ii) Labor force participation among women with no children
summarize emp_ind if nKids == 0
display "Participation rate (no children) = " r(mean)

* (iii) Labor force participation among women with 1 or 2 children
summarize emp_ind if nKids == 1 | nKids == 2
display "Participation rate (1 or 2 children) = " r(mean)

*------------------------------------------------------------*
* PART (c): Relationship between wages and hours worked
*------------------------------------------------------------*
* 1 Regression in levels: hours (uhrswork) on wage
regress uhrswork wage
display "Interpretation: A one-unit increase in hourly wage changes usual weekly hours by " _b[wage] " hours."

*️2 Regression: log(hours) on wage
gen lnuhrswork = ln(uhrswork)
regress lnuhrswork wage
display "Interpretation: A one-unit (1 dollar) increase in wage changes usual hours by " _b[wage]*100 " percent approximately."

*3.Regression: hours on log(wage)
gen lnwage = ln(wage)
regress uhrswork lnwage
display "Interpretation: A 1% increase in wage changes hours by approximately " _b[lnwage]/100 " hours."

*4 Regression: log(hours) on log(wage)
regress lnuhrswork lnwage
display "Interpretation: This coefficient is the wage elasticity of labor supply (Marshallian elasticity)."
display "A 1% increase in wage changes hours worked by " _b[lnwage]*100 " percent."


