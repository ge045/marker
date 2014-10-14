# MARKER Matlab toolbox

## Change history:

### 1.1.0
* feature: Added funciton "Delete labels by ID" in selective delete/prune menu
* feature: Function to modify MARKER drawerobj from workspace (EXPERIMENTAL)
* feature: Added data export option in marker_player_viewsound
* feature: Improved label list/statisitcs functions ('shift+l')
* feature: Following modes support intermediate commands: 'w','t','comma','period'
* feature: Print out runtime on exit
* core: Validated code to be compatible with mat2str of Matlab 2007a and later
* core: Changed option interactiveconsole to consolemenus
* core: Direct saving support (bypassing dialog) when filetype and name specified
* core: Made mode set tentative label continuous and changed shortcut to 't'
* core: Label delete ('d'+mid pointer button) now asks on ambigiuous label selection
* core: Changed initialisation procedure to avoid button reactions before complete start
* bugfix: Set tentative to ask on ambiguous label selection
* bugfix: Cursor probe mode ('Alt+c') now handles unspecified subplot case
* bugfix: Window manager may have returned ginput with empty button variable
* bugfix: Right-button exit from intermediate 'd' exited host mode as well
* bugfix: Prevent mid-button to highlight label in 'e' mode
* bugfix: Right-button exit from razor mode now works correct if extension was started
* bugfix: Cursor mode may have catched wrong signal trace, removed mag sensitvity
Thanks to Martin for the bugreports.
oam, 2008/04/09


### 1.0.3
* core: Changed marker_ginput.m according to a non-reproducable bug report
* core: Added optional exit question dialog
* bugfix: Loading labels (Ctrl-o) may have failed
Thanks to Martin for the bugreport.
oam, 2007/11/25


### 1.0.2
* core: Play mode ('p') now confirms ambigous label selection (mid pointer)
* bugfix: Redraw window after empty selection in 'w' mode
* bugfix: Special label razor may have deleted the label, when no neighbour was selected
oam, 2007/11/16


### 1.0.1
* core: Added version string to error message printouts
* bugfix: Added missing file: marker_selectlabel.m
oam, 2007/11/14


### 1.0.0
* initial SVN version
* feature: Added label mark/highligh function, some functions got more visual effects
* feature: Vertical panning support, vertical zoom is now adaptive
* feature: Label special razor (',') supports label tiling (using mid pointer button)
* feature: Ambiguous label selection is now confirmed by dialog
* feature: Modify mode ('m') now supports intermediate commands (Linux only)
* core: Added check for initlabels with fraction (during statup)
* core: Removed hypen key from label jump function (now exclusively Ctrl+b/n)
* core: Check/trunkate of warn meassages
* core: Changed setzoom shortcut to Shift+z (Ctrl+z is masked on some Unix systems)
* core: Redesign of player interface, more flexible support for display/play methods
* core: Removed explicit overloading configs: aligner, resampler, viewer, printer
* core: marker_timeaxisunits now handles all time axis code (was in marker_viewer)
* core: Alignment mode changed to shortcut 'a'
* core: Removed legacy code from marker_findoverlap, now supports 2-list checks
* bugfix: Label jump function now considers vivible labels only (now exclusively Ctrl+b/n)
* bugfix: marker_importlabeling: variable assignemtn in CLA compatibility mode fixed
* bugfix: Prevent float values in xdynoffset and xvisible that could cause float values in labeling
* bugfix: Solved concurrency in marker_panning (improves reaction time, avoid jumps)
* bugfix: Calling without arguments may have resulted in followup error messages
* bugfix: Dispatcher now handles key events reported by marker_ginput (Linux) consistently
* bugfix: Delete now only removes labels that are completely included in the spanned section
* bugfix: Edit modes not check that the new label is actually visible in the active plot
* bugfix: Changing ID of multiple labels may have returned an indexing error
* bugfix: Label shifting (Alignment mode) may have resulted in negative label positions
oam, 2007/11/11


### 0.11.0
* feature: extended mode for MARKER-specific plotting methods
* core: Improved plot method marker_plotsegments and omitted ylim-guessing in marker_init
* bugfix: Unexpectd question dialog input generated Maltab error message in console mode
* bugfix: Resolved printing bugs in marker_player and marker_version
oam, 2007/09/11


### 0.10.0
* feature: Added two more sub-functions to prune labels menu (alt+d)
* feature: Edit mode 'e' now supports some intermediate commands on *nix-OS, e.g. moving 'b/n'
* feature: Function goto stream position added, ctrl+g
* feature: Function set zoom added, ctrl+z
* feature: Function fullzoom added, shift+ctrl+z
* feature: Immediately play a label after creating it (Edit'n'play mode), alt+e
* feature: Added drawerobj.disp().save bool to flag transient plots (that should not be saved)
* feature: Added segment label view, marker_plotsegments.
* core: Added userdata field to marker_errorhandler(), used by marker_dispatcher
* core: Cleanups in marker_xrange, added marker_xrangeabs for absolute position move
* core: Added sound test routine WAVPlayerTest (not integrated into Marker startup)
* core: Label modifying modes display default label
* core: marker_ginput and _marksegment pass keyboard inputs to caller
* core: Version numbering now handled in marker_version.m
* bugfix: marker_viewer now displays correct unit type
* bugfix: Corrected label selection in marker_findoverlap, can display label size 1sa
* bugfix: Reset now definately redraws the screen, before any scheduled command
* bugfix: Label selection now prints out label number for all selections (marker_makelabelstr.m)
* bugfix: Switched off latex interpretation of label names
* bugfix: Playing of plot without player function may resulted in global error
* bugfix: Corrected display errors when using spare plots (marker_viewer.m)
* bugfix: Improved label checks; modified flag now indicates label changes in marker_init.m
* bugfix: Import labeling for CLA files had unresolved reference
oam, 2007/05/10



### 0.9.2
* bugfix: Function 'w' uses last label as default selection
* bugfix: Prevent using further functions while in save on exit dialog
* bugfix: Automatic estimation of drawerobj.disp().datasize left dynamic load mode unusable
* bugfix: Circumvent bug in Matlab audioplayer to play chunks smaller than 0.75 seconds (WAVPlayer.m)
* bugfix: Corrected messages/display for function 'alt+w'
* bugfix: Player returned from non-playable plot with last error although no error was present
* bugfix: Improved marker_guessylim(), now supports constant line plots
* core: Improved setup of drawerobj.disp().hideplot and drawerobj.disp().xvisible (marker_init.m)
* core: Removed old implementation of WAV player, now supports continuous sound (WAVPlayer.m)
* core: Support for correction of individual labelstrings, e.g. when empty in marker_init.m
* feature: Added support for SPARE plot (see marker_demo.m for configuration)
* feature: Label selection now prints out label number
oam, 2007/04/11


### 0.9.1
* bugfix: removed error when starting without initial labels
* bugfix: changed plotfunc_params behaviour and removed set linewidth hack in marker_viewer.m
* bugfix: Fixed some inconsistencies in drawerobj.disp().ylabel initialisation
* core: added automatic estimation of drawerobj.disp().datasize to marker_init.m
* core: updated marker_demo.m, how_to_use_marker.m
Thanks to Andreas for the line width patch.
oam, 2007/03/31


### 0.9.0
* feature: added plot method for labeling, marker_plotlabeling.m
* feature: initial window size configurable, drawerobj.windowsizescaling, .screensize
* feature: jump to next/previous label, ctrl+n/b
* feature: label bounded play function, alt+p (data probe/cursor moved to alt+c)
* feature: support for changing labeltextstyle in Marker properties (Ctrl+p)
* feature: added drawerobj.windoworientation to imporve window display
* core: support for parameterised plot functions
* core: corrected naming convention for dynamic load mode in drawerobj to loadfunc_*
* core: changed naming convention for plot function in drawerobj to plotfunc_*
* core: removed shortcut 'x', use 'ctrl+s' instead (backlog from version 0.8.0)
* core: removed shortcut 'i', use 'ctrl+o' instead (open labeling file dialog)
* core: removed shortcut 'g', use 'ctrl+x' instead (export figure graphics file dialog)
* core: removed shortcut 'l', use 'i' instead (label information)
* core: removed shortcut 'alt+p', use 'alt+c' instead (data probe/cursor mode)
* core: support disp().legend as alternative for disp().signalnames
* core: show/hide signal/labels detects when one plot is visible only
* core: added more checks in marker_init.m
* bugfix: corrected conflist varargout in segments2classlabels.m
* bugfix: ylim guessing now work for each plot individually (problem in marker_init.m)
* bugfix: initlabels supports unsorted input, initlabels startup checks improved.
* bugfix: corrected file name logging in marker_getdatafromfile.m 
* bugfix: added drawnow in marker_statusaxes.m for Windows platforms
Thanks to Martin for debugging version 0.8.0.
Thanks to Georg for debugging version 0.8.0.
Thanks to Martin for the jump to next/previous label code.
oam, 2007/03/25


### 0.8.0
* feature: support for defining label bounds in arbitrary order (end-begin OR begin-end)
* feature: added dataset statistics function in 'Shift+l' mode
* feature: signal name configurable (for show/hide signal selection)
* feature: added drawerobj.labelcolormap to choose common label colors or plot individual
* feature: label extending to another label bound
* core: support for canceling operation in marker_setlabel.m
* core: changed marker interface: iofilename and defaultDir may be supplied in drawerobj only
* bugfix: corrected visible label selection bug in marker_marksegment.m
* bugfix: marker_init.m: Check/omit initlabels for smaller or equal zero
* bugfix: marker_init.m: Check/correct initlabels label size
* bugfix: label delete did not resort labels
* bugfix: changed showlabels to logicals
* bugfix: errordlg reports non-maskable in console mode
* bugfix: saving crashed when file permission was denied
* bugfix: make label overlap check report state when called by shortcut
Thanks to Martin for debugging and bugfixes of version 0.7.0.
Thanks to Georg for debugging and bugfixes of version 0.7.0.
oam, 2007/03/02


### 0.7.0
* feature: status text support in main window
* feature: support for mouse pointer panning on main window
* feature: support for show/hide labels on each plot, Alt+l
* feature: marker properties config menu, Ctrl+p
* feature: extended alignment mode by labeling shift and labeling resampling
* feature: restructured alignment mode functions, now plot specific
* feature: time axis units display options (Ctrl+p): seconds (default),samples,min:sec
* feature: Ctrl+s as alternative shortcut for export/save labeling
* feature: Selectable player source for each plot (Shift+p)
* core: labels can now be supplied by drawerobj.seglist OR initlabels upon starting
* core: refactoring of marker.m, changed callback concept
* core: moved 'ShowHiddenHandles' hack to main fcn, since only place without callback
* core: marker_findselectedplot now determines pointer selected plot
* core: marker_viewer() cleanup
* core: support for command queue in maker_dispatcher
* core: major re-work of menu structures, supports UI and console; marker_menudlg()
* core: marker_errorhandler to catch errors and provide debug infos
* core: wrapper for drawerobj operations, including labeling, marker_modifydrawerobj()
* core: experimental changes for label commenting support
* bugfix: completely redraw display after resizing window
* bugfix: switch off backingstore manually
* bugfix: check initlabels column number, truncate if needed
* bugfix: when exited prematurely from modify function, last label was lost
* bugfix: Matlab file dialog problem (ui[get/put]file) could lead to empty filenames
* bugfix: main window was out of screen on Win systems when started
* bugfix: modify set label confidence to 1 erasing old setting
oam, 2007/02/23



### 0.6.3
* bugfix: correct interpret marker_player return value
* bugfix: signal probe reported wrong signal numbers when signals were hidden
* bugfix: signal hide accepts now input in valid range only
* core: changed renderers * now OpenGL is used, even if no labels are displayed
oam, 2007/01/03


### 0.6.2
* bugfix: if only one subplot, alt-s would display that it cannot hide subplot, but still do it
* core: use drawerobj.disp(splot).plotTag to identify active subplots, this covers marker.m,
	marker_ginput.m, and marker_markit.m. Now those files are independent of viewer.m and
	viewer() can arrange the subplot as the wishes (e.g. with subplot(1,5,i) or
	axes('Position',...), it even allows to display other graphics elements like pictures
* bugfix: corrected xticks in viewer, now starts at time 0 and works if less then 10 samples displayed
Thanks to Mathias for the above patches!
* core: refactored init code and added many checks, now in marker_init.m
mst, oam, 2006/11/23

### 0.6.1
* bugfix: removed second figure bug, thanks to Martin for the patch!
* bugfix: data probe now reports signal value, not mouse position
* feature: on-demand load funcitons now can have optial parameters
* core: confirm question before really exiting program
* bugfix: corrected sections for playing with marker_player()
oam


### 0.6.0
* bugfix: corrected latex interpretation of default class names
* bugfix: initialsation of hideplot was buggy, thanks Mathias!
* core: improved error handling when started with incosistent information
* core: re-implemented on-demand loading, EXPERIMENTAL
	see how_to_use_marker.m for guidance
* core: added datatypes var when saving CLA file format for ref. to align* vars
* core: removed cells from ylabel field, compatibiltiy to < 0.6 added
* core: add text to subplot show/hide selection, oam
* feature: data probe/cursor 'Alt+p'
* feature: optional label overlap check 'Alt+j', EXPERIMENTAL
oam, 2006/11/20


### 0.5.2
* core: changed marker_main.m to how_to_integrate_marker.m
* core: improved label color handling in marker_plotmark.m
* core: remove time from all subplot, except bottom, marker_viewer()
* core: hide/show subplots, EXPERIMENTAL, oam
* bugfix: segments2labeling() class column extraction
* bugfix: labeling2segments() bug, doubled entries
oam, 2006/11/16


### 0.5.1
* bugfix: died when launching w/o initial labels, bug in tentatives
oam, 2006/10/21

### 0.5.0
* feature: Import compatibility for older Marker versions (cla lists)
* bugfix: Labeling and information import from file now working
* bugfix: 'm' does not "forget" old label when terminated before/in step 2
* feature: 'w' can now be applied to multiple labels (similar to e.g. 'c')
* feature: added function to prune labels with size 0 or 1 (alt-'p')
* bugfix: 'm' mode indicated modified seglist although nothing was changed
* feature: added tentative label functionality (6th column of seglist)
* core: changed Marker CLA format, uses seglist instead of cla now
* feature: mode 'c' now supports deleting multiple labels (one only: mid pointer)
* feature: new mode 'l' for duration/position info of one label
* core: changed mode 'l' to 'shift-l', see help
* core: Changed labeling import key from 'a' to 'i'
* bugfix: marker_resort() crashed when called with an empty seglist
* core: improved marker_plotmark() text label display
* core: improved marker_helpscreen() org and display
* bugfix: modify mode loops in 2nd stage if overlap detected
* bugfix: function 'C' not working
* feature: new mode '.' to move one end of label
* feature: view and view size [s] in x-axis text
* bugfix: more than 100 percent view
* bugfix: when player crashes/terminates mouse changes back to 'arrow'
* bugfix: modified NULL-assignment in segments2labeling()
* feature: special function 'alt-w' to enable/disable default label
* core: changed function setting default label to use 'shift-w' key
oam, 2006/10/03


### 0.4.2
* label text support added with obj.labeltextstyle = 'name'
* automatic label text switch added (obj.labeltextstyle = 'auto')
* changed signal show/hide 's' to 'S' since used rarely
* extended play mode to play segment label (use mid pointer)
* added marker_findsegfrompos(), used by marker_pointsegment() and marker_marksegment()
* bugfix: WAVPlayer() now supports stereo sound
* modified internal user event handling to support special chars
* changed function of keys 'N', 'B' to use home/end keys
* added fast/slow data move by 'shift-*' and 'alt-*'
* bugfix: program exit with 'q' did not save modifications
oam, 2006/08/13

### 0.4.1
* removed legacy player/viewer functions
* modified section playing interface: see marker_player()
* added functions to load/play WAV files to the toolbox (WAVReader/WAVPlayer)
* new field: obj.disp().type to identify plot type, e.g. 'WAV'
* two column listing for marker_setlabel() and label list function ('l')
* bugfix: improved signal hide support in marker_viewer() 
oam, 2006/07/25

### 0.4.0
* added signal show/hide function ('s')
* bugfix: variable subplots in marker_ginput()
* added functionality to guess y-axis view, marker_guessylim()
* extended 'v' mode to zoom/move data for improved y-axis display
* corrected ambiguous config texts at startup
oam, 2006/07/22


### 0.3.2
* bugfix: maxLabelNum/maxLabelNum=1 not working
* bugfix: undeclared segment_size in classlabels2segments()
* corrected some help text issues and added config error checks
* added label ID change function ('w')
* added default label feature ('L')
* changed key for keyboard edit mode ('E' => 'k')
oam, 2006/07/14


### 0.3.1
* save time and marker version in CLA format
* created deployment template (marker_main.m)
oam, 2006/07/06


### 0.3.0
* code refactoring
* changed method naming convention
* redesigned data alignment
* bug fixing
oam, 2006/05/03


### 0.2.10
* bugfix 'hold on' in wav_labelview caused display errors
* fix blind variable load, now all variables are cleared before load()
* changed alignment handling
* dataaligner() now fixed part of marker
* bugfix checks for dataaligner() and alignrange while loading added
* improved readability of labels displayed by dataprinter() method
* added option 'E': edit labels by keyboard entry
* bugfix WAVFile in wav_labelview()
* added GPL license text, this toolbox is now available under GPL license
oam, 2006/04/18


### 0.2.9
* added option 'C': delete a segemnt by segment number
* added some comments on alignment
* print out selected file type when saving
oam, 2006/03/26


### 0.2.8
* added segment save option (w/o append)
* made dataviewer() independent (do not use plotfmt()-function)
oam, 2006/03/21


### 0.2.7
* added modify mode
* removed bug in alignment mode
* removed unused reference to repository in dataviewer()
oam, 2006/03/21


### 0.2.6
* extention of alignment mode (EXPERIMENTAL)
* added subplots variable to control # of plots (1 or 2)
oam, 2006/03/19


### 0.2.5
* added a data alignment mode (EXPERIMENTAL)
* changed load/save texts (more verbose)
* error handling for empty seglist in segments2classlabels()
* added markersps variable to CLA output filetype
* extendend funcitonality of segments2labeling() with totalsize param
* documented some shortcommings
oam, 2006/02/09


### 0.2.4
* corrected bug if xrange_vis > datasize in startup
* corrected bug in markit(): check for empty label list
* added partsize field to cla data format (export mode)
* corrected seglist problem in markit() for dynamic load mode
oam, 2006/01/05


### 0.2.3
* corrected iofilename bug in export figure
* corrected labelstrings default initialisation bug
* changed seglist sorting (code nicing only)
oam, 2005/10/25


### 0.2.2
* corrected zoomfac variable bug
oam


### 0.2.1
* added customizable title
* added label selection list for edit mode
* added segment list import function
* increased verbosity when loading/saving files
* added keys for getting to first/last slice of data ('B', 'N')
* added delete all key ('D')
* corrected a bug in edit mode; now checks for empty seglist
* added some comments to enable cell mode (m-file editor)
oam, georg


### 0.2.0
* code cleanups
* added segment printing hook
* adaped window size defaults
* changed default parameter handling
* added xoffs defaults
* new revision numbering scheme
oam


### 0.1d
* added keystroke to export current figure
* bug fixes
georg, csn

### 0.1c
* switched from global vars to nested functions
* no endless loop any more (unfortunately, no return value as well)
* program quits, in case fig is closed
* seg-list contains 5 rows now: [start, stop, length, labelNumber, segNumber]
* plotmark also adds text to the filled polygons
* drawerobj has a field 'maxLabelNum' (passed, e.g., to plotmark)
* all 'hold on' and 'hold off' in fcn 'markit', the viewer fcn should
      contain no 'hold on' or 'hold off' as well
georg, csn

### 0.1b
make it standalone, removed some debugging stuff, oam
added some nice comments, oam

### 0.1a
initial release version, oam

