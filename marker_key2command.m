function [cmdqueue cont] = marker_key2command(fh, drawerobj, cmdqueue, currentfcn, key)
% function [cmdqueue cont] = marker_key2command(fh, drawerobj, cmdqueue, currentfcn, key)
%
% Map keyboard code to a dispatcher command for intermediate commands.
% These are currently supported by 'e' and 'm' only. Param cont is zero
% upon successful match, one else.

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
cont = 1;

% check & return if cmdqueue has a size exceeding cmdqueue_maxsize
if (length(cmdqueue) > drawerobj.cmdqueue_maxsize), return; end;

if (key < 32) || (key > 127), return; end;

% key
% char(key)

switch char(key)
	case {'n', 'b', 'e', 'm', 'w', 'z', 'v', 'i', 'p', 'd', 't'}
		nextfcncode = char(key);

		% special case conversion
	case ' '
		nextfcncode = 'space';
	case 'N'
		nextfcncode = 'shift+n';
	case 'B'
		nextfcncode = 'shift+b';
	case '.'
		nextfcncode = 'period';
	case ','
		nextfcncode = 'comma';
	case 'D'
		nextfcncode = 'shift+d';

	otherwise
		nextfcncode = [];
end;

if isempty(nextfcncode) || strcmp(nextfcncode, currentfcn), return; end;

% found a valid function code, enqueue it and return to active fcn afterwards
cont = 0;
cmdqueue = {nextfcncode, 'redraw', currentfcn, cmdqueue{:}};

