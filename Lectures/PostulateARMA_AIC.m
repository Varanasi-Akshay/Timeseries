function [m,Model,AIC,MinAIC,res,MinAR_Order,MinMA_Order]=PostulateARMA_AIC(ts);


N=length(ts);
m=mean(ts);
[n1,n2]=size(ts);
ts=ts-m*ones(n1,n2);
MinAIC=inf; %Just to initiate the search - this will store the minimum AIC

Data=iddata(ts);

ModelIndex=0;
for AR_Order=17:21
    %AR_Order %Just to track the progress
    for MA_Order=1:AR_Order-1
        ModelIndex=ModelIndex+1;
        
        CurrentModel=armax(Data,[AR_Order MA_Order]);
        r=resid(CurrentModel,Data);
        residuals=r.y;
        RSS=sum(residuals.^2); %residual sum of squares
        AIC(ModelIndex)=N*log(RSS/N)+2*(AR_Order+MA_Order+2);
        %Two is added here for the mean and slope that were estimated
        
        if AIC(ModelIndex)<MinAIC
            MinAIC=AIC(ModelIndex);
            MinAR_Order=AR_Order;
            MinMA_Order=MA_Order;
            Model=CurrentModel;  
        end
        
        
    end
end

r=resid(Model,Data);
res=r.y;
