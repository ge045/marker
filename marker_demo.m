% marker_demo.m
%
% Demo script that runs Marker with some sin/cos data.
% This script is based on the template how_to_use_marker.m of the MARKER
% toolbox. It should run as is. If not, something is wrong with your installation.

% Copyright 2005, 2006 Oliver Amft, ETH Zurich, Wearable Computing Lab.
% Copyright 2006, Mathias Staeger, UMIT Innsbruck

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


fprintf('\n%s: MARKER toolbox test script. This will launch MARKER with some nice curves.', mfilename);
fprintf('\n%s: It is running as is. If not, something is wrong with the installation.', mfilename);
fprintf('\n%s: This script is based on how_to_use_marker.m.', mfilename);
fprintf('\n');

% clear all;
% clc;

% plug in the data for your plots here
fs = 1;
t = 0:1/fs:2000;
data1 = sin(2*pi*0.005.*t).';
data2 = cos(2*pi*0.01 .*t).';
x = [0,1,2,3,4,5,4,3,2,1];
data3 = repmat(x,1,200).';
clear x;
clear FeatureSet;
FeatureSet = {[data1 1.5*data2], data2, data3};
Classlist = {'MyClass one', 'MyClass two', 'whatever'};

% prepare your labels, 
% label format is 'segments', e.g. [begin end size class #number]
% some conversion methods from other formats are provided:
%   classlabels2segments, labeling2segments
initlabels = [ ...
    200 300 101 2 1 1;
    1200 1800 601 3 2 0];

% configure the names of your plots here
PlotTitle = {'Plot title 1','Plot title 2','Plot title 3'};

clear drawerobj;

% configure title of the MARKER window, e.g. subjects name, optional
drawerobj.title = sprintf('%s', mfilename);

% printout label count
if exist('initlabels','var')
    fprintf('\n%s: Found %u labels.', mfilename, size(initlabels,1));
end;

% setup marker display from FeatureSets
for sysno = 1:length(FeatureSet)
    drawerobj.disp(sysno).data = FeatureSet{sysno};

    drawerobj.disp(sysno).ylabel = [PlotTitle{sysno} ' [amp.]'];
    
    % reference sampling rate [Hz] for the data, must be equal for all plots
    drawerobj.disp(sysno).sfreq = fs;
    
    % y-axis resolution, optinally (default: guessed automatically)
    % drawerobj.disp(sysno).ylim = [0 max(3*std(drawerobj.disp(sysno).data))]
        
    % alignment shift in samples, optional
    %drawerobj.disp(sysno).alignshift = 0;
    
    % alignment sample rate (relative to sfreq), optional
    %drawerobj.disp(sysno).alignsps = 0;

    % size of the data
	%drawerobj.disp(sysno).datasize = max(size(drawerobj.disp(sysno).data));
    
    % initial visible data range (x-axis), optional
    drawerobj.disp(sysno).xvisible = drawerobj.disp(sysno).sfreq*345;
    
	% show/hide of individual subplots, optional
    %drawerobj.disp(sysno).hideplot = false;
    
	% show/hide of individual signals, optional
	%     drawerobj.disp(sysno).hidesignal(1) = false;
	%     if (sysno == 1)
	%         drawerobj.disp(sysno).hidesignal(2) = false;
	%     end;

    if (0)
        % Optional config player information
        % You may listen to the sound section / display a aviatar for motion
        % data or simply plot the data at its original (high) sampling
        % rate. See how_to_use_marker.m for more details.
        %
        % here we plug in a method to play sound
		player = 1;
		drawerobj.disp(sysno).playerdata(player).playerfun = @marker_player_playsound;
		drawerobj.disp(sysno).playerdata(player).title = 'Play my sound';
        drawerobj.disp(sysno).playerdata(player).file = 'data/mywavfile.wav'; % needed for WAV
    end;
end;


% this is a SPARE plot, e.g. to dispaly optional labels
if (1)
    sysno = length(FeatureSet)+1;
    drawerobj.disp(sysno).type = 'SPARE PLOT';
	drawerobj.disp(sysno).save = false;  % on saving: exclude plot information in CLA file
    drawerobj.disp(sysno).data = 0;
    drawerobj.disp(sysno).sfreq = fs;
end;    


% override automatic setting of y-axis scaling, optional
% use this if MARKER does not gess size correctly
drawerobj.disp(3).ylim = [0 5];

% string cell array of names for the labels, optional
drawerobj.labelstrings = Classlist;

% maximum number of classes/label types, default: 1
drawerobj.maxLabelNum = length(drawerobj.labelstrings);


% configure a default file name (suggested when saving a label file), optional
%[fdir fname fext] = fileparts('mylabelfile.mat');
%drawerobj.iofilename = [fname fext];
%drawerobj.defaultDir = fdir;

% Marker window size: [height width], optional
% drawerobj.windowsizescaling = [1 0.7];
drawerobj.windoworientation = 'classic';

fprintf('\n%s: Launching Marker...', mfilename);
marker(drawerobj, initlabels);

% clear up
%clear initlabels;
