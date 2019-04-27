clc; clear all; close all;
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

figure(3)
viscircles([0 0],1,'Color','b');
hold on

ylim([-1,1]);
xlim([-1,1]);
plot(ro(:,1),ro(:,2),'r*')
pbaspect([1 1 1])






