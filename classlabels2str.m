function str = classlabels2str(classlabels, scaler)
% function str = classlabels2str(classlabels, scaler)
%
% Convert segment list to string
% 
% scaler   optional, rescale samples in segment list
% 
% See also labeling2segments, segments2labeling, segments2classlabels.

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
str = [str sprintf('\n scale div: %u\n ', scaler)];

% convert classlabels to segment list
for class=1:max(size(classlabels))
    str = [str sprintf('\n Class %u:\n  [', class)];
    
    for row=1:size(classlabels{class},1)
        if (~rem(row, 5)) str = [str sprintf(' ...\n    ')]; end;
        
        str = [str sprintf('%.1f %.1f; ', ...
            classlabels{class}(row,1)/scaler, classlabels{class}(row,2)/scaler)];
    end;
    str = [str sprintf('];\n')]; 
end;
