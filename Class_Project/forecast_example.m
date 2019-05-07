load iddata1 z1
z1 = iddata(cumsum(z1.y),cumsum(z1.u),z1.Ts,'InterSample','foh');
past_data = z1(1:100);
future_inputs = z1.u(101:end);
sys = polyest(z1,[2 2 2 0 0 1],'IntegrateNoise',true);

K = 200;
[yf,x0,sysf,yf_sd,x,x_sd] = forecast(sys,past_data,K,future_inputs);

figure()
UpperBound = iddata(yf.OutputData+3*yf_sd,[],yf.Ts,'Tstart',yf.Tstart);
LowerBound = iddata(yf.OutputData-3*yf_sd,[],yf.Ts,'Tstart',yf.Tstart);
plot(past_data(:,:,[]),yf(:,:,[]),UpperBound,'k--',LowerBound,'k--')
legend({'Measured','Forecasted','3 sd uncertainty'},'Location','best')

%figure()
hold on
full_data = z1(1:end);
plot(full_data(:,:,[]))