function marker_errorhandler(fh, drawerobj, userdata)
% function marker_errorhandler(fh, drawerobj, userdata)
% 
% Handles MARKER errors.

% Copyright 2007-2008 Oliver Amft

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


% May be called when figure is already destroyed, e.g. by marker_quitprogram.
% Then, fh may still contain the 'old' content since errorhandler is called from marker_dispatcher, if 
% marker_quitprogram failed. Check whether Matlab still considers the figure as valid child.
if ~isempty(fh)
	fhlist = get(0, 'Children');
	if ~any(fhlist==fh),  fh = []; end;
	if strcmpi(get(fh, 'BeingDeleted'), 'on'), fh = []; end; % prevent reinitialisation below	
end;

if (~exist('userdata','var')), userdata = []; end;
if (~exist('drawerobj','var')), drawerobj = []; end;


% read out error log and format it
errorlog = lasterror;
errorstr = [];
errorstr = [errorstr sprintf('\n>>> Cut error log here <<<')];
errorstr = [errorstr sprintf('\n%s', repmat('-', 1,80))];
errorstr = [errorstr sprintf('\n%s: An error occurred while running MARKER.', mfilename)];
errorstr = [errorstr sprintf('\n%s: MARKER version %s', mfilename, marker_version)];
errorstr = [errorstr sprintf('\n%s: %s', mfilename, datestr(now))];
errorstr = [errorstr sprintf('\n%s', repmat('-', 1,80))];

if ~isempty(drawerobj)
	errorstr = [errorstr sprintf('\nSystem configuration:')];
	errorstr = [errorstr sprintf('%s%s', evalc('drawerobj'), evalc('drawerobj.eventdata'))];
	for splot = 1:drawerobj.subplots
		tmp = drawerobj.disp(splot);
		errorstr = [errorstr sprintf('%s', evalc('tmp'))];
	end;
else
	errorstr = [errorstr sprintf('\nSystem core data corrpted.')];
end;
errorstr = [errorstr sprintf('\n')];

if ~isempty(fh)
	errorstr = [errorstr sprintf('\nFigure handle is intact.')];
else
	errorstr = [errorstr sprintf('\nFigure handle was deleted or corrupted.')];
end;
errorstr = [errorstr sprintf('\n')];

errorstr = [errorstr sprintf('\nError message : %s', errorlog.message)];
errorstr = [errorstr sprintf('\nError identifier: %s', errorlog.identifier)];

if isfield(errorlog, 'stack')
    errorstr = [errorstr sprintf('\nError stack trace:')];
    for i = 1:length(errorlog.stack)
        tmp = errorlog.stack(i);
        errorstr = [errorstr sprintf('%s', evalc('tmp'))];
    end;
end;

if ~isempty(userdata), errorstr = [errorstr sprintf('\nUserdata: \n%s', mat2str(userdata))]; end;

errorstr = [errorstr sprintf('\n')];
errorstr = [errorstr sprintf('\n')];
errorstr = [errorstr sprintf('\nPlease report this problem to the MARKER toolbox developers at:')];
errorstr = [errorstr sprintf('\n  mailing list: marker@list.ee.ethz.ch, maintainer: oam@ife.ee.ethz.ch')];
errorstr = [errorstr sprintf('\nPlease include the complete error message and a brief summary of')];
errorstr = [errorstr sprintf('\nyour last activities.')];
errorstr = [errorstr sprintf('\n')];
errorstr = [errorstr sprintf('\nSave your work and restart MARKER before continuing.')];
errorstr = [errorstr sprintf('\n')];

% cleanups
if (~isempty(fh)) && (~isempty(drawerobj))
	set(fh, 'resize', 'on');
	drawerobj.eventdata.statuslinetext = 'Ready';
	drawerobj = marker_draw(fh, drawerobj);
	set(fh, 'Pointer', 'arrow');
	drawerobj.eventdata.dispatcherlock = false;
	set(fh, 'UserData', drawerobj);
	set(fh, 'Interruptible', 'on');
end;

% fprintf(errorstr);
error(errorstr);
%rethrow(errorlog);
