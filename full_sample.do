*********************************************
/* 	 Christina Koetter	           */
/* 	 Data Prep & Regression		   */
/*   Intergenerational Income Elasticity   */
*********************************************

*1) prep dataset sons
*2) prep dataset fathers
*3) merger and estimation

*1.) prep dataset sons

*define wd
cd "C:\Users\..." 

*load dt which includes sons with father id
use bioparen.dta, clear

*rename variables for matchig
drop pid cid
rename hhnr cid
rename persnr pid

*drop variables which are not used and clean missings
keep cid pid fnr fybirth locchildh bioyear age
mvdecode fnr ,mv(-1/-5)
drop if fnr ==.

*gen birthyear 
gen birthyear = bioyear - age
label variable birthyear "bioyear-age"

*merge 1:m with pl.dta 
merge 1:m pid using pl.dta
drop _merge
keep plc0013_h cid pid fnr fybirth bioyear age hid syear pla0009 age birthyear locchildh

*merge 1:1 with pequiv.dta over syear
merge 1:1 pid syear using pequiv.dta
keep i11101 cid pid fnr fybirth bioyear age hid d11102ll syear d11101 plc0013_h birthyear d11109 locchildh

*keep men for which observations are available
drop if d11102ll == 2
sort cid pid
drop if fnr ==.

*generate income variable
gen incomeS = plc0013_h
label variable incomeS "gross nominal wage last month (harmonized)"

*clean age variable
rename d11101 age

*identify oldest person in hh
bys cid: egen birthyear_min = min(birthyear)
label variable birthyear_min "oldest birthyear of the person in respective household"
keep if birthyear_min == birthyear

*check for a hh with sons born in the same year
egen tag = tag(cid pid)
egen distinct = total(tag), by(cid)
tab distinct
drop if distinct >= 2
*br cid pid fnr bioyear birthyear syear age incomeS birthyear_min distinct 

*clear missings again
mvdecode syear ,mv(-1/-5)

*drop negative income
drop if incomeS <=0

*keep only observations of 30 < age <55 for sons
*tab incomeS if age >30 & age < 55
drop if age <30
drop if age >55

*rename age to identify the age of the sons further on
rename age age_S

*drop income <400
drop if incomeS <400
order cid pid incomeS

*drop id when observations for id <5
bysort pid: egen counter_pid=count(pid)
drop if counter_pid <5

*create years of measurement
sort pid syear
br cid pid incomeS syear 

bys cid: egen first_observation = min(syear)
bys cid: egen last_observation = max(syear)
gen nryrs = .
replace nryrs = last_observation - first_observation
label variable nryrs "number of years in son’s earnings average"

*include inflation (up to 1991: year 1995 = 100, since 1992: year 2015 = 100)
gen inflationrate =.
replace inflationrate = 2.5 if syear == 1984
replace inflationrate = 2 if syear == 1985
replace inflationrate = -0.1 if syear == 1986
replace inflationrate = 0.2 if syear == 1987
replace inflationrate = 1.2 if syear == 1988
replace inflationrate = 2.8 if syear == 1989
replace inflationrate = 2.8 if syear == 1990
replace inflationrate = 3.7 if syear == 1991
replace inflationrate = 5 if syear == 1992
replace inflationrate = 4.5 if syear == 1993
replace inflationrate = 2.6 if syear == 1994
replace inflationrate = 1.8 if syear == 1995
replace inflationrate = 1.3 if syear == 1996
replace inflationrate = 2 if syear == 1997
replace inflationrate = 0.9 if syear == 1998
replace inflationrate = 0.6 if syear == 1999
replace inflationrate = 1.4 if syear == 2000
replace inflationrate = 2 if syear == 2001
replace inflationrate = 1.3 if syear == 2002
replace inflationrate = 1.1 if syear == 2003
replace inflationrate = 1.7 if syear == 2004
replace inflationrate = 1.5 if syear == 2005
replace inflationrate = 1.6 if syear == 2006
replace inflationrate = 2.3 if syear == 2007
replace inflationrate = 2.6 if syear == 2008
replace inflationrate = 0.3 if syear == 2009
replace inflationrate = 1.1 if syear == 2010
replace inflationrate = 2.1 if syear == 2011
replace inflationrate = 2 if syear == 2012
replace inflationrate = 1.4 if syear == 2013
replace inflationrate = 1 if syear == 2014
replace inflationrate = 0.5 if syear == 2015
replace inflationrate = 0.5 if syear == 2016
replace inflationrate = 1.5 if syear == 2017

gen income_S =.
replace income_S = incomeS/ (1+(inflationrate/100))
label variable income_S "gross real wage sons"

*create average income (years)
bysort syear: egen average_income = mean(income_S)
label variable average_income "average income (year)"

*create growth rate to the basis year 2017
gen mean_income_2017 = 4011.708
gen growthrate_year = . 
replace growthratee_year = 1/(average_income/mean_income_2017)

gen income_s = .
replace income_s = income_S * growthrate_year
label variable average_income "weighted gross real wage"

*gen income
sort cid
by cid: egen incomes_mean=mean(income_s)
order cid pid incomes_mean income_S

*check for double characteristics for the personal id (pid)
egen tag = tag(cid counter_pid)
egen distinct = total(tag), by(cid)
*tab distinct
drop tag
drop distinct

*collapse and save
collapse cid income_s income_S incomeS age_S fnr fybirth bioyear birthyear hid d11102ll i11101 nryrs locchildh, by(pid)
save "C:\Users\...sons.dta", replace



*2) prep dataset fathers

*load dt which includes fathers
clear all
use bioparen.dta, clear

*renaming for merging
drop pid cid
rename hhnr cid
rename persnr pid

*keep only variables needed, decode missings
keep cid pid fnr fybirth bioyear age
mvdecode fnr ,mv(-1/-5)

*match fnr id to every cid member
sort cid fnr
quietly by cid: replace fnr = fnr[_n-1] if fnr >=. 
sort cid pid fnr

*drop all non fathers
keep if pid == fnr
duplicates list fnr 

*gen birthyear
gen birthyear = bioyear - age
label variable birthyear "bioyear-age"

*merge 1:m over personal id (pid)
merge 1:m pid using pl.dta
drop _merge
keep plc0013_h cid pid fnr fybirth bioyear age hid syear pla0009 age birthyear 

*merge 1:1 over pid
merge 1:1 pid syear using pequiv.dta
keep i11101 cid pid fnr fybirth bioyear age hid d11102ll syear d11101 plc0013_h birthyear d11101 d11109

*drop all women and sort
drop if d11102ll == 2
sort cid pid

sort cid fnr
quietly by cid: replace fnr = fnr[_n-1] if fnr >=. 
keep if pid == fnr

*clear age
drop age
rename d11101 age

*gen income
gen incomeF = plc0013_h
label variable incomeF "Nominaler Bruttoverdienst letzter Monat (harmonisiert) Soehne"
*br cid pid fnr syear age incomeF

*keep only observations of 30 < age < 55
*tab incomeF if age >30 & age < 55
drop if age <30
drop if age >55

*clear missings
mvdecode incomeF ,mv(-1/-5)
mvdecode incomeF ,mv(0)

*drop income below 400 
drop if incomeF <400
order cid pid incomeF

*check count observations for each pid
bysort pid: egen counter_pid=count(pid)

*drop pid with <5 observations
drop if counter_pid <5
sort cid

*clear age
rename age age_F

*inflation (up to 1991: year 1995 = 100, since 1992: year 2015 = 100)
gen inflationrate =.
replace inflationrate = 2.5 if syear == 1984
replace inflationrate = 2 if syear == 1985
replace inflationrate = -0.1 if syear == 1986
replace inflationrate = 0.2 if syear == 1987
replace inflationrate = 1.2 if syear == 1988
replace inflationrate = 2.8 if syear == 1989
replace inflationrate = 2.8 if syear == 1990
replace inflationrate = 3.7 if syear == 1991
replace inflationrate = 5 if syear == 1992
replace inflationrate = 4.5 if syear == 1993
replace inflationrate = 2.6 if syear == 1994
replace inflationrate = 1.8 if syear == 1995
replace inflationrate = 1.3 if syear == 1996
replace inflationrate = 2 if syear == 1997
replace inflationrate = 0.9 if syear == 1998
replace inflationrate = 0.6 if syear == 1999
replace inflationrate = 1.4 if syear == 2000
replace inflationrate = 2 if syear == 2001
replace inflationrate = 1.3 if syear == 2002
replace inflationrate = 1.1 if syear == 2003
replace inflationrate = 1.7 if syear == 2004
replace inflationrate = 1.5 if syear == 2005
replace inflationrate = 1.6 if syear == 2006
replace inflationrate = 2.3 if syear == 2007
replace inflationrate = 2.6 if syear == 2008
replace inflationrate = 0.3 if syear == 2009
replace inflationrate = 1.1 if syear == 2010
replace inflationrate = 2.1 if syear == 2011
replace inflationrate = 2 if syear == 2012
replace inflationrate = 1.4 if syear == 2013
replace inflationrate = 1 if syear == 2014
replace inflationrate = 0.5 if syear == 2015
replace inflationrate = 0.5 if syear == 2016
replace inflationrate = 1.5 if syear == 2017

gen income_F =.
replace income_F = incomeF/ (1+(inflationrate/100))
label variable income_F "Brutto Reallohn Vaeter"

*create average
bysort syear: egen average_income = mean(income_F)
label variable average_income "Durchschnittliche Jahreseinkommen"

*gen growth rate
gen mean_income_2017 = 4009.589
gen wachstumsrate_year = . 
replace wachstumsrate_year = 1/(average_income/mean_income_2017)


gen income_f = .
replace income_f = income_F * wachstumsrate_year
label variable average_income "Gewichteter Brutto Reallohn monatl"

*collapse ans save
collapse cid income_f incomeF income_F age_F fnr fybirth bioyear birthyear hid d11102ll i11101, by(pid)
save "C:\Users\...fathers.dta", replace



*3) merger and estimation

*merge sons and fathers data
clear all
use "C:\...sons.dta"
merge 1:1 fnr using "C:\Users\...fathers.dta"

*drop missings
drop if income_s == .
drop if income_f == .
drop _merge

*gen ln of income
gen log_incomeS_mean = ln(income_s)
gen log_incomeF_mean = ln(income_f)

*rename variables
gen Lifeincome_Sons =.
replace Lifeincome_Sons = log_incomeS_mean
gen Lifeincome_Fathers = .
replace Lifeincome_Fathers = log_incomeF_mean

gen Age_Sons = .
replace Age_Sons = age_S
gen Age_Fathers = .
replace Age_Fathers = age_F

gen Nryrs = .
replace Nryrs = nryrs

*view short viz
graph twoway (lfitci log_incomeF_mean log_incomeS_mean ) (scatter income_F income_S)

*regression 
reg log_incomeS_mean log_incomeF_mean c.age_S##c.age_S c.age_F##c.age_F nryrs, robust
reg Lifeincome_Sons Lifeincome_Fathers c.Age_Sons##c.Age_Sons c.Age_Fathers##c.Age_Fathers Nryrs, robust

*quantile reg
*sqreg log_incomeS_mean log_incomeF_mean c.age_F##c.age_F c.age_S##c.age_S nryrs, q(.25 .5 .75)

******************************************************************
**************Estout for LaTex************************************
******************************************************************

*ssc install estout, replace
cd "C:\Users\...\Stata\Output\Regressions"

*LaTex regression output
eststo clear
eststo: reg log_incomeS_mean log_incomeF_mean c.age_F##c.age_F c.age_S##c.age_S , robust

eststo: reg log_incomeS_mean log_incomeF_mean c.age_S##c.age_S c.age_F##c.age_F nryrs, robust
esttab, se r2 scalars(F)

esttab using Regression.tex , se r2 scalars(F) replace

clear 
exit 
