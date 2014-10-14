function [drawerobj cont splot] = marker_marksegmentlabel(fh, drawerobj, setLabel, setConfidence)
% function [drawerobj cont splot] = marker_marksegmentlabel(fh, drawerobj, setLabel, setConfidence)
%
% Place markers with the mouse cursor, uses marker_marksegment()

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

if (~exist('setLabel','var')), setLabel = drawerobj.defaultlabel; end;
if (~exist('setConfidence','var')), setConfidence = 1; end;

cont = 2; % this is special :-( avoid catching an existing label
while (cont == 2), [newseg cont splot markHandles] = marker_marksegment(fh, drawerobj, false); end;

if (cont == 3), cont = 0; return; end; % filter out button=3 here: exit
if (isempty(newseg)), return; end;  % returns also on cont>3

% check for overlaps if in overlap check mode
if (~isempty(marker_findoverlap(newseg, drawerobj.seglist))) && drawerobj.labelovcheck
	str = sprintf('Overlap with label #%s detected. Label not set.', ...
		mat2str(marker_findoverlap(newseg, drawerobj.seglist)));
	marker_menudlg(fh, drawerobj, 'errordlg', str, 'Editing');

	cont = 4;  % this is an error, but do not want to leave the mode
	drawerobj = marker_draw(fh, drawerobj);
	return;
end;

label = marker_setlabel(fh, drawerobj, setLabel);
% if (label == 0), cont = -1; return; end;
if (label == 0), cont = 0; return; end;

tmplabel = marker_createlabel(newseg, label, setConfidence);
delete(markHandles)
%drawerobj = marker_modifydrawerobj(fh, drawerobj, [], 'labeling_add',  tmplabel);
%marker_markit(fh, drawerobj, drawerobj.seglist(end,:));
drawerobj.seglist(end+1,:) = tmplabel;
% marker_markit(fh, drawerobj, tmplabel);

% need to verify that the label is actually visible in the current plot
% if not: remove it again
if isempty(marker_islabelvisible(drawerobj, size(drawerobj.seglist,1), splot))
	marker_menudlg(fh, drawerobj, 'errordlg', 'The label will not be visible in the selected plot. Label not set.', 'Editing');
	cont = 4;
	drawerobj.seglist(end,:) = [];
	drawerobj = marker_draw(fh, drawerobj);
	return;
end;
	
% labels are resorted now. Some functions treat the new label specially
% (e.g. playing it), hence a pointer to it is kept.
drawerobj = marker_resort(fh, drawerobj);

drawerobj.ismodified = true;
drawerobj = marker_draw(fh, drawerobj);
