clc; clear all; close all;
num = xlsread('Retail_Sales_Data.xlsx');
%data = zeros(length(num),2);
% data(:,1)=1:length(num);
% data(:,2)=num(:,:,3);
X=1:length(num);
y=num(:,3);

%% Linear trend
mdl = LinearModel.fit(X,y);
pred_var = predict(mdl,transpose(X));

figure(1)
plot(X,y)
hold on
plot(X,pred_var)
xlabel('Time')
ylabel('Sales')
legend('Original','Predicted')

figure(2)
Res = y-pred_var;
plot(X,Res)

xlabel('Time')
ylabel('Residuals')

P=0.95;
ts = Res;
[m1,Model1,res1]=PostulateARMA(ts,P);
Model1

% Polynomial coeff
p=polydata(Model1);

% Roots of the poly
r=roots(p);
ro = zeros(length(r),4);

for j=1:length(r)
   ro(j,1)= real(r(j)); 
   ro(j,2)= imag(r(j)); 
   ro(j,3)= acos(ro(j,1)/abs(r(j))); % angle
   ro(j,4)= (2*pi)/ro(j,3)  ;     % Period
end


%% Roots on circle
figure(3)
viscircles([0 0],1,'Color','b');
hold on

ylim([-1,1]);
xlim([-1,1]);
plot(ro(:,1),ro(:,2),'r*')
pbaspect([1 1 1])

%% Autocorrelation
autocorr(y)
% lag and standard errors in confidence bounds
%autocorr(y,'NumLags',40,'NumSTD',3)
parcorr(y)

% difference removes the linear trend
dY = diff(y);
% 
% Specify and Estimate an ARIMA(2,1,0) Model
% 
% Specify, and then estimate, an ARIMA(2,1,0) model for the log quarterly Australian CPI. This model has one degree of nonseasonal differencing and two AR lags. By default, the innovation distribution is Gaussian with a constant variance.

Mdl = arima(2,1,0);
EstMdl = estimate(Mdl,y);
%Check Goodness of Fit

%Infer the residuals from the fitted model. Check that the residuals are normally distributed and uncorrelated. 
res = infer(EstMdl,y);
qqplot(res)
% 
% Generate Forecasts
% 
% Generate forecasts and approximate 95% forecast intervals for the next 4 years (16 quarters).

[yF,yMSE] = forecast(EstMdl,16,y);
UB = yF + 1.96*sqrt(yMSE);
LB = yF - 1.96*sqrt(yMSE);