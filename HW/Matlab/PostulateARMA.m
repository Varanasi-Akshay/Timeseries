function [m,Model,res]=PostulateARMA(ts,P);

%Variable ts is the time-series and P is the level of significance that will be used
%for F tests associated with the model fitting.


%Time-series object can be created by typing Data=iddata(ts); Then, this stucture is compatible with the
%ARMA fiting procedures in Matlab.

%Model is the model object representing the ARMA model fitted to the Data time-series object.
%It contains all necessary information about this model.
%Type set(idpoly) to see all the model properties and how you can get them.

%m is the mean value of the Data time-series calculated using the simple sample mean.

%Created by Dragan Djurdjanovic, September 2002, Ann Arbor, MI.

%Last modified Feb. 28th 2017 in Austin, TX

% load F_Distribution_Wrkspc %Loading the Fischer tables (for those who do not have the statistics toolbox
% ni1(length(ni1))=300;
% ni2(length(ni2))=300;
%You do not need the line above if you have the statistical toolbox.




N=length(ts);
m=mean(ts);
[n1,n2]=size(ts);
ts=ts-m*ones(n1,n2);
Cycle=1;

Data=iddata(ts);

%Initializing
CurrentModel=armax(Data,[2 1]);
n=1;
r=resid(CurrentModel,Data);
residuals=r.y;
CurrentRSS=sum(residuals.^2); %residual sum of squares

while Cycle
    n=n+1;
    OldModel=CurrentModel;
    OldRSS=CurrentRSS;
    CurrentModel=armax(Data,[2*n 2*n-1]);
    
    r=resid(CurrentModel,Data);
    residuals=r.y;
    CurrentRSS=sum(residuals.^2); %residual sum of squares

    TestRatio=((OldRSS-CurrentRSS)/4)/(CurrentRSS/(N-4*n));
    Control=finv(P,4,N-4*n); 
    %If you do not have statistical toolbox, uncomment the line below
    %and comment the line above
    %Control=FindFischer(4,N-4*n,f_95,ni1,ni2);
    [TestRatio Control;2*n 2*n-1;2*n-2 2*n-3];%this was just for debugging purposes.
    if TestRatio<Control
        Cycle=0;
        PreliminaryModel=OldModel;
        PreliminaryRSS=OldRSS;
        [TestRatio Control;2*n-1 2*n-2]; %this was just for debugging purposes.
    end
end
AR_Order=length(PreliminaryModel.a)-1;
MA_Order=length(PreliminaryModel.c)-1;


%Now check if the odd valued model is good
CurrentModel=armax(Data,[AR_Order-1 AR_Order-2]);
r=resid(CurrentModel,Data);
residuals=r.y;
CurrentRSS=sum(residuals.^2); %residual sum of squares

TestRatio=((CurrentRSS-PreliminaryRSS)/2)/(PreliminaryRSS/(N-(2*AR_Order-2)));

Control=finv(P,2,N-(2*AR_Order-2)); 
%If you do not have statistical toolbox, comment the line above
%and uncomment the line below
%Control=FindFischer(2,N-(2*AR_Order-2),f_95,ni1,ni2);

if TestRatio<Control
    PreliminaryModel=CurrentModel;
    PreliminaryRSS=CurrentRSS;
end

%Now, removing the unnecessary MA parameters.
AR_Order=length(PreliminaryModel.a)-1;
MA_Order=length(PreliminaryModel.c)-1;
CurrMA=MA_Order;
CurrentModel=PreliminaryModel;
CurrentRSS=PreliminaryRSS;

if CurrMA>1
    Cycle=1;
else
    Cycle=0;
    Model=PreliminaryModel;
    RSS=PreliminaryRSS;
end

while Cycle
    OldModel=CurrentModel;
    OldRSS=CurrentRSS;
    CurrMA=CurrMA-1;
    CurrentModel=armax(Data,[AR_Order CurrMA]);
    r=resid(CurrentModel,Data);
    residuals=r.y;
    CurrentRSS=sum(residuals.^2); %residual sum of squares
    
    NumOfParams=AR_Order+CurrMA+1;
    TestRatio=((CurrentRSS-PreliminaryRSS)/1)/(PreliminaryRSS/(N-NumOfParams));
    %%%%%%%%%%%%%%%%%%
    %Control=FindFischer(1,NumOfParams,f_95,ni1,ni2); 
    %If you do not have statistical toolbox, comment the line below
    %and uncomment the line above
    Control=finv(P,1,NumOfParams);
    if TestRatio>Control
        Cycle=0;
        Model=OldModel;
        RSS=OldRSS;
    end
end %Done

r=resid(Model,Data);
res=r.y;