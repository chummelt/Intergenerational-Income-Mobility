# intergenerational-income-mobility

## 1 Objective of the analysis:
Estimation of the economic mobility of Germany and to find regional differences of intergenerational income elasticities within Germany. The underlying theoretical model is the human capital theory.
The structure of the empirical investigation is as follows: 

First: intergenerational mobility in Germany (full sample)
Second: intergenerational mobility in rural and urban areas (sub-sample)
Third: intergenerational mobility in East Germany and West Germany (sub-sample)





```ruby
# open distribution list
with open('people.csv', 'r', newline='') as f:
    reader = csv.reader(f)
    distro = [row for row in reader]
```
```
*3. Umbenennung der Variablen, damit mit dem Datenset pequiv.dta / ppathl.dta gemerged werden kann
*sum pid -> min:0, max:0 
drop pid cid
rename hhnr cid
rename persnr pid

```
