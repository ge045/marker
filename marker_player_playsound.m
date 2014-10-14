function ok = marker_player_playsound(fh, drawerobj, playrange_r, splot, playerselect)
% function ok = marker_player_playsound(fh, drawerobj, playrange_r, splot, playerselect)
%
% Player method for playing sound. Different channels can be played by
% configuring this player with individual settings (see below).
%
% This code demonstrates the utilisation of the MARKER player interface for
% various playing purposes. See also: marker_player_viewsound
% 
% Settings for this play method (all stored in drawerobj.disp(splot).playerdata(playerselect)):
% file - WAV file to play
% channel - optional channel specification
% gain - optional gain setting

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
if isfield(drawerobj.disp(splot).playerdata(playerselect), 'channel')
	channel = drawerobj.disp(splot).playerdata(playerselect).channel;
else
	channel = [];
end;

% get sample rate
sourcefile = drawerobj.disp(splot).playerdata(playerselect).file;
marker_log(fh, 'Load WAV file %s...', sourcefile);
[dummy1 dummy2 sps] = WAVReader(sourcefile, [], 'channels', channel);

% adapt play section boundaries
playrange_r = ceil(playrange_r * sps/drawerobj.disp(splot).sfreq);
playrange_r(:,1) = playrange_r(:,1)-ceil(sps/drawerobj.disp(splot).sfreq)+1;
marker_log(fh, 'Play range %u:%u.', playrange_r(1), playrange_r(2));

% load and play this section
wavdata = WAVReader(sourcefile, playrange_r, 'channels', channel, 'verbose', drawerobj.cmdlinelog);

if isfield(drawerobj.disp(splot).playerdata(playerselect), 'gain')
	% pump up the volume
	wavdata = wavdata .* drawerobj.disp(splot).playerdata(playerselect).gain;
	wavdata(wavdata>1) = 1;
	marker_log(fh, 'applied gain');
end;

marker_log(fh, 'Play data %u, Rate %uHz.', size(wavdata,1), sps);
WAVPlayer(wavdata, sps);

ok = true;