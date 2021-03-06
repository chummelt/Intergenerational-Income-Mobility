(keep in mind: this readme includes equations which can only be read while using the dark mode theme)

# Like Father, Like Son - intergenerational income mobility in Germany

## 1 Objective and Structure of the Analysis:
Estimation of the economic mobility of Germany and to find regional differences of intergenerational income elasticities in Germany. The underlying theoretical model is the human capital theory.

The data preparation and linear regressions are conducted in the stata do-files. The visualizations, quantile regressions und transition matrices are conducted in the r scripts.
Every step is described in detail within the scripts. Nevertheless, this readme provides the additional econometric framework in addition to the codes. 

## 2 Methodology of Analysis:

Empirical strategy: identify correlation between the long-term income 𝑌(*i,g*) of the child in generation *g* and his social parent in generation *g-1*, in family *i*:

<img src="https://latex.codecogs.com/svg.latex?\bg_black&space;\large&space;{\color{White}&space;Y_{i,&space;g}=\alpha&plus;\beta&space;Y_{i,&space;g-1}&plus;\epsilon_{i,&space;g}}" title="\large {\color{White} Y_{i, g}=\alpha+\beta Y_{i, g-1}+\epsilon_{i, g}}" />

Since there is no data available for lifetime income, this has to be estimated. Estimation therefore follows a two-step process:

1. lifetime income
2. mobility coefficient

This is conducted with the following methods:

Log-log OLS, Quantile Regression, Transition Matrix  


### 2.1 Measuring Lifetime Income

To estimate the lifetime income, one has to use actual observable income data. 

<img src="https://latex.codecogs.com/svg.latex?\bg_black&space;\large&space;{\color{White}Y_{i,&space;g,&space;t}=Y_{i,&space;g}&plus;v_{i,&space;g,&space;t}}" title="\large {\color{White}Y_{i, g, t}=Y_{i, g}+v_{i, g, t}}" />

<img src="https://latex.codecogs.com/svg.latex?\bg_black&space;\large&space;{\color{White}Y_{i,&space;g-1,&space;t}=Y_{i,&space;g-1}&plus;v_{i,&space;g-1,&space;t}}" title="\large {\color{White}Y_{i, g-1, t}=Y_{i, g-1}+v_{i, g-1, t}}" />

with Y(*i,g,t*) being observable income of generation child of family *i* in year t. But, careful; error-in-variables bias emerges. Workers with higher lifetime earnings tend to enter the labor market later than workers with shorter education periods.

Basically this means, if you go to college, you probability start working later in life than your peers who started working right after highschool. Since we want to estimate the lifetime income and use real income data, it is not optimal to use income data of a college student who might earn less at the age of 22 but eventually might earn more after college.

So to solve for this bias, the estimation excludes income observations from before the age of 30 and after the life of 50.
```ruby
drop if age <30
drop if age >55
```
<img src="images/07_lifeincome.png" width="350">


In addition to that, control variables for *age*, *age squared* and the *number of years in a child's income* are generated and introduced in *Z(i,g-1)* and *W(i,g*).

```ruby
bys cid: egen first_observation = min(syear)
bys cid: egen last_observation = max(syear)
gen nryrs = .
replace nryrs = last_observation - first_observation
label variable nryrs "number of years in son’s earnings average"
```
This leads to the estimation equation:  

<img src="https://latex.codecogs.com/svg.latex?\bg_black&space;\large&space;{\color{White}\ln&space;Y_{i,&space;g}=\alpha&plus;\beta&space;\ln&space;Y_{i,&space;t}&plus;\eta&space;Z_{i,&space;g-1}&plus;\gamma&space;W_{i,&space;g}&plus;\varepsilon_{i,&space;t}}" title="\large {\color{White}\ln Y_{i, g}=\alpha+\beta \ln Y_{i, t}+\eta Z_{i, g-1}+\gamma W_{i, g}+\varepsilon_{i, t}}" />


### 2.2 Data and Sample Selection

The longitudinal survey of the Socio-Economic Panel (SOEP) is used which captures representative data from 1984-2017.  
DOI: 10.5684/soep.v34  
Collection period: 1984-2017  
Publication date: 2019-03-05  

The individual labor income variable covers gross income and salary from all employment before deduction of taxes and social security, unemployment and health insurance.
**Important sample restrictions**:  

- drop observations under 400€ a month - since it is assumed that this would be a mini-job, not a real living wage  
- drop ids for which there are less than 5 observations available. Estimating life-income on less income-data points introduces bias
- use only male observartions - income observations for women in 1980s may introduce a bias to the data  

```ruby
drop if incomeS <400
drop if counter_pid <5
drop if sex == 2
```

After the data for both sons and fathers are prepared, both samples have to be merged over the father id (fnr)

```
use "C:\Users\...Sons.dta"
merge 1:1 fnr using "C:\Users\...Fathers.dta"
```
The individuals who did not match have to be droppped, leaving only father-son pairs. This leaves us with a sample of N=367. 

```ruby
drop if income_s == .
drop if income_f == .
drop _merge
```
Now, if we take a step back and look again at the income observations for sons in the first graph, we see that the income variable is not normal distributed but rather skewed. In order to meet all of the assumptions of the OLS, the variable should be normal distributed. Thus, we change the income variables of sons and fathers to a log income variable. The second graph shows the distribution after the log.  
(The code for the two graphs is from the r-script which focuses on the graphical analysis) 

```ruby
#histogram with density curve real income
ggplot(income, aes(x=income_s)) +
  geom_histogram(aes(y=..density..), color="black", fill="lightgrey", breaks=seq(0,20000, by=290)) +
  geom_density(color="red")+
  xlab("Real Income Sons")+
  ylab("Density")
```

```ruby
#histogram with density curve ln real income
ggplot(income, aes(x=Lifeincome_Sons)) +
  geom_histogram(aes(y=..density..), color="black", fill="lightgrey", breaks=seq(6.8,10, by=0.060)) +
  geom_density(color="red")+
  xlab("Lifeincome Sons")+
  ylab("Density")
```

<img src="images/02_histogram_density.png" width="400">
<img src="images/03_histogram_density_ln.png" width="400">

This can also be done after the merging of the data. 
```ruby
gen log_incomeS_mean = ln(income_s)
gen log_incomeF_mean = ln(income_f)
```

## 3. Empirical Results

After the estimation of the lifetime income, the mobility coefficient is estimated with an OLS:
```ruby
reg Lifeincome_Sons Lifeincome_Fathers c.Age_Sons##c.Age_Sons c.Age_Fathers##c.Age_Fathers Nryrs, robust
```
Which gives a coefficient of 0.277***, with a 95% confidence interval of (0.173;0.382).

## 4. Transmission Matrix

Since the dataset is in a dta format, you need to load the package 'haven' into the library to open the file. For the transition matrix and the marcov chain you need to load the package 'markovchain'. For the usual data analysis tools we use 'dplyr' and 'tidyverse'. 
```ruby
rm(list=ls(all=TRUE)) 
library(tidyverse)
library(haven)
library(ggplot2)
library(dplyr)
library(markovchain)
```

After loading the data, we need to build two classes for fathers and sons. For each fathers and sons, quantiles will be used as limits for each class. 
```ruby
#new data for class fathers
father <- select(income_sub,income_f)
father$fs <- c("Father")

father %>% rename(Income = income_f)
colnames(father) <- c("Income", "Status")

#use quantiles to write limits for A, B, C, D, E for fathers
quantile(father$Income)
quantile(father$Income, probs = c(0,0.2,0.4,0.6,0.8,1))

father$perc[father$Income<=2763] = "A"
father$perc[father$Income>2763 & father$Income <= 3379] = "B"
father$perc[father$Income>3379 & father$Income <= 3915] = "C"
father$perc[father$Income>3915 & father$Income <= 4654] = "D"
father$perc[father$Income>4654 & father$Income <= 21120] = "E"
```
The same goes for the sons. The quantiles for the income data of the sons are used for the class limits. After that, we can build the transition matrix and print the rounded transition matrix.
```ruby
#build transition matrix
trans.mat1 <- prop.table(with(data.perc, table(Father, Son)),1)

#output transition matrix (rounded)
trans.mat1
round(trans.mat1, digits = 2)
```

Use this transition matrix for the plotting of the markov chain
```ruby
#visual marcov chain
trans.mat2 <- as.matrix.data.frame(trans.mat1)
markov2 <-new("markovchain",transitionMatrix=trans.mat2 ,states=c("1.Quantil","2.Quantil","3.Quantil","4.Quantil","5.Quantil"), name="markov")
plot(markov2)
```
