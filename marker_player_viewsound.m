function ok = marker_player_viewsound(fh, drawerobj, playrange_r, splot, playerselect)
% function ok = marker_player_viewsound(fh, drawerobj, playrange_r, splot, playerselect)
%
% Player method for displaying sound. 
%
% This code demonstrates the utilisation of the MARKER player interface for
% various playing purposes. See also: marker_player_playsound
% 
% Settings for this play method (all stored in drawerobj.disp(splot).playerdata(playerselect)):
% file - WAV file to play

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

% ok = false;

% if channel specified, play this one
channel = find(drawerobj.disp(splot).hidesignal==0);
if length(channel)>1
	marker_log(fh, 'Loading more than one channel is not yet supported!');
	error('Loading more than one channel is not yet supported!');
end;
	

% get sample rate
sourcefile = drawerobj.disp(splot).playerdata(playerselect).file;
marker_log(fh, 'Load WAV file %s...', sourcefile);
[dummy1 dummy2 sps] = WAVReader(sourcefile, [], 'channels', channel);

% adapt play section boundaries
playrange_rd = ceil(playrange_r * sps/drawerobj.disp(splot).sfreq);
playrange_rd(:,1) = playrange_rd(:,1)-ceil(sps/drawerobj.disp(splot).sfreq)+1;
marker_log(fh, 'Play range %u:%u.', playrange_rd(1), playrange_rd(2));

% load and play this section
if abs(diff(playrange_r))/sps > 20
	marker_log(fh, 'Loading more than 20 sec of data can be memory consuming!');
	error('Loading more than 20 sec of data can be memory consuming!');
end;
wavdata = WAVReader(sourcefile, playrange_rd, 'channels', channel, 'verbose', drawerobj.cmdlinelog);

str = sprintf('View plot %u (%s), data: %.2fsec, rate %.0fHz.', splot, mat2str(channel), size(wavdata,1)/sps, sps);
marker_log(fh, str);

vfh = figure('Name', str, 'NumberTitle', 'off', 'Toolbar', 'none', 'MenuBar', 'none', 'DockControls', 'off');
plot(wavdata);
if ~isempty(drawerobj.disp(splot).ylim), ylim(drawerobj.disp(splot).ylim); end;

% convert range info back to marker display
current_sps = drawerobj.disp(splot).sfreq - drawerobj.disp(splot).alignsps;
[p,q] = rat(current_sps / drawerobj.disp(splot).sfreq);
playrange = (playrange_r * q/p) - drawerobj.disp(splot).alignshift;
[dummy1 xtunits xtls] = marker_timeaxisunits(fh, drawerobj, splot, playrange);

xtickmarks = length(xtls);
xtlinc = abs(diff(playrange_rd))/(xtickmarks-1);
xticks = (playrange_rd(1): xtlinc : playrange_rd(2)) - playrange_rd(1);
set(gca(vfh), 'XTick', xticks);
set(gca(vfh), 'XTickLabel', xtls );

tres = abs(diff(playrange_r))/drawerobj.timeaxissamplesconv(1);
xlabel( ['Axis in ' lower(drawerobj.timeaxisunits) ';  View: ' num2str(tres,'%.1f') ' ' lower(xtunits(1:3))] );

try
	% try to provide data into main workspace, works only when variable exportvar was set
	evalin('base', ['clear ' drawerobj.disp(splot).playerdata(playerselect).exportvar]);
	assignin('base', drawerobj.disp(splot).playerdata(playerselect).exportvar, wavdata);
	marker_log(fh, '\n%s: Exporting WAV data to base workspace successful, var: %s.', mfilename, drawerobj.disp(splot).playerdata(playerselect).exportvar);
catch
	marker_log(fh, sprintf('\n%s: Exporting WAV data to base workspace failed.', mfilename));
end;

ok = true;