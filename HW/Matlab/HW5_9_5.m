ro=[0.62 0;
    0.99 0;
    0.998 0;
    0.5 0.866;
    0.5 -0.866;
    -0.5 0.866;
    -0.5 -0.866];
figure
viscircles([0 0],1,'Color','b');
hold on

ylim([-1,1]);
xlim([-1,1]);
plot(ro(:,1),ro(:,2),'r*')
pbaspect([1 1 1])
