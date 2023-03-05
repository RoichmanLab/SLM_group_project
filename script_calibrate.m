%Interfacing the laser with computer
obj=start_laser();
%%
pri=start_prior();
%%
fprintf(obj, 'S=0');
%turns shutter OFF
%%
fprintf(obj, 'S=1');
%%
blank_slm; %clear patterns
%%
%
fprintf(obj, 'P=0.01'); %sets output power - minimum P=0.0
%fprintf(obj, 'P=0.01'); %sets output power - minimum P=0.0
%% turn on the grasshopper camera 
grasshopper
%%
calibrate

%% Generate a circle
C=CircGen(6,65);
phi=fastphase(C);
%% block central spot
% generate a grid
G=GridGen(4,4)*100;
%phi=dsphase(G);
phi=fastphase(G);
%%
G=GridGen(1,1);
a = [1 2 3]
for i = 1:length(a)
    C=GridGen(1,1)*2
    phi=dsphase(G+C)
    pause(1)
end 
phi=dsphase(G);
%%
slm(doe_add(phi ...
    ,displace(0,0,0)))
%%
slm(vortex(80))
%%
fullscreen
%% 
G=GridGen(1,1);
phi=fastphase(G);
changh = [100 200 300]
for i = 1:length(changh)
    a = doe_add(phi,displace(0,0,100));
    b = doe_add(phi,displace(0,0,changh(i)));
    c = a+b;
    slm(c)
    pause(1)
end 

