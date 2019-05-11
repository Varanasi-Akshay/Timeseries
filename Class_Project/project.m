clc; clear all; close all;
% 
% data = readtable('/home/akshay/Desktop/Timeseries/Class_Project/delhi-weather-data/testset.csv');
% full_data = data.x_tempm;

data = readtable('/home/akshay/Desktop/Timeseries/Class_Project/austin-weather/austin_weather.csv');
full_data = data.TempAvgF;
% per = 0.5;
% train_size= round(per*size(full_data,1));
% train_data= full_data(1:train_size);
% y=train_data;


% data = readtable('daily-min-temperatures.csv');
% full_data = data.Temp;

% Removing nan
full_data = full_data(~isnan(full_data));
per = 0.5;
train_size= round(per*size(full_data,1));
train_data= full_data(1:train_size);

train_mean = 0;%mean(train_data);
y=train_data-train_mean;

X=1:length(y);
X=X';
X2=1:length(full_data);
X2=X2';
% Plot the original data
figure(1)
plot(X,y)
hold on
% plot(X2(train_size+1:end),full_data(train_size+1:end))
% legend('Training data','Validation data')

%% Stationary model using F-test

P=0.95;
ts = y;
[m1,Model1,res1]=PostulateARMA(ts,P);
Model1

OriginalRSS=sum(res1.^2);

% plot of fitted data
%hold on
K = 1;
pred = predict(Model1,y,K);
%figure(2)
plot(X,pred)
legend('Training data','Fitted data')
% plot of residual
figure()
plot(X,res1)
title('Residuals of ARMA(6,3) Model')
hold off
%% Autocorrelation
figure()
autocorr(res1)
title('Autocorrelation of ARMA(6,3) Residuals ')
% lag and standard errors in confidence bounds
%autocorr(y,'NumLags',40,'NumSTD',3)
%parcorr(res1)


%% Roots on circle

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


figure()
viscircles([0 0],1,'Color','b','LineWidth',1);
hold on

ylim([-1,1]);
xlim([-1,1]);
plot(ro(:,1),ro(:,2),'r*','LineWidth',3)
pbaspect([1 1 1])

%% Parsimonous for trend
% % since only 1 real root lies on unit circle, we use (1-B)
ytrend=zeros(length(ts)-1,1);
for i=2:length(ts)
    ytrend(i-1)=ts(i)-ts(i-1);
end

% AR model
n = max(size(Model1.A))-1; % remove 1
% MA model
m = max(size(Model1.C))-1; % remove 1

% fit parsimonous model arma(n-1,m)
CurrentModel=armax(ytrend,[n-1 m]);
r=resid(CurrentModel,ytrend);
residuals=r.y;
trendRSS=sum(residuals.^2); %residual sum of squares

N=length(ts);
% F-test
TestRatio=((trendRSS-OriginalRSS)/1)/(OriginalRSS/(N-(m+n+1)));
Control=finv(P,1,N-(m+n+1)); 
if TestRatio<Control
    disp('Stochastic Trend exists')
else
    disp('Stochastic Trend does not exists')
end    

%% Parsimonous for seasonality
%  we use (1-2cos(2pi/p)B-B^2)
% period= [4 4.5];%[2 3 4 6 12 Inf]; % look at periods in ro variable
% 
% for j=1:length(period)
%     
%     ytrend=zeros(length(ts)-2,1);
%     for i=3:length(ts)
%         ytrend(i-2)=ts(i)-2*cos(2*pi/period(j))*ts(i-1)+ts(i-2);
%     end
% 
%     % fit parsimonous model arma(n-2,m)
%     CurrentModel=armax(ytrend,[n-2 m]);
%     r=resid(CurrentModel,ytrend);
%     residuals=r.y;
%     trendRSS=sum(residuals.^2); %residual sum of squares
% 
%     N=length(ts);
%     % F-test
%     TestRatio=((trendRSS-OriginalRSS)/2)/(OriginalRSS/(N-(m+n+1)));
%     Control=finv(P,2,N-(m+n+1)); 
%     if TestRatio<Control
%         disp('Seasonality exists')
%         disp(period(j))
%     else
%         disp('Seasonality does not exists')
%     end    
% end
% 

%% Stationary model forcast
% orginal model
% nstep =1;
% [forecast_data,forecast_residuals]=forecast_nstep(Model1,y,full_data,nstep);
% figure()
% plot(forecast_data)
% hold on
% plot(full_data(train_size+1:end))
% legend('Forecast data','Validation data')


% since trend exists not the seasonality we use that

Model = CurrentModel;

% since trend exists
ts = full_data;
full_data_trend=zeros(length(ts)-1,1);
for i=2:length(ts)
    full_data_trend(i-1)=ts(i)-ts(i-1);
end

nstep =1;
[forecast_data,forecast_residuals]=forecast_nstep(Model,ytrend,full_data_trend,nstep);
figure()
plot(forecast_data)
hold on
plot(full_data_trend(train_size:end))
legend('Forecast data','Validation data')
std_data = sqrt(26.83);
figure()
plot(forecast_data(1:20))
hold on
plot(full_data_trend(train_size:train_size+20))
plot(forecast_data(1:20)+1.96*std_data)
plot(forecast_data(1:20)-1.96*std_data)


legend('Forecast data','Validation data','UB','LB')

% 
% [yF,yMSE] = forecast(Model1,y,1);
% UB = yF + 1.96*sqrt(yMSE);
% LB = yF - 1.96*sqrt(yMSE);
% 
% nstep=1;
% [forecast_values,new_res,new_data]= predict_nstep(Model1,y,res1,nstep);




