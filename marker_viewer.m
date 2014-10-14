function [xdynoffset drawerobj sh] = marker_viewer(fh, drawerobj)
% function [xdynoffset drawerobj] = marker_viewer(fh, drawerobj)
%
% Generic Marker viewer method for entire data load mode

% Copyright 2005-2007 Oliver Amft, ETH Zurich, Wearable Computing Lab.
% Copyright 2006 Mathias Staeger, UMIT Innsbruck
% Copyright 2005 Georg Ogris, UMIT CSN Innsbruck

% -------------------------------------------------------------------
% This file is part of the MARKER Matlab toolbox.
%
%     MARKER is free software; you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation; version 2 of the License.
%
%     MARKER is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
%
%     You should have received a copy of the GNU General Public License
%     along with MARKER; if not, write to the Free Software
%     Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
%
% A full text of this license can be found in license_gpl.txt.
% -------------------------------------------------------------------

all_axis_xticks = false; % set to true if all axis should get time axis

figure(fh);

% toolbox/signal/signal/resample.m
% -------------------------------------------------------------------

vsplot = 1; % needed to count visible subplots
sh = zeros(1, drawerobj.visibleplots);
xdynoffset = zeros(1, drawerobj.subplots);
for splot = 1:drawerobj.subplots
    if (drawerobj.disp(splot).hideplot), continue; end;
    
    if ~isfield(drawerobj.disp(splot),'plotHandles')
        bInit = true ;
    else
        if any( ishandle(drawerobj.disp(splot).plotHandles) == false ) || isempty(drawerobj.disp(splot).plotHandles)
            bInit = true ;
        else
            bInit = false ;
        end
    end
    
    xrange = drawerobj.disp(splot).xrange;
    xdynoffset(splot) = xrange(1)-1; %0;
    
    [p,q] = rat((drawerobj.disp(splot).sfreq + drawerobj.disp(splot).alignsps) / (drawerobj.disp(splot).sfreq));
    xrange_r = ceil((xrange + drawerobj.disp(splot).alignshift) *q/p);
    %xvisible_r = ceil(drawerobj.disp(splot).xvisible * q/p);
    xrange_r(xrange_r < 1) = 1;
    
    [pdata drawerobj] = marker_getdatafrombuffer(fh, drawerobj, splot, xrange_r);
    
    if (drawerobj.disp(splot).alignsps) && (~isempty(pdata))
        %fprintf('\n%s: Resample...', mfilename);
        %p,q
        pdata = resample(pdata, p,q);
        %fprintf(' Done.');
        
        %pdata = my_upsample(pdata, p);
        %pdata = my_downsample(pdata, q);
        %pdata = upsample(pdata, p);
        %pdata = downsample(pdata, q);
    end;
    
    % redraw subplot
    sh(vsplot) = subplot(drawerobj.visibleplots,1,vsplot);
    
    if bInit
        if (isempty(pdata)) %OSG Do we need this check?
            cla(sh(vsplot));
            lines = [] ;
        else
            if isempty(drawerobj.disp(splot).plotfunc_params) && (~drawerobj.disp(splot).plotfunc_extmode)
                lines = feval(drawerobj.disp(splot).plotfunc, sh(vsplot), pdata);
            else
                if (drawerobj.disp(splot).plotfunc_extmode)
                    % extended calling mode: this is used for marker-specific plotters
                    % see marker_plotsegmentation
                    lines = feval(drawerobj.disp(splot).plotfunc, sh(vsplot), pdata, drawerobj, splot);
                else
                    lines = feval(drawerobj.disp(splot).plotfunc, sh(vsplot), pdata, drawerobj.disp(splot).plotfunc_params{:});
                end
            end
            set(lines(drawerobj.disp(splot).hidesignal > 0), 'LineStyle', 'none');
        end
        drawerobj.disp(splot).plotHandles = lines ;
        
        % tag the subplot with the string in drawerobj.disp(splot).plotTag
        set(sh(vsplot), 'Tag', drawerobj.disp(splot).plotTag);
        
        % place ylabel
        ylabel(drawerobj.disp(splot).ylabel);
        %hold off;
    else
        try
            delete( drawerobj.disp(splot).segHandles(ishandle(drawerobj.disp(splot).segHandles))) ;
        end
        for iPH = 1:numel(drawerobj.disp(splot).plotHandles)
            set(drawerobj.disp(splot).plotHandles(iPH),'YData',pdata(:,iPH)) ;
        end
        set(drawerobj.disp(splot).plotHandles(drawerobj.disp(splot).hidesignal > 0), 'LineStyle', 'none');
    end
    
    % set display bounds
    xlim([1 drawerobj.disp(splot).xvisible]);
    
    if ~isempty(drawerobj.disp(splot).ylim)
        ylim(drawerobj.disp(splot).ylim);
    end
    
    % time axis for last plot only
    if (vsplot == drawerobj.visibleplots) || (all_axis_xticks)
        [~, xtunits xtls xticks] = marker_timeaxisunits(fh, drawerobj, splot, xrange);
    else
        xtls = '';
        xticks = xdynoffset(splot);
    end;
    
    set(sh(vsplot), 'XTick', xticks+1-xdynoffset(splot));
    set(sh(vsplot), 'XTickLabel', xtls );
    
    vsplot = vsplot +1;
end; % for splot



% view status text
%tres = (xrange(2)-xrange(1))/drawerobj.disp(splot).sfreq;
tres = abs(diff(xrange))/drawerobj.timeaxissamplesconv(1);
tprct= round(xrange(2)./max([drawerobj.disp(1:drawerobj.subplots).datasize])*100);

xlabel(['Axis in ' lower(drawerobj.timeaxisunits) ...
    ';         View: ' num2str(tres,'%.1f') ' ' lower(xtunits(1:3)) ...
    '      ' num2str(tprct,'(%u%%)') ]);
