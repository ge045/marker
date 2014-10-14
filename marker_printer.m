function marker_printer(fh, drawerobj)
% function marker_printer(fh, drawerobj)
%
% Generic Marker printer method
% Print out all labels

% Copyright 2005, 2006 Oliver Amft, ETH Zurich, Wearable Computing Lab.
% Copyright 2005 Georg Ogris, UMIT CSN Innsbruck

% -------------------------------------------------------------------
%
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
%
% -------------------------------------------------------------------


% if (~isfield(drawerobj, 'printscaler')) drawerobj.printscaler = 1; end;

% configure your favorite print function here
% fprintf('%s', ... 
%     classlabels2str(segments2classlabels(drawerobj.maxLabelNum, drawerobj.seglist), drawerobj.printscaler));

% disp(drawerobj.seglist);

for i = 1:size(drawerobj.seglist,1)
    fprintf('\n%10u %10u %10u %2u %3u %1u', ...
        drawerobj.seglist(i,1), drawerobj.seglist(i,2), drawerobj.seglist(i,3), ...
        drawerobj.seglist(i,4), drawerobj.seglist(i,5), drawerobj.seglist(i,6));
end;
fprintf('\n');
