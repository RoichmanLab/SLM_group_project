function blank_slm(wavelength, dim)
SLM_screen=2;
if nargin<1
    load('F:\Ron\SLM\SLM Calibration\wavelength.mat');
    if exist('D:\SLM calibration\SLM_screen.mat', 'file')==2 
        load('D:\SLM calibration\SLM_screen.mat');
    end
end
if nargin<2
        load('D:\SLM calibration\dim.mat');
end
%SLM_screen=2;

% phi=ones(600,800);
%dim = [800, 600];
phi = rand(dim);
slm(phi,wavelength,SLM_screen, 'dim', dim);