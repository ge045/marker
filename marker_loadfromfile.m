function [fromfile loaded] = marker_loadfromfile(fh, drawerobj, filename, varstring, default)
% function [fromfile loaded] = marker_loadfromfile(fh, drawerobj, filename, varstring, default)
%
% Load a variable from file

% Copyright 2006-2007 Oliver Amft, ETH Zurich, Wearable Computing Lab.

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

if ~exist('default', 'var'), default = []; end;

loaded = true;
fromfile = [];

warning('off');
try
	fromfile = load('-mat', filename, varstring);
	fromfile.(varstring);
catch
	fromfile.(varstring) = default;
	loaded = false;
end;
warning('on');
