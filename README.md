# intergenerational-income-mobility

## 1 Objective and structure of the analysis:
Estimation of the economic mobility of Germany and to find regional differences of intergenerational income elasticities within Germany. The underlying theoretical model is the human capital theory.

The structure of the empirical investigation is as follows: 

- First: intergenerational mobility in Germany (full sample)
- Second: intergenerational mobility in rural and urban areas (sub-sample)
- Third: intergenerational mobility in East Germany and West Germany (sub-sample)

The data preparation and linear regressions are conducted in the stata do-files. The visualizations, quantile regressions und transition matrices are conducted in the r scripts. 

## 2 Methodology of Research
### 2.1 Measuring Lifetime Income
### 2.2 Data and Sample Selection

## 3. Empirical Results
$ a^2 + b^2 = c^2 $
## 4. Conclusion

```
```
*3. Umbenennung der Variablen, damit mit dem Datenset pequiv.dta / ppathl.dta gemerged werden kann
*sum pid -> min:0, max:0 
drop pid cid
rename hhnr cid
rename persnr pid

```
