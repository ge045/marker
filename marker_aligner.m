function [new_alignshift obj shift] = marker_aligner(obj, splot, shift)
% function [new_alignshift obj shift] = marker_aligner(obj, splot, shift)
%
% Generic data alignment method for Marker
% Align data streams (plots) by shifting data (absolute shift stored in 
% disp.alignshift) by the increment provided in parameter shift. All
% display methods that read xrange must support alignments to make this
% work correctly (adapt xrange by the plot-specific disp.alignshift value).

% Copyright 2006 Oliver Amft, ETH Zurich, Wearable Computing Lab.

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


if isempty(splot), splot = 1:obj.subplots; end;
if (max(size(shift)) < length(splot))
    shift = repmat(shift, length(splot), 1);
end;

new_alignshift = zeros(1, length(splot));
for nsp = 1:length(splot)
    sp = splot(nsp);

    if (~isfield(obj.disp(sp), 'alignshift')) || ...
        isempty(obj.disp(sp).alignshift) || isnan(obj.disp(sp).alignshift) || ...
        (abs(obj.disp(sp).alignshift)>=inf) || (obj.disp(sp).alignshift<0)
        
        obj.disp(sp).alignshift = 0;
    end;

    new_alignshift(nsp) = obj.disp(sp).alignshift+shift(nsp);
    %fprintf(' nrange: %s', mat2str(nrange));

    if (abs(new_alignshift(nsp))>=inf) || (new_alignshift(nsp)<0)
        new_alignshift(nsp) = 0;
    end;
    
    % write back to obj structure
    obj.disp(sp).alignshift = new_alignshift(nsp);
end; % for sp
