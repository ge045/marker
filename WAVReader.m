function [WAVData, WAVSize, WAVRate, WAVBits] = WAVReader(WAVFile, WAVRanges, varargin)
% function [WAVData, WAVSize, WAVRate, WAVBits] = WAVReader(WAVFile, WAVRanges, varargin)
%
% Read segment or full WAV file and plays it optionally
%
% parameters:
%   Sample rate:        44100 Hz assuemd if not globally defined (WAVRate)
%   WAVFile:            WAV file to read from
%   WAVRanges:          Samples range vector in sample indices
% optional parameters:
%   channels:           Vector of channels to extract, default: [] (=all)
%   play                Play extracted WAV slice
%   precision           sample resolution: double (Default), single
%   verbose             Tell more

% Copyright 2005-2007 Oliver Amft, ETH Zurich, Wearable Computing Lab.

% -------------------------------------------------------------------
%     This program is free software; you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation; either version 2 of the License, or
%     (at your option) any later version.
% 
%     This program is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
% 
%     You should have received a copy of the GNU General Public License
%     along with this program; if not, write to the Free Software
%     Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
% -------------------------------------------------------------------

[verbose, play, channels precision] = process_options(varargin, ...
    'verbose', 0, 'play', false, 'channels', [], 'precision', 'double');

WAVData = [];
isMultiTrack = false;

% OAM REVISIT: This is a hack for multi-track recordings
if (exist(WAVFile,'file')==0) && (length(channels) == 1) 
	WAVFileCore = WAVFile;
	isMultiTrack = true;
	WAVFile = [ WAVFileCore '-' num2str(channels) '.wav' ];
end;
if ~exist(WAVFile,'file'), error('Audio file %s does not exist.', WAVFile); end;

% check sample rate & size
[WAVSamples, WAVRate, WAVBits] = wavread(WAVFile, 'size');
WAVSize = WAVSamples(1); % get file size

% returns information from WAV file
if (~exist('WAVRanges','var')) || isempty(WAVRanges), return; end;


% loop for all segments to extract from this wav
for i=1:size(WAVRanges,1)
    corrected = false;
    WAVBeg = WAVRanges(i, 1); WAVEnd = WAVRanges(i, 2);

    % do range corrections
    if (WAVEnd == inf) || (WAVEnd > WAVSize)
        WAVEnd = WAVSize; corrected = true;
    end;
    if (WAVBeg == 0)
        WAVBeg = 1; corrected = true;
    end;
    if (WAVBeg > WAVSize)
        WAVBeg = WAVSize; corrected = true;
    end;
    if (corrected) && (verbose > 1)
        fprintf('\n%s: Corrected WAVRanges at entry %u (%u:%u)\n', ...
            mfilename, i, WAVBeg, WAVEnd);
    end;

    thisWAVRange = [WAVBeg WAVEnd];

    [temp,fs,bits] = wavread(WAVFile, thisWAVRange);
    if isempty(channels) || isMultiTrack
        WAVData = [WAVData; temp];
    else
        WAVData = [WAVData; temp(:,channels)]; %(i,:)
    end;

    if (verbose > 1)
        fprintf('\n%s: Data in segment: %usa (%.3fs), channels: %s',...
            mfilename, length(temp), length(temp)/WAVRate, mat2str(channels));
    end;

    if (play > 0)
        WAVPlayer(WAVData, fs);
    end;
end;

WAVSize = size(WAVData,1);

% change precision, maybe faster
switch precision
    case 'single'
        WAVData = single(WAVData);
    case 'double'
end;

if (verbose)
    fprintf('\n%s: Total data: %usa, sample rate: %uHz, BPS: %ubit/sa, total time: %.3fs',...
        mfilename, WAVSize, WAVRate, WAVBits, WAVSize/WAVRate);
    fprintf('\n');
end;
