function marker_log(fh, varargin)
% function marker_log(fh, varargin)
%
% Print out log messages

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

if (length(varargin) < 1)
    error('Not enough parameters');
end;

if (length(varargin) > 1)
    string = sprintf(varargin{1}, varargin{2:end});
else
    string = varargin{1};
end;

drawerobj = get(fh, 'UserData');

% at initialisation (marker_init.m) there is no figure handle available
% marker_log will be called with fh = [], hence dump message anyway
if isempty(drawerobj) || (drawerobj.cmdlinelog)
    % Avoid conflicting with control characters, e.g. when filepaths ('\')
    % on Windows platforms are printed in the calling function already -
    % here it should be interpreted.
    fprintf(string);
    %disp(string);
end;