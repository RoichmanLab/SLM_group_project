function cal = load_calibration(cal, usecal, wavelength)

xc=cal{1};          % Center of phase mask on SLM
yc=cal{2};          % Center of phase mask on SLM
xfac=cal{3};        % Scale factor for square pixels
rfac_0=cal{4};      % Projection scale factor at z=0
rfac_slope=cal{5};	% Projection scale factor z correction
thetafac=cal{6};	% Orientation
% zfac = [cal(6) cal(7)]; % xy deviations
x0_0=cal{7};        % center of CCD image at z=0
x0_slope=cal{8};	% center of CCD image z correction
y0_0=cal{9};        % center of CCD image at z=0
y0_slope=cal{10};	% center of CCD image z correction
wavelength = 532; % Edited by Ron 20230302
if usecal
    try
        switch wavelength
            case 1085
                load('C:\Documents and Settings\iQ Workstation\My Documents\MATLAB\Holograms\Calibration\IR_cal.mat');
            case 532
                load('D:\SLM calibration\cal.mat')%load('F:\Ron\SLM\Calibration\green_grasshopper3_cal.mat');
            case 633
                load('C:\Documents and Settings\iQ Workstation\My Documents\MATLAB\Holograms\Calibration\HeNe_cal.mat');
            case 750
                load('C:\Documents and Settings\iQ Workstation\My Documents\MATLAB\Holograms\Calibration\TiSaph_cal_750.mat');
            case 780
                load('C:\Documents and Settings\iQ Workstation\My Documents\MATLAB\Holograms\Calibration\TiSaph_cal_780.mat');
        end
    catch
        disp 'Calibration file not found, using default parameters';
    end
end

cal = {xc yc xfac rfac_0 rfac_slope thetafac x0_0 x0_slope y0_0 y0_slope};