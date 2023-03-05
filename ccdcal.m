function [xfac, rfac, thetafac, new_x, new_y err] = ccdcal(wavelength, z)

% PURPOSE: calculate the xfac, rfac and thetafac calibration parameters.
%
% METHOD: project a 4x4 grid, take a snapshot of it and identify the spots.
% Compare the projected distances to the actual distances and claculate the
% calibration parameters.
%
% INPUTS:
%                   wavelength: the wavelength of the laser being
%                           calibrated.
%
%
% MODIFICATION HISTORY:
% 17/3/2011:	omer w. and maya yevnin -
%                           entered wavelength parameter for differant wavelengths
%                           enterd a criterion for brightness and spotsize
%                           added a way to eliminate briht spots by user
% 18.5.2011:   Maya Yevnin - added different calculation of xfac, rfac and thetafac
%                                                   for green and red  lasers
% 31.7.2011:   Omer Wagner: Added verdi back port and hologram pics
% 6.6.2012:     Maya Yevnin: added calibration at different z planes


agrid = 30;
ngrid = 4;

% default values for output params
xfac=1; rfac=1; thetafac=0; 
new_x=zeros(4,4); new_y=zeros(4,4);
err=1;

% parameters that need to be open to user input at a later stage
% loading pre-run hologram
switch(wavelength)
    case 1085
        load ('F:\Ron\SLM\Calibration\hologram_pics\grid_for_1085.mat');
    case 532
        %load ('C:\Documents and Settings\iQ Workstation\My Documents\MATLAB\Holograms\Calibration\hologram_pics\grid_for_532.mat');
        load ('F:\Ron\SLM\Calibration\hologram_pics\grid_for_532.mat');
    case  750
        load ('F:\Ron\SLM\Calibration\hologram_pics\grid_for_750.mat');
    case 633
        load ('F:\Ron\SLM\Calibration\hologram_pics\grid_for_633.mat');
    otherwise
        cal = {0 0 1 1 0 0 300 0 400 0};
        g=GridGen(ngrid)*agrid;
        phi = dsphase(g,wavelength,'cal',cal);
end

% z displacement
phi = doe_add(phi, displace(0,0,z));
slm(phi, wavelength);

exit_flg=1;
while(exit_flg)
    %%%%%%%%%%%%%%%%%%%%%%   Take Images   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    [im, bg, user_quit] = take_images_for_cal_grasshopper3;
    if user_quit
        return
    end
        
    %%%%%%%%%%%%%%%%%%%%%%%%   Image analysis   %%%%%%%%%%%%%%%%%%%%%%%%%

    % locate points
    cnt = run_feature_for_cal(im, bg, ngrid^2);
    x=cnt(:,1);
    y=cnt(:,2);
    
    % show detected points
    figi_handle = figure;  ax=axes;
    scatter(ax,x,y,'blue','+');
    title 'Detected points';
    
    if (size(cnt,1) < ngrid^2)
        disp('Error, not all spots detected!');
        return
    elseif (size(cnt,1) > ngrid^2)
        button=questdlg('There are too many spots! What do you wish to do?', 'Too many spots', 'Refocus','Eliminate points', 'Quit', 'Quit');
        switch button
%             case 'Pick brightest spots'
%                 how_many_to_delete = size(cnt,1) - ngrid^2;
%                 for i=1:how_many_to_delete
%                     vec=( find(cnt(:,3) == min(cnt(:,3)) ) );
%                     cnt(vec(1),:) =[];
%                 end

            case 'Eliminate points'
                msg_h = msgbox('Mark points for deletion, and press Del to delete. Press Enter to continue') ;
                k = waitforbuttonpress;
                key = 0;
                while k == 0 && double(key) ~= 13

                    rect=getrect(figi_handle);
                    if rect(1)<0
                        s1=0;
                    else
                        s1=round(rect(1));
                    end
                    if rect(2)<0
                        p1=0;
                    else
                        p1=round(rect(2));
                    end
                    s2=round(s1+rect(3));
                    p2=round(p1+rect(4));
                    
                    elim_pnt=(cnt(:,1)>s1).*(cnt(:,1)<s2).*(cnt(:,2)>p1).*(cnt(:,2)<p2) ;
                    ind=find(elim_pnt>0);
                    
                    set(gca, 'NextPlot', 'add');
                    points_2_del = scatter(cnt(ind,1), cnt(ind,2), 'FaceColor', 'black');
                    waitforbuttonpress;
                    key = get(figi_handle, 'currentCharacter');
                    
                    if double(key) == 27 || double(key) == 127
                        cnt(ind,:)=[];
                        delete(points_2_del);
                    end
                    
                    set(gca, 'NextPlot', 'replace');
                    x=cnt(:,1);
                    y=cnt(:,2);
%                     figi_handle = figure;  ax=axes;
                    scatter(ax,x,y,'blue','+');
%                     title 'Detected points';
                    
                    k = waitforbuttonpress;
                    key = get(figi_handle, 'currentCharacter');
                    
                    if double(key) == 27   % escape
                        return
                    end
%                     button2=questdlg('DONE?', 'Spot elimination', 'no','yes','quit', 'quit');
%                     switch button2
%                         case 'yes'
%                             stopit=0;
%                             exit_flg = 0;
%                         case 'no'
%                             stopit=1;
%                         case 'quit'
%                             xfac = 1;
%                             rfac = 1;
%                             thetafac = 0;
%                             err = 1;
%                             exit_flg = 0;
%                             stopit=0;
%                             return;
%                     end
                end
                exit_flg = 0;
                close (msg_h);
                break
            case 'Refocus'
                slm(phi, wavelength);
                exit_flg = 1;
                continue
            case 'Quit'
                return;
        end
        
    else
        exit_flg = 0;
        break
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%    Calculate parameters   %%%%%%%%%%%%%%%%%%%%%%%

%sorting x and y vectors from upper left corner to lower right corner:
[sorted_x, IX] = sort(x);
sorted_y = y(IX);

bunch1_x=sorted_x(1:4);
bunch2_x=sorted_x(5:8);
bunch3_x=sorted_x(9:12);
bunch4_x=sorted_x(13:16);

bunch1_y=sorted_y(1:4);
bunch2_y=sorted_y(5:8);
bunch3_y=sorted_y(9:12);
bunch4_y=sorted_y(13:16);

[sorted_bunch1_y, IX] = sort(bunch1_y);
sorted_bunch1_x = bunch1_x(IX);
[sorted_bunch2_y, IX] = sort(bunch2_y);
sorted_bunch2_x = bunch2_x(IX);
[sorted_bunch3_y, IX] = sort(bunch3_y);
sorted_bunch3_x = bunch3_x(IX);
[sorted_bunch4_y, IX] = sort(bunch4_y);
sorted_bunch4_x = bunch4_x(IX);

new_x = [sorted_bunch1_x, sorted_bunch2_x, sorted_bunch3_x, sorted_bunch4_x];
new_y = [sorted_bunch1_y, sorted_bunch2_y, sorted_bunch3_y, sorted_bunch4_y];


% shiftdim and transpose are occasionally  necessary since Matlab works
% column-wise, and we need to work row-wise.
% reshape to get a ngrid x ngrid matrices of x and y, so that the factors
% can be calculated.
% Pay attention: the rows and columns here are swapped in relation to what
% can be seen in the scatter graph (for the red lasers).

dx_rows=new_x-circshift(new_x,[0 -1]);  dx_rows(:,end)=[];                              % difference in X coordinates along rows
dy_rows=new_y-circshift(new_y,[0 -1]);  dy_rows(:,end)=[];                              % difference in Y coordinates along rows
dx_columns=new_x-circshift(new_x,[-1 0]);   dx_columns(end,:)=[];             % difference in X coordinates along columns
dy_columns=new_y-circshift(new_y,[-1 0]);   dy_columns(end,:)=[];             % difference in Y coordinates along columns

dx=sqrt(dx_rows.^2+dy_rows.^2);                             % distance between points along the image's X axis
dy=sqrt(dx_columns.^2+dy_columns.^2);             % distance between points along the image's Y axis

% % Maya 20.9.12

% Maya Yevnin 8.7.14, reactivated this version. It seems to depend on
% camera angle.
    xfac = mean(mean(dy)) / mean(mean(dx));
    rfac = agrid / mean(mean(dy));
%     thetafac= atan(dx_rows./dy_rows);       % Maya 2.10.12, unclear why it helps...
%     thetafac = mean(mean(thetafac));

% omer Wagner and Maya Yevnin 24.7.2012
% xfac = mean(mean(dx)) / mean(mean(dy));
% rfac= agrid/mean(mean(dx));
thetafac= atan(dx_columns./dy_columns);
thetafac = mean(mean(thetafac));
thetafac = -thetafac;  % needed since rows and columns got swapped in the red lasers



err=0;
