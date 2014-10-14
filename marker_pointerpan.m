function drawerobj = marker_pointerpan(fh, drawerobj)
% function drawerobj = marker_pointerpan(fh, drawerobj)
%
% Use pointer to pan across data

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

% pointer panning
if (~drawerobj.pointerpan) || isempty(drawerobj.eventdata.selectedplot), return; end;

% make a local copy to store panning view info
% will be copied to persistent drawerobj on exit
tmp_drawerobj = drawerobj;

% get(0, 'Units')
set(fh, 'Pointer', 'fleur'); 
mstartpos = get(0, 'PointerLocation');
splot = drawerobj.eventdata.selectedplot;

% get plot dimensions
hsplot = get(fh, 'Children');
idx = strmatch(drawerobj.disp(splot).plotTag, get(hsplot, 'Tag'), 'exact');
plotsize = get(hsplot(idx), 'Position'); % [x y width height]


% default settings
continouspan = false;
panspeed = [1 2]; % x y
% ignorepanthres = round(drawerobj.disp(splot).xvisible/1e3);
% ignorepanthres = 10./drawerobj.screensize(3:4);
ignorepanthres = 10./plotsize(3:4);


% function modifiers 
modkey = get(fh, 'SelectionType'); % update only on down event!
tmp_drawerobj = marker_statusaxes(fh, tmp_drawerobj, 'Panning...');
switch lower(modkey)
	case 'normal'
	case 'extend' % =shift
		panspeed = panspeed .* 4;
	case {'alternate', 'alt'} % =ctrl
		continouspan = true;
		tmp_drawerobj = marker_statusaxes(fh, tmp_drawerobj, 'Slide...');
end;


while(drawerobj.eventdata.ispointerpressed)
	mcurrentpos = get(0, 'PointerLocation'); % [x, y]

	%shift = round( (mstartpos(1) - mcurrentpos(1)) * panspeed * tmp_drawerobj.disp(splot).xvisible );
	shift = (mstartpos - mcurrentpos) ./ plotsize(3:4); %tmp_drawerobj.screensize(3:4);
	absshift = abs(shift);
	%shift

	% require pointer movement for panning
	if all(absshift < ignorepanthres), 
		set(fh, 'Pointer', 'fleur'); pause(0.1); drawerobj = get(fh, 'UserData'); continue; 
	end;


	
	% select x- or y-panning
	if absshift(1) > absshift(2)
		if (continouspan)
			% move on, while pointer is not returning to relative origin (start)
			shift = -shift;
			if (shift(1) < 0), set(fh, 'Pointer', 'left');	else set(fh, 'Pointer', 'right'); end;
		end;
		xrange_mov = repmat(shift(1)*panspeed(1)*tmp_drawerobj.disp(splot).xvisible, tmp_drawerobj.subplots, 1);
		tmp_drawerobj = marker_xrange(fh, tmp_drawerobj, xrange_mov);
	else
		if (continouspan)
			% move on, while pointer is not returning to relative origin (start)
			shift = -shift;
			if (shift(2) < 0), set(fh, 'Pointer', 'bottom');	else set(fh, 'Pointer', 'top'); end;
		end;
		ylim_mov = shift(2)*panspeed(2)*abs(diff(tmp_drawerobj.disp(splot).ylim))/2;
		tmp_drawerobj.disp(splot).ylim = tmp_drawerobj.disp(splot).ylim + ylim_mov;
	end;
	
	tmp_drawerobj = marker_draw(fh, tmp_drawerobj);

	if (~continouspan)
		mstartpos = mcurrentpos;
	end;
	
	
	% update persistent data to monitor ispointerpressed
	% ATTENTION: xrange is outdated!
	drawerobj = get(fh, 'UserData');
end; % while(drawerobj.eventdata.ispointerpressed)

% store back position
for splot = 1:tmp_drawerobj.subplots
	drawerobj.disp(splot).xrange = tmp_drawerobj.disp(splot).xrange;
	drawerobj.disp(splot).ylim = tmp_drawerobj.disp(splot).ylim;
end;

for splot = 1:3
    try
        delete( drawerobj.disp(splot).segHandles(ishandle(drawerobj.disp(splot).segHandles))) ;
        delete( tmp_drawerobj.disp(splot).segHandles(ishandle(tmp_drawerobj.disp(splot).segHandles))) ;
    end
end

set(fh, 'Pointer', 'arrow');

% % write back persistent data => done by marker_dispatcher
% set(fh, 'UserData', drawerobj);
