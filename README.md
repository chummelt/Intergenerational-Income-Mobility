# intergenerational-income-mobility


<%= %>
*2. Laedt die bioparen Datei, in der der relevante Father-ID enthalten ist*
clear all
use bioparen.dta, clear

sum pid -> min:0, max:0 
drop pid cid
rename hhnr cid
rename persnr pid


<%= %>
