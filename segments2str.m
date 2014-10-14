function str = segments2str(seglist, scaler)
% function str = segments2str(seglist, scaler)
% 
% Convert segment list to string
% 
% scaler   optional, rescale samples in segment list
% 
% See also labeling2segments, segments2labeling, segments2classlabels.

% Copyright 2005 Georg Ogris, UMIT CSN Innsbruck
% Copyright 2005 Oliver Amft, ETH Zurich, Wearable Computing Lab.

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

if (exist('scaler','var')~=1), scaler = 1; end;

str = '';

str = [str sprintf('\n seg_list = [ ...\n    ')];

for row=1:size(seglist,1)
    %if (~rem(row, 1)) str = [str sprintf(' ...\n    ')]; end;
    
    % instead of the timestamp, use the sample numbers
    % sprintf('%.0f %.0f %.0f %.0f; '
    str = [str sprintf('%.0f %.0f %.0f %u %u %.2f; ', ...
        seglist(row, 1)/scaler, ...
        seglist(row, 2)/scaler, ...
        seglist(row, 3)/scaler, ...
        seglist(row, 4), ...
        seglist(row, 5), ...
        seglist(row, 6) )];
    
    if (row < size(seglist,1)) str = [str sprintf(' ...\n    ')]; end;
end;

str = [str sprintf('];\n')];
