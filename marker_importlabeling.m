function [ok drawerobj] = marker_importlabeling(fh, drawerobj)
% function [ok drawerobj] = marker_importlabeling(fh, drawerobj)
% 
% Import labeling information

% Copyright 2007 Oliver Amft, Wearable Computing Lab., ETH Zurich

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

ok = false;

drawerobj=marker_statusaxes(fh, drawerobj, 'Import labeling...');

[filename,filepath,type] = uigetfile( { ...
	'*.mat','Marker label file'; ...
	'*.mat','Segment list (seg)'; ...
	'*.mat','Labeling list (gtc)'; ...
	} , ...
	'Add labels from file...', ...
	fullfile(drawerobj.defaultDir, drawerobj.iofilename) );

if isequal(filename,0) || isequal(filepath,0)
	marker_log(fh, '\n%s: Import cancelled.', mfilename);
	return;
end;
if isempty(filename)
	% this is a special case observed on some platforms
	marker_menudlg(fh, drawerobj, 'errordlg', 'No file name. Please try again.', 'Import labeling');
	ok = false; return;
end;


% save drawerobj
drawerobj_old = drawerobj;

% if (~exist([filepath,filename], 'file'))
% 	str = sprintf('File %s not found, aborted.', [filepath,filename]);
% 	marker_menudlg(fh, drawerobj, 'errordlg', str, 'Import labeling');
% 	return;
% end;

% OAM REVISIT
% import modes Segment/Labeling list do not support
% alignshift, alignsps
marker_log(fh, '\n%s: Load file (type: %u) %s...', mfilename, type, filename);
switch type
	case 2  % Segment list (seg)
		clear seg;
		%load([filepath,filename], 'seg');
		tmp = marker_loadfromfile(fh, drawerobj, [filepath,filename], 'seg', []);
		seg = tmp.seg;
		
	case 3  % Labeling list (gtc)
		clear gtc;
		%load([filepath,filename], 'gtc');
		tmp = marker_loadfromfile(fh, drawerobj, [filepath,filename], 'gtc', []);
		if (~isempty(tmp.gtc)), seg = labeling2segments(tmp.gtc); else seg = []; end;
		
	case 1   % Marker label file
		[tmp ok] = marker_loadfromfile(fh, drawerobj, [filepath,filename], 'seg', []);
		if (ok)
			seg = tmp.seg;
		else
			marker_log(fh, '\n%s: Attempting to load CLA file format < version 0.5.', mfilename);
			tmp = marker_loadfromfile(fh, drawerobj, [filepath,filename], 'cla', {});
			seg = classlabels2segments(tmp.cla);
		end;
		%fprintf('\nM1');

		% OAM REVISIT: Problem here
		% Attempt to add "alignshift" to a static workspace.
		% See MATLAB Programming, Restrictions on Assigning
		% to Variables for details.
		default_alignshift = repmat(0, drawerobj.subplots, 1);
		[tmp ok] = marker_loadfromfile(fh, drawerobj, [filepath,filename], 'alignshift', default_alignshift);
		if (~ok)
			marker_log(fh, '\n%s: No alignment shift information available.', mfilename);
			new_alignshift = default_alignshift;
		else
			new_alignshift = tmp.alignshift;
		end;
		default_alignsps = repmat(0, drawerobj.subplots, 1);
		[tmp ok] = marker_loadfromfile(fh, drawerobj, [filepath,filename], 'alignsps', default_alignsps);
		if (~ok)
			marker_log(fh, '\n%s: No alignment sps information available.', mfilename);
			new_alignsps = default_alignsps;
		else
			new_alignsps = tmp.alignsps;
		end;

		% plot alignment: reset with '-inf' then apply new shift value
		for splot = 1:drawerobj.subplots
			if (~drawerobj.disp(splot).save), continue; end;
			[dummy drawerobj] = marker_aligner(drawerobj, splot, -inf);
			[dummy drawerobj] = marker_resampler(drawerobj, splot, -inf);

			[alignshift drawerobj] = marker_aligner(drawerobj, splot, new_alignshift(splot));
			[alignsps drawerobj] = marker_resampler(drawerobj, splot, new_alignsps(splot));
		end; % for splot

		% time printout
		tmp = marker_loadfromfile(fh, drawerobj, [filepath,filename], 'MARKER_VERSION', 0);
		marker_log(fh, '\n%s: File version: %s', mfilename, tmp.MARKER_VERSION);
		tmp = marker_loadfromfile(fh, drawerobj, [filepath,filename], 'SaveTime', 0);
		marker_log(fh, '\n%s: File stamp  : %s', mfilename, datestr(tmp.SaveTime));
		clear tmp;

		% OAM REVISIT
		% merging of labelstrings, markersps not handled yet
		tmp = marker_loadfromfile(fh, drawerobj, [filepath,filename], 'labelstrings', {});
		drawerobj.labelstrings = tmp.labelstrings;
		tmp = marker_loadfromfile(fh, drawerobj, [filepath,filename], 'markersps', zeros(1,drawerobj.subplots));
		markersps = [drawerobj.disp(1:drawerobj.subplots).sfreq];
		markersps(~[drawerobj.disp(1:drawerobj.subplots).save]) = [];
		if any(markersps ~= tmp.markersps)
			str = sprintf('Marker sampling rate mismatch (%s), aborted.', mat2str(tmp.markersps));
			marker_menudlg(fh, drawerobj, 'errordlg', str, 'Import labeling');

			drawerobj = drawerobj_old; % restore saved struct
			return;
		end;
end; %switch type

% check for overlaps
ovsegs = [];
for i=1:size(seg,1)
	ovsegs = [ovsegs; marker_findoverlap(seg(i,:), drawerobj.seglist)];
	%                         if (~isempty(ovsegs)) break; end;
end;
if (~isempty(ovsegs))
	fprintf('\n%s: Overlap with existing labels detected!', mfilename);
	fprintf('\n%s: Overlap are at existing label: %s', mfilename, mat2str(ovsegs));
	if drawerobj.labelovcheck
		fprintf('\n%s: Import aborted.', mfilename);
		drawerobj = drawerobj_old; % restore saved struct
		return;
	end;
end;

% check if confidence list is there
if size(seg,2) < 6
	marker_log(fh, '\n%s: No confidence information available.', mfilename);
	seg(:,6) = 1; %zeros(size(seg,1), 1);
end;

% merge seglist
str = sprintf('Loaded %u labels from file %s', size(seg,1), filename);
marker_menudlg(fh, drawerobj, 'infodlg', str, 'Import labeling');

drawerobj.seglist = [ drawerobj.seglist; seg ];
% drawerobj.seglist = marker_modifylabeling(fh, drawerobj, [], 'labeling_sort');	
drawerobj = marker_resort(fh, drawerobj);


marker_log(fh, '\n%s: Plot alignment settings:', mfilename);
for splot = 1:drawerobj.subplots
	alignshift = marker_aligner(drawerobj, splot, 0);
	alignsps = marker_resampler(drawerobj, splot, 0);
	marker_log(fh, '\n%s: Plot %u: shift=%d, delta sps=%.1fHz', ...
		mfilename, splot, alignshift, alignsps);
end;
drawerobj.ismodified = true;
marker_log(fh, '\n');

clear drawerobj_old;
marker_log(fh, '\n%s: Done.\n', mfilename);
ok = true;

