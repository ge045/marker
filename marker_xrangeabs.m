function drawerobj = marker_xrangeabs(fh, drawerobj, absx, zoomx)
% function drawerobj = marker_xrangeabs(fh, drawerobj, absx, zoomx)
%
% Control xrange relative
% absx - shift absolute by deltax samples (value for each splot)
% zoomx - used for zooming keep begin of plot (value for each splot)

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

if (exist('absx', 'var')~=1) || isempty(absx), absx = repmat(nan, drawerobj.subplots, 1); end;
if (exist('zoomx', 'var')~=1) || isempty(zoomx), zoomx = repmat(nan, drawerobj.subplots, 1); end;

absx = round(absx); zoomx = round(zoomx);

datasizes = [drawerobj.disp(1:drawerobj.subplots).datasize];

for splot = 1:drawerobj.subplots
	xrange = drawerobj.disp(splot).xrange;
	
	if any(isnan(absx))
		% zoom only, absx is nan (empty; see initialisazion above)
		xrange(2) = xrange(1) + zoomx(splot);
	else
		% move
		xrange(1) = absx(splot);
		xrange(2) = xrange(1) + drawerobj.disp(splot).xvisible;
	end;

	% checks
	if (xrange(1) < 1)
		xrange = [1 drawerobj.disp(splot).xvisible];
	end;
	if xrange(2) > max(datasizes)
		xrange(2) = max(datasizes);
	end;
	if (xrange(2)-xrange(1) < 1)
		xrange = [ (max(datasizes)-drawerobj.disp(splot).xvisible+1)  max(datasizes) ];
	end;
	if (xrange(2)-xrange(1) > max(datasizes))
		xrange = [ 1 max(datasizes)-1];
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
