library("xlsx")
data<-read.xlsx("Retail_Sales_Data.xlsx",sheetIndex = 1, header=FALSE, stringsAsFactors=FALSE)
colnames(data)<-c("Year","Month","Sales")
data_sub<-data[3:length(data$Year), ]
data_sub$Time<-c(1:length(data_sub$Sales))
model<-lm(data_sub$Sales~data_sub$Time)
summary(model)
plot(fitted(model),residuals(model))
pre_variables<-predict(model,data=data_sub$Time)

plot.ts(data_sub$Sales)
lines(x=data_sub$Time,y=pre_variables)
data_sub$Predicted<-pre_variables
data_sub$Resdiuals<-as.numeric(data_sub$Sales)-as.numeric(data_sub$Predicted)

# AR(2)


res<-ar.ols(x = data_sub$Resdiuals, aic = FALSE, order.max = 2)
data_sub$Resdiuals_pre<-predict(res,data_sub$Resdiuals)
plot.ts(data_sub$Resdiuals)
lines(x=data_sub$Time,y=data_sub$Resdiuals_pre)

# AR(4)


res_4<-ar.ols(x = data_sub$Resdiuals, aic = FALSE, order.max = 4)
data_sub$Resdiuals_pre_4<-predict(res_4,data_sub$Resdiuals)
plot.ts(data_sub$Resdiuals)
lines(x=data_sub$Time,y=data_sub$Resdiuals_pre_4)