function marker_pointerup(fh, eventdata)
% function marker_pointerup(fh, eventdata)
% 
% Callback for pointer button released event. See also marker_pointerdown

% -------------------------------------------------------------------
% Copyright 2007 Oliver Amft, ETH Zurich, Wearable Computing Lab.
%
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

% disp(['called ' mfilename]);

% get persistent data
drawerobj = get(fh, 'UserData');

drawerobj.eventdata.ispointerpressed = false;

% write back persistent data
set(fh, 'UserData', drawerobj);
