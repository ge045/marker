function drawerobj = marker_xrange(fh, drawerobj, deltax, zoomx)
% function drawerobj = marker_xrange(fh, drawerobj, deltax, zoomx)
%
% Control xrange relative
% deltax - shift relative by deltax samples (value for each splot)
% zoomx - used for zooming keep begin of plot (value for each splot)
% % absx - shift absolute by deltax samples (value for each splot)

% Copyright 2005, 2006 Oliver Amft, ETH Zurich, Wearable Computing Lab.

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

if (exist('deltax', 'var')~=1), deltax = repmat(0, drawerobj.subplots, 1); end;
if (exist('zoomx', 'var')~=1), zoomx = repmat(0, drawerobj.subplots, 1); end;

% if (deltax-floor(deltax)~=0) || (zoomx-floor(zoomx)~=0)
% 	error('Triggered rounding bug!');
% end;
deltax = round(deltax); zoomx = round(zoomx);

% useabsshift = true;
% if (exist('absx', 'var')~=1)
% 	absx = repmat(0, drawerobj.subplots, 1);
% 	useabsshift = false;
% end;

% find pure max/min display sizes (depending on alignshift)
% minmax_datasize = min([drawerobj.disp(1:drawerobj.subplots).datasize]);% + abs([drawerobj.disp(1:drawerobj.subplots).alignshift]));
% maxmin_datasize = max([repmat(1,1,drawerobj.subplots)] + [drawerobj.disp(1:drawerobj.subplots).alignshift]);
datasizes = [drawerobj.disp(1:drawerobj.subplots).datasize];% - [drawerobj.disp(1:drawerobj.subplots).alignshift];

for splot = 1:drawerobj.subplots
	xrange = drawerobj.disp(splot).xrange;

% 	if useabsshift
% 		% shift absolute
% 		deltax(splot) = absx(splot) - xrange(1) + zoomx(splot);
% 	end;

	% shift relative, zoom
	xrange(1) = xrange(1) + deltax(splot) - zoomx(splot);
	xrange(2) = xrange(2) + deltax(splot);

	%checks
	if (xrange(1) < 1)
		xrange = [1 drawerobj.disp(splot).xvisible]; % +drawerobj.disp(splot).alignshift;
	end;
	if min(xrange(2) > datasizes)
		xrange = [ (max(datasizes)-drawerobj.disp(splot).xvisible+1) max(datasizes) ];
	end;
	if (xrange(2)-xrange(1) < 1) || (xrange(2)-xrange(1) > max(datasizes))  % samples!!
		xrange(2) = xrange(1) + drawerobj.disp(splot).xvisible-1;
	end;
	

	% write back to drawerobj structure
	drawerobj.disp(splot).xrange = xrange;
	drawerobj.disp(splot).xvisible = xrange(2) - xrange(1)+1;
end;


% OAM REVISIT
% A variable indicating coupled plots may be used here. This print is a hack.


% print current plot position
marker_log(fh, '\n%s: range: %u:%u (%.1fs) %u%%%%', ...
	mfilename, xrange(1), xrange(2), ...
	(xrange(2)-xrange(1))/drawerobj.disp(splot).sfreq, ...
	round(xrange(2)/max(datasizes)*100));
