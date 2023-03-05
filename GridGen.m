% Grid genertor
% 
% Input arguments:
%     nx: No. of points in the X direction.
%     ny: No. of points in the Y direction. Default is nx.
%     nz: No. of points in the Z direction. Default is 1.
%     triangular: If input is 'on' than returns a triangular grid (default: square).
%     theta: Grid rotation, defau;t is in radians.
%     degrees: if input is 'on' than the rotation is given in degrees.
% 
% Output argument:
%     grid: [x y] (or [x y z]) of grid points. Columns are individual points, rows are x, y, z coordinates.

function grid=GridGen(nx, ny, nz, triangular, theta, degrees)

if nargin<2
    ny=nx;
end
if nargin<3
    nz=1;
end

xc=(nx-1)/2;
yc=(ny-1)/2;
zc=(nz-1)/2;

npts=nx*ny*nz;

x=0:npts-1;
y=floor(x/nx);

if (nz > 1)
    y=mod(y,ny);
    z=floor(x/(nx*ny));
end
x=mod(x,nx);

% triangular keyword
if nargin>3
    if strcmpi(triangular,'on')
        x = x-0.25 + 0.5*mod(y,2);
        y = y*sqrt(3)/2;
        yc = yc*sqrt(3)/2;
    end
end


grid = [x-xc;  y-yc];
if (nz>1)
    grid = [grid;  z-zc];
end

% Rotation
if nargin>4
    if nargin>5
        theta = theta*pi/180;
    end
    grid(1,:) = grid(1,:) * cos(theta) + grid(2,:) * sin(theta);
    grid(2,:) = -1*grid(1,:) * sin(theta) + grid(2,:) * cos(theta);
end










