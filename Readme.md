
This document is always behind the code. You may use it as a general guidline.
Please see ~~www.ife.ee.ethz.ch/~oam/software~~ for new releases of ***marker*** and this
document. See CHANGELOG.md for a development history of this toolbox.

Comments, suggestions and improvements welcome! Send your message to 
~~marker@list.ee.ethz.ch. Make sure to search the list archive 
(http://lists.ee.ethz.ch/marker/)  before mailing.~~

## Main developers and contributors

* Oliver Amft, ETH Zurich, Wearable Computing Lab & Actlab, Uni Passau
* Georg Ogris, ~~UMIT CSN Innsbruck~~
* Martin Kusserow, ~~ETH Zurich, Wearable Computing Lab.~~
* Mathias Staeger, ~~UMIT CSN Innsbruck~~



## General information - How to get started in 10 minutes...

See also the template startup script `how_to_use_marker.m` and the 
self-demo `marker_demo.m`


## Installation

Unpack the zip to a directory (preferably to your location of Matlab
toolboxes). Add the **marker** path to your Matlab search variable.

## Getting familiar to the configuration

Below are the critical aspects you should know. A template script to adapt
**marker** to your environemt follows below (step 3).

**marker** calling procedure:
```
       function marker(drawerobj, initlabels)
```

Parameters in brief:
* `drawerobj` main control structure with several configuration fields
                     Some of the important ones are cited in this document;
                     many others can be set. After reviewing this document and 
                     the template startup script `how_to_use_marker.m` see 
                     `marker_init.m` for optional settings that can be overridden 
                     by custom startup scripts.
* `initlabels`    Labeling list with the format (in samples): 
                        `[begin end length class id confidence]`
                     "begin" and "end" are mandatory fields when initial labels
                     shall be used/displayed. As an alternative initial labels
                     can be configured in `drawerobj.seglist`. Only one of these
                     options may be used.


The `drawerobj` structure (selection of fields):
mandatory fields:
* `disp(n)`       structure of n plots to display, see below

optional fields (all assume a default when not found):
* `title`         String to control the window title
* `labelstrings`  String cell array of names for the labels
* `maxLabelNum`   Maximum number of classes/label types
* `iofilename`    import/export default file name (default: labeling.mat)
* `defaultDir`    start directory for import/export (default: current dir)


The drawerobj.disp(n) structure (n=number of plots):
mandatory fields:
* `sfreq`         initial sample rate (MUST BE EQUAL FOR ALL PLOTS)
* `datasize`      total size of data to display (e.g. samples)
* `func`          Plot function
* `data`          The data to be displayed itself

optional fields (all assume a default when not found):
* `xvisible`      initial visible data range (can be changed during runtime)
* `ylabel`        Some vertical text for the plot (string)


## Adaptation to your environment

Now, having seen some options, copy and edit the script `how_to_use_marker.m`
file to adapt **marker** to your environment.

Remark 1 on sampling rate/responsiveness: It is strongly recommended to use data
sampling rates below/at 100Hz since Matlab tends to get slow with high amounts
of data to display/load into memory. One strategy is to downsample/average the 
display signals for **marker** in advance and load these. The play function can still
use the data at the original resolution (see the player examples for details).
An data on-demand loading mode is available in **marker** to display WAV files
however this is slow as well. Loading functions for other data may be interfaced
to **marker**.

Remark 2 on sampling rate: Although the interface suggests it, it is currently
NOT supported to run **marker** with different sampling rates for each subplot. I
downsample the data to a common rate before using **marker**, see remark 1 above.
This function may be added on request in future versions.


## Annotation!

Run your script and have marking fun. Press `h` to get help on the available
commands at the Matlab console screen.


There are much more that can be customised with **marker**. Let me know if you have
any wish. See also WISHLIST.md for issues/feature requests that have been raised
already. Furthermore there are conversion scripts provided to convert the
labelling information to different formats. See `segments2*.m` functions.



## Known bugs / limitations
See WHISHLIST.md to get an overview on what is open/unsolved.

* Fixed data sampling rate and view range for subplots
  Currently **marker** does not support different data sampling rates for each
  subplot. Different view ranges are not supported either.

* Linux X-Server issues: **marker** is somewhat demanding for the graphics output
  of Matlab. There have been several reports of malfunctioning servers with 
  Matlab under Ubuntu and SUSE Linux. Upgrading distributions has helped in 
  most cases.

* Linux issues: The file saving dialog of Matlab R14 and lower, seems to work
  poorly. You may need to enter the filename, altough iofilename/defaultDir 
  are set in drawerobj.

* Windows issues: Windows does not support the intermediate command features
  of **marker**. This means you cannot run other commands while in edit/modify modes.

* Mac issues: Spurious **marker**/Matlab crashes?? Need to be confirmed.



## **marker** menu (this screen is printed on the console by pressing 'h')
```
This is current as of version 1.0.0.

**marker** 1.0.0 keyboard shortcut help

--- Editing labels --------------------------------------------------------------
 e          Create (pointer)               m          Cut/modify                    
 Shift+e    Create (keyboard)              Point      Extend/crop                   
 Comma      Extend to another/tile         w          Change label ID...            
 Shift+t    Toggle tentative               c          Comment/tag (not supported)   
 Alt+e      Enable edit'n'play            
--- Deleting labels -------------------------------------------------------------
 d          Delete (pointer)               Shift+d    Delete all...                 
 Shift+c    Delete (keyboard)              Alt+d      Selective delete/prune...     
--- Moving through data ---------------------------------------------------------
 b/n        Back/forward (0.5x screen)     z          Horizontal zoom out/in...     
 Alt+b/n    Back/forward (0.25x screen)    v          Vert. zoom/baseline move...   
 Shift+b/n  Back/forward (1x screen)       End        Jump to end of data           
 Home       Jump to begin of data          Ctrl+b/n   Jump to prev/next label       
 Ctrl+g     Goto position                  Shift+z    Set zoom                      
 S+C+z      Full zoom                     
--- I/O commands ----------------------------------------------------------------
 Ctrl+o     Open/load label list...        Shift+l    Printout lists...             
 Ctrl+s     Save label list...             Ctrl+x     Export figure graphics...     
--- Other commands --------------------------------------------------------------
 h/?        This screen                    r          Redraw view                   
 a          Data alignment...              p          Play section...               
 Alt+p      Play up to label bounds        Shift+p    Select player                 
 Shift+s    Show/hide signals in a plot... Alt+s      Show/hide plot                
 Alt+l      Show/hide labels               i          Label information             
 Alt+c      Data cursor/probe              Alt+j      enable label overlap check    
 Shift+w    (un)set default label          Alt+w      (N/A)                         
 Ctrl+p     **marker** properties...           q          Quit program                  

To exit from functions use right mouse button (or as indicated).
```


## Customising **marker**

`viewer()` function shall return a x-dim display offset when plotting
relative data views (e.g. when reading data on-demand)

To make `viewer()` do something useful you may add arbitrary fields
and sub-structures to drawerobj.

Calling procedures:
viewer:   `viewer(drawerobj, xrange)`

For more details have a look at the code or contact me.


## On-demand data loading

**marker** is shipped with a function to load WAV data on demand. See
how_to_use_marker.m for details. The loading function is called with the bounds
for each new view to display. Furthermore the function or another method may be
used to initially determine sampling rate and data size of hte plot.



## Technical details (outdated)

This doc is behind the code. Just take this as a reference.


### Playing of WAV files:

Try `WAVPlayerTest.m` to test your system's audio output. If you do not hear sound
there is most certainly something wrong with your Matlab configuration. Try 
restarting Matlab or other software which uses the Java sound interface (e.g. Firefox).


### Labels:

The labels are valid sample indices with respect to the following parameters:
* configured alignment shift
* configured alignment sample rate



### `viewer()`

The viewer receives the common object data structure that may contains private
information on how to display data, as well as the disp(n).*
fields. disp(n).xrange describes the sample boundaries of data sections that
should be displayed for each plot. These variables are controlled by **marker** core
methods only and may not be modified by external functions. The viewer-function
supplied with **marker** supports a number of further functions: data alignment,
hiding of signals, plots.  Two modes for data visualisation exist, namely
on-demand data load and entire data load.


### `viewer()` entire data load:

The data is loaded entirely into a Matlab variable. This mode is useful for
small data sets. It may not be feasible for e.g. 30 minutes of stereo-audio data
sampled at 44kHz (amounts to 30*60*44100Hz > 75MBytes). Data extraction is
handled by `marker_getdatafrombuffer(). Here entire and on-demand load are
handled differently.


### `viewer()` on-demand data load mode:

This operation allows dynamic on-demand loading of data when needed for
visualisation. disp(n).xrange keeps track on the data section needed for each
plot. This mode is intended to avoid loading very large datasets entirely into a
Matlab variable. However small data sets can be managed more effectively when
loaded completely. Therefore both modes (on-demand data load and entire data
load) coexist.

Fields to configure on-demand load

Prototypes for on-demand loading function:
```
      data = loadmydata(filename, Range);
      data = loadmydata(filename, Range, varargin);
```
The second version spplies user data in loadfuncparams. Use a cell array
to pass more than one parameter.



For both modes the Matlab figure object does not know the real sample range that
is visualised. Hence it will return mouse pointer responses starting with sample
1. Since **marker** uses internally the real sample values to store labelling and
visualisation information, a offset must be added to all such figure responses
(variable: xdynoffset). This is done automatically, however the viewer-method
needs to provide this offset, since **marker** itself does not know whether the data
is visualised in on-demand data load mode or is entirely loaded into a variable.

### Video integration

**marker** allows you to trigger video playbacks, e.g. by using the [videoio player](http://www.mathworks.com/matlabcentral/fileexchange/35119-videoioplayer)


### Alignment function

Data alignment is done by "shifting" the data visually under the labelling (and
hence relative to other data streams). This operation is achieved by adding an
offset to the disp(n).xrange. (This will also produce the "empty" space at the end
of a data stream. This is left in order to allow visually verification of the
data shift.)

The shift (variable: disp(n).alignshift) is greater or equal zero at all times. It
is stored in the common object structure in the display specific sections, since
it can be individually adjusted for each display. It is modified by the
alinger() method only. **marker** will use the shift value to modify xrange (see
Section on `viewer()`). `viewer() must not read/modify this variable.

This feature requires that plots can have a different view range (see Section on
`viewer()`, variable: disp(n).xrange).



### Resample function

Data resampling is done by modifying all sample-referencing variables (mostly
xrange, alignshift) in resampler(). The following formula is applied: 
```
        newrange = ceil( length(oldrange) * newsps/oldsps ).
```
The data resampling itself is done for the current data view only (for
displaying) by `viewer()`. The rate (variable: disp(n).alignsps) is stored per
view as absolute rate. The relative change must be derived in the `viewer()`
method by evaluating the original sampling rate (stored in the common data
structure, variable: sfreq). A `viewer()` method that does not support
resampling will display the data with the original sampling rate
only. `viewer()` must not modify this variable.




