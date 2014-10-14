function label = marker_setlabel(fh, drawerobj, setLabel, minLabel, defaultLabel)
% function label = marker_setlabel(fh, drawerobj, setLabel, minLabel, defaultLabel)
%
% Retrieve label number from user

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

if (exist('setLabel', 'var')~=1), setLabel = drawerobj.defaultlabel; end;
if (exist('minLabel', 'var')~=1), minLabel = 1; end;
if (exist('defaultLabel', 'var')~=1), defaultLabel = 1; end;

if (drawerobj.maxLabelNum > 1) && (setLabel == 0)
	labelstrings = marker_makelabelstr(fh, drawerobj, minLabel:drawerobj.maxLabelNum);

	label = marker_menudlg(fh, drawerobj, 'singlelistdlg', ...
		'Enter label number', 'Set label...', labelstrings, defaultLabel );

else
	% when called with drawerobj.maxLabelNum==1; label=1, when setlabel==0
	% since (drawerobj.maxLabelNum > 1) && (setLabel == 0) and setLabel =
	% drawerobj.defaultlabel; this should not be necessary anymore.
	label = setLabel + (setLabel==0);
end; % if (drawerobj.maxLabelNum
