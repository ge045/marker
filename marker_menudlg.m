function values = marker_menudlg(fh, drawerobj, mode, message, title, varargin)
% function values = marker_menudlg(fh, drawerobj, mode, message, title, varargin)
%
% Display popup menu and return choices.
% 
% General issue with *listdlg modes using Matlab GUI functions: One item
% must be selected. To deselect ALL items from the list, use console mode.

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

% Copyright 2007 Oliver Amft, Wearable Computing Lab., ETH Zurich


values = [];

if ~exist('message', 'var'), message = ''; end;
if ~exist('title', 'var'), title = ''; end;

set(fh, 'Interruptible', 'off'); % lock for now

if (drawerobj.consolemenus)
	% use text output, no GUIs
	% hack to bring command shell to foreground
	commandwindow; pause(0.1); commandwindow;
	
	% OAM REVISIT: How to force fixed width font?
	switch lower(mode)
		case 'errordlg'
			fprintf('\n --- ERROR %s ---\n', title);
			fprintf(message);
			fprintf('\n%s\n', repmat('-', 1, length(title)+14));
		case 'warndlg'
			fprintf('\n --- WARNING %s ---\n', title);
			fprintf(message);
			fprintf('\n%s\n', repmat('-', 1, length(title)+14));
			
			%marker_log(fh, '\nERROR: %s\n', message);
		case 'infodlg'
			fprintf('\n --- INFO %s ---\n', title);
			fprintf(message);
			fprintf('\n%s\n', repmat('-', 1, length(title)+14));
		case 'questdlg'
			fprintf('\n --- QUESTION %s ---\n', title); 
			fprintf(['\n %s: %s' repmat('/%s ', 1, length(varargin)-2) ' [%s]: '], message, varargin{:});
			reply = input(' ','s');
			values = evaluserinput(reply, varargin);

		case 'inputdlg'
			message = cellstr(message);
			[ reply{length(message)} ] = deal('');
			fprintf('\n --- %s ---\n', title); 
			for i = 1:length(message)
				fprintf('\n%s (0=cancel): ', message{i});
				fprintf('\n (Default=''%s'') >>', varargin{1}{i});	
				reply{i} = input(' ', 's');
				if (reply{i}=='0'), set(fh, 'Interruptible', 'on'); return; end;
				if isempty(reply{i}),  reply{i} = varargin{1}{i}; end;
			end;
			values = reply;
				
		case {'menudlg'}
			fprintf('\n --- %s ---\n', title); 
			fprintf('\n%s:', message); 
			for i = 1:length(varargin)
				fprintf('\n %2u: %s', i, varargin{i});
			end;
			fprintf('\n 0: Exit menu');
			fprintf('\n  >>');	reply = input(' ');
			if isempty(reply) || (~isnumeric(reply)) || (reply==0) 
				set(fh, 'Interruptible', 'on'); return; 
			end;
			values = reply;

		case 'singlelistdlg'
			values = varargin{2}; % 2nd param holds selection list
			fprintf('\n --- %s ---\n', title); 
			fprintf('\n%s (%u..%u):', message, 1, length(varargin{1})); 
			for i = 1:length(varargin{1})
				 if rem(i,2), fprintf('\n'); end;
				 if (i==values), sel = '*'; else sel = ' '; end;
				fprintf(' %3u: %20s%1s', i, varargin{1}{i}, sel);
			end;
			if (values==0), sel = '*'; else sel = ' '; end;
			fprintf('\n %3u: %20s%1s', 0, 'Cancel', sel);
			while (1)
				fprintf('\n (*=Default) >>');	reply = input(' ');
				if isempty(reply) || (~isnumeric(reply)),  set(fh, 'Interruptible', 'on'); return; end; 
				if (reply < 0) || (reply > length(varargin{1})), continue; end;
				break;
			end;
			values = reply;
			
		case 'multiplelistdlg'
			% last param holds selection list
			values = varargin{2};
			fprintf('\n --- %s ---\n', title); 
			if (length(varargin{1}) < 2),  values = 1; set(fh, 'Interruptible', 'on'); return; end;
			valuemap = zeros(1, length(varargin{1})); valuemap(values) = 1;
			while (1)
				fprintf('\n%s:', message);
				for i = 1:length(varargin{1})
					if rem(i,2), fprintf('\n'); end;
					if (valuemap(i)), sel = 'on'; else sel = 'off'; end;
					fprintf(' %3u: %20s %10s', i, varargin{1}{i}, sel);
				end;
				fprintf('\n %3u: %20s', 0, 'Exit');
				fprintf('\n >>');	reply = input(' ');
				if (reply == 0),  break; end; % way out
				if isempty(reply) || (~isnumeric(reply)) || (reply<0) || (reply>length(varargin{1}))
					continue; 
				end;
				valuemap(reply) = ~valuemap(reply);
			end;
			values = find(valuemap>0);
			
			
	end;
	%figure(fh);

else
	% use graphical output
	switch lower(mode)
		case 'errordlg'
			h = errordlg(message, title);
            if ishandle(h), uiwait(h); end; % ishandle hack for slow X window systems (or fast operators)
		case 'warndlg'
			h = warndlg(message, title);
            if ishandle(h), uiwait(h); end; % ishandle hack for slow X window systems (or fast operators)
		case 'infodlg'
			h = msgbox(message, title, 'help');
			%set(get(h, 'Children'), 'FontName', 'FixedWidth');
            if ishandle(h), uiwait(h); end; % ishandle hack for slow X window systems (or fast operators)
		case 'questdlg'
			values = questdlg(message, title, varargin{:});
		case 'inputdlg'
			values = inputdlg(message, title, 1, varargin{:});
		case 'menudlg'
			reply = menu(message, varargin{:}, 'Exit menu');
			if (reply > length(varargin)), set(fh, 'Interruptible', 'on'); return; end;
			values = reply;
			
		case 'singlelistdlg'
			% 2nd param holds selection list
			values = varargin{2};
			if (length(varargin{1}) < 2),  values = 1; set(fh, 'Interruptible', 'on'); return; end;
			[reply ok] = listdlg('Name', title, 'PromptString', message, ...
				'SelectionMode', 'single', 'ListSize', [240 450], ...
                'ListString', varargin{1}, 'InitialValue', varargin{end});
			if (~ok), values = 0; set(fh, 'Interruptible', 'on'); return; end;
			values = reply;

		case 'multiplelistdlg'
			% last param holds selection list
			values = varargin{2};
			if (length(varargin{1}) < 2),  values = 1; set(fh, 'Interruptible', 'on'); return; end;
			[reply ok] = listdlg('Name', title, 'PromptString', message, ...
				'SelectionMode', 'multiple', 'ListString', varargin{1}, ...
				'InitialValue', varargin{end});
			if (~ok), values = 0; set(fh, 'Interruptible', 'on'); return; end;
			values = reply;

	end;
end;

set(fh, 'Interruptible', 'on');
end


% check and match user input to selection for questdlg
function value = evaluserinput(reply, choices)
if isempty(reply)
	value = choices{end};
else
	reply = strmatch(lower(reply), lower(choices(1:end-1)));
	if isempty(reply) || (length(reply)>1)
		value = choices{end};
	else
		value = choices{reply};
	end;
end;
end



