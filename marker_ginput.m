function [xi, yi, button, splot] = marker_ginput(fh, drawerobj, count)
% function [xi, yi, button, splot] = marker_ginput(fh, drawerobj, count)
%
% Run ginput() and determine subplot (numbering includes invisible plots)
% from mouse click.

% Copyright 2005-2008 Oliver Amft, ETH Zurich, Wearable Computing Lab.
% Copyright 2006, Mathias Staeger, UMIT Innsbruck

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

if (exist('count','var')~=1), count = 1; end;
if (count > 1) 
    error('\n%s: Parameter count greater than 1 not suppored', mfilename); 
end;


% force user to click inside plot (and to programm marker_viewer.m correctly
correctClick = false;

while (~correctClick)
    % get mouse click
    [xi, yi, button] = ginput(1);
    % Window managers and Matlab - a mystery: button may be emtpy according to some bugreports
	if isempty(button), continue; end;

    splot = marker_findselectedplot(fh, drawerobj);

	% Can ginput really return more than one value for button? Potenitally this is a
	% bug related to the window manager. Anyway, make sure the error does
	% not recur here - by testing button(1) specifically.
    if isempty(splot) && (button(1) < 3)
        marker_log(fh, '\n%s: Please click on a plot.', mfilename);
    else
        correctClick = true;
    end;
end;


% % gather handles from all plots
% %hsplot = get(fh, 'Children'); % returns an unsorted list do it manually!
% for vsplot = 1:drawerobj.visibleplots
%     hvsplot(vsplot) = subplot(drawerobj.visibleplots,1, vsplot);
% end;
% 
% % get mount click
% [xi, yi, button] = ginput(1);
% 
% % look for corresponding handle
% vsplot = find(hvsplot == gca(fh));
% if isempty(vsplot) 
%     vsplot = drawerobj.visibleplots; % default to last subplot
%     found = 0; 
% end;
% % vsplot
% 
% % convert vsplot to splot (including non-visible plots)
% for splot = 1:drawerobj.subplots
%     if (drawerobj.disp(splot).hideplot) vsplot = vsplot + 1; continue; end;
%     if (vsplot == splot) break; end;
% end;
% 
% % vsplot
% 
% splot = vsplot;
% 
% % if ~(found) 
% %     fprintf('\n%s: Subplot not found!', mfilename); 
% % end;
