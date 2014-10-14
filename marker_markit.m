function drawerobj = marker_markit(fh, drawerobj, seglist)
% function marker_markit(fh, drawerobj, seglist)
%
% Plot labels for all subplots, using marker_plotmark()

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

% Copyright 2005-2007 Oliver Amft, ETH Zurich, Wearable Computing Lab.
% Copyright 2006, Mathias Staeger, UMIT Innsbruck

if isempty(seglist), return; end;
% fprintf('\n%s: Entry.', mfilename);

hsplot = get(fh, 'Children');
% vsplot = 1;
for splot = 1:drawerobj.subplots
    if (drawerobj.disp(splot).hideplot),  continue; end;
    
    xrange = drawerobj.disp(splot).xrange;
    xdynoffset = drawerobj.disp(splot).xdynoffset;
    
    seglist_vis = seglist(marker_findoverlap(xrange, seglist),:);
    
    % exclude hidden labels
    seglist_vis = seglist_vis( drawerobj.disp(splot).showlabels( seglist_vis(:,4) ), : );
    %seglist_vis = seglist_vis( drawerobj.disp(splot).showlabels( seglist_vis(:,4) ) == 1, : );
    %seglist_vis = seglist_vis( marker_islabelvisible(drawerobj, marker_findoverlap(xrange, seglist), splot) ,:);
    
    % find the index of the axes that matches the drawerobj.disp(splot).plotTag
    idx = strmatch(drawerobj.disp(splot).plotTag, get(hsplot, 'Tag'), 'exact');
    %idx = strcmp(drawerobj.disp(splot).plotTag, get(hsplot, 'Tag'));
    set(fh, 'CurrentAxes', hsplot(idx));
    if ~isempty(hsplot(idx))
        hold(hsplot(idx), 'on');
        drawerobj.disp(splot).segHandles = ...
            marker_plotmark(fh, drawerobj, [(seglist_vis(:,1:2)-xdynoffset)  seglist_vis(:,3:end)], splot);
        hold(hsplot(idx), 'off');
    end
end % for splot

% fprintf('\n%s: Exit.', mfilename);
