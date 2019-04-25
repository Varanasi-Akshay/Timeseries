clear all
close all
clc

%% Step 1: Loading the EP_port Vectors:
EP_port=xlsread('Electricity_Generation.xlsx');
mean_T=xlsread('Mean_temp2.xlsx');
mod = 1:132;
k=1:length(EP_port);
k=k';   

%% Step 2: Detrending Data
% Fitting a linear deterministic trend;
% energy trend
line_ep=polyfit(k,EP_port,1);
linevals_ep = line_ep(1)*k+line_ep(2);

% mean temperature trend
line_meanT = polyfit(k,mean_T,1);
linevals_meanT = line_meanT(1)*k+line_meanT(2);

% Extracting the residuals:
res_ep = EP_port-linevals_ep;
res_meanT=mean_T-linevals_meanT;

%% Step 3 Fit ARMAV model to Mean Temperature with Energy Consumption
% creating iddata(object for timeseries data) for use in modelling
data_meanT_ep=iddata(res_meanT,res_ep,1); %iddata(y,u,ts) y:output, u:input, ts: time interval for sampling


%Testing models of order (n,n,n-1)- (AR,Input,MA):
sys_meanT_ep = cell(25,1);
for n=1:25
    sys_meanT_ep{n}=armax(data_meanT_ep(mod),[n,n,n-1,0]);
end    

% Determining the AIC for each model:
maic_meanT_ep=zeros(25,1);
for n=1:25
    maic_meanT_ep(n)=aic(sys_meanT_ep{n});
end

% Localizing the least complex adequate, based on AIC:
[AIC_opt_meanT_ep,n]=min(maic_meanT_ep);
sys_opt_meanT_ep=sys_meanT_ep{n};

%Printing the selected model:
fprintf('Selected Model for the Mean Temperature driven by Energy Consumption')
present(sys_opt_meanT_ep)

% Confirming the adequacy of the model:
figure()
resid(sys_opt_meanT_ep,data_meanT_ep(mod));
title('Confirmation of adequacy of chosen models for mean temperature driven by energy consumption')

r=resid(sys_opt_meanT_ep,data_meanT_ep(mod));
res=r.y;
RSS_v_meanT = sum(res.^2);

%% Step 4 Fit ARMAV model to Energy Consumption with Mean Temperature
% creating iddata(object for timeseries data) for use in modelling
data_ep_meanT=iddata(res_ep,res_meanT,1); %iddata(y,u,ts) y:output, u:input, ts: time interval for sampling


%Testing models of order (n,n,n-1)- (AR,Input,MA):
sys_ep_meanT = cell(25,1);
for n=1:25
    sys_ep_meanT{n}=armax(data_ep_meanT(mod),[n,n,n-1,0]);
end    

% Determining the AIC for each model:
maic_ep_meanT=zeros(25,1);
for n=1:25
    maic_ep_meanT(n)=aic(sys_ep_meanT{n});
end

% Localizing the least complex adequate, based on AIC:
[AIC_opt_ep_meanT,n]=min(maic_ep_meanT);
sys_opt_ep_meanT=sys_ep_meanT{n};

%Printing the selected model:
fprintf('Selected Model for the Mean Temperature driven by Energy Consumption')
present(sys_opt_ep_meanT)

% Confirming the adequacy of the model:
figure()
resid(sys_opt_ep_meanT,data_ep_meanT(mod));
title('Confirmation of adequacy of chosen models for mean temperature driven by energy consumption')

r=resid(sys_opt_ep_meanT,data_ep_meanT(mod));
res=r.y;
RSS_v__ep = sum(res.^2);


%% Step 5: Compare RSS of ARMAV and 



