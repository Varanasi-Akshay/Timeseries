library("xlsx")
data<-read.xlsx("HW1_Problem1.xls",sheetIndex = 1, header=FALSE, stringsAsFactors=FALSE)

sum=0
sum_sq=0
mu=mean(data$X1)
var_data=0
data$X1<-data$X1-mu
for (i in 1:49) {
     sum = sum + ((data$X1[i])*(data$X1[i+1]))
     sum_sq = sum_sq+((data$X1[i]))^2 #*(data$X1[i]))
}

phi_1=sum/sum_sq
for (i in 1:49) {
  var_data=var_data+(data$X1[i+1]-phi_1*data$X1[i])^2
}
var_data=var_data/49
var_phi=var_data/sum_sq

ar.mle(x = data$X1, aic = FALSE, order.max = 1)

