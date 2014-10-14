function [ok drawerobj cmdqueue] = marker_labelrazor(fh, drawerobj, cmdqueue, functionid)
% function [ok drawerobj cmdqueue] = marker_labelrazor(fh, drawerobj, cmdqueue, functionid)
%
% Label razor / extend mode

% Copyright 2005-2008 Oliver Amft, ETH Zurich, Wearable Computing Lab.

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

drawerobj=marker_statusaxes(fh, drawerobj, 'Label razor/extending');
if isempty(drawerobj.seglist)
	marker_menudlg(fh, drawerobj, 'errordlg', 'No labels available.', 'Label razor');
	return;
end;

cont = 1;
while (cont)
	if strcmp(functionid, 'comma')
		drawerobj=marker_statusaxes(fh, drawerobj, ...
			'Special razor: Left=Select label for extension to neighbour, Mid=Tile');
	else
		drawerobj=marker_statusaxes(fh, drawerobj, ...
			'Razor: Left=Select label for extension, Mid=Immediate label crop');
	end;
	[row cont xpos splot segmarkHandles] = marker_pointsegment(fh, drawerobj);
	if (cont<=0) || (cont == 3), break; end;
	if (cont > 3)
		% marker_key2command changes cont, however it is needed below
		[cmdqueue cont] = marker_key2command(fh, drawerobj, cmdqueue, functionid, cont);  % input: cont == key
		if (cont<=0), continue; end;
	end;

	row = marker_islabelvisible(drawerobj, row, splot);
	row = marker_selectlabel(fh, drawerobj, row);
	if isempty(row), drawerobj = marker_draw(fh, drawerobj); continue; end;

	thisseg = drawerobj.seglist(row,:); drawerobj.seglist(row,:) = [];
	oldseg = thisseg; % save a copy
	xpos = round(xpos);

	% crop/tile mode
	if (cont==2)
		if strcmp(functionid, 'comma')
			% tile label, first part becomes "new" label
			drawerobj.seglist(end+1,:) = [xpos+1 thisseg(2) thisseg(2)-xpos thisseg(4:end)];
			thisseg(1:2) = [thisseg(1) xpos];
		else
			% crop label
			if xpos < (thisseg(1) + (thisseg(2)-thisseg(1))/2)
				% when first half of label cut from begin
				thisseg(1:2) = [xpos thisseg(2)];
			else
				thisseg(1:2) = [thisseg(1) xpos];
			end;
		end; % if strcmp(functionid, 'comma')
		thisseg(3) = thisseg(2)-thisseg(1)+1;

		drawerobj.seglist(end+1,:) = thisseg;
		drawerobj = marker_resort(fh, drawerobj);
		%drawerobj = marker_modifydrawerobj(fh, drawerobj, [], 'labeling_add', thisseg);
		%drawerobj = marker_modifydrawerobj(fh, drawerobj, [], 'labeling_sort');
		drawerobj.ismodified = true;
		drawerobj = marker_draw(fh, drawerobj);
		if (drawerobj.editnplay)
			% OAM REVISIT: This is a hack!
			marker_player(fh, drawerobj, drawerobj.seglist(drawerobj.lasteditedlabel, 1:2), splot);
		end;

		continue;
	end; % if (cont==2)



	if strcmp(functionid, 'comma')
		drawerobj=marker_statusaxes(fh, drawerobj, 'Special razor: Extend label bounds to neighbour label');
	else
		drawerobj=marker_statusaxes(fh, drawerobj, 'Razor: Extend label bounds');
	end;

	[xi1, yi1, cont, splot] = marker_ginput(fh, drawerobj, 1);
	if (cont<=0) || (cont == 3), 
		drawerobj.seglist(end+1,:) = thisseg; 
		marker_draw(fh, drawerobj); 
		break; 
	end;

	xpos = repmat(round(xi1) + drawerobj.disp(splot).xdynoffset, 1,2);


	if strcmp(functionid, 'comma')
		% extend label up to referenced label
		row = marker_findsegfrompos(drawerobj, xpos(1));
		row = marker_islabelvisible(drawerobj, row, splot);
		row = marker_selectlabel(fh, drawerobj, row);

		if isempty(row)
			marker_menudlg(fh, drawerobj, 'errordlg', 'Segment not found', 'Label extending');
			xpos = oldseg;
		else
			xpos = [drawerobj.seglist(row,1)-1 drawerobj.seglist(row,2)+1];
		end;
	end; % if strcmp(functionid, 'comma')

	% xpos are two elements, for 'period' xpos(1)==xpos(2)
	if xpos(2) < thisseg(1)
		% when clicked before (left from) old label start
		thisseg(1:2) = [xpos(2) thisseg(2)];
	elseif xpos(1) > thisseg(2)
		thisseg(1:2) = [thisseg(1) xpos(1)];
	else
		marker_log(fh, '\n%s: Not allowed. Use mid pointer to crop.', mfilename);
	end;

	% check for overlap
	if (~isempty(marker_findoverlap(thisseg, drawerobj.seglist))) && drawerobj.labelovcheck
		str = sprintf('Overlap with label #%s detected, skip.', ...
			mat2str(marker_findoverlap(thisseg, drawerobj.seglist)));
		marker_menudlg(fh, drawerobj, 'errordlg', str, 'Label razor');
		thisseg = oldseg;
	else
		drawerobj.ismodified = true;
	end;


	thisseg(3) = thisseg(2)-thisseg(1)+1;
	drawerobj.seglist(end+1,:) = thisseg;
	%drawerobj = marker_modifydrawerobj(fh, drawerobj, [], 'labeling_add', thisseg);
	drawerobj = marker_resort(fh, drawerobj);
	drawerobj.ismodified = true;
	%drawerobj = marker_modifydrawerobj(fh, drawerobj, [], 'labeling_sort');
	%drawerobj = marker_modifydrawerobj([drawerobj.seglist; thisseg]);
	drawerobj = marker_draw(fh, drawerobj);

	if (drawerobj.editnplay)
		% OAM REVISIT: This is a hack!
		marker_player(fh, drawerobj, drawerobj.seglist(drawerobj.lasteditedlabel, 1:2), splot);
	end;
    
    delete(segmarkHandles(ishandle(segmarkHandles)))
end; % while(cont)

ok = true;
