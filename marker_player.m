function ok = marker_player(fh, drawerobj, playrange, splot)
% function ok = marker_player(fh, drawerobj, playrange, splot)
%
% Spec function for player methods - register your playing methods here.
%
% Playing a section from the data typically requires the following:
%   1. Source file to play: drawerobj.disp(splot).playerdata().sourcefile
%       Multiple channels/sources may be configured for each plot by an
%       drawerobj.disp(splot).playerdata array. Selectable though MARKER
%       properties menu.
%   2. A procedure to load/play the data from this file. See for example 
%       marker_player_playsound.
%

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

ok = true;

set(fh, 'Pointer', 'watch'); drawnow;
marker_log(fh, '\n%s: Playing %.1fs, samples %u:%u...', mfilename, ...
	abs(diff(playrange))/drawerobj.disp(splot).sfreq, playrange(1), playrange(2));

% OAM REVISIT: alignshift assumes current_sps already!
% current_sps = drawerobj.disp(splot).sfreq + drawerobj.disp(splot).alignsps;
% [p,q] = rat(current_sps / drawerobj.disp(splot).sfreq);
% playrange_r = ceil((playrange + drawerobj.disp(splot).alignshift) * q/p);
%playrange * p/q  + drawerobj.disp(splot).alignshift;

current_sps = drawerobj.disp(splot).sfreq - drawerobj.disp(splot).alignsps;
[p,q] = rat(current_sps / drawerobj.disp(splot).sfreq);
playrange_r = (playrange + drawerobj.disp(splot).alignshift) * p/q;
% playrange_r


% check if any player confugured
if isempty(drawerobj.disp(splot).playerdata)
	marker_menudlg(fh, drawerobj, 'errordlg', ...
		sprintf('No player information found for plot %u', splot), 'Play error');
	ok = false; set(fh, 'Pointer', 'arrow'); drawnow;
	return;
end;

playerselect = drawerobj.disp(splot).playerselect;

% check if player method registered
if isempty(drawerobj.disp(splot).playerdata(playerselect).playerfun)
	marker_menudlg(fh, drawerobj, 'errordlg', ...
		sprintf('No player function found for plot %u', splot), 'Play error');
	ok = false;  set(fh, 'Pointer', 'arrow'); drawnow;
	return;
end;

% call player method
try
	ok = feval(drawerobj.disp(splot).playerdata(playerselect).playerfun, fh, drawerobj, playrange_r, splot, playerselect);
catch
	errorlog = lasterror;
	marker_menudlg(fh, drawerobj, 'errordlg', ...
		sprintf('Player %u for plot %u failed. \nMessage: %s', playerselect, splot, errorlog.message), 'Player error');
	ok = false;
end;

%set(fh, 'Pointer', 'arrow'); drawnow;

