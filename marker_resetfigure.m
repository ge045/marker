function marker_resetfigure(fh, eventdata)

% WARNING: Will destroy all existing graphics objects during redraw!

drawerobj = get(fh, 'UserData'); % get persistent data

% save axis text before redraw
th = findobj(fh, 'Tag', drawerobj.statusTextTag);
axisstring = get(th, 'String');
if isempty(axisstring), axisstring = 'Ready'; end;

marker_statusaxes(fh, drawerobj, 'Reset');
marker_xrange(fh, drawerobj);
% clf needed for resizing main window - unclear why subplots are
% lost/replicated otherwise
clf;
marker_draw(fh, drawerobj, true); %% OSD added
% restore axis text
marker_statusaxes(fh, drawerobj, axisstring);