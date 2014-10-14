function lhs = marker_marksegmentpos(fh, drawerobj, markseglist, mode)
% function lhs = marker_marksegmentpos(fh, drawerobj, markseglist, mode)
%
% Plot vertical lines at the position of a segment/label. Param markseglist
% must be a list of labels. Param mode can be anything of the following:
% old, highlight.

% OAM REVISIT: This code is a hack. It should be merged with the main label
% plotting routine once MARKER uses a strct array to represent the label
% list. Then deleted labels, highlighted labels can be plotted in a
% scalable way.

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

lhs = [];
if isempty(markseglist), return; end;
if ~exist('mode','var'), mode = 'old'; end;

switch lower(mode)
    case 'old'
        opts = {'linestyle', '--', 'color', 'k'} ;
    case 'mark'
        opts = {'linestyle', '-', 'color', 'r', 'linewidth', 2} ;
    case 'highlight'
        opts = {'linestyle', '-', 'color', 'k', 'linewidth', 2} ;
end

hsplot = get(fh, 'Children');
lhs = NaN(drawerobj.subplots,2);
for splot = 1:drawerobj.subplots
    if (drawerobj.disp(splot).hideplot), continue; end;
    
    % find the index of the axes that matches the drawerobj.disp(splot).plotTag
    idx = strmatch(drawerobj.disp(splot).plotTag, get(hsplot, 'Tag'), 'exact');
    set(fh, 'CurrentAxes', hsplot(idx));
    hold(hsplot(idx), 'on');
    
    for s = 1:size(markseglist,1)
        % plot marks only if segment is visible in this plot
        if (size(markseglist,2) >=4) && (~drawerobj.disp(splot).showlabels(markseglist(s,4)))
            continue
        end
        
        lhs(splot,1) = line(repmat(markseglist(s,1),1,2)-drawerobj.disp(splot).xdynoffset, ylim, opts{:});
        lhs(splot,2) = line(repmat(markseglist(s,2),1,2)-drawerobj.disp(splot).xdynoffset, ylim, opts{:});
    end % for s
    
    hold(hsplot(idx), 'off');
end
