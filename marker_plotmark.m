function fillHandles = marker_plotmark(fh, drawerobj, SegTS, splot)
% function marker_plotmark(fh, drawerobj, SegTS, splot)
%
% Plot label marks

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

% Copyright 2005, 2006 Oliver Amft, ETH Zurich, Wearable Computing Lab.

TextFontSize = [10 8]; % text sizes for label and label text
TextOffset = 10; % offset between text lines in pixels
TextBase = 10; % offset plot boarder to text in pixels

yrange = ylim; xrange = xlim;

% define colormap for labels (although strings, should be fast)
if strcmpi(drawerobj.labelcolormap, 'single')
	pcolor = zeros( drawerobj.maxLabelNum, 3) ;
	pcolor( drawerobj.disp(splot).showlabels==1, : ) = jet(sum(drawerobj.disp(splot).showlabels));
else
	% default coloring
	pcolor = jet(drawerobj.maxLabelNum);

	% OAM REVISIT: hack
	%pcolor = lines(drawerobj.maxLabelNum);
end;

% 1. Determine upper end of current subplot (axis) in pixels
% 2. Obtain position in data units (by drawing a probe text)
% 3. Delete probe text and use data units to annotation plot text
set(gca, 'Units', 'Pixels');
splotpos = get(gca, 'Position');
ytextpos = [];
for t = 1:2
    th = text('Position', [splotpos(1) splotpos(4)+TextBase+(t-1)*TextOffset], 'Units', 'pixels', ...
        'VerticalAlignment', 'bottom', 'FontSize', TextFontSize(1), 'String', ' ');
    set(th, 'Units', 'data');
    textpos = get(th, 'Position'); %textpos = get(th, 'Extent');
    delete(th);
    %th = text('Position', [textpos(1) textpos(2)], 'VerticalAlignment', 'bottom', 'String', 'HUHU');
    ytextpos(t) = textpos(2);
end; % for t
%ypos = yrange(2);   % upper end of subplot
ypos = ytextpos;   % upper end of subplot


% plot labels
nSegTS = size(SegTS,1) ;
fillHandles = nan(nSegTS,3) ;
for seg = 1:nSegTS
    thisseg = SegTS(seg,:);
    
    if (thisseg(6) == 1)
        fillHandles(seg,1) = fill([thisseg(1) thisseg(1) thisseg(2) thisseg(2)], ...
            [yrange(1) yrange(2) yrange(2) yrange(1)], ...
            pcolor(thisseg(4),:), 'FaceAlpha', 0.4) ;
    else
        fillHandles(seg,1) = fill([thisseg(1) thisseg(1) thisseg(2) thisseg(2)], ...
            [yrange(1) yrange(2) yrange(2) yrange(1)], ...
            pcolor(thisseg(4),:), 'FaceAlpha', 0.25) ;
    end;

    xpos = thisseg(1);  % begin of label

    % if begin is not visible avoid writing on boarder
    %if (thisseg(2) < 0) continue; end;
    if (xpos < 0), xpos = 0; end;

    switch lower(drawerobj.labeltextstyle)
        case {'simple', 'on'}
            fillHandles(seg,2:3) = simpletext(xpos, ypos, thisseg, TextFontSize);

        case 'name'
            fillHandles(seg,2:3) = nametext(xpos, ypos, thisseg, drawerobj.labelstrings{thisseg(4)}, TextFontSize);

        case 'auto'
            %ypos = 39;
            th = nametext(xpos, ypos, thisseg, drawerobj.labelstrings{thisseg(4)}, TextFontSize);

            if (seg < nSegTS), nextxpos = SegTS(seg+1,1); else nextxpos = xrange(2); end;

            % find out if text overlaps with next text label
            for t = 1:length(th)
                % Extent [left,bottom,width,height]
                pos = get(th(t), 'Extent');

                % if too large, use smaller one
                if (pos(1)+pos(3) > nextxpos)
                    delete(th);
                    th = simpletext(xpos, ypos, thisseg, TextFontSize);
                end;
            end; % for t
            fillHandles(seg,2:3) = th ;

        case {'none', 'off'}
    end;

end; % for seg
end


function th = simpletext(xpos, ypos, seg, TextFontSize)
% tight text label
if seg(6), tentext = ''; fontweight = 'bold'; 
else  tentext = '?'; fontweight = 'normal'; end;
th = [];
th = [th text( xpos, ypos(2),  ['#' num2str(seg(5))], ...
    'FontSize', TextFontSize(1), 'FontWeight', fontweight) ];
th = [th text( xpos, ypos(1),  ['L' num2str(seg(4)) tentext], ...
    'FontSize', TextFontSize(1), 'FontWeight', fontweight) ];
end % simpletext


function th = nametext(xpos, ypos, seg, labelstring, TextFontSize)
% wide text label
if seg(6), tentext = ''; fontweight = 'bold'; 
else  tentext = ' ?'; fontweight = 'normal'; end;
th = [];
th = [th text( xpos, ypos(2),  ['#',num2str(seg(5)),' - L',num2str(seg(4))], ...
    'FontSize', TextFontSize(1), 'FontWeight', fontweight) ];
th = [th text( xpos, ypos(1),  [labelstring tentext], ...
    'FontSize', TextFontSize(2), 'FontWeight', fontweight, 'Interpreter', 'none') ];
end % nametext




% % wide text label
% text( SegTS(seg,1), yrange(2)*1.2,  ['#',num2str(SegTS(seg,5)),' - L',num2str(SegTS(seg,4))], ...
%     'FontSize',10,'FontWeight','bold' ) ;
% text( SegTS(seg,1), yrange(2)*1.1,  drawerobj.labelstrings{SegTS(seg,4)}, ...
%     'FontSize',8,'FontWeight','bold' ) ;
