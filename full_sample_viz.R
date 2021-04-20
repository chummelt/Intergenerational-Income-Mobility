#Graphical Analysis for the respective estimations

#1) histogram and density curve
#2) transmission matrix
#3) quantile regression


#1) histogram and density curve

rm(list=ls(all=TRUE))
library(tidyverse)
library(haven)
library(ggplot2)
options(scipen=999) 

#read data
income <- read_dta("C:/Users/....dta")
attach(income)
str(income)
Income <- as.factor(income)

#first histogram impression
hist(income_s, breaks=50)

#median for visualisation
median(income$income_s) 
median(income$income_S) 

#histogram with density curve real income
ggplot(income, aes(x=income_s)) +
  geom_histogram(aes(y=..density..), color="black", fill="lightgrey", breaks=seq(0,20000, by=290)) +
  geom_density(color="red")+
  xlab("Real Income Sons")+
  ylab("Density")

#histogram with density curve ln real income
ggplot(income, aes(x=Lifeincome_Sons)) +
  geom_histogram(aes(y=..density..), color="black", fill="lightgrey", breaks=seq(6.8,10, by=0.060)) +
  geom_density(color="red")+
  xlab("Lifeincome Sons")+
  ylab("Density")
 


#2) transition matrix and marcov chain

rm(list=ls(all=TRUE)) 
library(tidyverse)
library(haven)
library(ggplot2)
library(dplyr)
library(markovchain)

income <- read_dta("C:/Users/....dta")

#optional exclusion of outliers, 25000 includes all variables for sons and fathers
income_sub <- subset(income, income_f <= 25000, income_s <= 25000)

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

#new data for class fathers
sons <- select(income_sub,income_s) 
sons$fs <- c("Sons")
colnames(sons) <- c("Income","Status")

#use quantiles to write limits for A, B, C, D, E for fathers
summary(sons)
quantile(sons$Income, probs = c(0,0.2,0.4,0.6,0.8,1))

sons$perc[sons$Income<=2836] = "A"
sons$perc[sons$Income>2837 & sons$Income <= 3611] = "B"
sons$perc[sons$Income>3611 & sons$Income <= 4074] = "C"
sons$perc[sons$Income>4074 & sons$Income <= 4854] = "D"
sons$perc[sons$Income>4854 & sons$Income <= 21799] = "E"

#new data frame
data.perc <- cbind(father$perc, sons$perc)
data.perc <- as.data.frame(data.perc)
data.perc$V1 <- as.factor(data.perc$V1)
data.perc$V2 <- as.factor(data.perc$V2)
colnames(data.perc) <- c("Father", "Son")

#build transition matrix
trans.mat1 <- prop.table(with(data.perc, table(Father, Son)),1)

#output transition matrix (rounded)
trans.mat1
round(trans.mat1, digits = 2)

#visual marcov chain
trans.mat2 <- as.matrix.data.frame(trans.mat1)
markov2 <-new("markovchain",transitionMatrix=trans.mat2 ,states=c("1.Quantil","2.Quantil","3.Quantil","4.Quantil","5.Quantil"), name="test")
plot(markov2)



#3) quantile regression

rm(list=ls(all=TRUE))
library(tidyverse)
library(ggplot2)
library(quantreg)
library(markovchain)
library(dplyr)
library(tidyr)

#load data
income <- read_dta("C:/Users/....dta")
attach(income)
str(income)

#estimate regression
OLS<-lm(Lifeincome_Sons~Lifeincome_Fathers+Age_Sons+I(Age_Sons^2)+Age_Fathers+I(Age_Fathers^2)+Nryrs)
summary(OLS)
confint(OLS, level=0.99)

#fitted residuals vs OLS
res <- ggplot(data = OLS, aes(x = fitted(OLS), y = resid(OLS))) +
  geom_point(shape=1) +
  geom_smooth(method=lm, aes(colour = fitted(OLS), fill = fitted(OLS)))
res+geom_hline(yintercept=0)

#Lifeincome Sons vs Lifeincome Fathers
set.seed(955)
dat <- data.frame(income,
                  xvar = Lifeincome_Fathers,
                  yvar = Lifeincome_Sons)

ggplot(dat, aes(x=xvar, y=yvar)) +
  geom_point(shape=1) +    # Use hollow circles
  geom_smooth(method=lm)  +
  labs(y="Lifeincome_Sons", x="Lifeincome_Fathers")

#breusch pegan test (no heteroskedasticity)
bptest(OLS)

#quantile regressions
options(scipen=999)
quantreg25<-rq(OLS, data=income, tau=0.25)
summary(quantreg25)

quantreg50<-rq(OLS, data=income, tau=0.50)
summary(quantreg50)

quantreg75<-rq(OLS, data=income, tau=0.75)
summary(quantreg75)
coef(summary(object = quantreg25, se = "nid"))

quantreg2527<-rq(OLS, data=income, tau=c(0.25, 0.75))
summary(quantreg2527)

anova(quantreg25, quantreg75)

#plot quantile regressions
quantreg.all <-rq(OLS, tau=seq(0.05, 0.95, by=0.05), data=income)
quantreg.plot <-summary(quantreg.all)
plot(quantreg.plot)

income_s <- subset(income, log_incomeF_mean <= 25000, log_incomeS_mean <= 25000 )

#viz of quantile regressions
q <- ggplot(income_s, aes(x = Lifeincome_Fathers, y=Lifeincome_Sons)) + geom_point(shape=1)
q10 <- seq(0.25, 0.75, by = 0.25) 
q + geom_quantile(quantiles = q10, colour = "blue", size = 1, alpha = 0.5)




