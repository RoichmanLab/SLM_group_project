%vortex

function phi=vortex(ell,varargin)

% Input parameters
p = inputParser;
addRequired(p,'ell', @isnumeric);                                                                          % vortex dimension
addParamValue(p, 'cal', [0 0 1 1 0 300 400], @(x)length(x)>=7);                            % known calibration parameters.
addParamValue(p, 'dim',[600,800], @isnumeric);% SLM dimensions. default: 600*800 pixles
addParamValue(p, 'xc', 0, @isnumeric);
addParamValue(p, 'yc', 0, @isnumeric);
parse(p, ell, varargin{:});

wavelength=532;
w=p.Results.dim(1);
h=p.Results.dim(2);
ell=p.Results.ell;

% if nargin < 2
%     w=800;
%     h=600;
% else
%     w=dim(1);
%     h=dim(2);
% end

if nargin<1, ell=80;
end
usecal = any(strcmp(p.UsingDefaults, 'xc')) && any(strcmp(p.UsingDefaults, 'yc'));
tempcal = [{p.Results.xc p.Results.yc} num2cell(ones(1,8))];

cal = load_calibration(tempcal, usecal,wavelength);
xc = cal{1};
yc = cal{2};

theta=maketheta([w,h],xc, yc);
% theta=maketheta([w,h],2);
%theta=maketheta([h,w],2);
phi=mod(theta*ell,2*pi);


end
