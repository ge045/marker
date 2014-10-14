function [classlabels, classlist, conflist]= segments2classlabels(classcount, seglist, classlist)
% function classlabels = segments2classlabels(classcount, seglist)
%
% Returns a cell array of segment lists with the following structure:
% {LABEL}[START STOP] (all in samples)
% 
% classcount    number of classes
% seglist       segment list 
%       [START STOP LENGTH LABEL COUNT CONFIDENCE]  (LENGTH is in samples)
% classlist     class list, optional
% 
% See also labeling2segments, segments2labeling, labeling2samplesegments.

% Copyright 2005, 2006 Oliver Amft, ETH Zurich

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

classlabels = [];

if isempty(seglist), return; end;
if (nargin < 2), error('Not enough input arguments!'); end;

% supplied classlist overwrites labellist in seglist
if (~exist('classlist', 'var'))
    if (size(seglist,2) < 4), error('No class information found!'); end;
    classlist = seglist(:,4);
end;

% use/generate confidence column
if (size(seglist,2) >= 6)
    conflist = seglist(:,6);
else
    fprintf('\n%s: No confidence information found!', mfilename);
    conflist = ones(size(seglist,1),1);
end;

if (size(classlist,1) ~= size(seglist,1)), error('Size mismatch: seglist/classlist'); end;

% convert classlabels to segment list
for class=1:classcount
    thisidx = find(classlist == class);
    thisseglist = seglist(thisidx,:);
    
    classlabels{class}(:,1) = thisseglist(:,1);
    classlabels{class}(:,2) = thisseglist(:,2);
    classlabels{class}(:,3) = thisseglist(:,2)-thisseglist(:,1)+1;
    classlabels{class}(:,4) = class; %repmat(class, size(classlabels{class},1), 1);
    classlabels{class}(:,5) = (1:size(classlabels{class},1)).';
    classlabels{class}(:,6) = conflist(thisidx);
end;
