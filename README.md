# intergenerational-income-mobility


'''
*2. Laedt die bioparen Datei, in der der relevante Father-ID enthalten ist*
clear all
use bioparen.dta, clear

*3. Umbenennung der Variablen, damit mit dem Datenset pequiv.dta / ppathl.dta gemerged werden kann* --> Mit dem SOEP abgesprochen, dass das in Ordnung geht
*sum pid -> min:0, max:0 
drop pid cid
rename hhnr cid
rename persnr pid


'''
