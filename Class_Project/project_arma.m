clc; clear all; close all;
% 
% data = readtable('/home/akshay/Desktop/Timeseries/Class_Project/delhi-weather-data/testset.csv');
% full_data = data.x_tempm;


data = readtable('/home/akshay/Desktop/Timeseries/Class_Project/austin-weather/austin_weather.csv');
%full_data = data.TempAvgF;
load('Detrended_data.mat')
full_data=Res_full;

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
figure()
plot(X,y)
hold on
% plot(X2(train_size+1:end),full_data(train_size+1:end))
% legend('Training data','Validation data')

%% ARMAV model

full_humidity = str2double(data.HumidityAvgPercent);
full_humidity(isnan(full_humidity))=mean(full_humidity(~isnan(full_humidity)));

train_humidity = full_humidity(1:train_size);
mean_humidity=mean(train_humidity);
mean_temp=mean(train_data);


res_cpu=train_data; % CPU---Temp
res_memory=train_humidity; % Memory---Humidity

train_data_cpu=train_data;
train_data_memory=train_humidity;

test_data_cpu=full_data(train_size+1:end);
test_data_mem=full_humidity(train_size+1:end);


figure()
plot(X,train_data_memory)
hold on
plot(X2(train_size+1:end),full_humidity(train_size+1:end))
legend('Training data','Validation data')

%Step2: Fitting a ARMAV model for CPU using Memory as input
data_cpu_mem=iddata(res_cpu,res_memory,1); %here one is the sampling rate
%testing the models
sys_cpu_mem=cell(25,1);
for n=1:25
    sys_cpu_mem{n}=armax(data_cpu_mem,[n,n,n-1,0]);
end

%Determining the AIC for each model
maic_cpu_mem=zeros(25,1);
for n=1:25
    maic_cpu_mem(n)=aic(sys_cpu_mem{n});
end

[AIC_opt_cpu_mem,n]=min(maic_cpu_mem);
model_cpu_mem=sys_cpu_mem{n};


% F-test
P=0.95;
[Model,res]=Multivariate_PostulateARMA(data_cpu_mem,P);
model_cpu_mem=Model;

%Step3: Fitting a ARMAV model for Memory using CPU as input
data_mem_cpu=iddata(res_memory,res_cpu,1); %here one is the sampling rate
%testing the models
sys_mem_cpu=cell(25,1);
for n=1:25
    sys_mem_cpu{n}=armax(data_mem_cpu,[n,n,n-1,0]);
end

%Determining the AIC for each model
maic_mem_cpu=zeros(25,1);
for n=1:25
    maic_mem_cpu(n)=aic(sys_mem_cpu{n});
end

[AIC_opt_mem_cpu,n]=min(maic_mem_cpu);
model_mem_cpu=sys_mem_cpu{n};


% F-test
P=0.95;
[Model,res]=Multivariate_PostulateARMA(data_mem_cpu,P);
model_mem_cpu=Model;


fprintf('Selected Model for Temperature driven by Humidity')
present(model_cpu_mem)
fprintf('Selected Model for Humidity driven by Temperature')
present(model_mem_cpu)

figure()
resid(model_cpu_mem,data_cpu_mem);
title('confirmation of adequacy of chosen model for Temperature output')
figure()
resid(model_mem_cpu,data_mem_cpu);
title('confirmation of adequacy of chosen model for Humidity output')

r=resid(model_cpu_mem,data_cpu_mem);
res=r.y;
RSS_train=sum(res.^2);
RMSE_train=sqrt(RSS_train/length(train_data_cpu));

r_mem=resid(model_mem_cpu,data_mem_cpu);
res_mem=r_mem.y;
RSS_train_mem=sum(res_mem.^2);
RMSE_train_mem=sqrt(RSS_train_mem/length(train_data_memory));

%Making Predictions
pred_cpu=zeros(length(test_data_cpu),1);
pred_mem=zeros(length(test_data_mem),1);
input_cpu=res_cpu;
input_mem=res_mem;
for i=1:length(test_data_cpu)
    % disp(i) % for debugging
    comb_1=iddata(input_cpu,input_mem,1);
    comb_2=iddata(input_mem,input_cpu,1);
    y_cpu=forecast(model_cpu_mem,comb_1,1);
    y_mem=forecast(model_mem_cpu,comb_2,1);
    pred_cpu(i)=y_cpu.y;
    pred_mem(i)=y_mem.y;
    input_cpu=[input_cpu;test_data_cpu(i)];
    input_mem=[input_mem;test_data_mem(i)];
end

std_cpu = RMSE_train;

std_mem = RMSE_train_mem;
figure()
plot(pred_cpu(1:20))
hold on
plot(test_data_cpu(1:20),'Color','b')

plot(pred_cpu(1:20)+1.96*std_cpu)
plot(pred_cpu(1:20)-1.96*std_cpu)
legend('Forecast data','Validation data','UB','LB')

figure()
plot(pred_mem(1:20))
hold on
plot(test_data_mem(1:20),'Color','b')

plot(pred_mem(1:20)+1.96*std_mem)
plot(pred_mem(1:20)-1.96*std_mem)
legend('Forecast data','Validation data','UB','LB')

%% Green function plot
%  G=GreenFunction(Model,30);
%  figure()
%  plot(G)
save('armav_detrended_Ftest.mat')