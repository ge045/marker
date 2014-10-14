function drawerobj = marker_guessylim(drawerobj, splotlist)
% function drawerobj = marker_guessylim(drawerobj, splotlist)
%
% Guess a ylim field from data

% Copyright 2005, 2006 Oliver Amft, ETH Zurich, Wearable Computing Lab.

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

spreadfactor = 3; % controls the number of SDs displayed

% guess on all plots if none specified
if (exist('splotlist','var')~=1), splotlist = 1:drawerobj.subplots; end;

for splot = splotlist
    if (~isfield(drawerobj.disp, 'ylim')) || (isempty(drawerobj.disp(splot).ylim)) || (diff(drawerobj.disp(splot).ylim) == 0)
        drawerobj.disp(splot).ylim = [-1 1];   % default
    end;

    % get estimate if data is available in memory (NOT dynamic load mode)
    if isempty(drawerobj.disp(splot).loadfunc)
        % get some probing data
        pdata = marker_getdatafrombuffer([], drawerobj, splot, [1 drawerobj.disp(splot).datasize]);

        if find(isnan(pdata)>0)
            marker_log([], '\n%s: Data contains NaNs. Could not esitmate.', mfilename);
            continue; 
        end;
        
        dsd = std(pdata);
        dmean = mean(pdata);

        if min(pdata) < 0
            drawerobj.disp(splot).ylim = [min(dmean - spreadfactor*dsd) max(dmean + spreadfactor*dsd)];
            continue;
        end;
        if dsd ~= 0
            drawerobj.disp(splot).ylim = [0 max(dmean + spreadfactor*2*dsd)];
            continue;
        end;
        
        % default: keep setting

    else
        marker_log([], '\n%s: Plot %u: Could not esitmate.', mfilename, splot);
    end;
    
end; % for splot

%[drawerobj.disp(1:drawerobj.subplots).ylim] = deal([0 1]);
