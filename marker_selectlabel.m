function slabel = marker_selectlabel(fh, drawerobj, labellist)
% function slabel = marker_selectlabel(fh, drawerobj, labellist)
% 
% Let user select one label from labellist.

% Copyright 2007 Oliver Amft, ETH Zurich, Wearable Computing Lab.

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

% if less than two, nothing to do
if (size(labellist,1) < 2), slabel = labellist; return; end;

marker_log(fh, 'Label selection is ambiguous.');

labelstrings = cell(size(labellist,1),1);
for i = 1:size(labellist,1)
	lnr = labellist(i);
	[dummy str xtls] = marker_timeaxisunits(fh, drawerobj, 1, ...
        [drawerobj.seglist(lnr,1) drawerobj.seglist(lnr,2)+1]);
	labelstrings{i} = sprintf('#%u, Class %u (%s), Beg: %s  End: %s (%s)', ...
		drawerobj.seglist(lnr,5), drawerobj.seglist(lnr,4), ...
        drawerobj.labelstrings{drawerobj.seglist(lnr,4)}, ...
		xtls{1}, xtls{end}, str(1:3) );
end;
lnr = marker_menudlg(fh, drawerobj, 'singlelistdlg', ...
	'Enter label number', 'Select non-ambiguous label', labelstrings, 1);
if (lnr <= 0), slabel = []; return; end;

slabel = labellist(lnr);