function seglist = labeling2samplesegments(labeling, labelbase)
% function seglist = labeling2samplesegments(labeling, labelbase)
% 
% Convert labeling to samplewise segment list.
% WARNING: This is slow and potenitally requires much memory!
% 
% labelbase: shift labeling basis: 0=default, 1=report zero-label segments
% 
% Returns a segment list with the following columns:
% [START STOP LENGTH LABEL COUNT CONFIDENCE]  (LENGTH is in samples)
% 
% See also labeling2segments, segments2labeling, segments2classlabels.

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


if (exist('labelbase','var')~=1), labelbase = 0; end;

labeling = labeling + labelbase;
labels = find(labeling>0);
seglist = zeros(length(labels), 6);

for i = 1:length(labels)
	seglist(i,:) = [labels(i) labels(i) 1 (labeling(labels(i))-labelbase) i 1];
end;