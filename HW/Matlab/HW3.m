num = xlsread('Retail_Sales_Data.xlsx');
%data = zeros(length(num),2);
% data(:,1)=1:length(num);
% data(:,2)=num(:,:,3);
X=1:length(num);
y=num(:,3);

mdl = LinearModel.fit(X,y);
mdl
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

%[m2,Model2,res2]=PostulateARMA_AIC(ts);
[m2,Model2,AIC,MinAIC,res2,MinAR_Order,MinMA_Order]=PostulateARMA_AIC(Res);
Model2