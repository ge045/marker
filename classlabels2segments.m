function [seglist, sortidx] = classlabels2segments(classlabels)
% function seglist = classlabels2segments(classlabels)
%
%  Convert cell array of classwise labels to segment list
% 
% classlabels       cell list of segments per class
%
% Returns a segment list with the following columns:
% [START STOP LENGTH LABEL COUNT CONFIDENCE]  (LENGTH is in samples)
%
% See also segments2classlabels.m, labeling2segments, segments2labeling, labeling2samplesegments.

% Copyright 2005-2008 Oliver Amft, ETH Zurich

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
% -------------------------------------------------------------------

seglist = [];

% convert classlabels to segment list
% may go easier: cell2mat(col(classlabels))
for class=1:max(size(classlabels))
    if isempty(classlabels{class}), continue; end;
    nrsegments = size(classlabels{class},1);
    
     % class field is extracted from classwise list if available
    if (size(classlabels{class},2)>=4)
        classlist = classlabels{class}(:,4);
        
% 		if (class==1)
% 			warning('MATLAB:classlabels2segments', 'Class was taken from segmentation list NOT from cell structure position.');
% 		end;
    else
        classlist = repmat(class, nrsegments, 1);
    end;
   
    
    % confidence field is extracted from classwise list if available
    if (size(classlabels{class},2)>=6)
        conflist = classlabels{class}(:,6);
    else
        conflist = ones(nrsegments, 1);
    end;
    
    tmp_seglist = [];
    tmp_seglist(:,1) = classlabels{class}(:,1);
    tmp_seglist(:,2) = classlabels{class}(:,2);
    tmp_seglist(:,3) = classlabels{class}(:,2)-classlabels{class}(:,1)+1;
    tmp_seglist(:,4) = classlist; %repmat(class, nrsegments, 1);
    %tmp_seglist(:,5) = 0; %zeros(nrsegments, 1);
    tmp_seglist(:,6) = conflist;
    
    seglist = [seglist; tmp_seglist];
%         [classlabels{class}(:,1:2), (classlabels{class}(:,2)-classlabels{class}(:,1)+1), ...
%         repmat(class, nrsegments, 1),  zeros(nrsegments, 1),  conflist ] ];
end;

if ~isempty(seglist)
    [dummy, sortidx] = sort(seglist(:,1)); %clear dummy;
    seglist = seglist(sortidx,:);

    seglist(:,5) = (1:size(seglist,1)).';
end;
