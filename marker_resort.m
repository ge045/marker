function drawerobj = marker_resort(fh, drawerobj, seglist)
% function drawerobj = marker_resort(fh, drawerobj, seglist)
%
% Resorts seglist (often needed)

% Copyright 2005-2007 Oliver Amft, ETH Zurich, Wearable Computing Lab.

% -------------------------------------------------------------------
%
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
%
% -------------------------------------------------------------------

if ~exist('seglist','var'), seglist = drawerobj.seglist; end;

if isempty(seglist), return; end;

[tmp,idx] = sort(seglist(:,1));
if ~isempty(idx)
    seglist = seglist(idx,:);
    seglist(:,5) = (1:size(seglist,1)).';
else
    seglist = [];
end;

drawerobj.seglist = seglist;
drawerobj.lasteditedlabel = find(idx == size(seglist,1));
