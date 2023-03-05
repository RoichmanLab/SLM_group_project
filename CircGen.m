function circ=CircGen(n,r)

if nargin<2
    r=1;
end

theta=[0:2*pi/n:2*pi];
theta(end)=[];

x=r*cos(theta);
y=r*sin(theta);

circ=[x; y];