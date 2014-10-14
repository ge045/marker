function [splot tag] = marker_findselectedplot(fh, drawerobj)
% function [splot tag] = marker_findselectedplot(fh, drawerobj)
% 
% Determine subplot that is selected, e.g. by pointer button press.
% Default=last plot

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

splot = [];

% try 
% 	tag = get(gco(fh),'Tag'); 
% catch
% 	tag = '';
% end;

tag = get( get(fh, 'CurrentAxes'), 'Tag');
if isempty(tag), return; end;

splot = strmatch(tag, {drawerobj.disp(1:drawerobj.subplots).plotTag}, 'exact');
