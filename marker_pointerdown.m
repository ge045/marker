function marker_pointerdown(fh, eventdata)
% function marker_pointerdown(fh, eventdata)
% 
% Callback for pointer button pressed event. See also marker_pointerup

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
	
%if (~get(fh, 'Selected')) return; end;

% get persistent data
drawerobj = get(fh, 'UserData');
% if (drawerobj.eventdata.dispatcherlock), return; end;

drawerobj.eventdata.ispointerpressed = true;
drawerobj.eventdata.selectedplot = marker_findselectedplot(fh, drawerobj);
% drawerobj.eventdata.selectedplot

% write back persistent data
% This may not become visible if marker_dispatcher is executing and saving
% back its local copy of drawerobj. However functions may use the
% information as marker_pointerpan() does.
set(fh, 'UserData', drawerobj);

if (drawerobj.pointerpan)
	marker_dispatcher(fh, [], 'pointerpan');
end;

