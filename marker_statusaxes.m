function drawerobj = marker_statusaxes(fh, drawerobj, string)
% function marker_statusaxes(fh, drawerobj)
% 
% Print status line in main window. Parameter string is optional.

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

% text sizes for label and label text
TextFontSize = 14;
%HideLogTexts = {};
HideLogTexts = {'Busy...'};  % , 'Ready'

% in most cases status axes is deleted by re-drawing the window
th = findobj(fh, 'Tag', drawerobj.statusAxesTag);
if isempty(th) 
	axes('Position' , [0 0 1 1], 'Visible', 'off', 'Tag', drawerobj.statusAxesTag);
end;

%set(fh, 'CurrentAxes', th);

% use string when available and make it current status text
if exist('string', 'var') && (~isempty(string)) 
	drawerobj.eventdata.statuslinetext = string; 
end;

% in most cases status text is deleted by re-drawing the window
th = findobj(fh, 'Tag', drawerobj.statusTextTag);
if isempty(th)
	text(0.5, 0.03, ...
		drawerobj.eventdata.statuslinetext, 'Tag', drawerobj.statusTextTag, ...
		'Interpreter', 'none', 'HorizontalAlignment', 'center', ...
		'FontSize', TextFontSize, 'FontWeight', 'bold'); % 'FontName', 'FixedWidth', 
else
	set(th, 'String', drawerobj.eventdata.statuslinetext);
end;

% needed for drawing/handling callbacks on Windows platforms
drawnow;

% log string
if isempty(strmatch(drawerobj.eventdata.statuslinetext, HideLogTexts, 'exact'))
	marker_log(fh, '\n%s: %s', mfilename, drawerobj.eventdata.statuslinetext);
end;
