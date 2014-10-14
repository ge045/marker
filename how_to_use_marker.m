% how_to_use_marker.m
%
% This script is a template frontend for the MARKER toolbox. It is not 
% running as is! Feel free to adapt it to your environment.

fprintf('\nThis script is a template frontend for the MARKER toolbox.');
fprintf('\nIt is not running as is! Feel free to adapt it to your environment.');
fprintf('\n');
fprintf('\nTo see a demo of MARKER run marker_demo.');
return;

% -------------------------------------------------------------------
%
% -------------------------------------------------------------------

% This structure will hold most of the configuration fields
% Keep this line before initialising drawerobj.
clear drawerobj; 


% Configure title of the MARKER window, e.g. subjects name, optional
% Part = ''; 
% Subject = '';
% drawerobj.title = sprintf('Part: %3u, Subject: %s', Part, Subject);

% To obtain text menu instead of graphic UI: uncomment following line.
% (This option can be changed in Marker properties (ctrl+p) as well.)
% drawerobj.consolemenus = true;

% enable command line logging, default: false (disabled)
% This option can be changed in Marker properties (ctrl+p) as well.
% drawerobj.cmdlinelog = true;

% enable label overlap checking, default: false (disabled)
% This option can be changed in Marker properties (ctrl+p) as well.
% drawerobj.labelovcheck = true;

% string cell array of names for the labels, optional
%drawerobj.labelstrings = Classlist;

% maximum number of classes/label types, default: 1
%drawerobj.maxLabelNum = length(drawerobj.labelstrings);




% -------------------------------------------------------------------
% Setup marker displays
% -------------------------------------------------------------------
% The following variables shall be set (required):
% FeatureSet
% PlotTitle
% initlabels

% plug in the data for your plots here
FeatureSet = {data1 data2};

% prepare your labels, 
% label format is 'segments', e.g. [begin end size class #number]
% some conversion methods from other formats are provided:
%   classlabels2segments, labeling2segments
% At least, [begin end] must be provided for a valid labeling display.
initlabels = [];

% configure the names of your plots here
PlotTitle = {'Plot title 1', 'Plot title 2'};


% configure each Marker plot
for sysno = 1:length(FeatureSet)
    drawerobj.disp(sysno).type = 'WAV'; % data type, e.g. WAV, XSENS...

    drawerobj.disp(sysno).data = FeatureSet{sysno}; % [samples, channels] = size(data)
    
	% plot routine used to display data, default: plot()
	% options
	% @plot: Use this function for all time series signals
	% @marker_plotlabel: Use this function to plot labels in a subplot, parameters: maxclasses.
	%drawerobj.disp(sysno).plotfunc = @plot;
	
	% Cell array of additional parameters for plot routine, optional
	% Default 'drawerobj.disp(sysno).plotfunc_params = {'LineWidth', 2}' is
	% used when field is empty. To omit this, e.g. when using another plot
	% function, use drawerobj.disp(sysno).plotfunc_params = {' '};
	%drawerobj.disp(sysno).plotfunc_param = {};
	
    
	% y-axis title, optional
	drawerobj.disp(sysno).ylabel = [PlotTitle{sysno} ' [amp.]'];
    
    % reference sampling rate [Hz] for the data, must be equal for all plots
    drawerobj.disp(sysno).sfreq = 100;
    
    % y-axis resolution, optinally (default: guessed automatically)
    %drawerobj.disp(sysno).ylim = [0 max(3*std(drawerobj.disp(sysno).data))];
    
    % alignment shift in samples, optional
    %drawerobj.disp(sysno).alignshift = 0;
    
    % alignment sample rate (relative to sfreq), optional
    %drawerobj.disp(sysno).alignsps = 0;

    % size of the data, optional
	%drawerobj.disp(sysno).datasize = size(drawerobj.disp(sysno).data,1);

    % initial visible data range (x-axis), optional
    drawerobj.disp(sysno).xvisible = drawerobj.disp(sysno).sfreq*40;

	
	% config label visibility
	if (0)
		% Labels may be shown/hidden for each plot to improve visibility.
		% Setting an label map index to zero hides the corresponding label
		% in the plot. Default: all enabled.
		drawerobj.disp(sysno).showlabels = true(1, length(Classlist));
	end;

	
	% config player information
    % you may listen to the sound section or display a aviatar
    if (0)
        % here we provide some optional infos to play sound
        % you may register your "play" method in marker_player()
		% several player sources can be configured for each plot by
		% extending the array drawerobj.disp(sysno).playerdata(). Source is
		% selectable through drawerobj.disp(splot).playersource and Shift+p 
		% Available player methods: 
		%   marker_player_playsound
		%   marker_player_viewsound
		player = 1;
		drawerobj.disp(sysno).playerdata(player).playerfun = @marker_player_playsound;
		drawerobj.disp(sysno).playerdata(player).title = 'Play my sound';
        drawerobj.disp(sysno).playerdata(player).file = 'data/mywavfile.wav'; % needed for WAV
        drawerobj.disp(sysno).playerdata(player).channel = 1; % optional, WAV only
		drawerobj.disp(sysno).playerdata(player).gain = 1; % optional, WAV only
    end;
    
	
    % on-demand data load
	%
    % When using this mode, set drawerobj.disp(sysno).data = []
    % The following example is valid for WAV audio data. Other data types
    % require a specific load function.
    % 
    % Determine size and sample rate of a WAV file:
    % [dummy, WAVSize, WAVRate] = WAVReader(WAVFile);
    %
    %drawerobj.disp(sysno).data = [];
    %drawerobj.disp(sysno).loadfunc = @WAVReader;
    %drawerobj.disp(sysno).loadfunc_params = {'option1', 1}; % <= optional
    %drawerobj.disp(sysno).loadfunc_filename = WAVFile;
    %
    % All other fields may be configured as usual.
end;



% configure a default file name (suggested when saving a label file), optional
[fdir fname fext] = fileparts('mylabelfile.mat');
drawerobj.iofilename = [fname fext];
drawerobj.defaultDir = fdir;


% Marker window size: [height width], optional
% drawerobj.windowsizescaling = [0.7 1];


% Launch Marker by supplying drawerobj struct and initlabels.
% Alternatively labels can be stored in drawerobj.seglist, while initlabels = [].
fprintf('\n%s: Launching Marker...', mfilename);
marker(drawerobj, initlabels);


% clear up
clear initlabels;
