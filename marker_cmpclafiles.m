function [isequal] = marker_cmpclafiles(file1, file2, varargin)
% function [isequal] = marker_cmpclafiles(file1, file2, varargin)
% 
% Compare two CLA files, report differences

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

verbose = process_options(varargin, 'verbose', 1);

isequal = true;

vars1 = whos('-file', file1);   vars2 = whos('-file', file2); 
varnames = unique([ extractfield(vars1, 'name') extractfield(vars2, 'name') ]);

if length(vars1) ~= length(vars2)
	fprintf('\n%s: Variable count differs:', mfilename);
	isequal = false;
	
	v = extractfield(vars1, 'name');
	if length(cellstrmatch(v, varnames)) ~= length(varnames)
		fprintf('\n%s: Variable %s missing in file 1.', mfilename, varnames{cellstrmatch(varnames, v)==0});
		%v{find(findn(1:length(varnames), cellstrmatch(v, varnames))==0)} );
		varnames(cellstrmatch(varnames, v)==0) = [];
	end;
	v = extractfield(vars2, 'name');
	if length(cellstrmatch(v, varnames)) ~= length(varnames)
		fprintf('\n%s: Variable ''%s'' missing in file 2.', mfilename, varnames{cellstrmatch(varnames, v)==0});
		%v{find(findn(1:length(varnames), cellstrmatch(v, varnames))==0)} );
		varnames(cellstrmatch(varnames, v)==0) = [];
	end;
	%return;
end;


% check all variables
for i = 1:length(varnames)
	[varfromfile1 loaded1] = marker_loadfromfile([], [], file1, varnames{i});
	[varfromfile2 loaded2] = marker_loadfromfile([], [], file2, varnames{i});
	
	if (~loaded1) || (~loaded2)
		isequal = false;
		fprintf('\n%s: Could not load variable %s from file %u', mfilename, varnames{i}, (~loaded1)+(~loaded2)*2 );
	end;
	
	if length(varfromfile1.(varnames{i})) ~= length(varfromfile2.(varnames{i}))
		isequal = false;
		fprintf('\n%s: Size of variable %s does not match: %u vs. %u', mfilename, ...
			varnames{i}, length(varfromfile1.(varnames{i})), length(varfromfile2.(varnames{i})));
		continue;
	end;
	
	switch lower(varnames{i})
		case 'labelstrings'
			if cellstr2vcat(varfromfile1.(varnames{i})) ~= cellstr2vcat(varfromfile2.(varnames{i}))
				fprintf('\n%s: Variable %s differs.', mfilename, varnames{i});
				isequal = false;
				continue;
			end;
			
		case { 'seg', 'SaveTime', 'alignshift', 'alignsps' }
			if ~all(all( varfromfile1.(varnames{i}) == varfromfile2.(varnames{i}) ))
				fprintf('\n%s: Variable %s differs.', mfilename, varnames{i});
				isequal = false;
				continue;
			end;
			
	end;
	
% 	if iscell(varfromfile1.(varnames{i}))
% 		fprintf('\n%s: Variable %s is a cell.', mfilename, varnames{i});
% 	end;
end;

if ~isequal
	varfromfile1 = marker_loadfromfile([], [], file1, 'SaveTime');
	varfromfile2 = marker_loadfromfile([], [], file2, 'SaveTime');
	fprintf('\n%s: Save time file 1: %s', mfilename, datestr(varfromfile1.SaveTime) );
	fprintf('\n%s: Save time file 2: %s', mfilename, datestr(varfromfile2.SaveTime) );
end;
	
if (verbose)
	fprintf('\n%s: OK', mfilename);
end;
