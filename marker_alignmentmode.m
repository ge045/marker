function [ok drawerobj] = marker_alignmentmode(fh, drawerobj)
% function [ok drawerobj] = marker_alignmentmode(fh, drawerobj)
% 
% Manage alignment functions

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

while (1)
	drawerobj=marker_statusaxes(fh, drawerobj, 'Alignment mode...');

	reply = marker_menudlg(fh, drawerobj, 'menudlg', ...
		'Alignment operations', 'Alignment mode', ...
		'Shift plot', 'Resample plot', ...
		'Reset plot shift', 'Reset plot resample', 'Reset plot', 'Reset all plots', ...
		'Shift labeling', 'Resample labeling', 'Alignment status');

	% exit from alingment mode
	if isempty(reply)
        % check, delete labels that have been shifted out (position below zero)
        bz = drawerobj.seglist(:,2)<1;
        drawerobj.seglist(bz,:) = [];
        if (bz), marker_log(fh, '\n%s: Removed labels %s since position was below zero.', mfilename, mat2str(find(bz))); end;
        bz = drawerobj.seglist(:,1)<1;
        drawerobj.seglist(bz,[1 3]) = [ones(sum(bz),1) drawerobj.seglist(bz,2)];
        if (bz), marker_log(fh, '\n%s: Trunkated labels %s since position was below zero.', mfilename, mat2str(find(bz))); end;
        ok = true; return; 
    end;

	switch reply
		case 1  % alignment shift mode
			drawerobj=marker_statusaxes(fh, drawerobj, 'Alignment shift: Left=shift left, Mid=shift right, Factor=<<- small -- large ->>');
			while (1)
				%figure(fh);
				[xi, yi, button, splot] = marker_ginput(fh, drawerobj);
				if (button == 3), break; end;
				marker_log(fh, '\n%s: Plot=%u: wait...', mfilename, splot);

				deltashift = round(xi*(button == 1) - xi*(button==2));

				[alignshift drawerobj] = marker_aligner(drawerobj, splot, deltashift);

				marker_log(fh, ' change=%d, shift=%s', deltashift, mat2str(alignshift));
				drawerobj.ismodified = true; 
				drawerobj = marker_draw(fh, drawerobj);
			end; % while (1)

		case 2  % alignment resample mode
			drawerobj=marker_statusaxes(fh, drawerobj, 'Alignment resample: Left=upsample, Mid=downsample, Factor=<<- small -- large ->>');
			while (1)
				%figure(fh);
				[xi, yi, button, splot] = marker_ginput(fh, drawerobj);
				if (button == 3), break; end;
				marker_log(fh, '\n%s: Plot=%u: wait...', mfilename, splot);

				deltasps = round(xi/drawerobj.disp(splot).xvisible*100)/100;
				deltasps = deltasps*(button == 1) - deltasps*(button==2);
				[alignsps drawerobj] = marker_resampler(drawerobj, splot, deltasps);

				marker_log(fh, ' change=%.1f, sps=%.1f', deltasps, alignsps);
				drawerobj.ismodified = true; 
				drawerobj = marker_draw(fh, drawerobj);
			end; % while (1)

		case 3  % reset alignment shift
			drawerobj=marker_statusaxes(fh, drawerobj, 'Alignment shift reset');
			[xi, yi, button, splot] = marker_ginput(fh, drawerobj);
			if (button == 3), continue; end;
			[alignshift drawerobj] = marker_aligner(drawerobj, splot, -inf);
			drawerobj.ismodified = true; 

		case 4  % reset alignment resample
			drawerobj=marker_statusaxes(fh, drawerobj, 'Alignment resample reset');
			[xi, yi, button, splot] = marker_ginput(fh, drawerobj);
			if (button == 3), continue; end;
			[alignsps drawerobj] = marker_resampler(drawerobj, splot, -inf);
			drawerobj.ismodified = true; 

		case 5  % reset plot alignment information
			drawerobj=marker_statusaxes(fh, drawerobj, 'Alignment reset');
			[xi, yi, button, splot] = marker_ginput(fh, drawerobj);
			if (button == 3), continue; end;
			[alignshift drawerobj] = marker_aligner(drawerobj, splot, -inf);
			[alignsps drawerobj] = marker_resampler(drawerobj, splot, -inf);
			drawerobj.ismodified = true; 

		case 6  % reset all alignment information
			drawerobj=marker_statusaxes(fh, drawerobj, 'Alignment reset');
			[alignshift drawerobj] = marker_aligner(drawerobj, [], -inf);
			[alignsps drawerobj] = marker_resampler(drawerobj, [], -inf);
			drawerobj.ismodified = true; 

		case 7 % shift labeling
			drawerobj=marker_statusaxes(fh, drawerobj, 'Labeling shift: Left=shift left, Mid=shift right, Factor=<<- small -- large ->>');
			while (1)
				%figure(fh);
				[xi, yi, button, splot] = marker_ginput(fh, drawerobj);
				if (button == 3), break; end;
				marker_log(fh, '\n%s: Wait...', mfilename);

				deltashift = round(xi*(button == 1) - xi*(button==2));
				drawerobj.seglist(:,1:2) = drawerobj.seglist(:,1:2) - deltashift;
                
                % may produce labels at positions below zero
                % that will be resolved deleted at exit from alignment mode
				marker_log(fh, ' change=%d', deltashift);
				drawerobj.ismodified = true; 
				drawerobj = marker_draw(fh, drawerobj);
			end; % while (1)
			
		case 8 % resample labeling
			drawerobj=marker_statusaxes(fh, drawerobj, 'Labeling shift: Left=upsample, Mid=downsample, Factor=<<- small -- large ->>');
			while (1)
				%figure(fh);
				[xi, yi, button, splot] = marker_ginput(fh, drawerobj);
				if (button == 3), break; end;
				marker_log(fh, '\n%s: Wait...', mfilename);

                %deltasps = round(xi*1000)/1000;
				%deltasps = round(xi/(drawerobj.disp(splot).sfreq*drawerobj.disp(splot).xvisible)*1000)/1000;
                deltasps = xi/(drawerobj.disp(splot).sfreq*drawerobj.disp(splot).xvisible);
				deltasps = deltasps*(button == 1) - deltasps*(button==2);
                %if (~deltasps), marker_log(fh, '\n%s: deltasps=%f', mfilename, deltasps); continue; end;
				drawerobj.seglist(:,1:2) = ceil(drawerobj.seglist(:,1:2) .* (deltasps+1));
				
% 				% compensate for zero 
% 				drawerobj.seglist(:,1:2) = [ 
% 					(drawerobj.seglist(:,1)<=0)+drawerobj.seglist(:,1)  
% 					(drawerobj.seglist(:,2)<=0)+drawerobj.seglist(:,2) ];
				
				drawerobj.seglist(:,3) = drawerobj.seglist(:,2)-drawerobj.seglist(:,1)+1;

				marker_log(fh, ' change=%.2fHz', deltasps);
				drawerobj.ismodified = true; 
				drawerobj = marker_draw(fh, drawerobj);
			end; % while (1)
			
			
		case 9 % status information
			str = marker_alignmentmode_status(fh, drawerobj);
			marker_menudlg(fh, drawerobj, 'infodlg', str, 'Alignment information');
			
		otherwise
	end; % switch reply

	str = marker_alignmentmode_status(fh, drawerobj);
	marker_log(fh, '\n%s\n', str);
	drawerobj = marker_draw(fh, drawerobj);
end;  % while (1)


function str = marker_alignmentmode_status(fh, drawerobj)
str = 'Plot alignment settings:';
for splot = 1:drawerobj.subplots
	alignshift = marker_aligner(drawerobj, splot, 0);
	alignsps = marker_resampler(drawerobj, splot, 0);
	str = [ str sprintf('\nPlot %u: shift=%usa, delta sps=%.2fHz', splot, alignshift, alignsps) ];
end;


