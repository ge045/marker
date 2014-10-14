function [row cont xi1 splot segmarkHandles] = marker_pointsegment(fh, drawerobj) % , filterkeys
% function [row cont xi1 splot] = marker_pointsegment(fh, drawerobj)
%
% Select label by mouse click. May return more than one hit.

% Copyright 2005-2007 Oliver Amft, ETH Zurich, Wearable Computing Lab.

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

row = [];
segmarkHandles = [];
[xi1, yi1, cont, splot] = marker_ginput(fh, drawerobj, 1);
if (cont >= 3)  % filterkeys and button3
	if (cont == 3), cont = 0; end; 
	return;
end;

xi1 = round(xi1) + drawerobj.disp(splot).xdynoffset;

row = marker_findsegfrompos(drawerobj, xi1); 
if isempty(row)
	marker_log(fh, '\n%s: Segment not found.', mfilename);
	return;
end;

segmarkHandles = marker_marksegmentpos(fh, drawerobj, drawerobj.seglist(row,:), 'highlight');

for i = 1:length(row)
	marker_log(fh, '\n%s:   %u => segment: %u:%u (#%u)', mfilename, ...
		xi1, drawerobj.seglist(row(i),1), drawerobj.seglist(row(i),2), row(i));
end;
