function [drawerobj warnmsg] = marker_init(drawerobj, initlabels)
% function [drawerobj warnmsg] = marker_init(drawerobj, initlabels)
% 
% Initialise Marker, guess or correct settings

% Copyright 2005-2007 Oliver Amft, Wearable Computing Lab., ETH Zurich

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

% gather warnings for summary
warnmsg = '';

% -------------------------------------------------------------------
% configuration fields of drawerobj, guess as much as possible
% these fields allow customisation to specific applications
% -------------------------------------------------------------------

% flag marking user changes to drawerobj
drawerobj.ismodified = false;

% main window title line
if ~isfield(drawerobj, 'title'), drawerobj.title = 'untitled'; end;

% enable/disable command line text output
if ~isfield(drawerobj, 'cmdlinelog'), drawerobj.cmdlinelog = false; end;

% enable/disable command line based interaction, false=GUI interaction
if ~isfield(drawerobj, 'consolemenus'), drawerobj.consolemenus = false; end;

% ask before quitting program
if ~isfield(drawerobj, 'askbeforequit'), drawerobj.askbeforequit = true; end;

% -------------------------------------------------------------------------
% basic settings
% -------------------------------------------------------------------------

% set nr of plots from struct array size
if (~isfield(drawerobj, 'disp')), error('Field drawerobj.disp should be configured in order to run MARKER.'); end;
drawerobj.subplots = max(size(drawerobj.disp));

% set default file and path for label saving
if ~isfield(drawerobj, 'askbeforesave'), drawerobj.askbeforesave = true; end;
if ~isfield(drawerobj, 'iofilename') || isempty(drawerobj.iofilename)
	drawerobj.iofilename = 'labeling.mat';  drawerobj.askbeforesave = true;
else
	% if there is a filename AND filetype configured, don't ask for it again
	 if isfield(drawerobj, 'defaultsavetype'), drawerobj.askbeforesave = false; end;
end;
if ~isfield(drawerobj, 'defaultsavetype'), drawerobj.defaultsavetype = 1; end; % Marker label file
if ~isfield(drawerobj, 'defaultDir'), drawerobj.defaultDir = '.'; end;

% -------------------------------------------------------------------------
% label initialisation
%
% seglist format: [begin end length class id confidence]
% -------------------------------------------------------------------------

if isfield(drawerobj,'seglist')
	% labels may be supplied by drawerobj.seglist OR parameter initlabels
	if (~isempty(drawerobj.seglist)) && (~isempty(initlabels))
		str = '\nWARNING: Conflicting settings: drawerobj.seglist and initlabels, using initlabels.';
		fprintf(str);
		warnmsg = [warnmsg str];
	end;
	if (~isempty(drawerobj.seglist)) && (isempty(initlabels))
		initlabels = drawerobj.seglist;
	end;
end;


% build segment list from initlabels
drawerobj.seglist = [];
if exist('initlabels','var') && (~isempty(initlabels)) && (size(initlabels,2)>=2)

	% labels with at negative begin/end position
	badlabels = [ find(initlabels(:,1) <= 0)' find(initlabels(:,2) <= 0)' ];
	if ~isempty(badlabels)
		str = sprintf('\nWARNING: Label bounds negative or zero, omitted label(s): #%s.', mat2str(unique(badlabels)));
		fprintf(str);
		warnmsg = [warnmsg str];
		drawerobj.ismodified = true;
	end;
	initlabels(badlabels, :) = [];
	
	
	% omit non-labels
	labelsize = initlabels(:,2) - initlabels(:,1)+1;
	badlabels = find(labelsize < 1);
	if ~isempty(badlabels)
		str = sprintf('\nWARNING: Label size zero or label bound mismatched, omitted label(s): #%s.', mat2str(badlabels));
		fprintf(str);
		warnmsg = [warnmsg str];
		drawerobj.ismodified = true;
	end;
	initlabels(badlabels, :) = [];
	
	
	% check, correct labels that have a fraction
	badlabels = [ find((initlabels(:,1)-round(initlabels(:,1)))~=0); find((initlabels(:,2)-round(initlabels(:,2)))~=0) ];
	if ~isempty(badlabels)
		str = sprintf('\nWARNING: Corrected label(s) that had fraction values: #%s.', mat2str(badlabels));
		fprintf(str);
		warnmsg = [warnmsg str];
		drawerobj.ismodified = true;
	end;
	initlabels(:,1:2) = [ round(initlabels(:,1)) round(initlabels(:,2)) ];
	
	
    % label size
	labelsize = initlabels(:,2) - initlabels(:,1)+1;
	badlabels = find(labelsize ~= initlabels(:,3));
	if (size(initlabels,2) > 3) && (~isempty(badlabels) )
		str = sprintf('\nWARNING: Label size corrected for label(s): #%s.', mat2str(badlabels));
		fprintf(str);
		warnmsg = [warnmsg str];
		drawerobj.ismodified = true;
	end;
	initlabels(:,3) = labelsize;

	
    % class
    if (size(initlabels,2) < 4)
        initlabels(:, 4) = 1;
    end;
    
	
    % id
    initlabels(:,5) = (1 : size(initlabels,1)).';
	
	
    % confidence
    if (size(initlabels,2) < 6), initlabels(:,6) = 1;  end;
	badlabels = [find(initlabels(:,6) < 0); find(initlabels(:,6) > 1)];
	if ~isempty(badlabels)
		str = sprintf('\nWARNING: Label confidence value wrong, set confidence to zero at label(s): #%s.', mat2str(unique(badlabels)));
		fprintf(str);
		warnmsg = [warnmsg str];
		drawerobj.ismodified = true;
	end;
	initlabels(badlabels, 6) = 0;

	
	% anything else
    if size(initlabels,2) > 6
		str = '\nWARNING: Initial label list has too many columns, truncated.';
		fprintf(str);
		warnmsg = [warnmsg str];
		
		initlabels = initlabels(:,1:6);
		drawerobj.ismodified = true;
    end;

	
    % copy initlabels to drawerobj.seglist
    drawerobj = marker_resort([], drawerobj, initlabels);
end;


% set maxLabelNum and do some error checking
if ~isfield(drawerobj, 'maxLabelNum')
    fprintf('\nINFO: Field drawerobj.maxLabelNum not found. Setting drawerobj.maxLabelNum=%u.', max(drawerobj.seglist(:,4)));
    drawerobj.maxLabelNum = max(drawerobj.seglist(:,4)); 
end;
if ~isempty(drawerobj.seglist) && (max(drawerobj.seglist(:,4)) > drawerobj.maxLabelNum)
    drawerobj.maxLabelNum = max(drawerobj.seglist(:,4));
    fprintf('\nINFO: Field drawerobj.maxLabelNum set to %u. Check whether this is correct.', ...
        drawerobj.maxLabelNum);
end;

% default label strings (displayed e.g. during label edit)
if (~isfield(drawerobj, 'labelstrings')) || (length(drawerobj.labelstrings) ~= drawerobj.maxLabelNum)
    for c = 1:drawerobj.maxLabelNum
        drawerobj.labelstrings{c} = ['class ',num2str(c)];
    end;
	
	fprintf('\nINFO: Missing/malformat settings for drawerobj.labelstrings.');
end;
corrected = false(1, drawerobj.maxLabelNum);
for c = 1:drawerobj.maxLabelNum
	if isempty(drawerobj.labelstrings{c}) %|| (length(drawerobj.labelstrings{c}) > 25)
		drawerobj.labelstrings{c} = ['class ',num2str(c)];
		corrected(c) = true;
	end;
end;
if (~isempty(find(corrected==true,1)))
	fprintf('\nINFO: Corrected drawerobj.labelstrings for classes %s', mat2str(find(corrected==true)));
end;
clear corrected;


% default label/shaddow setting
if (~isfield(drawerobj, 'defaultlabel')) || isempty(drawerobj.defaultlabel) || (~isnumeric(drawerobj.defaultlabel))
    if (drawerobj.maxLabelNum == 1)
        % obviously a default label is useful
        drawerobj.defaultlabel = 1;
    else
        drawerobj.defaultlabel = 0;
    end;
end;
drawerobj.olddefaultlabel = 0;

% EXPERIMENTAL - not supported yet!
% create label comment list
% if (~isfield(drawerobj, 'commentlist'))
% 	drawerobj.commentlist = repmat({[]}, size(drawerobj.seglist,1),1);
% end;
% if (length(drawerobj.commentlist) ~= size(drawerobj.seglist,1))
% 	drawerobj.commentlist = repmat({[]}, size(drawerobj.seglist,1),1);
%     fprintf('\nINFO: Field commentlist did not equal label list, reseting.');
% end;


% data field
if (~isfield(drawerobj.disp, 'data')), drawerobj.disp(drawerobj.subplots).data = []; end;


% plot type
if ~isfield(drawerobj.disp, 'type')
    [drawerobj.disp(1:drawerobj.subplots).type] = deal('UNKNOWN'); 
end;
for splot = 1:drawerobj.subplots
	if isempty(drawerobj.disp(splot).type) || (~ischar(drawerobj.disp(splot).type))
		drawerobj.disp(splot).type = 'UNKNOWN';
	end;
end;


% check datasize field (required)
if (~isfield(drawerobj.disp, 'datasize'))
    %error('Field drawerobj.disp(1).datasize missing or empty.'); 
	[drawerobj.disp(1:drawerobj.subplots).datasize] = deal(0);
end;
for splot = 1:drawerobj.subplots
    if (~isfield(drawerobj.disp, 'datasize')) || isempty(drawerobj.disp(splot).datasize) || (drawerobj.disp(splot).datasize==0)

        % drawerobj.disp(splot).loadfunc may not be initialised up to now
        if (isfield(drawerobj.disp, 'loadfunc')) && (~isempty(drawerobj.disp(splot).loadfunc))
            error('Valid value for drawerobj.disp().datasize must be set in dynamic data load mode.');
        end;
        
        % OAM REVISIT: This is tricky. All calls to the data shall normally
        % be made through marker_getdatafrombuffer(). However nothing is yet initialised.
		switch lower(drawerobj.disp(splot).type)
			case 'segments'
				drawerobj.disp(splot).datasize = drawerobj.disp(splot).data(end,2);
			otherwise
				drawerobj.disp(splot).datasize = size(drawerobj.disp(splot).data,1);
		end;

        if (drawerobj.disp(splot).datasize==0)
            error('No valid value for drawerobj.disp().datasize found, since no data was found.');
        else
            str = sprintf('\nINFO: Field drawerobj.disp(%u).datasize set to %u.', splot, drawerobj.disp(splot).datasize);
            fprintf(str);
        end;
    end;
end;

% check whether there are labels beyond datasize
if (~isempty(drawerobj.seglist)) && (drawerobj.seglist(end,2) > max([drawerobj.disp(1:drawerobj.subplots).datasize]))
	str = sprintf('\nWARNING: Found labels that exceed the maximum datasize. Added some dummy data at the end.');
	fprintf(str);
	warnmsg = [warnmsg str];
    for iSP = 1:drawerobj.subplots
        newSiz = drawerobj.seglist(end,2)+1 ;
        drawerobj.disp(iSP).data(end+1:newSiz,:) = 0 ;
        drawerobj.disp(iSP).datasize = newSiz ;
    end
end;



% save field
if (~isfield(drawerobj.disp, 'save'))
	[drawerobj.disp(1:drawerobj.subplots).save] = deal([]);
end;
for splot = 1:drawerobj.subplots
	if isempty(drawerobj.disp(splot).save) || (~islogical(drawerobj.disp(splot).save))
		drawerobj.disp(splot).save = true;
	end;
end;


% data sampling rate setting
% Marker does currently NOT support different values here! Although
% parameters definition would suggest it. Correct if needed.
if (~isfield(drawerobj.disp, 'sfreq')) || isempty(drawerobj.disp(1).sfreq)
    error('Field drawerobj.disp(1).sfreq missing or empty.'); 
end;
for splot = 1:drawerobj.subplots
    if (~isfield(drawerobj.disp, 'sfreq')) || isempty(drawerobj.disp(splot).sfreq)
        str = sprintf('\nWARNING: Field drawerobj.disp(%u).sfreq not found or empty, using %uHz.', splot, drawerobj.disp(1).sfreq);
        fprintf(str);
        warnmsg = [warnmsg str];
        drawerobj.disp(splot).sfreq = drawerobj.disp(1).sfreq;
    end;
end;
if (length(unique([drawerobj.disp(1:drawerobj.subplots).sfreq])) > 1)
    str = sprintf('\nWARNING: Different values for drawerobj.disp().sfreq not supported, using %uHz.', drawerobj.disp(1).sfreq);
    fprintf(str);
    warnmsg = [warnmsg str];
    [drawerobj.disp(1:drawerobj.subplots).sfreq] = deal(drawerobj.disp(1).sfreq);
end;


% label sampling rate setting
% Marker does currently NOT support values different from data rate! Correct if needed.
if (~isfield(drawerobj, 'labelsfreq')) || isempty(drawerobj.labelsfreq) || (drawerobj.labelsfreq ~= drawerobj.disp(1).sfreq)
    fprintf('\nINFO: Field drawerobj.labelsfreq not found or wrong setting, using %uHz.', drawerobj.disp(1).sfreq);
    drawerobj.labelsfreq = drawerobj.disp(1).sfreq;
end;


% this is for DEBUGING purposes only
if ~isfield(drawerobj.disp, 'xdynoffset')
    [drawerobj.disp(1:drawerobj.subplots).xdynoffset] = deal(0); 
end;


% dynamic load mode fields
if (~isfield(drawerobj.disp, 'loadfunc')), drawerobj.disp(drawerobj.subplots).loadfunc = []; end;
if (~isfield(drawerobj.disp, 'loadfunc_filename')), drawerobj.disp(drawerobj.subplots).loadfunc_filename = []; end;
if (~isfield(drawerobj.disp, 'loadfunc_params'))
	%drawerobj.disp(splot).loadfunc_params = {}; 
	[drawerobj.disp(1:drawerobj.subplots).loadfunc_params] = deal({}); 
end;
for splot = 1:drawerobj.subplots
    if (~iscell(drawerobj.disp(splot).loadfunc_params)) 
        fprintf('\nINFO: Field drawerobj.disp(%u).loadfunc_params converted to cell array.', splot);
        drawerobj.disp(splot).loadfunc_params = {drawerobj.disp(splot).loadfunc_params}; 
    end;
    
    if (~isempty(drawerobj.disp(splot).loadfunc)) && isempty(drawerobj.disp(splot).data)
        % configure for dynamic load mode
        drawerobj.disp(splot).loadfunc_dynrange = [0 0];
    else
        drawerobj.disp(splot).loadfunc_dynrange = [1 drawerobj.disp(splot).datasize]; 
    end;
    
    if (~isempty(drawerobj.disp(splot).loadfunc)) && isempty(drawerobj.disp(splot).loadfunc_filename)
        fprintf('\nERROR: Field drawerobj.disp(%u).loadfunc is set, but loadfunc_filename is not.', splot);
        error('Configuration error: Dynamic load mode');
    end;
end;


% ylim field
if (~isfield(drawerobj.disp, 'ylim')), drawerobj.disp(1).ylim = []; end;
for splot = 1:drawerobj.subplots
	if isempty(drawerobj.disp(splot).ylim) && (~strcmpi(drawerobj.disp(splot).type, 'segments'))
		fprintf('\nINFO: Field drawerobj.disp(%u).ylim not found or empty, guessing.', splot);
		%[drawerobj.disp(1:drawerobj.subplots).ylim] = deal([0 1]);
		drawerobj = marker_guessylim(drawerobj, splot);
	end;
end;


% xvisible field
for splot = 1:drawerobj.subplots
	if (~isfield(drawerobj.disp, 'xvisible')) || isempty(drawerobj.disp(splot).xvisible)
		drawerobj.disp(splot).xvisible = 100 * drawerobj.disp(splot).sfreq;
		fprintf('\nINFO: Field drawerobj.disp(%u).xvisible not found - setting initial view to %.1fs.', ...
			splot, drawerobj.disp(splot).xvisible/drawerobj.disp(splot).sfreq);
	end;

	if (drawerobj.disp(splot).xvisible < 1)
		drawerobj.disp(splot).xvisible = 2;
		fprintf('\nINFO: Field drawerobj.disp(%u).xvisible set to %u samples.', splot, drawerobj.disp(splot).xvisible);
	end;
	if (drawerobj.disp(splot).xvisible-floor(drawerobj.disp(splot).xvisible))>0
		drawerobj.disp(splot).xvisible = round(drawerobj.disp(splot).xvisible);
		fprintf('\nINFO: Field drawerobj.disp(%u).xvisible has fraction, set to %u samples.', splot, drawerobj.disp(splot).xvisible);		
	end;
end;
if (length(unique([drawerobj.disp(1:drawerobj.subplots).xvisible])) > 1)
    fprintf('\nINFO: Different values for drawerobj.disp().xvisible not supported, using %u samples.', drawerobj.disp(1).xvisible);
    [drawerobj.disp(1:drawerobj.subplots).xvisible] = deal(drawerobj.disp(1).xvisible);
end;

% adapt display range and create initial view xrange
% xvisible is same for all plots!
maxdatasize = max([drawerobj.disp(1:drawerobj.subplots).datasize]);
if any(([drawerobj.disp(1:drawerobj.subplots).xvisible]) > maxdatasize)
    [drawerobj.disp(1:drawerobj.subplots).xvisible] = deal(maxdatasize);
end;
[drawerobj.disp(1:drawerobj.subplots).xrange] = deal([1 drawerobj.disp(splot).xvisible]);



% ylabel field
for splot = 1:drawerobj.subplots
	% compatibility preprocessing for version < 0.6.0
	if (isfield(drawerobj.disp, 'ylabel')) && iscell(drawerobj.disp(splot).ylabel)
		fprintf('\nINFO: Removed cell from field drawerobj.disp(%u).ylabel.', splot);
		drawerobj.disp(splot).ylabel = drawerobj.disp(splot).ylabel{:};
	end;

	% default processing
	if (~isfield(drawerobj.disp, 'ylabel')) || isempty(drawerobj.disp(splot).ylabel)
		if (isfield(drawerobj.disp, 'type')) && (~isempty(drawerobj.disp(splot).type)) && ischar(drawerobj.disp(splot).type)
			drawerobj.disp(splot).ylabel = drawerobj.disp(splot).type;
		else
			drawerobj.disp(splot).ylabel = ['Plot ' num2str(splot)];
		end;
		fprintf('\nINFO: Field drawerobj.disp(%u).ylabel set to %s.', splot, drawerobj.disp(splot).ylabel);
	end;
end;



% plot function
for splot = 1:drawerobj.subplots
	% drawerobj.disp(splot).ylabel, compatibility for version < 0.8.1
	if (isfield(drawerobj.disp, 'func')) && (~isempty(drawerobj.disp(splot).func))
		fprintf('\nINFO: Converted field drawerobj.disp(%u).func to field plotfunc.', splot);
		drawerobj.disp(splot).plotfunc = drawerobj.disp(splot).func;
	end;

	if (~isfield(drawerobj.disp, 'plotfunc')) || (~isa(drawerobj.disp(splot).plotfunc, 'function_handle'))
		%fprintf('\nINFO: Field plotfunc not found for drawerobj.disp(%u).', splot);
		drawerobj.disp(splot).plotfunc = @plot;
	end;
end;

% add 'LineWidth'=2 for better visibility
if (~isfield(drawerobj.disp, 'plotfunc_params'))
	[drawerobj.disp(1:drawerobj.subplots).plotfunc_params] = deal({'LineWidth', 2});
end;
for splot = 1:drawerobj.subplots
	if isempty(drawerobj.disp(splot).plotfunc_params)
		drawerobj.disp(splot).plotfunc_params = {'LineWidth', 2};
	end;
	
	if (~iscell(drawerobj.disp(splot).plotfunc_params))
		drawerobj.disp(splot).plotfunc_params = {drawerobj.disp(splot).plotfunc_params};
	end;
end;
% extended calling mode: this is used for marker-specific plotters
if (~isfield(drawerobj.disp, 'plotfunc_extmode'))
	[drawerobj.disp(1:drawerobj.subplots).plotfunc_extmode] = deal(false);
end;
for splot = 1:drawerobj.subplots
	if isempty(drawerobj.disp(splot).plotfunc_extmode), drawerobj.disp(splot).plotfunc_extmode = false; end;
end;


% edit'n'play
if ~isfield(drawerobj, 'editnplay'), drawerobj.editnplay = false; end;


% time axis configuration
if ~isfield(drawerobj, 'timeaxisunits'), drawerobj.timeaxisunits = 'seconds'; end;
drawerobj = marker_timeaxisunits([], drawerobj);


% estimate signal count
% dynamic load mode should be configured/checked beforehand
for splot = 1:drawerobj.subplots
	switch lower(drawerobj.disp(splot).type)
		case 'segments'
			drawerobj.disp(splot).signalcount = 1;
		otherwise
			drawerobj.disp(splot).signalcount = size(marker_getdatafrombuffer([], drawerobj, splot, [1 2]),2);
	end;
    
    if (drawerobj.disp(splot).signalcount <= 0)
        fprintf('\nERROR: No data found for plot %u.', splot);
        error('No data was found for at least one plot.');
    end;
end;


% manage signal show/hide
for splot = 1:drawerobj.subplots
	if (~isfield(drawerobj.disp, 'hidesignal')) || isempty(drawerobj.disp(splot).hidesignal)
		drawerobj.disp(splot).hidesignal = repmat(false, 1,drawerobj.disp(splot).signalcount);
	end;

	if (length(drawerobj.disp(splot).hidesignal) ~= drawerobj.disp(splot).signalcount)
		fprintf('\nINFO: Malformat settings for drawerobj.disp(%u).hidesignal, ignored.', splot);
		drawerobj.disp(splot).hidesignal = repmat(false, 1,drawerobj.disp(splot).signalcount);
	end;
end;


% manage signal names
for splot = 1:drawerobj.subplots
	% disp().legend is an alternative name for disp().signalnames convert it 
	if isfield(drawerobj.disp, 'legend') && (~isempty(drawerobj.disp(splot).legend))
		drawerobj.disp(splot).signalnames = drawerobj.disp(splot).legend;
		fprintf('\nINFO: Use of field legend is depricated, converted to drawerobj.disp(%u).signalnames', splot);		
	end;
	
	if (~isfield(drawerobj.disp, 'signalnames')) || isempty(drawerobj.disp(splot).signalnames)
		%drawerobj.disp(splot).signalnames = cell(drawerobj.disp(splot).signalcount,1);
		for i = 1:drawerobj.disp(splot).signalcount
			drawerobj.disp(splot).signalnames{i} = sprintf('Signal %u', i);
		end;
	end;

	if (~iscell(drawerobj.disp(splot).signalnames)) || (max(cellfun('size', drawerobj.disp(splot).signalnames,2)) > 20) || ...
			(length(drawerobj.disp(splot).signalnames) ~= drawerobj.disp(splot).signalcount)

		fprintf('\nINFO: Malformat settings for drawerobj.disp(%u).signalnames, ignored.', splot);
		%drawerobj.disp(splot).signalnames = cell(drawerobj.disp(splot).signalcount,1);
		for i = 1:drawerobj.disp(splot).signalcount
			drawerobj.disp(splot).signalnames{i} = sprintf('Signal %u', i);
		end;
	end;
end;
if isfield(drawerobj.disp, 'legend')
	drawerobj.disp = rmfield(drawerobj.disp, 'legend');
end;



% manage plot show/hide
drawerobj.visibleplots = drawerobj.subplots;
for splot = 1:drawerobj.subplots
	if (~isfield(drawerobj.disp, 'hideplot')) || isempty(drawerobj.disp(splot).hideplot) 
		drawerobj.disp(splot).hideplot = false;
	end;
    
	if (~islogical(drawerobj.disp(splot).hideplot))
		drawerobj.disp(splot).hideplot = false;
		fprintf('\nINFO: Malformat settings for drawerobj.disp(%u).hideplot, ignored.', splot);
	end;

	if (drawerobj.disp(splot).hideplot == true)
		drawerobj.visibleplots = drawerobj.visibleplots -1;
	end;
end;


% manage label show/hide
for splot = 1:drawerobj.subplots
	if (~isfield(drawerobj.disp, 'showlabels')) || isempty(drawerobj.disp(splot).showlabels)
		drawerobj.disp(splot).showlabels = true(1,drawerobj.maxLabelNum);
	end;

	if (~islogical(drawerobj.disp(splot).showlabels)) || ...
			(length(drawerobj.disp(splot).showlabels) ~= drawerobj.maxLabelNum)
		%(~isnumeric(drawerobj.disp(splot).showlabels)) || ...

		fprintf('\nINFO: Malformat settings for drawerobj.disp(%u).showlabels, ignored.', splot);
		drawerobj.disp(splot).showlabels = true(1,drawerobj.maxLabelNum);
	end;
end;


% assign names to the subplot, thus creating a match (see marker_viewer.m)
% between the data in drawerobj.disp(splot) and the subplot which will
% display this data  
% -> this allows the viewer to handle any configuration of axes (and not only subplot commands)
% -> this also allows to handle different data types in the viewer (e.g. movies and pictures)
%    by giving them a different name (e.g. drawerobj.disp(i).plotTag = 'myMoviePlot')
for splot = 1:drawerobj.subplots
	if (~isfield(drawerobj.disp, 'plotTag')) || isempty(drawerobj.disp(splot).plotTag)
		drawerobj.disp(splot).plotTag = sprintf('defaultdataplot%02u',splot);
	end;
end;


% create handler for main window display
drawerobj.statusAxesTag = 'statusaxes';
drawerobj.statusTextTag = 'statustext';


% control display of label text, modes are: 'auto', 'simple', 'name', 'none'
if (~isfield(drawerobj, 'labeltextstyle')), drawerobj.labeltextstyle = 'auto'; end;

% control label colormap: 
% - common coloring for all plots: common 
% - plot individual coloring colormap: single
if (~isfield(drawerobj, 'labelcolormap'))
	drawerobj.labelcolormap = 'common';
else
	if (~ischar(drawerobj.labelcolormap))
		fprintf('\nINFO: Field drawerobj.labelcolormap should be string, ignoring.');
		drawerobj.labelcolormap = 'common';
	end;
end;



% label overlap check on/off
if (~isfield(drawerobj, 'labelovcheck')), drawerobj.labelovcheck = false; end;

% pointer press panning on/off
if (~isfield(drawerobj, 'pointerpan')), drawerobj.pointerpan = true; end;

% player configuration
if (~isfield(drawerobj.disp, 'playerdata')), drawerobj.disp(1).playerdata = []; end;
if (~isfield(drawerobj.disp, 'playerselect')), drawerobj.disp(1).playerselect = 0; end;
for splot = 1:drawerobj.subplots
	if isempty(drawerobj.disp(splot).playerdata), continue; end;

	% default play source is first element in playerdata array (if any)
	if isempty(marker_findoverlap([1 length(drawerobj.disp(splot).playerdata)], repmat(drawerobj.disp(splot).playerselect,1,2)))
        drawerobj.disp(splot).playerselect = 1;
		fprintf('\nINFO: Field drawerobj.disp(%u).playerselect out of range, corrected.', splot);
	end;

	if (~isfield(drawerobj.disp(splot).playerdata, 'playerfun')), drawerobj.disp(splot).playerdata(1).playerfun = []; end;
	if (~isfield(drawerobj.disp(splot).playerdata, 'title')), drawerobj.disp(splot).playerdata(1).title = ''; end;
	
	% scan through list of configured players
	for p = 1:length(drawerobj.disp(splot).playerdata)
		if isempty(drawerobj.disp(splot).playerdata(p).playerfun)
			str = sprintf('\nWARNING: No player method configured for plot %u, player %u.', splot, p);
			fprintf(str);
			warnmsg = [warnmsg str];
		end;
		if isempty(drawerobj.disp(splot).playerdata(p).title)
			drawerobj.disp(splot).playerdata(p).title = 'NONAME'; 
		end;
	end;
end;



% initial window size scaling factors (at startup); [width height]
% On some X systems window size is not adjusted to displayable bounds.
% Parameter screensize can be used to achieve this, e.g. for a
% 1024x768 screen: [ 4 29 1018 716 ] may be applicable. 
% get(1, 'OuterPosition')
if (~isfield(drawerobj, 'windowsizescaling')), drawerobj.windowsizescaling = [1 0.95]; end;
if (length(drawerobj.windowsizescaling)<2) || (max(drawerobj.windowsizescaling)>1)
	fprintf('\nINFO: Malformat settings for drawerobj.windowsizescaling, ignored.');
	drawerobj.windowsizescaling = [1 0.95];
end;
% window orientation: full, classic, center, top
if (~isfield(drawerobj, 'windoworientation')) || (~ischar(drawerobj.windoworientation))
    drawerobj.windoworientation = 'top'; 
end;
% screen size setting
if (~isfield(drawerobj, 'screensize')) || isempty(drawerobj.screensize)
	drawerobj.screensize = get(0,'screensize');   % left, bottom, width, height; 
end;
if (length(drawerobj.screensize)<4) 
	fprintf('\nINFO: Malformat settings for drawerobj.screensize, ignored.');
	drawerobj.screensize = get(0,'screensize');   % left, bottom, width, height; 
end;


% cmdqueue_maxsize
if (~isfield(drawerobj, 'cmdqueue_maxsize')) || isempty(drawerobj.cmdqueue_maxsize)
	drawerobj.cmdqueue_maxsize = 1;
end;


% functions can be overloaded by pre-configuration of drawerobj fields
% none at this time
