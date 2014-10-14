function handles = marker_plotsegmentation(ph, data, drawerobj, splot)
% function handles = marker_plotsegmentation(ph, data, drawerobj, splot)
%
% Plot signal and segmentation points. This function can be used as plug-in,
% replacing the default plot method for displaying signals.
% Usage on MARKER initialisation:
%
%     drawerobj.disp(<yourlabelplot>).plot_func = @marker_plotsegmentation;
%     drawerobj.disp(<yourlabelplot>).plotfunc_params = { <seglist> };
%     drawerobj.disp(<yourlabelplot>).plotfunc_extmode = true;
%
% See also marker_plotlabeling

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

% plot signal
hold(ph, 'off');
plot(data);

% prepare segments
seglist = drawerobj.disp(splot).plotfunc_params{1};
xrange = drawerobj.disp(splot).xrange;
seglist = seglist(marker_findoverlap(xrange, seglist),:);

% drawerobj.disp(splot).xdynoffset is updated when marker_viewer finishes!
seglist = seglist(:,1:2)-xrange(1)-1;
% seglist = seglist(:,1:2)-drawerobj.disp(splot).alignshift;
%drawerobj.disp(splot)

% marker_findoverlap keeps the last segment that would exceed the visible bounds
seglist( (seglist(:,2)<=0) ,:) = [];  %seglist( (seglist(:,1)<0) ,:) = []; 
seglist(seglist(:,2)>size(data,1),:) = [];


% plot segmentation points
hold(ph, 'on');
for seg = 1:size(seglist,1)
	%if seglist(seg,2)>size(data,1), break; end;
	plot(seglist(seg,2), data(seglist(seg,2)),  'color', [1 0 0], 'marker', 'x', 'linewidth', 2);
end;
hold(ph, 'off');

handles = [];
