function phi=dsphase(points, varargin)
% PURPOSE: Calculates the phase hologram encoding a desired trapping
%          pattern by superposition as fast as possible.
%
% CATEGORY:
%      Computed holography
%
% CALLING SEQUENCE:
%      phi = fastphase(points)
%
% VERSION:
% 5
%
% INPUTS:
%      points: [2,npts] or [3,npts] array of (x,y) coordinates of points in the plane,
%         relative to the center of the field of view.
%         Coordinates are measured in arbitrary pixel units, unless
%         the CAL keyword is set.
% OPTIONAL
%        wavelength - optional - the wavelength used in [nm]
%         Default: 1085
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
%
%18/11/2010: Omer Wagner - a. added lambda paramters b. changed
%'trap_intensities' default from length to columns
% 11/5/2011: Maya Yevnin - added wavelength parameter and calibration files
%26/6/2011 - fixed corrdination bug
% Mar 2013: Maya Yevnin -   Moved calibration parameters from the xmat, ymat
%                           vectors to new vector corrected_points, and
%                           added zfac parameter
% Mar 2014: Maya Yevnin - Calibration moved to load_calibration and
%                           apply_calibration scripts. cal should be a cell
%                           array
%% parameters and data preperation
%%

tic
% Input parameters
p = inputParser;
addRequired(p,'points', @isnumeric);                                            % array of points to transform
addOptional(p,'wavelength', 532, @isnumeric);                        % the wavelength used, in nm
addParamValue(p,'rho', 0.5, @isnumeric);                                       % convergence ratio
addParamValue(p,'trap_intensities', ones(1,size(points,2)), @isnumeric)        % relative trap intensities
addParamValue(p,'dim',[600,800], @isnumeric);                                  % SLM dimensions. default: 600*800 pixles
addParamValue(p, 'cal', {0 0 1 1 0 0 300 0 400 0}, @(x)length(x)>=9);   % known calibration parameters.
addParamValue(p,'thresh', 0.00005, @isnumeric);                                  % threshold for stopping the iterations
addParamValue(p,'topological_charge',zeros(1,length(points)), @isnumeric);     % topological charge for vortices
addParamValue(p,'window',0,@isnumeric);
addParamValue(p, 'screen',[640,480], @isnumeric);                     % Screen resolution. default: 480x640 pixles
addParamValue(p, 'centered','off', @ischar);                          % should the image be centered?
addParamValue(p, 'quiet','off', @ischar);                          % should the image be centered?
parse(p, points, varargin{:});

% threshold for convergence
thresh = p.Results.thresh;

% convergence ratio
rho = p.Results.rho;

% Relative trap intensities
alpha = p.Results.trap_intensities;

% topological charge
topc = p.Results.topological_charge;

% windowing effect
win = p.Results.window;

% SLM resolution parameters
w=p.Results.dim(1);
h=p.Results.dim(2);

%wavelength used
wavelength = p.Results.wavelength % laser wavelengtrh in nanometers

% checks if the user passed calibration parameters
usecal=1;
for i=1:length(p.UsingDefaults)
    if strcmp(p.UsingDefaults{i}, 'cal')
        usecal=0;
    end
end

% Calibration parameters
cal = load_calibration(p.Results.cal, usecal, wavelength);
corrected_points = apply_calibration(points, cal, p.Results.centered, p.Results.screen);

[ndim, npts]=size(points);    % ndims: number of dimensions; npts: number of points

%% start stage 1: compute initial estimate for the phase. randomize the
%% phases at trap locations. The code is based on fastphase.m
%%

% wavevectors associated with trap position (times i)
ikx = single(complex(0, (2*pi/w)*squeeze(corrected_points(1,:))));
iky = single(complex(0, (2*pi/h)*squeeze(corrected_points(2,:))));

if ndim>2
    aperture = 5000;                             % 5mm aperture
    lambda = (wavelength/1000)*w/aperture;      % wavelength in aperture pixels
    na = 1.4;                                                % numerical aperture of objective
    f = aperture/na;                            % focal length in pixels
    ikz = complex(0, (2*pi)*squeeze(corrected_points(3,:))/(lambda*f^2));
end

% coordinates in SLM plane (row vectors)

xc = cal{1};
yc = cal{2};

x = (0:w-1);
y = (0:h-1);
[ymat,xmat] = meshgrid(y-h/2-yc,x-w/2-xc);

if ndim>2
    rsq = xmat.^2 + ymat.^2;
end

if sum(topc)
    itheta = complex(0,atan2(ymat,xmat));
end

if win
    qxx = ~corrected_points(1,:)*1e-6+corrected_points(1,:); %to avoid problems when input to sinc equals to zero
    qyy = ~corrected_points(2,:)*1e-6+corrected_points(2,:);

    sinc = sin(win*pi*qxx/w)./(win*pi*qxx/w).*sin(win*pi*qyy/h)./(win*pi*qyy/h);
    alpha = alpha./sinc.^2;
end

alpha = alpha/sum(alpha); %normalize alpha



iphase = complex(0, 2*pi*rand(1,npts));      % relative phases
% load('iphase.mat');

psi=zeros(w,h);
tpsi= zeros(w,h);
for n=1:npts

    ikxx = ikx(n)* x + iphase(n);
    ikyy = iky(n) * y;
    ex = exp(-ikxx);
    ey = exp(-ikyy);
    tpsi = sqrt(alpha(n))*(ex.'*ey);

    if ndim>2
        tpsi = tpsi.* exp(-ikz(n)*rsq);
    end

    if topc(n)
        tpsi = tpsi.*exp(-itheta*topc(n));
    end

    psi=psi+tpsi;

end

phi_initial=angle(psi) + pi;


phi_initial = (round(phi_initial/(2*pi) * 256))*2*pi/256; %quantize
phaselut = complex(0,phi_initial);
expphaselut = exp(phaselut);


%% start stage 2: Compute initial fields & intensities of traps using the
%% initial phase estimate from stage 1
%%

for n=1:npts

    ikxx=ikx(n)*x;
    ikyy=iky(n)*y;
    ex=exp(ikxx);
    ey=exp(ikyy);
    exy{n} = ex.'*ey; % these are the propagators from each pixel to each trap

    if ndim>2
        exy{n} = exy{n}.* exp(ikz(n)*rsq);
    end

    if topc(n)
        exy{n} = exy{n} .*exp(itheta*topc(n));
    end

    E(n) = sum(sum(exy{n}.*expphaselut));

end

I = E.*conj(E); %Initial intensities
%I_norm = I/max(I);

% calc initial convergence factor & other trap array parameters


gamma = sum(alpha.*I)/sum(alpha.^2);
sigma = sqrt(mean((I-gamma*alpha).^2));
initial_conv = rho*sigma - (1-rho)*mean(I);
conv = initial_conv;
efficiency = sum(I)/sum(alpha);
rmserror= sigma/max(I);
max_I = max(I./alpha);min_I = min(I./alpha);
uniformity = (max_I-min_I)/(max_I+min_I);


%% start stage 3: direct search
%%

acc=0;
phaselut_new = zeros(w,h);
if (strcmpi(p.Results.quiet, 'on'))
    quiet = 0;
else
    quiet = 1;
end

for r = 1:1

    for t = 1:w*h
%         if quiet
%             disp(['Iterration ' num2str(t) ' of direct search']);
%         end
        % choose a random pixel

        l = ceil(rand(1)*w);
        m = ceil(rand(1)*h);

        % change current pixel to a random phase (quantized)

        deltaphi = round((rand(1))*256)*2*pi/256;
        phaselut_new(l,m) = complex(0,deltaphi);

        % calc the new fields (maybe this can be done in matrix form to
        % save the for loop)

        for q=1:npts

            E_new(q) = E(q) + (exy{q}(l,m))*(-expphaselut(l,m) + exp(phaselut_new(l,m))); % subtract the old phase and add the new

        end

        % calc new intensities, conv factor and other trap array
        % parameters

        I_new = E_new.*conj(E_new);
        I_new_norm = I_new/max(I_new);

        gamma_new = sum(alpha.*I_new)/sum(alpha.^2);
        sigma_new = sqrt(mean((I_new-gamma_new*alpha).^2));
        conv_new = rho*sigma_new - (1-rho)*mean(I_new);
        efficiency_new = sum(I_new_norm)/sum(alpha);
        rmserror_new = sigma/max(I_new);
        max_I_new = max(I_new./alpha);min_I_new = min(I_new./alpha);
        uniformity_new = (max_I_new-min_I_new)/(max_I_new+min_I_new);

        if conv_new < conv % if convergence has improved accept new values

            acc=acc+1;
            phaselut(l,m) = phaselut_new(l,m);
            expphaselut(l,m) = exp(phaselut_new(l,m));
            E = E_new;
            I = I_new;
            I_norm = I_new_norm;
            gamma = gamma_new;
            sigma = sigma_new;
            conv = conv_new;
            efficiency = efficiency_new;
            rmserror = rmserror_new;
            uniformity = uniformity_new;
            

            %                 rmserror
            %                 uniformity

            if  rmserror < thresh && uniformity < thresh
                break
            end



        end

    end

    if  rmserror < thresh && uniformity < thresh
        break
    end

end

%conv
toc
%r
%fraction_of_pixels = t/(w*h)
phi = abs(phaselut);
