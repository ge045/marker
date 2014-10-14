function ovlist = marker_findoverlap(seglist1, seglist2, ovmode)
% function ovlist = marker_findoverlap(seglist1, seglist2, ovmode)
%
% Find overlapping segments of seglist1 list in seglist2.
%
% ovmode can be any of the following:
%   'any' - matches any type of overlap
%   'included' - matches completely included segments only
%   'identical' - matches exact begin/end positions only

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
%
% -------------------------------------------------------------------

ovlist = [];  % list of overlaps found
if ~exist('ovmode', 'var'), ovmode = 'any'; end;

% scan thorugh both list and find overlaps of seglist1 in seglist2
for i = 1:size(seglist1,1)
	ibeg = seglist1(i,1); iend = seglist1(i,2);
	for j = 1:size(seglist2,1)
		jbeg = seglist2(j,1); jend = seglist2(j,2);

		% check if no overlap at all
		if (ibeg > jend) || (iend < jbeg)
			continue;
		end

		% now, there is overlap - check according to mode
		switch lower(ovmode)
			case 'any'  % take all that do somehow overlap
				% nothing more to do here
				ovlist = [ovlist; j];

			case 'included'
				if (ibeg <= jbeg) && (iend >= jend)
					ovlist = [ovlist; j];
				end;

			case 'identical'
				if (ibeg == jbeg) && (iend == jend)
					ovlist = [ovlist; j];
				end;

			otherwise
				error('Overlap mode not supported.');
		end;

	end; % for j = 1:size(seglist2,1)
end; % for i = 1:size(seglist1,1)

% may have multiple hits from several segments in seglist1 list
ovlist = unique(ovlist);
