# intergenerational-income-mobility

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
<img src="https://latex.codecogs.com/svg.latex?\Large&space;x=\frac{-b\pm\sqrt{b^2-4ac}}{2a}" title="\Large x=\frac{-b\pm\sqrt{b^2-4ac}}{2a}" />
![\Large x=\frac{-b\pm\sqrt{b^2-4ac}}{2a}](https://latex.codecogs.com/svg.latex?x%3D%5Cfrac%7B-b%5Cpm%5Csqrt%7Bb%5E2-4ac%7D%7D%7B2a%7D)
