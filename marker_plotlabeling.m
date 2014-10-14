function handles = marker_plotlabeling(ph, segments, varargin)
% function handles = marker_plotlabeling(ph, segments, varargin)
%
% Plot lines indicating labels. This function can be used as plug-in,
% replacing the default plot method for displaying labelings.
% Usage on MARKER initialisation:
%
%     drawerobj.disp(<yourlabelplot>).plot_func = @marker_plotlabeling;
%     drawerobj.disp(<yourlabelplot>).plotfunc_params = {<total nr of labels>, {<labelstrings>}};
%
% See also marker_plotsegmentation

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

% %classincr = round(10/maxclasses) + (round(10/maxclasses)==0);
% classincr = 1;
% % guess setting
% maxclasses = max(unique(segments(:,4)));
% minclasses = min(unique(segments(:,4)));
% classnames = minclasses:classincr:maxclasses;

classids = varargin{1};  % list of all occuring class IDs
if length(varargin)<2
	classnames = marker_makelabelstr(fh, drawerobj, classids);
else
	classnames = varargin{2};  % list of class names
end;

nclasses = length(classids);
viewclassrange = 1:nclasses;

% classnames = classnames(viewclassrange);  % OAM REVISIT: changed, 2007/08/13

JETMode = true;
% pcolor = jet(maxclasses);
%%pcolor = lines(maxclasses);
pcolor = repmat([ 1 0 0 ], nclasses,1); % RGB => all in blue
ctab = jet(128);
cla(ph);

% OAM REVISIT:
% How to make larger share of window available for this plot, NOT overriding other plots?

% OAM REVISIT: PM hack
% drawerobj = get(get(ph, 'parent'), 'UserData');
% xrange = drawerobj.disp(end).xrange;
% xdynoffset = drawerobj.disp(end).xdynoffset;
% % int2str(segments(end,:))
% segments = segments(marker_findoverlap(xrange, segments),:);
% segments = [segments(:,1:2) - drawerobj.disp(end).xdynoffset   segments(:,3:end)];
% % whos segments 

hold(ph, 'on');
handles = zeros(1, size(segments,1));
for seg = 1:size(segments,1)
	if (JETMode)
		c = round(segments(seg,6)*128); c = c + (c==0);		thispcolor = ctab(c,:);
		c = round(segments(seg,6)*10); c = c + (c==0);		thislinewidth = c;
	else
		hsvm = rgb2hsv(pcolor(segments(seg,4),:));
		% OAM REVISIT: PM hack
		colf = segments(seg,6)*0.4 + 0.6; % color tweaking
		%colf = segments(seg,6)*0.8 + 0.4;
		hsvm(:,2) = hsvm(:,2) * colf;
		thispcolor = hsv2rgb(hsvm);
		thislinewidth = 3;
	end;
	
	% OAM REVISIT: PM hack
	classpos = find(segments(seg,4)==classids);
	handles(seg) = line(segments(seg,1:2), repmat(classpos,1,2), 'color', thispcolor, 'linewidth', thislinewidth);
% 	handles(seg) = line(segments(seg,1:2), repmat(segments(seg,4),1,2), 'color', thispcolor, 'linewidth', 10);
% 	text(segments(seg,1), segments(seg,4)+0.1, sprintf('%3.0f%%', segments(seg,6)*100), ...
% 		'HorizontalAlignment', 'left', 'VerticalAlignment', 'bottom', 'FontWeight', 'bold');
end;
hold(ph, 'off');

set(ph, 'YTick', viewclassrange, 'yticklabel', classnames, 'ylim', [0 nclasses+1], 'YGrid', 'on');
