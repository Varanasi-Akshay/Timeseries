[values]=predict_nstep(model,y,res,nstep);

% Flip the data to have recent value first
data=flipud(y);


% AR model
coef_AR=model.A;
m=length(coef_AR);

% MA model
coef_MA=model.C;
n=length(coef_MA);

% residuals
residuals=flipud(res);

for i=1:nstep
    values(i) = -coef_AR(2:end)*data(1:m-i)+coef_MA*residuals(1:n);
    data(2:end)=data(1:end-1);
    data(1)=values(i);
    residuals(2:end)=residuals(1:end-1);
    residuals(1)=0;
end    