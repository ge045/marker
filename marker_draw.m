function drawerobj = marker_draw(fh, drawerobj, bInit)
% function drawerobj = marker_draw(fh, drawerobj)
% 
% Draw main figure

% Copyright 2006 Oliver Amft, ETH Zurich, Wearable Computing Lab.

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

% enable marker figure handle which is visible only to callbacks
% Setting of 'ShowHiddenHandles' will be switch back later since
% various functions do not see the handle to the marker figure (no
% callbacks!) and consequently will use other handles or create a new
% axes | figure handle if they don't find any.
% set(0,'ShowHiddenHandles','on');

% fprintf('\n%s: Enter.', mfilename);

if ~exist('bInit','var'), bInit = false ; end

% get(fh, 'Children')
[xdynoffset drawerobj subplotHandles] = marker_viewer(fh, drawerobj);
% get(fh, 'Children')
for splot = 1:drawerobj.subplots
    drawerobj.disp(splot).xdynoffset = xdynoffset(splot);
    
    if 0%bInit %% OSG added 
        % FIXME SOMEWHERE THE POINTER HANDLE IS STILL DELETED
        % FIXME when marker_xrange changes change these objects as well
        playerselect = drawerobj.disp(splot).playerselect ;
        if playerselect
            playerdata = drawerobj.disp(splot).playerdata(playerselect) ;
            if isfield(playerdata, 'playerIsVideoPlayer')
                if playerdata.playerIsVideoPlayer
                    % create a videoIsHerePointer
                    axes(subplotHandles(splot)) %#ok<LAXES>
                    videoPointer = line([0 0],drawerobj.disp(splot).ylim, ...
                        'Color',[.9 .4 .0],'LineWidth',2) ;
                    % define a function to move the videoIsHerePointer
                    freqFactor = drawerobj.disp(splot).playerdata(playerselect).freqFactor ;
                    drawerobj.disp(splot).playerdata(playerselect).listener = addlistener( ...
                        drawerobj.disp(splot).playerdata(playerselect).vobj, ...
                        'frameChanged', ...
                        @(h,e)set(videoPointer,'XData', [1 1]*(h.currentFrame * freqFactor )));
                end
            end
        end
    end
end;

% OAM REVISIT
if marker_version('DEBUG')
	if any((xdynoffset-floor(xdynoffset))>0), error('Triggered rounding bug in xdynoffset!'); end;

	if (~isempty(drawerobj.seglist)) && any(any((drawerobj.seglist(:,1:2)-floor(drawerobj.seglist(:,1:2)))>0)), 
		error('Triggered rounding bug in seglist!'); 
	end;
end; % if marker_version('DEBUG')

% extract labels and plot them
drawerobj = marker_markit(fh, drawerobj, drawerobj.seglist);

% OAM REVISIT: PM hack
% plotfmt(fh, 'fs', 14);

% print status axes
drawerobj = marker_statusaxes(fh, drawerobj);

% needed for drawing/handling callbacks on Windows platforms
drawnow;

% enable marker figure handle which is visible only to callbacks
% set(0,'ShowHiddenHandles','off');

