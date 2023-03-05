function slm(phi,varargin)

% NAMD:
%          slm
%
% PURPOSD:
%          projects the wanted hologram on displays, correct if needed
%
%
% CALLING SEQUENCD:
%          slm_omer(phi,[alpha],[correction picture name])
%
% INPUTS:
%          phi: hologram to project.
%
% OPTIONAL INPUT:
%          alpha:  alph is the bit value for 2*pi delay on the SLM ,
%          default 255
%          correction picture name+ path:
%
% KEYWORDS:
%          corrpic: correction picture name+ path:
%           example 'D:\002 Important Software\021 Lcos
%           -LSM\deformation_correction_pattern\CAL_LSH0400106_532nm.bmp'
%           default: 'off' which means no picture
%
% EXAMPLD:
%
% MODIFICATION HISTORY:
% 8/11/2005: omer w. added correction capability.
% 11/5/2011: Maya Yevnin added wavelength optional parameter
% 25/11/2014: Tamir Admon added SLM_screen when the display is 1 and not 2.
% the parameter SLM_screen is added to the SLM calibration folder

% Input parameters
p = inputParser;
addRequired(p,'phi', @isnumeric);                  % Hologram to transform
addOptional(p,'wavelength', 1, @isnumeric);     % Hologram wavelength
addOptional(p,'SLM_screen', 1, @isnumeric);  % SLM display screen number

addParamValue(p,'alpha', NaN, @isnumeric);    % alpha is the bit value for 2*pi delay on the SLM
addParamValue(p,'corrpic','off',@ischar);   % 'off': no correction picture, elsD: the correction picture name + path:
addParameter(p,'dim',[600,800]);              % SLM dimensions. default: 600*800 pixles

%example 'D:\002 Important Software\021 Lcos -LSM\deformation_correction_pattern\CAL_LSH0400106_532nm.bmp'
parse(p, phi, varargin{:});
% wavelength used in nanometers & added screen display number for SLM
if any(strcmp(p.UsingDefaults, 'wavelength'))
    load('D:\SLM calibration\wavelength','wavelength');
else
    wavelength = p.Results.wavelength;
end

% if any(strcmp(p.UsingDefaults, 'SLM_screen'))
if exist('D:\SLM calibration\SLM_screen.mat', 'file') ==2
    load('D:\SLM calibration\SLM_screen.mat');
end


% else
%     SLM_screen = p.Results.SLM_screen;
% end


% SLM_Screen = 3 was changed on 20221226 by Ron
% Get correction parameters according to wavelength
switch(wavelength)
    case 1085
        corr=imread('F:\Ron\SLM\SLM\HOTs_correction_images\CAL_LSH0300104_1085nm.bmp');
        alpha = 215;
    case 532
        corr=imread('F:\Ron\SLM\SLM\HOTs_correction_images\CAL_LSH0400106_532nm.bmp');
        alpha = 208;
    case 633
        corr=imread('F:\Ron\SLM\SLM\STED_correction_images\CAL_LSH0300104_633nm.bmp');
        alpha = 115;
    case 750
        %         corr=imread('D:\Dropbox\Matlab\Holograms\SLM\STED_correction_images\CAL_LSH0300104_750nm.bmp');
        corr = zeros(768,1024);
        alpha = 255;
    case 780
        corr=imread('F:\Ron\SLM\SLM\STED_correction_images\CAL_LSH0300104_780nm.bmp');
        alpha = 142;
    otherwise
        corr = zeros(600,792);
        alpha = 255;
end

if (~isnan(p.Results.alpha))
    alpha = p.Results.alpha;
end
if (~strcmpi(p.Results.corrpic,'off'))
    corr=imread(p.Results.corrpic);
end

dim = p.Results.dim;


corr_image=zeros(dim);
corr_image(:,1:size(corr,2))=corr;
corr_image=corr_image*(2*pi)/255;
final_image=phi+corr_image;
final_image=mod(final_image,2*pi);

% if (strcmpi(p.Results.corrpic,'off')==1)
%     %no correction picturD:
%     final_image=phi;
% else
%     %correction picturD:
%     corr_image=zeros(600,800);
%     corr=imread(p.Results.corrpic);
%     %corr_image(:,5:796)=corr;
%     corr_image(:,1:792)=corr;
%     corr_image=corr_image*(2*pi)/255;
%
%     final_image=phi+corr_image;
%     final_image=mod(final_image,2*pi);
% end
SLM_screen
final_image=final_image.*(alpha/255);
fullscreen(final_image/(2*pi),SLM_screen); % divide by 2*pi to create intensity normalized image required by fullscreen. % checking if final image and slm screen has the same resolution

end