function [new_alignsps obj deltasps] = marker_resampler(obj, splot, deltasps)
% function [new_alignsps obj deltasps] = marker_resampler(obj, splot, deltasps)
%
% Generic data resampling method for Marker
% Align data streams (plots) by resampling data (relative sampling rate
% stored in disp.alignsps) by the increment provided in parameter deltasps. 
% All display methods that read xrange must support alignments to make this
% work correctly (disp.sfreq contains the absolute sampling rate).
%
% Method will adapt disp.xrange and .xrange_vis by the plot-specific 
% disp.alignsps value. Viewer needs to read disp.sfreq and adapt data
% accordingly.


% -------------------------------------------------------------------
% Copyright 2006 Oliver Amft, ETH Zurich, Wearable Computing Lab.
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


if isempty(splot) splot = 1:obj.subplots; end;

if (max(size(deltasps)) < length(splot))
    deltasps = repmat(deltasps, length(splot), 1);
end;

new_alignsps = [];
for nsp = 1:length(splot)
    sp = splot(nsp);

    if (~isfield(obj.disp(sp), 'alignsps')) | ...
        isempty(obj.disp(sp).alignsps) | isnan(obj.disp(sp).alignsps) | ...
        (abs(obj.disp(sp).alignsps)>=inf)
        
        obj.disp(sp).alignsps = 0;
    end;

    new_alignsps(nsp) = obj.disp(sp).alignsps + round(deltasps(nsp)*100)/100;
    %fprintf(' newsps: %s', mat2str(newsps));

    if abs(new_alignsps(nsp))>=inf
        new_alignsps(nsp) = 0;
    end;
    
    % write back to obj structure
    obj.disp(sp).alignsps = new_alignsps(nsp);
end; % for nsp
