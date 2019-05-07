clear all
close all
clc

%% Step 1: Loading the EP_port Vectors:
EP_port=xlsread('Electricity_Generation.xlsx'); % energy produced during month
mean_T=xlsread('Mean_temp2.xlsx'); % mean temperature over month
mod=1:132; % use 132 data points for training
k=1:length(EP_port);
k=k';

%% Step 2: Detrending data 
% Fitting a linear deterministic trend:
% energy production trend
line_ep=polyfit(k,EP_port,1);
linevals_ep=line_ep(1)*k+line_ep(2);

% mean temperature trend
line_meanT=polyfit(k,mean_T,1);
linevals_meanT=line_meanT(1)*k+line_meanT(2);

% Extracting the residuals:
res_ep=EP_port-linevals_ep;
res_meanT=mean_T-linevals_meanT;

%% Step 3: Fit ARMAV model to Mean Temperature with Energy Consumption as an input:
%Creating iddata (objeect for time-series data)for use in modelling:
data_meanT_ep=iddata(res_meanT,res_ep,1); %iddata(y,u,Ts) y:output, u:input, Ts:time interval between samples

%Testing models of order (n,n,n-1) - (AR,Input,MA):
sys_meanT_ep=cell(25,1);
for n=1:25
    sys_meanT_ep{n}=armax(data_meanT_ep(mod),[n,n,n-1,0]); % use help armax to see the meaning of the parameters used
end

%Determining the AIC for each model:
maic_meanT_ep=zeros(25,1);
for n=1:25
    maic_meanT_ep(n)=aic(sys_meanT_ep{n});
end

%Localizing the least complex adequate, based on AIC:
[AIC_opt_meanT_ep,n]=min(maic_meanT_ep);
sys_opt_meanT_ep=sys_meanT_ep{n};

%Printing selected model:
fprintf('Selected Model for the Mean Temperature driven by Energy Consumption, based on AIC, is [%d,%d]',n,n-1)
present(sys_opt_meanT_ep)

%Confirming the adequacy of the model:
figure()
resid(sys_opt_meanT_ep,data_meanT_ep(mod));
title('Confirmation of Adequacy of Chosen Models for Mean Temperature driven by Energy Consumption','fontsize',11,'fontweight','demi')

r = resid(sys_opt_meanT_ep,data_meanT_ep(mod));
res = r.y;
RSS_v_meanT = sum(res.^2);


%% Step 4: Fit model to the energy production with mean temperature as an input:
%Creating iddata for use in modelling:
data_ep_meanT=iddata(res_ep,res_meanT,1); %iddata(y,u,Ts) y:output, u:input, Ts:time interval between samples

%Testing models of order (n,n,n-1) - (AR,Input,MA):
sys_ep_meanT=cell(25,1);
for n=1:25
    sys_ep_meanT{n}=armax(data_ep_meanT(mod),[n,n,n-1,0]); % use help armax to see the meaning of the parameters used
end

%Determining the AIC for each model:
maic_ep_meanT=zeros(25,1);
for n=1:25
    maic_ep_meanT(n)=aic(sys_ep_meanT{n});
end

%Localizing the least complex adequate, based on AIC:
[AIC_opt_ep_meanT,n]=min(maic_ep_meanT);
sys_opt_ep_meanT=sys_ep_meanT{n};

%Printing selected model:
fprintf('Selected Model for the Energy Production driven by Mean Temperature, based on AIC, is [%d,%d]',n,n-1)
present(sys_opt_ep_meanT)

%Confirming the adequacy of the model:
figure()
resid(sys_opt_ep_meanT,data_ep_meanT(mod));
title('Confirmation of Adequacy of Chosen Models for Energy Production driven by Mean Temperature','fontsize',11,'fontweight','demi')

r = resid(sys_opt_ep_meanT,data_ep_meanT(mod));
res = r.y;
RSS_v_ep = sum(res.^2);

%% Step 5: Compare RSS of ARMAV and ARMA model 
%--------------Fit ARMA model for temperature residuals-------------------%
%Fitting Independant series to the models of various orders to the mean temperature residuals:
sys_meanT=cell(25,1);
% note here that we are simply fitting arma model to the temperature
for n=1:25
    sys_meanT{n}=armax(res_meanT(mod),[n n-1]);
end

%Determining the AIC for each model:
maic_meanT=zeros(25,1);
for n=1:25
    maic_meanT(n)=aic(sys_meanT{n});
end

%Localizing the least complex adequate model, based on AIC:
[AIC_opt_meanT,n]=min(maic_meanT);
sys_opt_meanT=sys_meanT{n};

%Printing selected model:
fprintf('Selected Model for the energy production, based on AIC, is [%d,%d]',n,n-1)
present(sys_opt_meanT)

%Confirming the adequacy of the model:
figure()
resid(sys_opt_meanT,res_meanT(mod));
title('Confirmation of Adequacy of Chosen Models for Mean Temperature','fontsize',11,'fontweight','demi')

r = resid(sys_opt_meanT,res_meanT(mod));
res = r.y;
RSS_meanT = sum(res.^2);

%-------------Fit ARMA model for energy prouction residuals---------------%
%Fitting Independant series to the models of various orders to energy production residuals:
sys_ep=cell(25,1);
% note here that we are simply fitting arma model to the energy production
for n=1:25
    sys_ep{n}=armax(res_ep(mod),[n n-1]);
end

%Determining the AIC for each model:
maic_ep=zeros(25,1);
for n=1:25
    maic_ep(n)=aic(sys_ep{n});
end

%Localizing the least complex adequate model, based on AIC:
[AIC_opt_ep,n]=min(maic_ep);
sys_opt_ep=sys_ep{n};

%Printing selected model:
fprintf('Selected Model for the energy production, based on AIC, is [%d,%d]',n,n-1)
present(sys_opt_ep)

%Confirming the adequacy of the model:
figure()
resid(sys_opt_ep,res_ep(mod));
title('Confirmation of Adequacy of Chosen Models for Mean Temperature','fontsize',11,'fontweight','demi')

r = resid(sys_opt_ep,res_ep(mod));
res = r.y;
RSS_ep = sum(res.^2);

fprintf('RSS of ARMAV model for Energy Production driven by Mean Temperature is %d \n',RSS_v_ep)
fprintf('RSS of ARMA model for Energy Production is %d \n',RSS_ep)

fprintf('RSS of ARMAV model for Mean Temperature driven by Energy Production is %d \n',RSS_v_meanT)
fprintf('RSS of ARMA model for Mean Temperature is %d \n',RSS_meanT)


