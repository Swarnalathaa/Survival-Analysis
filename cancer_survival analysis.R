
  ##Description of the data:
  
  #The samples are taken from the colorectal cancer patients.
  #All the patients have undergone sugery as a primary treatment. 
  #Apart from the primary treatment some patients have taken chemotherapy and radiotherapy 
  #or both. Here the time to event is "how many months the patients have survived
  #without the disease after the treatment".


dat <- load("CRC_226_GSE14333.RData")

dim(clinical_data)

head(clinical_data)

str(clinical_data)

# ##variable description:
# 
# sampleID    : Unique id for each individual.
# location    : Location of the cancer. It is a categorical variable with 4 values 
# namely Colon, Rectum, Right, Left.
# Dukes Stage : Classification of cancer. It is a categorical variable with 3 levels
# A,B,C. "C" being the advanced stage.
# age_diag    : Age of the patient and it is a continuous variable.
# gender      : sex of the patient. "F" -> Female "M"->Male.
# dfs_time    : Disease free survival time in months.
# dfs_event   : Indicator to indicate whether the event has occured or censored. 
# 0->censoring, 1->event has occured.
# adjXRT      : Says whether the patient has taken radio therapy. has two values
# "Y"-> Yes and "N"->No.
# adjCTX      : Says whether the patient has taken radio therapy. has two values
# "Y"-> Yes and "N"->No.
# 
# ##Summary of the data
# Made table for each variable to understand better about the data set and we 
# can see that data set has no missing values and from the histogram of the age 
# we can notice that most of the observations lies between age group 50-80 years.


sum(is.na(clinical_data) | clinical_data == "")

table(clinical_data$location, dnn = "Number of observations based on location of the cancer")


table(clinical_data$dukes_stage,dnn = "Number of observations based on Dukes stage of the cancer")

table(clinical_data$gender,dnn = "Number of observations based on Gender")


table(clinical_data$dfs_event, dnn = "Number of observations that have been censored and which experienced the event")


hist(clinical_data$age_diag, xlab = "Patients age", main = "Histogram of patients age")

table(clinical_data$adjXRT=="N" & clinical_data$adjCTX == "N", dnn = "Number of observations underwent just the surgery")


table(clinical_data$adjCTX, dnn = "Number of observations underwent Chemo Therapy after surgery")

table(clinical_data$adjXRT, dnn = "Number of observations underwent Radio Therapy after surgery")

table(clinical_data$adjXRT=="Y" & clinical_data$adjCTX == "Y", dnn = "Number of observations underwent Both treatment after surgery")


# From the below summary we can see meadian and quartiles for 
# the continuous variable and we can also make sure that all the variable are 
# in same type as desribed before.


summary(clinical_data)



# ##Survival Analysis
# Question asked : To find the variables that has significance in 
# construction of the model.
# 
# converting the disease free survival time from months to years for the ease of work.

library(survival)
clinical_data$test = with(clinical_data, Surv(dfs_time/12,dfs_event))
# 
# Next step is to check for the trend of the survival curve.
# 
# The Kaplan-Meier survival curve shows the cumulative proportion of patients survived over time. 
# The rate of of loss of patient is relatively constant over time.The median survival time is 4.15 years.
# Most of the censored observation are before the median survival time.


survfit(test~1, data = clinical_data)
plot(survfit(test~1, data = clinical_data), col = 1:3, xlab = "Time in Years", ylab ="Survival", mark.time = TRUE)




# Now we run the Kaplan-Meier test for all individual variable. 
# 
# From the graph, We do not see any noticable diffrence between the levels of gender and location. 
# We have also confirmed this by running logrank test which gives high p-value. 
# Higher p-value means that we fail to reject null hypothesis which says that there is 
# no significant difference between the levels of the variable.
# 
# so we may omit this variables while building the model.





survfit(test~gender, data = clinical_data)
plot(survfit(test~gender, data = clinical_data), col = 1:2,xlab = "Time in Years", ylab ="Survival",pch = seq(1,2) )
legend(x = "topright",legend=c("Female","Male"),pch = seq(1,2) ,bty ="o",col=seq(1,2),cex = 0.75)
title("Survival Curve based on gender")

survdiff(test~gender, data = clinical_data)



survfit(test~location, data = clinical_data)
plot(survfit(test~location, data = clinical_data), col = 1:4,xlab = "Time in Years", ylab ="Survival")
legend(x = "topright",legend=c("Rectum","Colon","Left","Right"),pch = seq(1,4) ,bty ="o",col=seq(1,4),cex = 0.75)
title("Survival Curve based on Location of the cancer")

survdiff(test~location, data = clinical_data)



# 
# We Perform the Kaplan-Meier test for other variables along with the longrank test to see the 
# significancy of the variable in building the modle. Since we can't perform 
# logrank test in a continuous variable and age of the patients is a continuous variable.
# so,we are converting into a categorical variable by dividing the obsevations into three group (i.e 0-50,50-80 and 80-inf).
# 
# From the below analyzis we can say that variable adjCTX (variable indicating whether 
# the patient has take radio therapy or not) has smaller p-value so we can reject the null hypothesis 
# and accept the alternative one which says that the difference between the two group is significant.
# 
# similarly for the other variable age, dukes stage doesn't 
# show any high significant but in real world situation survival of the cancer patients also 
# depends on the cancer stage so I have decided to consider this variable in the model building.  
# 
# 
# For adjXRT (variable indicating whether the patient has taken chemo therapy or not) although p-value indicates 
# the difference between the variable group is not significant.


survfit(test~dukes_stage, data = clinical_data)
plot(survfit(test~dukes_stage, data = clinical_data), col = 1:3)
legend(x = "topright",legend=c("Stage A","Stage B","Stage C"),pch = seq(1,3) ,bty ="o",col=seq(1,3),cex = 0.75)
title("Survival Curve based on Dukes Stage")

survdiff(test~dukes_stage, data= clinical_data)




survfit(test~adjCTX, data = clinical_data)
plot(survfit(test~adjCTX, data = clinical_data), col = 1:2,xlab = "Time in Years", ylab ="Survival")
legend(x = "topright",legend=c("Did not ungergo Chemo therapy","Underwent Chemo therapy"),pch = seq(1,2) ,bty ="o",col=seq(1,2),cex = 0.75)
title("Survival Curve based on Chemo therapy")

survdiff(test~adjCTX, data = clinical_data)


survfit(test~adjXRT, data = clinical_data)
plot(survfit(test~adjXRT, data = clinical_data), col = 1:2,xlab = "Time in Years", ylab ="Survival")
legend(x = "topright",legend=c("Did not ungergo Radio therapy","Underwent radio therapy"),pch = seq(1,2) ,bty ="o",col=seq(1,2),cex = 0.75)
title("Survival Curve based on Radio therapy")

survdiff(test~adjXRT, data = clinical_data)


clinical_data$agecat = cut(clinical_data$age_diag,breaks = c(0,50,80,Inf))
table(clinical_data$agecat)


survfit(test~agecat,data = clinical_data)
plot(survfit(test~agecat,data = clinical_data), col = 1:3,xlab = "Time in Years", ylab = "Survival")
legend(x = "topright",legend=c("<50","50-80",">80"),pch = seq(1,3) ,bty ="o",col=seq(1,3),cex = 0.75)
title("Survival Curve based on 3 set of age group")

survdiff(test~agecat, data = clinical_data)



# 
# We can notice that there are some patients who has taken both the therapy. 
# so I have decided to see the effect of it. In order to do that I have created a new categorical variable 
# "treatment_type"" with 4 values "No Treatment", "Chemo", "Radiation" and "Both".
# 
# From the table we can see that all the patients that has taken the radio therapy 
# has also take the chemo tratment and only one patient had just the radio therapy and even that observation has 
# been censored. so we have decided to remove this observation from the dataset to make the further analyzis easier.



clinical_data$treatment_type = "No Treatment"
clinical_data$treatment_type[clinical_data$adjXRT == "Y" ] <- "Radiation"
clinical_data$treatment_type[clinical_data$adjCTX == "Y"] <- "Chemo"
clinical_data$treatment_type[clinical_data$adjXRT == "Y"& clinical_data$adjCTX == "Y"] <- "Both"


table(clinical_data$treatment_type , dnn = "Kind of treatment underwent by patients")

table(clinical_data$treatment_type[clinical_data$dfs_event == 1], dnn = "Kind of treatment underwent by patients and also not being censored")



#New dataset with one observation less than the original data.

clinical_data = subset(clinical_data,!(clinical_data$treatment_type == "Radiation"))



# From the Kaplan-Meier test we can say that the patients who took both treatments 
# has higher survival time than others. So the significancy show by the variable adjXRT is because it 
# indicated the patients who has taken both the therapy.



survfit(test~treatment_type, data = clinical_data)
plot(survfit(test~treatment_type, data = clinical_data), col = 1:3,pch = seq(1,3))
legend(x = "topright",legend=c("Both","Chemo","No Treatment"),pch = seq(1,3) ,bty ="o",col=seq(1,3),cex = 0.75)

survdiff(test~treatment_type, data =  clinical_data)


# But in real world we have cases where the patients can take just radio therapy without 
# taking chemo.so I have decided to create two multivariate model.
# 
# model1 : with 3 variables dukes_stage, age and treatment_type 
# model2 : with 3 varibles dukes_stage, age and adjXRT
# 
# From summary of model1 we can see that the variables selected has significance. 
# 
# Variable : dukes_stage
# "dukes_stageA" is taken as the base value. Positive coeffecient implies the increse in risk factor 
# which corresponds to decrease in the survival time. so as seen in the survival plot before, survival time of 
# observations with stage A is higher than stage C which is higher than stage B.
# 
# 
# variable : treatment_type
# "Both"" is taken as the base value. Positive coeffecient implies the increse in risk 
# factor which corresponds to decrease in the survival time. so as seen in the survival plot before, survival time of patients who took both the treatment is more than patients who just took chemo and surgery.
# 
# Inference we made by performing CoxRegression corresponds to the Suvival graph derived from the Kaplan-Meier test (univariate model)
# 
# smaller P-value from Wald test and likelyhood ratio shows that it is a good model.



model1 = coxph(test~dukes_stage + treatment_type + age_diag, data = clinical_data)

summary(model1)


#We can notice that the p-values are high so we cannot rejec the null hypothesis which states that the propotionality of hazard holds. 


cox.zph(model1)




# Creating the model2 but the only difference from model1 is that we have used adjXRT instead of treatment_type variable.
# 
# variable : adjXRT (indicates whether the patient has taken radiotherapy or not)
# 
# Coeffecient is negative which implies the reduction of risk factor and high survival rate.
# 
# smaller P-value from Wald test and likelyhood ratio shows that it is a good model.

model2 <- coxph(test~dukes_stage + adjXRT + age_diag, data = clinical_data)
summary(model2)



#We can notice that the p-values are high so we cannot rejec the null hypothesis which states that the propotionality of hazard holds. 



cox.zph(model2)



#We are using step variable selection method to check whether the model obtained by our inference is same as the one provided by the step function.


model1_ss = coxph(test~location + dukes_stage + age_diag + gender + treatment_type, data = clinical_data)
summary(model1_ss)


model1_fit <- step(model1_ss)
summary(model1_fit)


model2_ss = coxph(test~location + dukes_stage + age_diag + gender + adjXRT + adjCTX, data = clinical_data)
summary(model2_ss)


#From the test we can see that step function is giving the same model as the one predicted by us.


model2_fit <- step(model2_ss)
summary(model2_fit)

#But, When we look for the better fitted model using Akaike information criterion, model2 is best fitted than model1. 

AIC(model1)
AIC(model2)

# ##Conclusion
# 
# While building model2 we have consider the variable adjXRT (indicates whether the patient has 
# taken radiotherapy or not). From the study of our data we have seen that effect of the adjXRT (radiotherapy treatment) 
# is not only based on radiation but based on combined effect of both chemotherapy and radiotherapy. 
# But in real world situation we may have some patients who don't have a combined treatment but just 
# have only one of the treatment (chemotherapy without radiation and vice-versa).
# 
# 
# AIC value shows that model2 is better than model1, however from our comparison to real case 
# situation we can conclude that model2 is overfitting the data.
# 
# As the result of the above inference we choose to select model1 over model2.


