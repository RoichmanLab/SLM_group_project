function phi=fastphase(points, varargin)

% PURPOSE: Calculates the phase hologram encoding a desired trapping
%          pattern by superposition as fast as possible.
%
% CATEGORY:
%      Computed holography
%
% CALLING SEQUENCE:
%      phi = fastphase(points)
%
% INPUTS:
%      points: [2,npts] or [3,npts] array of (x,y) coordinates of points in the plane,
%         relative to the center of the field of view.
%         Coordinates are measured in arbitrary pixel units, unless
%         the CAL keyword is set.
%
% KEYWORD PARAMETERS:
%      dim: [nx] or [nx,ny] array giving dimensions of DOE, in pixels.
%             Default: 768
%             
%      cal: Spatial calibration factors returned by CALIBRATE.
%           Default: square pixels, no rotation, arbitrary scale.
%           
% OUTPUTS:
%      phi: phase pattern encoding pattern of traps described by
%           points with values ranging from [0,2 pi].
% RESTRICTIONS:
%      Can be very memory intensive for large numbers of points.
%
% PROCEDURE:
%      Initial estimate is obtained by superposing the fields of the
%      specified beams.
%
% NOTES:
%      If we calibrate the SLM's phase transfer function, then we
%      should be able to pass the lookup table to this function, and
%      return a hologram of indices into the look-up table.
% MODIFICATION HISTORY:
% Created by David G. Grier, New York University, 12/12/2004.
% 1/19/2005: DGG.  Implemented 3D.
% 1/29/2005: DGG.  Major code clean-up leading to improved speed.
%                  Implemented SUBSAMPLE for major speedup.
% 11/5/2011: Maya Yevnin -  added wavelength parameterand calibration files
% Mar 2013: Maya Yevnin -   Moved calibration parameters from the xmat, ymat
%                           vectors to new vector corrected_points, and
%                           added zfac parameter
%-

% Input parameters
p = inputParser;
addRequired(p,'points', @isnumeric);                                  % array of points to transform
addOptional(p,'wavelength', 1, @isnumeric);                           % default wavelength, in nm
addParamValue(p, 'dim',[600,800], @isnumeric);                        % SLM dimensions. default: 600*800 pixles
addParamValue(p, 'cal', {0 0 1 1 0 0 300 0 400 0}, @(x)length(x)>=9);   % known calibration parameters.
addParamValue(p, 'screen',[1920,1200], @isnumeric);                     % Screen resolution. default: 480x640 pixles
addParamValue(p, 'centered','off', @ischar);                          % should the image be centered?
parse(p, points, varargin{:});

% SLM resolution parameters
w=p.Results.dim(1);
h=p.Results.dim(2);

% wavelength used in nanometers
if any(strcmp(p.UsingDefaults, 'wavelength'))
    load('D:\SLM calibration\wavelength_Green.mat');
    wavelength = wavelength_Green;
else
    wavelength = p.Results.wavelength;
end

% checks if the user passed calibration parameters
% usecal=1;
% for i=1:length(p.UsingDefaults)
%     if strcmp(p.UsingDefaults{i}, 'cal')
%         usecal=0;
%     end
% end


% Calibration parameters
usecal =  any(strcmp(p.UsingDefaults, 'cal'));  % use default calibration
cal = load_calibration(p.Results.cal, usecal);
corrected_points = apply_calibration(points, cal, p.Results.centered, p.Results.screen);

[ndim, npts]=size(points);    % ndims: number of dimensions; npts: number of points
    
% wavevectors associated with trap position (times i)
ikx = single(complex(0, (2*pi/w)*squeeze(corrected_points(1,:))));
iky = single(complex(0, (2*pi/h)*squeeze(corrected_points(2,:))));

if ndim>2
    aperture = 5000;                            % 5mm aperture
    lambda = (wavelength/1000)*w/aperture;      % wavelength in aperture pixels
    na = 1.4;                                   % numerical aperture of objective
    f = aperture/na;                            % focal length in pixels
    ikz = complex(0, (2*pi)*squeeze(corrected_points(3,:))/(lambda*f^2));
end

% coordinates in SLM plane (row vectors)
x = (0:w-1);
y = (0:h-1);

xc = cal{1};
yc = cal{2};
if ndim>2
    xsq = (x-w/2-xc).^2;
    ysq = (y-h/2-yc).^2;
end

iphase = complex(0, 2*pi*rand(1,npts));      % relative phases

psi=zeros(w,h);
for n=1:npts
    ikxx=ikx(n)*x+iphase(n);
    ikyy=iky(n)*y;
    if ndim>2
        ikxx=ikxx+ikz(n)*xsq;
        ikyy=ikyy+ikz(n)*ysq;
    end
    ex=exp(-ikxx);
    ey=exp(-ikyy);
    psi=psi+(ex.'*ey);
end

phi=angle(psi) + pi;
