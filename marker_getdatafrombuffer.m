function [data drawerobj] = marker_getdatafrombuffer(fh, drawerobj, splot, Range)
% function data = marker_getdatafrombuffer(fh, drawerobj, splot, Range)
%
% extract data in the range of Range [begin end] from buffer, if Range
% are oversized, available data is returned.
%
% Range: absolute ranges to display
% loadfunc_dynrange: absolute ranges of available data
%
% Prototypes for on-demand loading function:
%      data = loadmydata(filename, Range);
%      data = loadmydata(filename, Range, varargin);
% The second version spplies user data in loadfunc_params. Use a cell array
% to pass more than one parameter
%
% Fields used for dynamic load:
% drawerobj.disp(splot).loadfunc
% drawerobj.disp(splot).loadfunc_filename
% drawerobj.disp(splot).loadfunc_params
% drawerobj.disp(splot).loadfunc_dynrange

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

% OAM REVISIT: check for transposed data

data = [];

% if (isempty(Range)) return; end;
% Range(find(Range < 1)) = 1;
if (Range(1) > drawerobj.disp(splot).datasize), return; end;
% Range(find(Range > drawerobj.disp(splot).datasize)) = drawerobj.disp(splot).datasize;
Range(Range > drawerobj.disp(splot).datasize) = drawerobj.disp(splot).datasize;

% Range

% check, return when data available
if (~isempty(findincluded(drawerobj.disp(splot).loadfunc_dynrange, Range)))
	%fprintf('\n%s: Fetch from buffer.', mfilename);
	RelRange = Range - drawerobj.disp(splot).loadfunc_dynrange(1)+1;
	%[RelRange splot]

	switch lower(drawerobj.disp(splot).type)
		case 'segments'
			% OAM REVISIT: This could be slow since all labels are send for
			% plotting and eventually Matlab handles visibility. Using
			% findoverlap might help.
			%data = drawerobj.disp(splot).data(findincluded(RelRange, drawerobj.disp(splot).data(:,1:2)),:);
			
			% OAM REVISIT: PM hack
			%data = drawerobj.disp(splot).data;
			data = [ drawerobj.disp(splot).data(:,1:2)-RelRange(1) drawerobj.disp(splot).data(:,3:end) ];
		otherwise
			data = drawerobj.disp(splot).data(RelRange(1):RelRange(2),:);
	end;
	return;
end;


% try loading dynamic data
% OAM REVISIT: Make load more intelligent: keep previously loaded data,
%              load diff only
if (~isempty(drawerobj.disp(splot).loadfunc))
	% need to workaround windows path separator
	marker_log(fh, '\nLoad from file %s', strrep(drawerobj.disp(splot).loadfunc_filename, '\', '\\'));

	% when additional parameters are required, use
	%   loadfunc_params = {param1, param2, ...}
	if isempty(drawerobj.disp(splot).loadfunc_params)
		data = feval(drawerobj.disp(splot).loadfunc, drawerobj.disp(splot).loadfunc_filename, Range);
	else
		data = feval(drawerobj.disp(splot).loadfunc, drawerobj.disp(splot).loadfunc_filename, Range, drawerobj.disp(splot).loadfunc_params{:});
	end;
	%fprintf(' Done.');

	% store in data cache
	drawerobj.disp(splot).data = data;
	drawerobj.disp(splot).loadfunc_dynrange = Range;
end;

% drawerobj.disp(splot)
end


% find included segments
function ovsegs = findincluded(interval, seglist)
cand = find(seglist(:,1) >= interval(1));
% ovsegs = cand(find(seglist(cand,2) <= interval(2)));
ovsegs = cand(seglist(cand,2) <= interval(2));
end

