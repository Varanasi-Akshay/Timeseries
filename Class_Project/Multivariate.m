close all
clc
%Step1: Loading the Data
datatable=readtable('F:\Spring 2019\Applied Project\sl73caehdp4211_min_idle.csv');
ts_cpu=datatable{:,{'min_idle'}};
ts_memory=datatable{:,{'percent_memused'}};
train_data_cpu=ts_cpu(1:fix((2/3)*length(ts_cpu)));
m_cpu=mean(train_data_cpu);
train_data_cpu=train_data_cpu-m_cpu;
train_data_memory=ts_memory(1:fix((2/3)*length(ts_cpu)));
m_mem=mean(train_data_memory);
train_data_memory=train_data_memory-m_mem;
test_data_cpu=ts_cpu(fix((2/3)*length(ts_cpu))+1:length(ts_cpu))-m_cpu;
test_data_mem=ts_memory(fix((2/3)*length(ts_memory))+1:length(ts_memory))-m_mem;

res_cpu=train_data_cpu;
res_memory=train_data_memory;

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

fprintf('Selected Model for CPU driven by Memory')
present(model_cpu_mem)
fprintf('Selected Model for Memory driven by CPU')
present(model_mem_cpu)

figure()
resid(model_cpu_mem,data_cpu_mem);
title('confirmation of adequacy of chosen model')
figure()
resid(model_mem_cpu,data_mem_cpu);
title('confirmation of adequacy of chosen model')

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
for i=1:100
    %fprintf(i)
    i
    comb_1=iddata(input_cpu,input_mem,1);
    comb_2=iddata(input_mem,input_cpu,1);
    y_cpu=forecast(model_cpu_mem,comb_1,1);
    y_mem=forecast(model_mem_cpu,comb_2,1);
    pred_cpu(i)=y_cpu.y;
    pred_mem(i)=y_mem.y;
    input_cpu=[input_cpu;test_data_cpu(i)];
    input_mem=[input_mem;test_data_mem(i)];
end

figure()
plot(pred_cpu(1:100))
hold on
plot(test_data_cpu(1:100))
% %Extracting Model Parameters and Making predictions
% ar_param_cpu=model_cpu_mem.a;
% ar_param_cpu_mem=model_cpu_mem.b;
% ma_param_cpu=model_cpu_mem.c;
% 
% ar_param_mem=model_mem_cpu.a;
% ar_param_mem_cpu=model_mem_cpu.b;
% ma_param_mem=model_mem_cpu.c;
% 
% x_cpu=train_data_cpu(length(train_data_cpu)-length(ar_param_cpu)+2:length(train_data_cpu));
% a_cpu=res(length(res)-length(ma_param_cpu)+2:length(res));
% x_cpu_mem=train_data_memory(length(train_data_memory)-length(ar_param_cpu_mem)+2:length(train_data_memory));
% %x_cpu_mem=[x_cpu_mem;0];
% 
% x_mem=train_data_memory(length(train_data_memory)-length(ar_param_mem)+2:length(train_data_memory));
% a_mem=res_mem(length(res_mem)-length(ma_param_mem)+2:length(res_mem));
% x_mem_cpu=train_data_cpu(length(train_data_cpu)-length(ar_param_mem_cpu)+2:length(train_data_cpu));
% x_mem_cpu=[x_mem_cpu;0];
% 
% %ahead_pred=zeros(length(test_data_cpu),6);%length(test_data_cpu)
% ahead_pred_cpu=zeros(1,6);
% ahead_pred_mem=zeros(1,6);
% for i=1:1%length(test_data_cpu)
%     %six_pred=[];
%     diff_cpu=x_cpu;
%     diff_cpu_mem=x_cpu_mem;
%     err_list_cpu=a_cpu;
%     diff_mem=x_mem;
%     diff_mem_cpu=x_mem_cpu;
%     err_list_mem=a_mem;
%     for step=1:6
%        %one_step=0;
%        prediction_cpu=-fliplr(ar_param_cpu(2:end))*diff_cpu+fliplr(ar_param_cpu_mem(2:end))*diff_cpu_mem+fliplr(ma_param_cpu(2:end))*err_list_cpu;
%        diff_mem_cpu=[diff_mem_cpu(2:end);prediction_cpu];
%        prediction_mem=-fliplr(ar_param_mem(2:end))*diff_mem+fliplr(ar_param_mem_cpu)*diff_mem_cpu+fliplr(ma_param_mem(2:end))*err_list_mem;
%        diff_cpu_mem=[diff_cpu_mem(2:end);prediction_mem];
%        diff_cpu=[diff_cpu(2:end);prediction_cpu];
%        diff_mem=[diff_mem(2:end);prediction_mem];
%        %prediction=prediction+m_cpu;
%        ahead_pred_cpu(i,step)=prediction_cpu;
%        ahead_pred_mem(i,step)=prediction_mem;
%        %six_pred=[six_pred,prediction];
%        err_list_cpu=[err_list_cpu(2:end);0];
%        err_list_mem=[err_list_mem(2:end);0];
%     end
%     x_cpu=[x_cpu(2:end);test_data_cpu(i)];
%     a_cpu=[a_cpu(2:end);test_data_cpu(i)-ahead_pred_cpu(i,1)];
%     if(i<length(test_data_mem))        
%         x_cpu_mem=[x_cpu_mem(2:end);test_data_mem(i+1)];
%     else
%         x_cpu_mem=[x_cpu_mem(2:end);test_data_mem(length(test_data_mem))];
%     end
%     x_mem=[x_mem(2:end);test_data_mem(i)];
%     a_mem=[a_mem(2:end);test_data_mem(i)-ahead_pred_mem(i,1)];
%     if(i<length(test_data_cpu))        
%         x_mem_cpu=[x_mem_cpu(2:end);test_data_cpu(i+1)];
%     else
%         x_mem_cpu=[x_mem_cpu(2:end);test_data_cpu(length(test_data_cpu))];
%     end
% end
% residual_one_step=ahead_pred(:,1)-(test_data_cpu+m_cpu);
% rss_onestep=sum(residual_one_step.^2);
% rmse_onestep=sqrt(rss_onestep/length(test_data_cpu));
% figure()
% plot(ahead_pred(:,1))
% hold on
% plot(test_data_cpu+m_cpu)
% 
% residual_two_step=ahead_pred(1:(length(test_data_cpu)-1),2)-(test_data_cpu(2:end)+m_cpu);
% rss_twostep=sum(residual_two_step.^2);
% rmse_twostep=sqrt(rss_twostep/(length(test_data_cpu)-1));
% figure()
% plot(ahead_pred(1:(length(test_data_cpu)-1),6))
% hold on
% plot(test_data_cpu(2:end)+m_cpu)
% 
% residual_three_step=ahead_pred(1:(length(test_data_cpu)-2),3)-(test_data_cpu(3:end)+m_cpu);
% rss_threestep=sum(residual_three_step.^2);
% rmse_threestep=sqrt(rss_threestep/(length(test_data_cpu)-2));
% 
% residual_four_step=ahead_pred(1:(length(test_data_cpu)-3),4)-(test_data_cpu(4:end)+m_cpu);
% rss_fourstep=sum(residual_four_step.^2);
% rmse_fourstep=sqrt(rss_fourstep/(length(test_data_cpu)-3));
% 
% residual_five_step=ahead_pred(1:(length(test_data_cpu)-4),5)-(test_data_cpu(5:end)+m_cpu);
% rss_fivestep=sum(residual_five_step.^2);
% rmse_fivestep=sqrt(rss_fivestep/(length(test_data_cpu)-4));
%     
% residual_six_step=ahead_pred(1:(length(test_data_cpu)-5),6)-(test_data_cpu(6:end)+m_cpu);
% rss_sixstep=sum(residual_six_step.^2);
% rmse_sixstep=sqrt(rss_sixstep/(length(test_data_cpu)-5));
% figure()
% plot(ahead_pred(1:(length(test_data_cpu)-5),6))
% hold on
% plot(test_data_cpu(6:end)+m_cpu)
