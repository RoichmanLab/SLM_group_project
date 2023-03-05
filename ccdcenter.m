function [x0 y0] = ccdcenter(xfac, rfac, thetafac,wavelength, z)

% PURPOSE: calculate the x0 and y0 calibration parameters.
%
% METHOD: project a circle, take a snapshot of it and identify the spots.
% Find the center of the circle using the CircleFitByTaubin function.
%
% INPUTS:
%                   HObject, eventdata, handles: the hnadles object from
%                           the camera gui, needed to obtain the camera handle.
%                   xfac, rfac, thetafac: calibration parameters obtained
%                           by ccdcal function.
%                   wavelength: the wavelength of the laser being
%                           calibrated.
% updates:
%%omer 22.12.2011 added back port verdi calibration:
%%omer 22.12.2011 - 1 non diffraction point error:
% 6.6.2012 Maya Yevnin: added z displacement


% parameters that need to be open to user input at a later stage
r = 150; %original value for grasshopper3 150
ncirc = 20;
% w = 600;
% h = 800;
% cal = [0 0 xfac rfac thetafac 300 400];
% spotsize = 15;                           % radius of projected spots
noise=5;                                             % Characteristic lengthscale of noise in pixels
% brightness = 2;                   % min brightness for pkfnd function. FIND GOOD VALUE!!!


% default values for output params
x0 = 0; y0 = 0;

try
    switch(wavelength)
        case 1085
            load ('C:\Documents and Settings\iQ Workstation\My Documents\MATLAB\Holograms\Calibration\hologram_pics\circle_for_1085.mat');
%         case 532
%             load ('D:\Matlab\Holograms\Calibration\hologram_pics\circle_for_532.mat');
            %  load ('F:\Ron\SLM\Calibration\hologram_pics\circle_for_532.mat');
        % case  750
%             load ('D:\Matlab\Holograms\Calibration\hologram_pics\circle_for_750.mat');
%         case 633
%             load ('D:\Matlab\Holograms\Calibration\hologram_pics\circle_for_633.mat');
        otherwise
            cal = {0 0 1 1 0 0 300 0 400 0};
            c=CircGen(ncirc,r);
            phi = dsphase(c, wavelength,'cal',cal);
    end
catch
    cal = [0 0 1 1 0 0 0 300 400];
    c=CircGen(ncirc,r);
    phi = dsphase(c, wavelength,'cal',cal);
end
% z displacement
phi = doe_add(phi, displace(0,0,z));
% save(filename,'phi','ncirc','r','w','h');
% figure;
% imagesc(phi);
% colormap 'gray';
% title 'Projected hologram';
% set(handles.imagedisp,'HandleVisibility','ON');
% slm(phi, alpha, 'corrpic', correction_file);
slm(phi, wavelength);

%%%%%%%%%%%%%%%%%%%%%%   Take Images   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[im, bg, user_quit] = take_images_for_cal_grasshopper3;
if user_quit
    return
end

%%%%%%%%%%%%%%%%%%%%%%%%   Image analysis   %%%%%%%%%%%%%%%%%%%%%%%%%

% locate points
cnt = run_feature_for_cal(im, bg, ncirc);

%%%%%%%%%%%%%%%%%%%%%    Calculate parameters   %%%%%%%%%%%%%%%%%%%%%%%

x=cnt(:,1);
y=cnt(:,2);
figure;  ax=axes;
scatter(ax,x,y,'blue','+');
title 'Detected points';


% ellarr = EllipseDirectFit(cnt);         % fitts the points to an ellipse, returns ellarr=[a b c d e f], which can be used to derive ellipse parameters.
% x0 = (ellarr(3)*ellarr(4)-ellarr(2)*ellarr(6))/(ellarr(2)^2-ellarr(1)*ellarr(3)); % formula 19, http://mathworld.wolfram.com/Ellipse.html
% y0 = (ellarr(1)*ellarr(6)-ellarr(2)*ellarr(6))/(ellarr(2)^2-ellarr(1)*ellarr(3));

%omer 22.12.2011 - 1 non diffraction point error:
if (size(cnt,1)==1)
    x0 = cnt(1,1);
    y0 = cnt(1,2);
else
    Par  = CircleFitByTaubin(cnt(:,1:2));
    x0 = Par(1);
    y0 = Par(2);
end



