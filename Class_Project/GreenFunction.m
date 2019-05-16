function G=GreenFunction(Model,TimeHorizon);

%G is the Green function of the ARMA model Model, calculated up to the Time Horizon. An assumption has been
%made that all roots of the ARMA model are distinct.
%Note that G(1) corresponds to G_0 index from the Pandit & Wu book, simply because Matlab can't take
%indices that are zero or negative :-(. Also, note that G(1)=1.

%Created by Dragan Djurdjanovic, Ann Arbor, MI, Aug. 28,2002.

AR_Poly=Model.a;
MA_Poly=Model.c;
l=roots(AR_Poly); %Roots of the characteristic polynomial.

n=length(l);

for i=1:n
    Down=1;
    Up=polyval(MA_Poly,l(i));
    for j=1:n
        if j~=i
            Down=Down*(l(i)-l(j));
        end
    end
    C(i)=Up/Down;
end

for i=1:TimeHorizon
    G(i)=0;
    for j=1:n
        G(i)=G(i)+C(j)*l(j)^i;
    end
end
        
G=[1 real(G)];  %The term G_0 is actually equal to 1 and this is done because Matlab has no way of
                %using zero, or negative indices :-(.
        