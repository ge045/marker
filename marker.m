function marker(drawerobj, initlabels)
% function marker(drawerobj, initlabels)
%
% Required parameters:
% drawerobj     main MARKER control structure
% initlabels       label list to start from (default: [])
% 
%
% For detailled information please refer to README.TXT. 
% See also: marker_demo.m, how_to_use_marker.m.

% Copyright 2005-2008 Oliver Amft, Wearable Computing Lab., ETH Zurich

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

% -------------------------------------------------------------------
% Comments, suggestions and improvements welcome
% please contact: oam@ife.ee.ethz.ch
%
% Please see www.ife.ee.ethz.ch/~oam/software for new releases.
%
% See CHANGELOG.TXT for a development history of this toolbox.
% See README.TXT for a brief documentation.
% -------------------------------------------------------------------



fprintf('\nMARKER version %s', marker_version('version'));
fprintf('\nCopyright 2005-2008 Oliver Amft, and contributors.');
fprintf('\nPlease see README.TXT for documentation and contributors');
fprintf('\nfor this toolbox.');
fprintf('\n');
fprintf('\nMARKER is free software; you can redistribute it and/or');
fprintf('\nmodify it under the terms of the GNU General Public');
fprintf('\nLicense as published by the Free Software Foundation;');
fprintf('\nversion 2 of the license.');
fprintf('\n');
fprintf('\nA full text of this license can be found in license_gpl.txt.');
fprintf('\n');

% -------------------------------------------------------------------

if (~exist('drawerobj', 'var')) || isempty(drawerobj)
    fprintf('\nParameter drawerobj not set. Check parameter requirements for running MARKER.');
    fprintf('\n\n');
    help marker/marker
    fprintf('\n');
    return;
end;

fprintf('\nStarting...');

% initialise drawerobj
drawerobj.marker_version = marker_version('version');
drawerobj.StartTime = clock;

if (~exist('initlabels', 'var')), initlabels = []; end;
[drawerobj warnmsg] = marker_init(drawerobj, initlabels);


fprintf('\nConfiguration:');
for splot = 1:drawerobj.subplots
    fprintf('\nPlot %u: Sampling rate: %uHz, view range: %usa (%2.1fs).', ...
        splot, drawerobj.disp(splot).sfreq, drawerobj.disp(splot).xvisible, ...
        drawerobj.disp(splot).xvisible/drawerobj.disp(splot).sfreq);

    [alignshift drawerobj] = marker_aligner(drawerobj, splot, 0);
    [alignsps drawerobj] = marker_resampler(drawerobj, splot, 0);

    if (alignshift) || (alignsps)
        fprintf('\nPlot %u: Alignment: shift=%ssa, sps=%.2fHz.', splot, mat2str(alignshift), alignsps);
    end;
end; % for splot
fprintf('\nTotal categories : %u', drawerobj.maxLabelNum);
fprintf('\nTotal labels     : %u', size(drawerobj.seglist,1));
if (~isempty(drawerobj.seglist))
    tlabels = length(find(drawerobj.seglist(:,6)==false));
else
    tlabels = 0;
end;
fprintf('\nTotal t-labels   : %u', tlabels);
tmp = whos('drawerobj');
mem = tmp.bytes/1024;
if (mem > 1e3)
    fprintf('\nCore memory      : %u MB', round(mem/1024));
else
    fprintf('\nCore memory      : %u KB', round(mem));
end;

if (drawerobj.defaultlabel)
    fprintf('\nDefault label: %u', drawerobj.defaultlabel);
end;
fprintf('\n');


% configure dynamic settings
%drawerobj.xdisplay = get(fh,'XDisplay');
drawerobj.eventdata.dispatcherlock = false;
drawerobj.eventdata.ispointerpressed = false;
drawerobj.eventdata.selectedplot = [];
drawerobj.eventdata.statuslinetext = 'Ready. Type key ''h'' for command help.';


% screen size configuration: left (x), bottom (y), width (x), height (y)
srange = drawerobj.screensize(3:4);
% window size scaling: width, height
vrange(1) = floor(drawerobj.screensize(3)*drawerobj.windowsizescaling(1)); % width, x 
vrange(2) = floor(drawerobj.screensize(4)*drawerobj.windowsizescaling(2)); % height, y
% determine initial window position and size
switch drawerobj.windoworientation
    case 'full'
        sc = drawerobj.screensize;
    case 'classic'
		sc = drawerobj.screensize;
		sc = [sc(1) sc(4)-sc(4)*.7 sc(3) sc(4)*.7];
    case 'center'
        sc = [srange./2-vrange./2+1, vrange];
    otherwise
        %case 'top'
        sc = [srange-vrange+1, vrange];
end;

fh = figure( ...
    'Name', '', 'Position', sc, 'IntegerHandle', 'off', ...
    'NumberTitle', 'off', 'Toolbar', 'none', 'MenuBar', 'none', 'DockControls', 'off', ...
    'HandleVisibility', 'callback', 'UserData', drawerobj); 
% 	'WindowButtonMotionFcn', @marker_mousemove, ...

% make up titleline
set(fh, 'Name', marker_titleline(fh, drawerobj));

% fix renderer due to display flickering when labels (fill areas) and
% non-labeled data views are plotted.
set(fh, 'Renderer','OpenGL');
% Backingstore is set off automatically on most but not all window managers
set(fh, 'BackingStore', 'off');


figure(fh);
% Showing hidden handles allows marker_draw() to plot into the main window.
% Otherwise a new window would be created, since the handle is visible from
% a window callback routine only.
set(0,'ShowHiddenHandles','on');
drawerobj = marker_draw(fh, drawerobj, true); %% OSG added 'true' in order to tell the function that it is called the first time
set(0,'ShowHiddenHandles','off');


set(fh, 'UserData', drawerobj);
% set(fh, 'ResizeFcn', @marker_resetfigure);
set(fh, 'ResizeFcn', {@marker_dispatcher, 'reset'});

figure(fh);

% dump warning messages if there are any
maxwarnmsgsize = 1000;
if ~isempty(warnmsg)
	if length(warnmsg)>maxwarnmsgsize, warnmsg = [warnmsg(1:maxwarnmsgsize) '... [trunkated]']; end;
	
	marker_menudlg(fh, drawerobj, 'warndlg', ...
		sprintf('Marker generated the following warnings during startup:\n%s', warnmsg), 'Marker import');
end;


% activate user operations
set(fh, 'CloseRequestFcn', @marker_quitprogram);
set(fh, 'KeyPressFcn', @marker_dispatcher);
set(fh, 'WindowButtonDownFcn', @marker_pointerdown);
set(fh, 'WindowButtonUpFcn', @marker_pointerup);


% Marker is running
marker_log(fh, '\n%s: Ready.\n', mfilename);
