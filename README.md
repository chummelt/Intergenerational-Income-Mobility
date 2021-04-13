# intergenerational-income-mobility

## 1 Objective and structure of the analysis:
Estimation of the economic mobility of Germany and to find regional differences of intergenerational income elasticities within Germany. The underlying theoretical model is the human capital theory.

The structure of the empirical investigation is as follows: 

- First: intergenerational mobility in Germany (full sample)
- Second: intergenerational mobility in rural and urban areas (sub-sample)
- Third: intergenerational mobility in East Germany and West Germany (sub-sample)

The data preparation and linear regressions are conducted in the stata do-files. The visualizations, quantile regressions und transition matrices are conducted in the r scripts. 

## 2 Methodology of Analysis:

Empirical strategy: identify correlation between the long-term income 𝑌(i,g) of the child in family i and his social parent:

<img src="https://latex.codecogs.com/svg.latex?\bg_black&space;\large&space;{\color{White}&space;Y_{i,&space;g}=\alpha&plus;\beta&space;Y_{i,&space;g-1}&plus;\epsilon_{i,&space;g}}" title="\large {\color{White} Y_{i, g}=\alpha+\beta Y_{i, g-1}+\epsilon_{i, g}}" />

Since there is no data available for lifetime income, this has to be estimated. Estimation therefore follows a two-step process:

1. lifetime income
2. mobility coefficient

This is conducted with the following methods:
**Full sample**: Log-log OLS, Quantile Regression, Transition Matrix
**Sub-samples** (East/West and rural/urban): Log-log OLS

### 2.1 Measuring Lifetime Income
### 2.2 Data and Sample Selection

## 3. Empirical Results



## 4. Conclusion

```
```
*3. Umbenennung der Variablen, damit mit dem Datenset pequiv.dta / ppathl.dta gemerged werden kann
*sum pid -> min:0, max:0 
drop pid cid
rename hhnr cid
rename persnr pid

```
