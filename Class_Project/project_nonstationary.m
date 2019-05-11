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

%% Non-stationary 

% Linear trend
% mdl = LinearModel.fit(X,y);
% pred_var = predict(mdl,X);

% Polynomial trend
% [mdl,gof]=fit(X,y,'poly3');
% pred_var = mdl(X);


% 
% % Exponential trend
% [mdl,gof]=fit(X,y,'exp1');
% pred_var = mdl(X);
% 
% % Sinusoidal trend
[mdl,gof]=fit(X,y,'sin2');
pred_var = mdl(X);
% 
% % Customized model
% lft = fittype({'x','sin(x)','1'});
% fo = fitoptions(lft);
% [mdl,gof]=fit(X,y,lft);
% pred_var = mdl(X);


% % Train data
% figure()
% plot(X,y)
% hold on
% plot(X,pred_var)
% xlabel('Days')
% ylabel('Avg Temperature (^oF)')
% legend('Training','Fitted')
% 
% 
% % full data
pred_var_full = mdl(X2);

% figure()
% plot(X2,full_data)
% hold on
% plot(X2,pred_var_full)
% xlabel('Days')
% ylabel('Avg Temperature (^oF)')
% legend('Full Data','Fitted')


Res = y-pred_var;


Res_full = full_data-pred_var_full;

P=0.95;
ts = Res;
[m1,Model1,res1]=PostulateARMA(ts,P);
Model1

OriginalRSS=sum(res1.^2);

% plot of fitted data
%hold on
K = 1;
pred = predict(Model1,Res,K);
% figure()
% plot(X,Res)
% hold on
% plot(X,pred)
% xlabel('Days')
% ylabel('Residuals')
% legend('Training data','Fitted data')
% plot of residual
figure()
plot(X,res1)
%title('Residuals of ARMA(6,3) Model')

%% Autocorrelation
figure()
autocorr(res1)
title('Autocorrelation of AR(3) Residuals ')
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


% AR model
n = max(size(Model1.A))-1; % remove 1
% MA model
m = max(size(Model1.C))-1; % remove 1

%% Parsimonous for trend
% % since only 1 real root lies on unit circle, we use (1-B)
% ytrend=zeros(length(ts)-1,1);
% for i=2:length(ts)
%     ytrend(i-1)=ts(i)-ts(i-1);
% end
% 

% 
% % fit parsimonous model arma(n-1,m)
% CurrentModel=armax(ytrend,[n-1 m]);
% r=resid(CurrentModel,ytrend);
% residuals=r.y;
% trendRSS=sum(residuals.^2); %residual sum of squares
% 
% N=length(ts);
% % F-test
% TestRatio=((trendRSS-OriginalRSS)/1)/(OriginalRSS/(N-(m+n+1)));
% Control=finv(P,1,N-(m+n+1)); 
% if TestRatio<Control
%     disp('Stochastic Trend exists')
% else
%     disp('Stochastic Trend does not exists')
% end    

%% Parsimonous for seasonality
%  we use (1-2cos(2pi/p)B-B^2)
period= [4 4.5];%[2 3 4 6 12 Inf]; % look at periods in ro variable

for j=1:length(period)
    
    ytrend=zeros(length(ts)-2,1);
    for i=3:length(ts)
        ytrend(i-2)=ts(i)-2*cos(2*pi/period(j))*ts(i-1)+ts(i-2);
    end

    % fit parsimonous model arma(n-2,m)
    CurrentModel=armax(ytrend,[n-2 m]);
    r=resid(CurrentModel,ytrend);
    residuals=r.y;
    trendRSS=sum(residuals.^2); %residual sum of squares

    N=length(ts);
    % F-test
    TestRatio=((trendRSS-OriginalRSS)/2)/(OriginalRSS/(N-(m+n+1)));
    Control=finv(P,2,N-(m+n+1)); 
    if TestRatio<Control
        disp('Seasonality exists')
        disp(period(j))
    else
        disp('Seasonality does not exists')
    end    
end


%% Non Stationary model forcast
% since trend and seasonality  does not exists we use original model

Model = Model1;


nstep =1;
[forecast_data,forecast_residuals]=forecast_nstep(Model,Res,Res_full,nstep);
figure()
forecast_data=forecast_data+pred_var_full(train_size+1:end);
plot(forecast_data)
hold on
plot(full_data(train_size+1:end))
legend('Forecast data','Validation data')


std_data = sqrt(25.69);
forecast_rss = sum(forecast_residuals.^2);
figure()
plot(forecast_data(1:20))
hold on
plot(full_data(train_size:train_size+20))
plot(forecast_data(1:20)+1.96*std_data)
plot(forecast_data(1:20)-1.96*std_data)


legend('Forecast data','Validation data','UB','LB')

% 
% [yF,yMSE] = forecast(Model1,y,1);
% UB = yF + 1.96*sqrt(yMSE);
% LB = yF - 1.96*sqrt(yMSE);
