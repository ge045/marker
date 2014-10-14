function ok = marker_dispatcher(fh, eventdata, cmdqueue)
% function ok = marker_dispatcher(fh, eventdata, cmdqueue)
%
% MARKER main function dispatcher. All commands issue (except program
% quitting) from here. This function is called following an event or from
% other sources (using the cmdqueue parameter directly). Parameter eventdata
% will override cmdqueue and shall be empty when called to invoke a command.

% Copyright 2005-2007 Oliver Amft, ETH Zurich, Wearable Computing Lab.

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

ok = true;
% eventdata
% cmdqueue
% fprintf('\n%s: DEBUG: Entry', mfilename);

%if ~exist('cmdqueue', 'var') cmdqueue = get(fh,'CurrentCharacter'); else cmdqueue = ''; end;
if exist('eventdata', 'var') && (~isempty(eventdata)) && (isfield(eventdata,'Key'))
    % called from KeyPressFcn callback
    key = eventdata.Key; keymod = cell2mat(eventdata.Modifier);
    if strcmpi(key, 'control'), key = 'ctrl'; end;
    if strcmpi(keymod, 'control'), keymod = 'ctrl'; end;
    if strcmpi(keymod, 'shiftcontrol'), keymod = 'shift+ctrl'; end;
    %key
    % exit here when: 1. no key, 2. only modifier pressed (gets into key variable)
    if isempty(key) || (~isempty(strmatch(key, {'alt', 'shift', 'ctrl'}, 'exact')))
        %set(fh, 'Interruptible', 'on'); % release lock
        return;
    end;
    
    %key
    
    if isempty(keymod), cmdqueue = key; else cmdqueue = [keymod '+' key]; end;
end;

% cmdqueue may be a cell array of commands
if (~iscell(cmdqueue)), cmdqueue = {cmdqueue}; end;

% mat2str(cell2mat(cmdqueue))


set(fh, 'Interruptible', 'off'); % lock for now
drawerobj = get(fh, 'UserData'); % get persistent data
if (drawerobj.eventdata.dispatcherlock)
    % dispatcher is running already, exit
    set(fh, 'Interruptible', 'on'); % release lock
    return;
end;
drawerobj.eventdata.dispatcherlock = true;
set(fh, 'UserData', drawerobj);
set(fh, 'Interruptible', 'on'); % release lock

% OAM REVISIT: Blocking resize in this way causes window flickering on Linux
% set(fh, 'resize', 'off'); % block resize

% try to process command(s)
%try
bNeedRedraw = true ;
while (~isempty(cmdqueue))
    ok = true;
    marker_statusaxes(fh, drawerobj, 'Busy...');
    
    functionid = cmdqueue{1}; % used to initiate a follow-up function
    cmdqueue(1) = [];
    
    %% switch functionid
    switch functionid
        case {'q', 'ctrl+q', 'quit'} % quit
            marker_statusaxes(fh, drawerobj, 'Exiting MARKER...');
            drawerobj.eventdata.dispatcherlock = false;	set(fh, 'UserData', drawerobj);
            marker_quitprogram(fh, []);
            return;
            
        case {'r', 'reset'} % reset
            bNeedRedraw = false ;
            marker_resetfigure(fh, []);
            
        case {'redraw'} % just redraw view
            bNeedRedraw = false ;
            drawerobj = marker_draw(fh, drawerobj);
            
            
        case {'shift+d', 'deleteall'} % delete all
            drawerobj = marker_statusaxes(fh, drawerobj, 'Delete all labels');
            if isempty(drawerobj.seglist)
                marker_menudlg(fh, drawerobj, 'errordlg', 'No labels available.', 'Delete all labels');
                continue;
            end;
            drawerobj = marker_statusaxes(fh, drawerobj, 'Delete labels...');
            ButtonName=marker_menudlg(fh, drawerobj, 'questdlg', ...
                'Really delete all labels?', 'Confirm deleting labels', 'Yes', 'No', 'No');
            if strcmpi(ButtonName, 'yes'),
                drawerobj.seglist = [];
                drawerobj.ismodified = true;
                %drawerobj = marker_modifydrawerobj(fh, drawerobj, [], 'labeling_deleteall');
            end;
            
            
        case {'d', 'shift+c'} % delete selected label
            drawerobj = marker_statusaxes(fh, drawerobj, 'Delete labels');
            if isempty(drawerobj.seglist)
                marker_menudlg(fh, drawerobj, 'errordlg', 'No labels available.', 'Delete labels');
                break;
            end;
            
            segmarkHandles = [] ;
            if strcmp(functionid, 'd')
                drawerobj=marker_statusaxes(fh, drawerobj, ...
                    'Delete labels: Left=Select range, Mid=Select one label');
                [spanseg button splot segmarkHandles] = marker_marksegment(fh, drawerobj);
                if (button >= 3), continue; end;
                row = marker_findoverlap(spanseg, drawerobj.seglist, 'included');
                row = marker_islabelvisible(drawerobj, row, splot);
                if (button==2) && length(row)>1,
                    row = marker_selectlabel(fh, drawerobj, row);
                end;
            else
                % clear label by label number
                drawerobj=marker_statusaxes(fh, drawerobj, 'Enter label number to delete');
                reply = marker_menudlg(fh, drawerobj, 'inputdlg', ...
                    ['Enter label number to delete (1..' num2str(size(drawerobj.seglist,1)) '):'], ...
                    'Delete labels...', {'1'});   % num2str(size(drawerobj.seglist,1))
                if isempty(reply), continue; end;
                reply = str2double(reply{1});
                if (reply<1) || (reply>size(drawerobj.seglist,1))
                    marker_log(fh, '\n%s: Input ignored (%s).', mfilename, mat2str(reply));
                    continue;
                end;
                row = reply;
                marker_log(fh, '\n%s: Selected label: %u:%u (#%u)', mfilename, ...
                    drawerobj.seglist(row,1), drawerobj.seglist(row,2), row);
            end;
            
            if isempty(row)
                marker_log(fh, '\n%s: Label not found.', mfilename);
            else
                drawerobj.seglist(row,:) = [];
                %drawerobj = marker_modifydrawerobj(fh, drawerobj, [], 'labeling_del', row);
                drawerobj = marker_resort(fh, drawerobj);
                drawerobj.ismodified = true;
            end;
            delete(segmarkHandles(ishandle(segmarkHandles)))
            
            
        case 'alt+d' % selective delete/prune labels
            drawerobj=marker_statusaxes(fh, drawerobj, 'Selective delete/prune...');
            if isempty(drawerobj.seglist)
                marker_menudlg(fh, drawerobj, 'errordlg', 'No labels available.', 'Selective delete/prune');
                break;
            end;
            reply = marker_menudlg(fh, drawerobj, 'menudlg', ...
                'Selective delete/prune label functions', 'Selective delete/prune', ...
                'Delete labels with size <= 1', ...
                'Delete labels starting after end of max datasize', ...
                'Delete labels larger than min datasize', ...
                'Delete labels by ID...');
            if isempty(reply), break; end;
            switch reply
                case 1  % delete size equal or below 1
                    dellabels = drawerobj.seglist(:,3)<=1;
                case 2 % delete labels beyond max datasize
                    dellabels = drawerobj.seglist(:,1) > max([drawerobj.disp(1:drawerobj.subplots).datasize]);
                case 3 % delete labels beyond min datasize
                    dellabels = drawerobj.seglist(:,2) > min([drawerobj.disp(1:drawerobj.subplots).datasize]);
                case 4 % delete labels of certain class/id
                    drawerobj=marker_statusaxes(fh, drawerobj, 'Delete labels with ID');
                    reply = marker_menudlg(fh, drawerobj, 'inputdlg', ...
                        ['Enter label ID for deletion (1..' num2str(drawerobj.maxLabelNum) '):'], ...
                        'Delete labels by ID...', {'1'});
                    if isempty(reply), continue; end; reply = str2double(reply{1});
                    if (reply<1) || (reply>drawerobj.maxLabelNum)
                        marker_log(fh, '\n%s: Input ignored (%s).', mfilename, mat2str(reply));
                        break;
                    end;
                    dellabels = drawerobj.seglist(:,4)==reply;
            end;
            if any(dellabels)
                drawerobj.seglist(dellabels, :) = [];
                %drawerobj = marker_modifydrawerobj(fh, drawerobj, [], 'labeling_del', drawerobj.seglist(:,3)<=1 );
                drawerobj = marker_resort(fh, drawerobj);
                drawerobj.ismodified = true;
                marker_log(fh, '\n%s: Deleted labels: %s', mfilename, mat2str(find(dellabels)));
            end;
            marker_menudlg(fh, drawerobj, 'infodlg', sprintf('Deleted %u labels.', sum(dellabels)), 'Prune labels');
            
        case 'alt+e'
            drawerobj.editnplay = ~drawerobj.editnplay;
            if (drawerobj.editnplay)
                str = sprintf('Edit''n''play enabled');
            else
                str = sprintf('Edit''n''play disabled');
            end;
            marker_log(fh, '\n%s: %s', mfilename, str);
            if isempty(cmdqueue)
                % slow, if called by shortcut
                drawerobj=marker_statusaxes(fh, drawerobj, str);
                pause(0.5);
            end;
            clear str;
            
            
        case {'e', 'edit'}
            str = '';
            if (drawerobj.defaultlabel),
                str = [str sprintf(' #%u (%s)', drawerobj.defaultlabel, drawerobj.labelstrings{drawerobj.defaultlabel})];
            end;
            if (drawerobj.editnplay),
                str = [str sprintf('   edit''n''play')];
            end;
            drawerobj=marker_statusaxes(fh, drawerobj, ['Pointer edit mode' str]);
            cont = 1;
            while (cont)
                [drawerobj cont splot] = marker_marksegmentlabel(fh, drawerobj);
                if (cont <= 0), break; end;
                if (cont == 1) && (drawerobj.editnplay)
                    % OAM REVISIT: This is a hack!
                    ok = marker_player(fh, drawerobj, drawerobj.seglist(drawerobj.lasteditedlabel, 1:2), splot);
                end;
                % OAM REVISIT: This hack
                if (cont == 2), marker_draw(fh, drawerobj); end;
                
                [cmdqueue cont] = marker_key2command(fh, drawerobj, cmdqueue, functionid, cont);  % input: cont == key
                
                %drawerobj.ismodified = true;
                %drawerobj = marker_modifydrawerobj(fh, drawerobj, [], 'labeling_sort');
                %drawerobj = marker_resort(fh, drawerobj);
            end; % while (cont)
            
            % OAM REVISIT: marker_marksegmentlabel will return 0 when
            % canceled in label selection - exit here
            
        case 'shift+e'
            str = '';
            if (drawerobj.defaultlabel),
                str = sprintf(' #%u (%s)', drawerobj.defaultlabel, drawerobj.labelstrings{drawerobj.defaultlabel});
            end;
            drawerobj=marker_statusaxes(fh, drawerobj, ['Keyboard edit mode' str]);
            while (1)
                reply = marker_menudlg(fh, drawerobj, 'inputdlg', ...
                    {'Enter label start time (in seconds)', 'Enter label stop time (in seconds)'}, ...
                    'Edit labels...', {'1', '2'});
                if isempty(reply), break; end;
                xs1 = str2double(reply{1});  xs2 = str2double(reply{2});
                if (xs1<=0) || (xs2<=0) || (xs2 <= xs1)
                    marker_log(fh, '\n%s: Input ignored (%s).', mfilename, reply{1});
                    break;
                end;
                
                xi1 = round(xs1*drawerobj.disp(1).sfreq) + drawerobj.disp(1).xdynoffset;
                xi2 = round(xs2*drawerobj.disp(1).sfreq) + drawerobj.disp(1).xdynoffset;
                newseg = [xi1 xi2];
                
                % check for overlaps if in overlap check mode
                if (~isempty(marker_findoverlap(newseg, drawerobj.seglist))) && drawerobj.labelovcheck
                    str = sprintf('Overlap with label #%s detected. Label not set.', ...
                        mat2str(marker_findoverlap(newseg, drawerobj.seglist)));
                    marker_menudlg(fh, drawerobj, 'errordlg', str, 'Editing');
                    continue;
                end;
                
                label = marker_setlabel(fh, drawerobj);
                if (label == 0), continue; end;
                
                tmplabel = marker_createlabel(newseg, label, setConfidence);
                drawerobj.seglist(end+1,:) = tmplabel;
                
                % need to verify that the label is actually visible in the current plot, if not: remove it again
                if isempty(marker_islabelvisible(drawerobj, size(drawerobj.seglist,1), splot))
                    marker_menudlg(fh, drawerobj, 'errordlg', 'The label will not be visible in the selected plot. Label not set.', 'Editing');
                    drawerobj.seglist(end,:) = [];
                    drawerobj = marker_draw(fh, drawerobj);
                    continue;
                end;
                
                % labels are resorted now. Some functions treat the new label specially
                % (e.g. playing it), hence a pointer to it is kept.
                drawerobj = marker_resort(fh, drawerobj);
                
                drawerobj.ismodified = true;
                drawerobj = marker_draw(fh, drawerobj);
            end; % while 1
            
            
        case {'m'} % modify label: m=reposition label
            drawerobj=marker_statusaxes(fh, drawerobj, 'Modify labels');
            if isempty(drawerobj.seglist)
                marker_menudlg(fh, drawerobj, 'errordlg', 'No labels available.', 'Modify labels');
                continue;
            end;
            
            cont = 1;
            while (cont)
                drawerobj=marker_statusaxes(fh, drawerobj, ...
                    'Modify label: 1. Select label for modify');
                [row cont dummy splot segmarkHandles] = marker_pointsegment(fh, drawerobj);
                if (cont<=0), break; end;
                
                [cmdqueue cont] = marker_key2command(fh, drawerobj, cmdqueue, functionid, cont);  % input: cont == key
                if (cont<=0), continue; end;
                
                row = marker_islabelvisible(drawerobj, row, splot);
                row = marker_selectlabel(fh, drawerobj, row);
                if isempty(row), drawerobj = marker_draw(fh, drawerobj); continue; end;
                
                oldseg = drawerobj.seglist(row,:);
                
                drawerobj.seglist(row,:) = [];
                %drawerobj = marker_modifydrawerobj(fh, drawerobj, [], 'labeling_del', row);
                drawerobj = marker_resort(fh, drawerobj);
                drawerobj = marker_draw(fh, drawerobj);
                %oldsegmarkHandles = marker_marksegmentpos(fh, drawerobj, oldseg);
                
                ret = 2;
                while (ret>1)
                    drawerobj=marker_statusaxes(fh, drawerobj, ...
                        'Modify label: 2. Left=Redefine label boundaries, Mid=Delete label');
                    [drawerobj ret] = marker_marksegmentlabel(fh, drawerobj, oldseg(4), oldseg(6));
                    oldsegmarkHandles = marker_marksegmentpos(fh, drawerobj, oldseg, 'old');
                end;
                if (ret==0)
                    marker_log(fh, '\n%s: Restoring old label.', mfilename);
                    drawerobj.seglist(end+1,:) = oldseg;
                    %drawerobj = marker_modifydrawerobj(fh, drawerobj, [], 'labeling_sort');
                    drawerobj = marker_resort(fh, drawerobj);
                    drawerobj = marker_draw(fh, drawerobj);
                    break;
                end;
                if (ret) && (drawerobj.editnplay)
                    % OAM REVISIT: This is a hack!
                    ok = marker_player(fh, drawerobj, drawerobj.seglist(drawerobj.lasteditedlabel, 1:2), splot);
                end;
                
                drawerobj = marker_resort(fh, drawerobj);
                %drawerobj = marker_modifydrawerobj(fh, drawerobj, [], 'labeling_sort');
                drawerobj.ismodified = true;
                drawerobj = marker_draw(fh, drawerobj);
                delete(segmarkHandles(ishandle(segmarkHandles)))
                delete(oldsegmarkHandles(ishandle(oldsegmarkHandles)))
            end; % while(cont)
            
            
            
        case 'w' % change label ID
            str = '';
            if (drawerobj.defaultlabel),
                str = sprintf(' #%u (%s)', drawerobj.defaultlabel, drawerobj.labelstrings{drawerobj.defaultlabel});
            end;
            drawerobj=marker_statusaxes(fh, drawerobj, ['Change label ID' str]);
            if isempty(drawerobj.seglist)
                marker_menudlg(fh, drawerobj, 'errordlg', 'No labels available.', 'Change label ID');
                continue;
            end;
            
            cont = 1;
            while (cont)
                drawerobj=marker_statusaxes(fh, drawerobj, ...
                    'Change label ID: Left=Select a sequence of labels, Mid=Select one label');
                
                [spanseg cont splot segmarkHandles] = marker_marksegment(fh, drawerobj);
                if (cont<=0) || (cont == 3), break; end;
                
                [cmdqueue cont] = marker_key2command(fh, drawerobj, cmdqueue, functionid, cont);  % input: cont == key
                if (cont<=0), continue; end;
                
                row = marker_findoverlap(spanseg, drawerobj.seglist, 'included');
                row = marker_islabelvisible(drawerobj, row, splot);
                if isempty(row), drawerobj = marker_draw(fh, drawerobj); continue; end;
                
                % change ID only
                %label = marker_setlabel(fh, drawerobj);
                label = marker_setlabel(fh, drawerobj, drawerobj.defaultlabel, 1, drawerobj.seglist(row, 4));
                if (label == 0), continue; end;
                drawerobj.seglist(row, 4) = label;
                
                %drawerobj = marker_modifydrawerobj(fh, drawerobj, [], 'labeling_sort');
                % get out the relevant labels and readd them at the end, so
                % we get lasteditedlabel correctly updated by marker_resort
                tmp = drawerobj.seglist(row,:); drawerobj.seglist(row,:) = []; drawerobj.seglist(end+1:end+length(row),:) = tmp;
                drawerobj = marker_resort(fh, drawerobj);
                drawerobj.ismodified = true;
                delete(segmarkHandles(ishandle(segmarkHandles)))
                drawerobj = marker_draw(fh, drawerobj);
            end; % while(cont)
            
            
        case 't' % toggle tentative label
            drawerobj=marker_statusaxes(fh, drawerobj, 'Set/unset tentative label');
            if isempty(drawerobj.seglist)
                marker_menudlg(fh, drawerobj, 'errordlg', 'No labels available.', 'Set/unset tentative label');
                continue;
            end;
            
            cont = 1;
            while (cont)
                [row cont dummy splot segmarkHandles] = marker_pointsegment(fh, drawerobj);
                if (cont<=0) || (cont == 3), break; end;
                [cmdqueue cont] = marker_key2command(fh, drawerobj, cmdqueue, functionid, cont);  % input: cont == key
                if (cont<=0), continue; end;
                
                row = marker_islabelvisible(drawerobj, row, splot);
                row = marker_selectlabel(fh, drawerobj, row);
                if isempty(row), continue; end;
                
                if drawerobj.seglist(row,6)
                    marker_log(fh, '\n%s: Mark label %u as tentative.', mfilename, row);
                else
                    marker_log(fh, '\n%s: Clear tentative flag for label #%u.', mfilename, row);
                end;
                delete(segmarkHandles(ishandle(segmarkHandles)))
                drawerobj.seglist(row,6) = ~drawerobj.seglist(row,6);
                drawerobj.ismodified = true;
                drawerobj = marker_draw(fh, drawerobj);
            end; % while(cont)
            
            
        case {'period', 'comma'} % label razor/extending
            [ok drawerobj cmdqueue] = marker_labelrazor(fh, drawerobj, cmdqueue, functionid);
            
            
        case 'n' % next slice
            xrange_mov = round([drawerobj.disp(1:drawerobj.subplots).xvisible]*0.5);
            drawerobj = marker_xrange(fh, drawerobj, xrange_mov);
        case 'space'
            xrange_mov = round([drawerobj.disp(1:drawerobj.subplots).xvisible]*0.75);
            drawerobj = marker_xrange(fh, drawerobj, xrange_mov);
        case {'alt+n', 'rightarrow'}
            xrange_mov = round([drawerobj.disp(1:drawerobj.subplots).xvisible]*0.25);
            drawerobj = marker_xrange(fh, drawerobj, xrange_mov);
        case 'shift+n'
            xrange_mov = round([drawerobj.disp(1:drawerobj.subplots).xvisible]*1);
            drawerobj = marker_xrange(fh, drawerobj, xrange_mov);
        case 'b' % back
            xrange_mov = -round([drawerobj.disp(1:drawerobj.subplots).xvisible]*0.5);
            drawerobj = marker_xrange(fh, drawerobj, xrange_mov);
        case {'alt+b', 'leftarrow'}
            xrange_mov = -round([drawerobj.disp(1:drawerobj.subplots).xvisible]*0.25);
            drawerobj = marker_xrange(fh, drawerobj, xrange_mov);
        case 'shift+b'
            xrange_mov = -round([drawerobj.disp(1:drawerobj.subplots).xvisible]*1);
            drawerobj = marker_xrange(fh, drawerobj, xrange_mov);
            
        case 'ctrl+n' % jump to next label (wrap around mode)
            xjumpoffset = [drawerobj.disp(1:drawerobj.subplots).xvisible] * 0.1;
            xrange = reshape([drawerobj.disp(:).xrange],2,drawerobj.subplots)';
            seglist_vis = drawerobj.seglist(marker_islabelvisible(drawerobj, 1:size(drawerobj.seglist,1), 1:drawerobj.subplots),:);
            row = find( seglist_vis(:,1) > (xrange(1,1)+min(xjumpoffset)+1) );
            if isempty(row), row = 1; end;
            xrange_mov = repmat(seglist_vis(row(1),1), drawerobj.subplots,1) - xrange(:,1);
            drawerobj = marker_xrange(fh, drawerobj, xrange_mov);
            drawerobj = marker_xrange(fh, drawerobj, -xjumpoffset);
        case 'ctrl+b' % jump to previous label (wrap around mode)
            xjumpoffset = [drawerobj.disp(1:drawerobj.subplots).xvisible] * 0.1;
            xrange = reshape([drawerobj.disp(:).xrange],2,drawerobj.subplots)';
            seglist_vis = drawerobj.seglist(marker_islabelvisible(drawerobj, 1:size(drawerobj.seglist,1), 1:drawerobj.subplots),:);
            if isempty(seglist_vis), continue; end;
            row = find( seglist_vis(:,1) < (xrange(1,1)+min(xjumpoffset)-1) );
            if isempty(row), row = size(seglist_vis,1); end;
            xrange_mov = repmat(seglist_vis(row(end),1), drawerobj.subplots,1) - xrange(:,1);
            drawerobj = marker_xrange(fh, drawerobj, xrange_mov);
            drawerobj = marker_xrange(fh, drawerobj, -xjumpoffset);
            
            
        case {'home', 'ctrl+a', 'gotohome'} % first slice
            drawerobj = marker_xrange(fh, drawerobj, repmat(-inf, drawerobj.subplots,1));
        case {'end', 'ctrl+e', 'gotoend'} % last slice
            drawerobj = marker_xrange(fh, drawerobj, repmat(inf, drawerobj.subplots,1));
            
        case 'pointerpan' % pointer panning
            drawerobj = marker_pointerpan(fh, drawerobj);
            
            
        case {'ctrl+g', 'goto', 'shift+z', 'setzoom'} % goto position/ set zoom
            [dummy str] = marker_timeaxisunits(fh, drawerobj);
            convunit = drawerobj.timeaxissamplesconv;
            
            if strcmpi(functionid, 'ctrl+g') || strcmpi(functionid, 'goto')
                drawerobj=marker_statusaxes(fh, drawerobj, 'Goto stream position...');
                xvalue = round(drawerobj.disp(1).xrange(1) / convunit(1));
                reply = marker_menudlg(fh, drawerobj, 'inputdlg', ...
                    sprintf('Enter data stream position in %s', str), 'Goto...', {num2str(xvalue)});
            else
                drawerobj=marker_statusaxes(fh, drawerobj, 'Set zoom...');
                xvalue = round(drawerobj.disp(1).xvisible / convunit(1));
                reply = marker_menudlg(fh, drawerobj, 'inputdlg', ...
                    sprintf('Enter zoom setting in %s', str), 'Set zoom...', {num2str(xvalue)});
            end;
            if isempty(reply), break; end;
            
            xs = str2double(reply{1});
            if (xs<0)
                marker_log(fh, '\n%s: Input ignored (%s).', mfilename, reply{1});
                break;
            end;
            xvalue = round(xs.*convunit);
            marker_log(fh, '\n%s: Move/Zoom: %s', mfilename, mat2str(xvalue));
            
            if strcmpi(functionid, 'ctrl+g') || strcmpi(functionid, 'goto')
                drawerobj = marker_xrangeabs(fh, drawerobj, xvalue);
            else
                if (xvalue == 0), break; end;
                drawerobj = marker_xrangeabs(fh, drawerobj, [], xvalue);
            end;
            
            
        case {'z', 'zoom'} % horizontal zoom
            drawerobj=marker_statusaxes(fh, drawerobj, ...
                'Horizontal zoom: Left=Zoom out, Mid=Zoom in, Factor=<<- small -- large ->>');
            while(1)
                [xi, yi, button, splot] = marker_ginput(fh, drawerobj);
                if (button>=3), break; end;
                delta_xvisible = round(repmat(xi*(button==1) - xi*(button==2), drawerobj.subplots,1));
                
                % 				datasizes = [drawerobj.disp(1:drawerobj.subplots).datasize] ...
                % 					- [drawerobj.disp(1:drawerobj.subplots).alignshift];
                %
                % 				for splot = 1:drawerobj.subplots
                % 					drawerobj.disp(splot).xvisible = drawerobj.disp(splot).xvisible + delta_xvisible(splot);
                %
                % 					if (drawerobj.disp(splot).xvisible>max(datasizes))
                % 						drawerobj.disp(splot).xvisible = max(datasizes);
                % 					end;
                % 				end;
                drawerobj = marker_xrange(fh, drawerobj, delta_xvisible, delta_xvisible);
                drawerobj = marker_draw(fh, drawerobj);
            end; % while(1)
            
        case {'shift+ctrl+z', 'fullzoom'} % full zoom
            drawerobj = marker_xrangeabs(fh, drawerobj, ones(drawerobj.subplots,1));
            drawerobj = marker_xrangeabs(fh, drawerobj, [], repmat(inf, drawerobj.subplots,1));
            
            
        case {'v', 'vzoom'} % vertical zoom
            drawerobj=marker_statusaxes(fh, drawerobj, ...
                'Vertical zoom: Left=Zoom out, Mid=Zoom in, Factor=<<- small -- large ->>');
            
            while (1)
                [xi, yi, button, splot] = marker_ginput(fh, drawerobj);
                if (button>=3), break; end;
                ysize = abs(diff(drawerobj.disp(splot).ylim));
                xvisible = drawerobj.disp(splot).xvisible;
                
                % x-pos controls vzoom steps, y-pos vzoom center position
                ysize = ysize*(1+xi/xvisible)*(button==1) + ...
                    ysize*(1-xi/xvisible)*(button==2);
                %ysize
                if ysize < 1e-6, ysize = 1e-6; end;  if ysize > 1e9, ysize = 1e9; end;
                drawerobj.disp(splot).ylim = [ yi-ysize/2 yi+ysize/2 ];
                
                drawerobj = marker_draw(fh, drawerobj);
            end; % while(1)
            
            
        case 'shift+s' % show/hide signals in plot
            drawerobj=marker_statusaxes(fh, drawerobj, 'Show/hide signals...');
            
            if (drawerobj.visibleplots > 1)
                drawerobj=marker_statusaxes(fh, drawerobj, 'Select plot to edit signal visibility');
                [xi, yi, button, splot] = marker_ginput(fh, drawerobj);
            else
                button = 1;
                splot = find([drawerobj.disp(1:drawerobj.subplots).hideplot] == false);
            end;
            if (button < 3)
                marker_log(fh, '  plot: %u', splot);
                
                % hard coded color code is not a nice thing but handy
                colorcode = {'blue', 'green',  'red', 'cyan', 'magenta', 'yellow', 'grey'}; % cmap lines
                signallist = cell(1, length(drawerobj.disp(splot).hidesignal));
                for i = 1:length(drawerobj.disp(splot).hidesignal)
                    signallist{i} = sprintf('%s (%s)', drawerobj.disp(splot).signalnames{i}, ...
                        colorcode{rem(i-1, length(colorcode))+1});
                end;
                drawerobj=marker_statusaxes(fh, drawerobj, 'Select visibile signals...');
                signals = marker_menudlg(fh, drawerobj, 'multiplelistdlg', ...
                    'Select visibile signals', 'Show/hide signals', ...
                    signallist, find(drawerobj.disp(splot).hidesignal==0) );
                if (max(signals) < 1), continue; end;
                
                % this map has inverted logic
                drawerobj.disp(splot).hidesignal = ones(1, length(drawerobj.disp(splot).hidesignal));
                drawerobj.disp(splot).hidesignal(signals) = 0;
                
                %drawerobj = marker_draw(fh, drawerobj);
            end;
            
            
        case 'alt+l' % show/hide labels
            drawerobj=marker_statusaxes(fh, drawerobj, 'Show/hide labels...');
            
            if (drawerobj.visibleplots > 1)
                marker_statusaxes(fh, drawerobj, 'Select plot to edit label visibility');
                [xi, yi, button, splot] = marker_ginput(fh, drawerobj);
            else
                button = 1;
                splot = find([drawerobj.disp(1:drawerobj.subplots).hideplot] == false);
            end;
            
            if (button > 3), continue; end;
            marker_log(fh, 'plot: %u', splot);
            marker_statusaxes(fh, drawerobj, 'Select visibile labels...');
            items = marker_menudlg(fh, drawerobj, 'multiplelistdlg', ...
                'Select visibile labels', 'Show/hide labels', ...
                marker_makelabelstr(fh, drawerobj), find(drawerobj.disp(splot).showlabels) );
            if (max(items) < 1), continue; end;
            
            drawerobj.disp(splot).showlabels = false(1, length(drawerobj.labelstrings));
            drawerobj.disp(splot).showlabels(items) = true;
            clear items;
            
            
        case 'alt+s' % show/hide subplot
            drawerobj=marker_statusaxes(fh, drawerobj, 'Show/hide subplots...');
            if (drawerobj.subplots <= 1)
                marker_menudlg(fh, drawerobj, 'errordlg', 'Function requires more than one plot', 'Show/hide subplots');
                continue;
            end;
            
            plotlist = cell(1, drawerobj.subplots);
            plotmap = zeros(1, drawerobj.subplots);
            for splot = 1:drawerobj.subplots
                plotlist{splot} = sprintf('Plot %u (%s)', splot, drawerobj.disp(splot).ylabel);
                plotmap(splot) = ~drawerobj.disp(splot).hideplot;
            end;
            
            marker_statusaxes(fh, drawerobj, 'Select visible subplots...');
            items = marker_menudlg(fh, drawerobj, 'multiplelistdlg', ...
                'Select visible subplots', 'Show/hide subplots', ...
                plotlist, find(plotmap>0) );
            
            if isempty(items) || (max(items) < 1)
                if isempty(items)
                    marker_menudlg(fh, drawerobj, 'errordlg', 'At least one plot must be visible', 'Show/hide subplots');
                end;
                continue;
            end;
            
            drawerobj.visibleplots = length(items);
            for splot = 1:drawerobj.subplots
                drawerobj.disp(splot).hideplot = isempty(find(items == splot,1));
            end;
            clf(fh);
            
            
        case {'i'} % label info (can process more than one label)
            bNeedRedraw = false ;
            drawerobj=marker_statusaxes(fh, drawerobj, 'Label info');
            if isempty(drawerobj.seglist)
                marker_menudlg(fh, drawerobj, 'errordlg', 'No labels available.', 'Label info');
                continue;
            end;
            
            drawerobj=marker_statusaxes(fh, drawerobj, 'Mark label with left pointer');
            [row cont dummy splot segmarkHandles] = marker_pointsegment(fh, drawerobj);
            row = marker_islabelvisible(drawerobj, row, splot);
            if isempty(row), continue; end;
            
            str = '';
            for i = 1:length(row)
                str = [ str sprintf('\n Label %3u: Class=%u (%s)  Confidence=%s', ...
                    row(i), drawerobj.seglist(row(i),4), ...
                    drawerobj.labelstrings{drawerobj.seglist(row(i),4)}, ...
                    mat2str(drawerobj.seglist(row(i),6))) ];
                str = [ str sprintf('\n Samples: Begin=%u  End=%u  Duration=%u', ...
                    drawerobj.seglist(row(i),1), drawerobj.seglist(row(i),2), drawerobj.seglist(row(i),3)) ];
                str = [ str sprintf('\n Time      : Begin=%.2fs  End=%.2fs  Duration=%.2fs', ...
                    drawerobj.seglist(row(i),1)/drawerobj.disp(1).sfreq, ...
                    drawerobj.seglist(row(i),2)/drawerobj.disp(1).sfreq, ...
                    drawerobj.seglist(row(i),3)/drawerobj.disp(1).sfreq) ];
            end; % for i
            marker_menudlg(fh, drawerobj, 'infodlg', str, sprintf('Information for label(s) #%s', mat2str(row)));
            delete(segmarkHandles(ishandle(segmarkHandles)))
            clear str;
            
            
        case {'alt+p', 'p'} % play
            bNeedRedraw = false ;
            playseg = [];
            
            if strcmpi(functionid, 'alt+p')
                % --- play up to start/end of label ---
                drawerobj=marker_statusaxes(fh, drawerobj, 'Play mode: Left=select start point, Mid=select end point');
                if isempty(drawerobj.seglist)
                    marker_menudlg(fh, drawerobj, 'errordlg', 'No labels available.', 'Play up to label');
                    continue;
                end;
                
                [row cont xi1 splot segmarkHandles] = marker_pointsegment(fh, drawerobj);
                row = marker_selectlabel(fh, drawerobj, row);
                if isempty(row), break; end;
                
                % end point
                if (cont == 2)
                    playseg = [drawerobj.seglist(row,1) xi1];
                    marker_log(fh, 'begin:%u end:%u', playseg(1), playseg(2));
                end;
                
                % start point
                if cont == 1
                    playseg = [xi1 drawerobj.seglist(row,2)];
                    marker_log(fh, 'begin:%u end:%u', playseg(1), playseg(2));
                end;
                
            else % functionid == 'p'
                % --- let user mark the range to play: begin+end or label bounds ---
                drawerobj=marker_statusaxes(fh, drawerobj, 'Play mode: Left=mark segment, Mid=select label');
                [playseg dummy splot segmarkHandles] = marker_marksegment(fh, drawerobj);
                
                if size(playseg,1)>1
                    % This is tricky: more than one playseg indicates that labels were selected
                    % instead of a continuous range, marker_selectlabel will work then.
                    row = marker_findoverlap(playseg, drawerobj.seglist);
                    row = marker_selectlabel(fh, drawerobj, row);
                    playseg = drawerobj.seglist(row,1:2);
                end;
            end;
            
            if ~isempty(playseg)
                % play it
                
                %ok = feval(drawerobj.player, fh, drawerobj, playseg, splot);
                ok = marker_player(fh, drawerobj, playseg, splot);
                % 				if (ok == false)
                % 					err = lasterror;
                % 					if (~isempty(err.message))
                % 						marker_menudlg(fh, drawerobj, 'errordlg', sprintf('Player error message: %s', err.message), 'Marker play');
                % 					end;
                % 				end;
            end;
            if (ok)
                marker_log(fh, '\n%s: Player done.', mfilename);
            else
                marker_log(fh, '\n%s: Player failed.', mfilename);
            end
            delete(segmarkHandles(ishandle(segmarkHandles)))
            
            
            
            
        case 'shift+p' % select player
            bNeedRedraw = false ;
            drawerobj=marker_statusaxes(fh, drawerobj, 'Select plot to configure player channel');
            [xi, yi, button, splot] = marker_ginput(fh, drawerobj);
            if (button >= 3), continue; end;
            if (length(drawerobj.disp(splot).playerdata) <= 1)
                marker_menudlg(fh, drawerobj, 'errordlg', ...
                    sprintf('Not enough players configured for plot %u. Must be two players at least.', ...
                    splot, drawerobj.disp(splot).type), 'Select player...');
                continue;
            end;
            
            % create a player string and display it in the select box
            str = cell(1, length(drawerobj.disp(splot).playerdata));
            for i = 1:length(drawerobj.disp(splot).playerdata)
                % 				tmp = 'NONAME';
                % 				if (isfield(drawerobj.disp(splot).playerdata, 'name'))
                tmp = drawerobj.disp(splot).playerdata(i).title;
                % 				end;
                str{i} = sprintf('Player %u: %s', i, tmp);
            end;
            reply = marker_menudlg(fh, drawerobj, 'singlelistdlg', ...
                sprintf('Select player for plot %u', splot), 'Select player...', ...
                str, drawerobj.disp(splot).playerselect);
            if (reply==0), continue; end;
            drawerobj.disp(splot).playerselect = reply;
            
            
        case 'shift+w' % set/unset default label
            drawerobj=marker_statusaxes(fh, drawerobj, 'Set/Unset a default label...');
            marker_log(fh, '\n%s: This label will be used for all label assignments.', mfilename);
            olddeflabel = drawerobj.defaultlabel; %drawerobj.defaultlabel = 0;
            
            if (olddeflabel==0), olddeflabel = 1; end; % zero not supported by listdlg
            reply = marker_menudlg(fh, drawerobj, 'singlelistdlg', ...
                'Enter new default label', 'Select default label...', ...
                marker_makelabelstr(fh, drawerobj), olddeflabel );
            
            if (reply==0), drawerobj.defaultlabel = 0;
            else drawerobj.defaultlabel = reply; end;
            % when using the following line, defaultlabel cannot be reset
            % to zero due to menu restrictions
            %if (reply > 0), drawerobj.defaultlabel = reply; end;
            
            drawerobj.olddefaultlabel = 0;
            if (drawerobj.defaultlabel)
                marker_log(fh, '\n%s: Current defaut label: %u (%s).', mfilename, ...
                    drawerobj.defaultlabel, drawerobj.labelstrings{drawerobj.defaultlabel});
            else
                marker_log(fh, '\n%s: No default label set.', mfilename);
            end;
            
            
            
        case 'alt+w' % toggle default label on/off
            %drawerobj=marker_statusaxes(fh, drawerobj, 'Toggle default label on/off');
            if (drawerobj.olddefaultlabel)
                drawerobj.defaultlabel = drawerobj.olddefaultlabel;
                drawerobj.olddefaultlabel = 0; % on
                str = sprintf('Default label label #%u enabled', drawerobj.defaultlabel);
            else
                % shortcut to defaultlabel setting
                if (drawerobj.olddefaultlabel==0) && (drawerobj.defaultlabel==0), cmdqueue = {'shift+w', cmdqueue{:}}; continue; end;
                
                drawerobj.olddefaultlabel =drawerobj.defaultlabel;
                drawerobj.defaultlabel = 0; % off
                str = sprintf('Default label suspended, press %s again to re-activate', functionid);
            end;
            %marker_menudlg(fh, drawerobj, 'infodlg', str, 'Toggle default label on/off');
            marker_log(fh, '\n%s: %s', mfilename, str);
            if isempty(cmdqueue)
                % slow, if called by shortcut
                drawerobj=marker_statusaxes(fh, drawerobj, str);
                pause(0.5);
            end;
            clear str;
            
            
        case {'shift+l'}  % listing mode
            drawerobj=marker_statusaxes(fh, drawerobj, 'List mode...');
            
            reply = marker_menudlg(fh, drawerobj, 'menudlg', ...
                'List functions', 'List mode', ...
                'List of all labels set', 'List of categories', 'Total statistics'	);
            if isempty(reply), break; end;
            switch reply
                case 1  % list of all labels
                    if (~isempty(drawerobj.seglist))
                        marker_printer(fh, drawerobj);
                    else
                        marker_menudlg(fh, drawerobj, 'infodlg', 'List is empty', 'List mode');
                    end;
                case 2 % list of label classes
                    %labelstrings = marker_makelabelstr(fh, drawerobj);
                    str = '';
                    str = [ str sprintf('\n  %5s  %15s %9s  %5s  %15s %9s', 'Class', 'Name', 'Lab/Tent', 'Class', 'Name', 'Lab/Tent') ];
                    for class = 1:drawerobj.maxLabelNum
                        if rem(class,2), str = [str sprintf('\n')]; end;
                        str = [str sprintf('  %5u: %15s (%3u/%3u)', class, drawerobj.labelstrings{class}, ...
                            sum(drawerobj.seglist(:,4)==class), sum(drawerobj.seglist(:,4)==class & drawerobj.seglist(:,6)<1))];
                    end;
                    str = [ str sprintf('\n') ];
                    %fprintf(str);
                    marker_menudlg(fh, drawerobj, 'infodlg', str, 'List of labels');
                    clear str;
                case 3 % Total statistics
                    str = '';
                    str = [str sprintf('\n%-20s: %3u', 'Total categories', drawerobj.maxLabelNum) ];
                    str = [str sprintf('\n%-20s: %3u', 'Total labels', size(drawerobj.seglist,1)) ];
                    if ~isempty(drawerobj.seglist)
                        tlabels = length(find(drawerobj.seglist(:,6)==false));
                    else
                        tlabels = 0;
                    end;
                    str = [str sprintf('\n%-20s: %u', 'Total t-labels', tlabels) ];
                    %fprintf(str);
                    marker_menudlg(fh, drawerobj, 'infodlg', str, 'Total statistics');
                    clear str;
            end; % switch reply
            
            
        case 'alt+c'  % data cursor/probe
            ph = []; cont = 1; pcount = 1;
            
            while (cont)
                drawerobj=marker_statusaxes(fh, drawerobj, 'Place probe with pointer');
                %                     if (~isempty(cinfo)) set(cinfo.Target, 'LineWidth', 2); end;
                %                     dcmobj = datacursormode(fh)
                %                     set(dcmobj, 'enable', 'on', 'UpdateFcn', @marker_datatiptext);
                %                     cinfo = getCursorInfo(dcmobj)
                %                     set(cinfo.Target, 'LineWidth', 3); % Make selected line wider
                
                [xi, yi, cont, splot] = marker_ginput(fh, drawerobj);
                if (cont<=0) || (cont== 3) || isempty(splot), break; end;
                
                % need to store cursor points for reentrent operation
                %[cmdqueue cont] = marker_key2command(fh, drawerobj, cmdqueue, functionid, cont);  % input: cont == key
                %if (cont<=0), continue; end;
                
                
                if all(drawerobj.disp(splot).hidesignal)
                    marker_menudlg(fh, drawerobj, 'errordlg', 'No active signals found in this plot', 'Data cursor/probe');
                    continue;
                end;
                
                %yi
                [p,q] = rat((drawerobj.disp(splot).sfreq + drawerobj.disp(splot).alignsps) / drawerobj.disp(splot).sfreq);
                xpos = round(xi)+drawerobj.disp(splot).xdynoffset;
                xpos = ceil((xpos + drawerobj.disp(splot).alignshift) *q/p);
                cands = marker_getdatafrombuffer(fh, drawerobj, splot, [xpos xpos]); % y candidates
                cands(drawerobj.disp(splot).hidesignal==1) = [];
                %cands
                %yi
                %cands = drawerobj.disp(splot).data(xpos,:); % y candidates
                %foundline = find(abs((cands-yi)./0.2) < abs(cands)); % find line
                %[rerr foundline] = min( abs(cands-yi)./cands );
                [rerr foundline] = min( abs(cands-yi) );
                %foundline
                %rerr
                if isempty(foundline) || foundline==0 %|| rerr>0.1
                    continue;
                end;
                %foundline = foundline(1); % use first match only
                
                %disp('m1')
                hold on;
                ph(pcount) = plot(xi, cands(foundline), ...
                    'Marker', '+', 'MarkerSize', 10, 'LineWidth', 3, 'MarkerEdgeColor', [1 0 0]);
                hold off;
                
                str = '';
                str = [ str sprintf('\n Probe %u: Signal: %u  Plot: %u', pcount, foundline(1), splot) ];
                str = [ str sprintf('\n X: %usa (%.2fsec)  Y: %f', ...
                    xpos, xpos/drawerobj.disp(splot).sfreq, cands(foundline)) ];
                str = [ str sprintf('\n') ];
                marker_menudlg(fh, drawerobj, 'infodlg', str, sprintf('Information for probe #%u', pcount));
                pcount = pcount +1;
            end;
            %                 datacursormode(fh, 'enable', 'off');
            if length(pcount), delete(ph); end;
            clear ph str;
            
            
        case 'alt+j'  % toggle label overlap check
            drawerobj.labelovcheck = ~drawerobj.labelovcheck;
            str = sprintf('Label overlap check is %s', upper(mat2str(drawerobj.labelovcheck)));
            marker_log(fh, '\n%s: %s', mfilename, str);
            if isempty(cmdqueue)
                % slow, if called by shortcut
                drawerobj=marker_statusaxes(fh, drawerobj, str);
                pause(0.5);
            end;
            clear str;
            
            
        case {'ctrl+s', 'shift+ctrl+s'} % save labeling
            % OAM REVISIT
            % Why is dir and/or filename not used when calling uiputfile() under certain Linuxes?
            
            drawerobj=marker_statusaxes(fh, drawerobj, 'Export labeling...');
            if (~drawerobj.askbeforesave) && (~drawerobj.ismodified) && strcmp(functionid, 'ctrl+s'),
                drawerobj=marker_statusaxes(fh, drawerobj, 'Nothing to save.'); pause(0.3);
                continue;
            end;
            
            if (drawerobj.askbeforesave) || strcmp(functionid, 'shift+ctrl+s')
                [userFname,userPath,filetype] = uiputfile( ...
                    { '*.mat', 'Marker label file'; }, ...
                    'Export Variables to File...', ...
                    fullfile(drawerobj.defaultDir, drawerobj.iofilename) );
                
                if isequal(userFname,0) || isequal(userPath,0)
                    marker_log(fh, '\n%s: Export cancelled.', mfilename);
                    ok = false; % figure(fh);
                    continue;
                end;
                if isempty(userFname)
                    % this is a special case observed on some platforms
                    marker_menudlg(fh, drawerobj, 'errordlg', 'No file name. Please try again.', 'Export labeling');
                    ok = false; continue;
                end;
                % store path for later
                drawerobj.iofilename = userFname;  drawerobj.defaultDir = userPath;
                drawerobj.askbeforesave = false;
                drawerobj.defaultsavetype = filetype;
            end;
            clear userFname userPath;
            
            %fprintf('\n%s: File type: %u', mfilename, type);
            SaveTime = clock;
            %try
            switch drawerobj.defaultsavetype
                case 1                                        
                    eventList = drawerobj.seglist;
                    labelstrings = drawerobj.labelstrings; % label strings
                    partsize = []; markersps = []; alignshift = []; alignsps = [];
                    for splot = 1:drawerobj.subplots
                        if (~drawerobj.disp(splot).save), continue; end;
                        datasize(splot) = drawerobj.disp(splot).datasize; % size of data
                        dataSamplingFreq(splot) = drawerobj.disp(splot).sfreq; % sampling rate
                        alignshift(splot) = marker_aligner(drawerobj, splot, 0);
                        alignsps(splot) = marker_resampler(drawerobj, splot, 0);
                    end;
                    MARKER_VERSION = drawerobj.marker_version;
                    
                    %keyboard
                    save(fullfile(drawerobj.defaultDir, drawerobj.iofilename), ...
                        'eventList', 'labelstrings', 'datasize', 'dataSamplingFreq', ...
                        'alignshift', 'alignsps', ...
                        'SaveTime', 'MARKER_VERSION');
                    if isfield(drawerobj,'struct2save')
                        struct2save = drawerobj.struct2save ;
                        save( fullfile(drawerobj.defaultDir, drawerobj.iofilename), ...
                            '-struct', 'struct2save', '-append') ;
                    end
                otherwise
                    % this hack is needed for MACs, ui is set to * here
                    str = sprintf('No filetype selected. Nothing will be exported!');
                    marker_menudlg(fh, drawerobj, 'errordlg', str, 'Export error');
                    marker_log(fh, str);
                    ok = false; continue;
            end;
            %catch
            %	ok = false;
            %end;
            
            % permission denied or similar error
            if (ok == false)
                err = lasterror;
                str = sprintf('%s', err.message);
                marker_menudlg(fh, drawerobj, 'errordlg', str, 'Save error');
                marker_log(fh, str);
                drawerobj.askbeforesave = true;
                continue;
            end;
            
            drawerobj.ismodified = false;
            
            str = sprintf('Saved file ''%s'' at %s.', marker_ctrlstr(fullfile(drawerobj.defaultDir, drawerobj.iofilename)), datestr(SaveTime));
            marker_menudlg(fh, drawerobj, 'infodlg', str, 'Export labeling');
            marker_log(fh, str);
            
            
            
        case {'ctrl+o'} % load labeling
            [ok drawerobj] = marker_importlabeling(fh, drawerobj);
            
        case {'ctrl+x'} % export figure
            % OAM REVISIT
            % export of jpg/eps is broken on Linux platforms due to label transparencies
            drawerobj=marker_statusaxes(fh, drawerobj, 'Export figure...');
            
            tmp_fh = figure;  set(tmp_fh, 'UserData', drawerobj);
            drawerobj = marker_draw(tmp_fh, drawerobj);
            drawerobj=marker_statusaxes(tmp_fh, drawerobj, ' ');
            [d,f] = fileparts(drawerobj.iofilename);
            
            [filename, pathname, filterindex] = uiputfile( ...
                {'*.fig', 'Figures (*.fig)'; ...
                '*.jpg', 'JPEG image (*.jpg)'; ...
                '*.eps', 'EPS file (*.eps)'}, ...
                'Save as', ...
                fullfile(drawerobj.defaultDir, [f,'.fig']) );
            
            if isempty(filename)
                % this is a special case observed on some platforms
                marker_menudlg(fh, drawerobj, 'errordlg', 'No file name. Please try again.', 'Export labeling');
                ok = false; delete(tmp_fh); continue;
            end;
            if isequal(filename,0), close(tmp_fh); break; end
            
            wait_h = waitbar(0,'Saving ...');
            switch filterindex
                case 1
                    saveas(tmp_fh, fullfile(pathname,filename), 'fig');
                case 2
                    saveas(tmp_fh, fullfile(pathname,filename), 'jpg');
                case 3
                    saveas(tmp_fh, fullfile(pathname,filename), 'epsc2');
            end
            waitbar(1);
            close(tmp_fh);
            close(wait_h);
            
            
        case 'a' % data alignment mode
            [ok drawerobj] = marker_alignmentmode(fh, drawerobj);
            
            
        case {'alt+t', 'test'}
            %                 set(0,'ShowHiddenHandles', 'on');
            %                  colormapeditor(fh);
            %                  set(0,'ShowHiddenHandles', 'off');
            
        case {'shift+quote', 'h', '?', 'help'}
            % OAM REVISIT: with all keyboard layouts: 'shift+quote' == '?' ???
            marker_helpscreen(fh, drawerobj);
            
            
        case {'ctrl+p', 'properties'}
            drawerobj=marker_statusaxes(fh, drawerobj, 'Marker properties...');
            while (1)
                reply = marker_menudlg(fh, drawerobj, 'menudlg', ...
                    'Select/toggle functions', 'Marker properties', ...
                    ['Label overlap check: ' upper(mat2str(drawerobj.labelovcheck))], ...
                    ['Interactive console: ' upper(mat2str(drawerobj.consolemenus))], ...
                    ['Console logging: ' upper(mat2str(drawerobj.cmdlinelog))], ...
                    ['Time axis units: ' upper(drawerobj.timeaxisunits)], ...
                    ['Single label colormap: ' upper(drawerobj.labelcolormap)], ...
                    ['Label text style: ' upper(drawerobj.labeltextstyle)], ...
                    'Configure player channels', ...
                    'Debug dump');
                if isempty(reply), break; end;
                switch reply
                    case 1  % Label overlap check
                        %drawerobj.labelovcheck = ~drawerobj.labelovcheck;
                        cmdqueue(end+1:end+2) = {'alt+j', 'properties'};
                        break;
                    case 2  % Menus on console
                        drawerobj.consolemenus = ~drawerobj.consolemenus;
                    case 3 % Console logging
                        drawerobj.cmdlinelog = ~drawerobj.cmdlinelog;
                    case 4 % time axis units
                        supportedvalues = {'seconds', 'samples', 'min:sec'};
                        idx = strmatch(drawerobj.timeaxisunits, supportedvalues, 'exact');
                        drawerobj.timeaxisunits = supportedvalues{ mod(idx, length(supportedvalues))+1 };
                        drawerobj = marker_timeaxisunits(fh, drawerobj);
                        drawerobj = marker_draw(fh, drawerobj);
                    case 5 % Single label colormap
                        supportedvalues = {'common', 'single'};
                        idx = strmatch(drawerobj.labelcolormap, supportedvalues, 'exact');
                        drawerobj.labelcolormap = supportedvalues{ mod(idx, length(supportedvalues))+1 };
                        drawerobj = marker_draw(fh, drawerobj);
                    case 6 % label text style
                        supportedvalues = {'auto', 'simple', 'name', 'none'};
                        idx = strmatch(drawerobj.labeltextstyle, supportedvalues, 'exact');
                        drawerobj.labeltextstyle = supportedvalues{ mod(idx, length(supportedvalues))+1 };
                        drawerobj = marker_draw(fh, drawerobj);
                        
                    case 7 % configure player channels
                        cmdqueue(end+1:end+2) = {'shift+p', 'properties'};
                        break;
                    case 8 % Debug dump
                        %marker_dispatcher(fh, [], '1');
                        cmdqueue(end+1:end+2) = {'1', 'properties'}; % debug dump
                        break;
                end; % switch reply
            end; % while (1)
            
        case 'undo' % undo last step
            % not implemented yet, oam
            % Idea: copy a snapshot of drawerobj at each location where
            % ismodified is set to true to an undo cache. Update a use
            % pointer to the last position-1 when undo is called and
            % restore this snapshot.
            
        case 'comment' % add a label comment
            % not implemented yet, oam
            % This requires a consistent array of structures containing labels (now seglist)
            % and comments. Consequently a method to add/remove... labels
            % from the array of such structs is needed and all locations
            % where currently seglist is changed must be adapted.
            
            
        case '1' % debug dump
            fprintf('\n%s: Debug dump.\n', mfilename);
            disp(drawerobj); disp(drawerobj.eventdata);
            for splot = 1:drawerobj.subplots, disp(drawerobj.disp(splot)); end;
            
            
            % 	otherwise
            % 		% missing 'return' makes matlab crash, because marker_draw is
            % 		% called with every key stroke
            % 		% FIXME: make this return unnecessary!!
            % 		return
        otherwise
            bNeedRedraw = true ;
    end % switch
    
end; % while ~isempty(next_functionid)

% catch
% 	marker_errorhandler(fh, drawerobj, sprintf('functionid: %s, command queue: %s', functionid, cell2mat(cmdqueue)));
% end;

% redraw main window
drawerobj.eventdata.statuslinetext = 'Ready';
if bNeedRedraw
    drawerobj = marker_draw(fh, drawerobj);
end

% make up titleline
set(fh, 'Name', marker_titleline(fh, drawerobj));

set(fh, 'Pointer', 'arrow');  % reset mouse pointer

% OAM REVISIT: Blocking resize in this way causes window flickering on Linux
% set(fh, 'resize', 'on');  % unblock resize

% write back persistent data
set(fh, 'Interruptible', 'off'); % lock for now
drawerobj.eventdata.dispatcherlock = false;
set(fh, 'UserData', drawerobj);
set(fh, 'Interruptible', 'on');
