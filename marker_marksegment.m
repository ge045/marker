function [seg cont splot lhs] = marker_marksegment(fh, drawerobj, allowselect)
% function [seg cont splot] = marker_marksegment(fh, drawerobj, allowselect)
%
% Subroutine to place markers with the mouse cursor
% (called by marker_marksegmentlabel() and directly). Will return one
% segment or label (mid pointer button) only.
% 
% cont - button that was pressed, buttons 1,2 are processed in this routine

% Copyright 2005-2008 Oliver Amft, ETH Zurich, Wearable Computing Lab.

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
if (~exist('allowselect','var')) || isempty(allowselect), allowselect = true; end;

seg = [];
lhs = [] ; %% OSG added

marker_log(fh, '\nPlace markers: ');
[xi1, yi1, button, splot] = marker_ginput(fh, drawerobj, 1);    % left border
cont = button; 
% if (button == 3), cont = 0; return; end;
if (button >= 3), return; end;

xi1 = round(xi1) + drawerobj.disp(splot).xdynoffset;

% special function: mid button selects segment from existing label
% this is useful for playing a labeled section
if (button == 2)
	if allowselect
		%row = marker_findsegfrompos(drawerobj, xi1);
		row = marker_islabelvisible(drawerobj, marker_findsegfrompos(drawerobj, xi1), splot);
		if isempty(row), return; end;
		seg = drawerobj.seglist(row,1:2);
		marker_log(fh, 'begin:%u end:%u', seg(1), seg(2));
		lhs = marker_marksegmentpos(fh, drawerobj, seg, 'mark');
	end;
    return;
end;

marker_log(fh, 'mark1:%u mark2: ', xi1);
lh1 = line([xi1 xi1]-drawerobj.disp(splot).xdynoffset, ylim, 'linestyle', '-', 'color', 'r'); %+alignshift

[xi2, yi2, button, splot] = marker_ginput(fh, drawerobj, 1);    % right border
%if (button == 3), cont = button; delete(lh1); return; end;
if (button >= 3), cont = button; delete(lh1); return; end;

xi2 = round(xi2) + drawerobj.disp(splot).xdynoffset;
marker_log(fh, '%u', xi2);
% lh2 = line([xi2 xi2]-drawerobj.disp(splot).xdynoffset, ylim, 'linestyle', '-', 'color', 'r'); %+alignshift
% delete(lh1,lh2); 

% flip bounds if wrong order
if (xi2 < xi1), 
	%delete(lh1); return; 
	tmp = xi1; xi1 = xi2; xi2 = tmp;
end;
seg = [xi1 xi2];

delete(lh1);
lhs = marker_marksegmentpos(fh, drawerobj, seg, 'mark');

cont = 1;
