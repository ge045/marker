function vlabels = marker_islabelvisible(drawerobj, labels, splotlist)
% function vlabels = marker_islabelvisible(drawerobj, labels, splotlist)
% 
% Filter labels from index list <labels> when they are hidden. This is
% needed to selectively view/modify labels in a specific plot. 

% OAM REVISIT: disabled the following functionality because unused
% % When called
% % without/empty splotlist, all plots are considered. When called
% % without/empty labels, entire labellist (drawerobj.seglist) is considered.

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

vlabels = [];
if (~exist('splotlist','var')) || isempty(splotlist), return; end;
if (~exist('labels','var')) || isempty(labels), return; end;
% if (~exist('splotlist','var')) || isempty(splotlist), splotlist = 1:drawerobj.subplots; end;
% if (~exist('labels','var')) || isempty(labels), labels = 1:size(drawerobj.seglist,1); end;

% if ~exist('seglist','var'), seglist = drawerobj.seglist; end;
seglist = drawerobj.seglist;

% gather activated plots and labels
showlabels = zeros(1,drawerobj.maxLabelNum);
for splot = splotlist
    if (drawerobj.disp(splot).hideplot),  continue; end;
	showlabels = showlabels + drawerobj.disp(splot).showlabels;
end;

vlabels = labels( showlabels( seglist(labels,4) ) > 0);
% vlabels = labels( drawerobj.disp(splot).showlabels( drawerobj.seglist(labels,4) ) == true );
