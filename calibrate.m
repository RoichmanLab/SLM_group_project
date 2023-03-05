function cal = calibrate(varargin)
  
p = inputParser;
addOptional(p,'wavelength', 1, @isnumeric);                        % the wavelength used, in nm
addParamValue(p, 'recalculate', 'off', @ischar);        % recalculate holograms or used previously saved ones
addParamValue(p, 'zRange', 0, @isnumeric);
addParamValue(p, 'ShowFigs', 'off', @ischar);        % recalculate holograms or used previously saved ones

parse(p, varargin{:});

% if strcmpi(p.Results.recalculate, 'off') == 1
%     wavelength = 1085;
% else
%     wavelength = 0;
% end

% wavelength used in nanometers
if any(strcmp(p.UsingDefaults, 'wavelength'))
    %load('D:\SLM calibration\wavelength');
    load('D:\SLM calibration\wavelength_Green.mat'); %changed by Ron 20230216
    wavelength = wavelength_Green;  %changed by Ron 20230216
else
    wavelength = p.Results.wavelength;
end

% run ccdcal along the z axis to find xfac, rfac, thetafac and zfac 
zRange = p.Results.zRange;
x_arr = zeros(4,4,length(zRange));
y_arr = zeros(4,4,length(zRange));
for i=1:length(zRange)
    [xfac(i), rfac(i), thetafac(i), x_arr(:,:,i), y_arr(:,:,i), err] = ccdcal(wavelength, zRange(i));
    if err
        errordlg('Calibration failed.', 'Calibration failed');
        return
    end
    [x0(i), y0(i)] = ccdcenter(xfac(i), rfac(i), thetafac(i), wavelength, zRange(i));
end

q = polyfit(zRange,rfac,1);
rfac_slope = q(1);
rfac_0 = q(2);
q = polyfit(zRange,x0,1);
x0_slope = q(1);
x0_0 = q(2);
q = polyfit(zRange,y0,1);
y0_slope = q(1);
y0_0 = q(2);

xfac = mean(xfac);
thetafac = mean(thetafac);

% if length(zRange) > 1
%     for i=2:length(zRange)
%         dx = mean(mean(x_arr(:,:,i) - x_arr(:,:,i-1)));
%         dy = mean(mean(y_arr(:,:,i) - y_arr(:,:,i-1)));
%         dz = zRange(i) - zRange(i-1);
%         zfac_x(i-1) = dx/dz;
%         zfac_y(i-1) = dy/dz;
%     end
%     zfac(1) = mean(zfac_x);
%     zfac(2) = mean(zfac_y);
% else
%     zfac = [0 0];
% end

% x0=0;
% y0=0;

slm_step_output = slmstep_gui(wavelength);
%slm_step_output = slmstep_gui(xfac, rfac, thetafac, zfac, x0,y0, wavelength);
xc = slm_step_output(1);
yc = slm_step_output(2);

cal = {xc yc xfac rfac_0 rfac_slope thetafac x0_0 x0_slope y0_0 y0_slope};

save('D:\SLM calibration\cal.mat', 'xc', 'yc' ,'xfac', 'rfac_0', 'rfac_slope', 'thetafac', 'x0_0', 'x0_slope', 'y0_0','y0_slope');
disp (mat2str([xc yc xfac rfac_0 rfac_slope thetafac x0_0 x0_slope y0_0 y0_slope]));
if strcmpi(p.Results.ShowFigs, 'off')
    close all;
end
