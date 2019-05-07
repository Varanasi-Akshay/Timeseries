clc; clear all; close all;
%num = xlsread('Retail_Sales_Data.xlsx');
data = csvread('daily-min-temperatures.csv',1,1);

%data = zeros(length(num),2);
% data(:,1)=1:length(num);
% data(:,2)=num(:,:,3);
X=1:length(data);
X=X';
%y=transpose(num);
y=data;

% Plot the original data
figure(1)
plot(X,y)
hold on

%% Stationary model using F-test

P=0.95;
ts = y;
[m1,Model1,res1]=PostulateARMA(ts,P);
Model1


% plot of fitted data
K = 1;
pred = predict(Model1,y-m1,K)+m1;
figure(2)
plot(X,pred)

% plot of residual
figure(3)
plot(X,res1)

%% Autocorrelation
autocorr(res1)
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


figure(4)
viscircles([0 0],1,'Color','b');
hold on

ylim([-1,1]);
xlim([-1,1]);
plot(ro(:,1),ro(:,2),'r*')
pbaspect([1 1 1])

%% Parsimonous for trend
% since only 1 real root lies on unit circle, we use (1-B)
ytrend=zeros(length(ts)-1,1);
for i=2:length(ts)
    ytrend(i)=ts(i)+ts(i-1);
end

% fit parsimonous model arma(13,13)
CurrentModel=armax(ytrend,[13 13]);
r=resid(CurrentModel,ytrend);
residuals=r.y;
trendRSS=sum(residuals.^2); %residual sum of squares

N=length(ts);
% F-test
TestRatio=((trendRSS-OriginalRSS)/1)/(OriginalRSS/(N-28));
Control=finv(P,1,N-28); 
if TestRatio<Control
    disp('Trend exists \n')
else
    disp('Trend does not exists \n')
end    

%% Parsimonous for seasonality
%  we use (1-2cos(2pi/p)B-B^2)
period=[2 3 4 6 12 Inf]; % look at periods in ro variable

for j=1:length(period)
    
    ytrend=zeros(length(ts)-2,1);
    for i=3:length(ts)
        ytrend(i)=ts(i)-2*cos(2*pi/period(j))*ts(i-1)+ts(i-2);
    end

    % fit parsimonous model arma(12,13)
    CurrentModel=armax(ytrend,[12 13]);
    r=resid(CurrentModel,ytrend);
    residuals=r.y;
    trendRSS=sum(residuals.^2); %residual sum of squares

    N=length(ts);
    % F-test
    TestRatio=((trendRSS-OriginalRSS)/2)/(OriginalRSS/(N-28));
    Control=finv(P,2,N-28); 
    if TestRatio<Control
        disp('Seasonality exists')
        disp(period(j))
    else
        disp('Seasonality does not exists')
    end    
end


%% Parsimonous model
% for 1-B^12
ytrend=zeros(length(ts)-6,1);
for i=7:length(ts)
    ytrend(i)=ts(i)-ts(i-6);
end

% fit parsimonous model arma(2,13)
CurrentModel=armax(ytrend,[8 13]);
r=resid(CurrentModel,ytrend);
residuals=r.y;
trendRSS=sum(residuals.^2); %residual sum of squares

N=length(ts);
% F-test
TestRatio=((trendRSS-OriginalRSS)/6)/(OriginalRSS/(N-28));
Control=finv(P,6,N-28); 
if TestRatio<Control
    disp('We can use the operator')
    disp(period(j))
else
    disp('We cannot use the operator')
end


%% Stationary model forcast




[yF,yMSE] = forecast(Model1,y,1);
UB = yF + 1.96*sqrt(yMSE);
LB = yF - 1.96*sqrt(yMSE);


%% Non-stationary 

% Linear trend
mdl = LinearModel.fit(X,y);
pred_var = predict(mdl,X);

% Polynomial trend
[mdl,gof]=fit(X,y,'poly2');
pred_var = mdl(X);

% Exponential trend
[mdl,gof]=fit(X,y,'exp1');
pred_var = mdl(X);

% Sinusoidal trend
[mdl,gof]=fit(X,y,'sin6');
pred_var = mdl(X);

% Customized model
lft = fittype({'x','sin(x)','1'});
fo = fitoptions(lft);
[mdl,gof]=fit(X,y,lft);
pred_var = mdl(X);

figure()
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

%Autocorrelation
autocorr(y)


%% Non-Stationary model forcast



[yF,yMSE] = forecast(Model1,y,1);
UB = yF + 1.96*sqrt(yMSE);
LB = yF - 1.96*sqrt(yMSE);

%% ARMAV model




