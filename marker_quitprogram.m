function marker_quitprogram(fh, eventdata)
% function marker_quitprogram(fh, eventdata)
% 
% Shutdown MARKER gracefully

% Copyright 2005-2008 Oliver Amft, ETH Zurich, Wearable Computing Lab.

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

drawerobj = get(fh, 'UserData');

% OAM REVISIT: 
% Problem when quit is initiated and a console input was not satisfied
if (drawerobj.eventdata.dispatcherlock)
	marker_log(fh, '\n%s: dispatcherlock is set.', mfilename);
	ButtonName = marker_menudlg(fh, drawerobj, 'questdlg', ...
		'MARKER is busy. Maybe open dialog. Unlock?', 'MARKER Error', 'Yes', 'No','Yes');

	if strcmpi(ButtonName, 'yes')
		drawerobj.eventdata.dispatcherlock = false;
		set(fh, 'UserData', drawerobj);
		marker_dispatcher(fh, [], 'r');
		marker_menudlg(fh, drawerobj, 'errordlg', 'MARKER unlocked. This is an instable state. Save and restart the application.', 'MARKER Error');
	end;
	return;
end;

% prevent re-entry in marker_dispatcher while in question dialog
drawerobj.eventdata.dispatcherlock = true;	set(fh, 'UserData', drawerobj);

% ask for saving when modified
if (drawerobj.ismodified)
	ButtonName = marker_menudlg(fh, drawerobj, 'questdlg', ...
		'Labeling not saved - save it?', 'Confirm program exit', 'Yes', 'No','Cancel','Yes');
	
	drawerobj.eventdata.dispatcherlock = false;	set(fh, 'UserData', drawerobj);
	switch lower(ButtonName)
		case 'yes'
			if (marker_dispatcher(fh, [], 'ctrl+s') == false)
				return; 
			end;
		case 'cancel'
			marker_dispatcher(fh, [], 'r');
			return;
	end;
end; % if (drawerobj.ismodified)

if (drawerobj.askbeforequit) && (~drawerobj.ismodified)
	% ask before really quitting
	ButtonName = marker_menudlg(fh, drawerobj, 'questdlg', ...
		'Really exit MARKER?', 'Confirm program exit', 'Yes', 'No','Cancel','Yes');

	drawerobj.eventdata.dispatcherlock = false;	set(fh, 'UserData', drawerobj);
	if ~strcmpi(ButtonName, 'Yes')
		marker_dispatcher(fh, [], 'r');
		return;
	end;
end;

% added (OSG)
if isfield(drawerobj,'handles2deleteBeforeQuit')
    h2d = drawerobj.handles2deleteBeforeQuit ;
    cellfun(@delete,h2d) ;
end

% shutdown MARKER
delete(fh); fh = [];

% determine runtime
drawerobj.StopTime = clock;
runtime = etime(drawerobj.StopTime, drawerobj.StartTime); % in seconds
runtime_str = sprintf('%02uh %02umin %02us',  fix(runtime/3600), fix(rem(runtime,3600)/60), fix(rem(runtime, 60)) );
marker_log(fh, '\nMARKER finished: ''%s''   (runtime: %s)\n', drawerobj.title, runtime_str );

% bye bye