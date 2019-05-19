function [forecast_data,forecast_residuals]=forecast_nstep(model,y,full_data,nstep);
n = max(size(y));
m = max(size(full_data));

forecast_data = zeros(m-n,1);
forecast_residuals = zeros(m-n,1);
updating_data = y;
for i= 1:m-n
    [yf yMSE] = forecast(model,updating_data,nstep);
    forecast_data(i) = yf(nstep); 
    updating_data(n+i) = full_data(n+i); 

end
forecast_residuals = full_data(n+1:end)-forecast_data;

end

