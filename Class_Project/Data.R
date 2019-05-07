library(tsdl)
library(forecast)
tsdl
#subset(tsdl,"Sales")
#str(meta_tsdl)
meta=meta_tsdl
meta$timeseries_num=c(1:length(meta$source))
health_data=meta[which(meta$subject=="Health"),]


library(tscompdata)
#> Loading required package: Mcomp
#> Loading required package: forecast
#> Loading required package: Tcomp
library(forecast)
library(ggplot2)
autoplot(nn5[[23]])
