function [version releaseid] = marker_version(mode)
% function [version releaseid] = marker_version(mode)
% 
% Return MARKER version

% Copyright 2007, 2008 Oliver Amft, ETH Zurich, Wearable Computing Lab.

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
if (~exist('mode','var')), mode = 'version'; end;

% DEBUG mode
releaseid.DEBUG = false;
% releaseid.DEBUG = true;

releaseid.major = 1;
releaseid.minor = 1;
releaseid.patch = 0;
% releaseid.comment = '(WIP)';
releaseid.comment = '(OSG ::: spantec)';

% 2 digits for patch level and minor
releaseid.vernr = releaseid.major*1e4 + releaseid.minor*1e2 + releaseid.patch;

switch lower(mode)
    case {'ver', 'version'}
        version = [ int2str(releaseid.major) '.' int2str(releaseid.minor) '.' int2str(releaseid.patch) ' ' releaseid.comment ];
    case {'vernr', 'versionnumber'}
        version = releaseid.vernr;
	case 'debug'
		version = releaseid.DEBUG;
%    case 'date'
%        
    otherwise
        fprintf('\n%s: Parameter ''mode'' not supported.', mfilename);
        version = [ int2str(releaseid.major) '.' int2str(releaseid.minor) '.' int2str(releaseid.patch) ' ' releaseid.comment ];
end;