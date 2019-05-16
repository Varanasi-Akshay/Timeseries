function [var,std]=variance_nstep(G,MSE); % takes green function and variance
    var=zeros(size(G));
    std=zeros(size(G));
    sum=0;
    for i=1:max(size(G))
        sum=sum+G(i)^2;
        var(i)=MSE*(sum);
        std(i)=sqrt(var(i));
    end    


end