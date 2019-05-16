function [Model,res]=Multivariate_PostulateARMA(Data,P)

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




N=length(Data.y);
%m=mean(Data.y);
%[n1,n2]=size(Data);
%Data=Data-m*ones(n1,n2);
Cycle=1;

%Data=iddata(ts);

%Initializing
CurrentModel=armax(Data,[2,2,1,0]);
n=1;
r=resid(CurrentModel,Data);
residuals=r.y;
CurrentRSS=sum(residuals.^2); %residual sum of squares

while Cycle
    n=n+1;
    OldModel=CurrentModel;
    OldRSS=CurrentRSS;
    CurrentModel=armax(Data,[2*n,2*n,2*n-1,0]);
    
    r=resid(CurrentModel,Data);
    residuals=r.y;
    CurrentRSS=sum(residuals.^2); %residual sum of squares

    TestRatio=((OldRSS-CurrentRSS)/6)/(CurrentRSS/(N-6*n));
    Control=finv(P,6,N-6*n); 
    %If you do not have statistical toolbox, uncomment the line below
    %and comment the line above
    %Control=FindFischer(4,N-4*n,f_95,ni1,ni2);
    %[TestRatio Control;2*n 2*n-1;2*n-2 2*n-3];%this was just for debugging purposes.
    if TestRatio<Control
        Cycle=0;
        Model=OldModel;
        RSS=OldRSS;
        [TestRatio Control;2*n-1 2*n-2]; %this was just for debugging purposes.
    end
end

r=resid(Model,Data);
res=r.y;