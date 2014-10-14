function [drawerobj str xtls xticks] = marker_timeaxisunits(fh, drawerobj, splot, xrange, xtickmarks)
% function [drawerobj str xtls xticks] = marker_timeaxisunits(fh, drawerobj, splot, xrange, xtickmarks)
% 
% Set drawerobj.timeaxissamplesconv and returns several time axis elements
if ~exist('splot','var'), splot = 1; end;
if ~exist('xrange','var'), xrange = drawerobj.disp(splot).xrange; end;
if ~exist('xtickmarks','var'), xtickmarks = 11; end;

xtlinc = abs(diff(xrange))/(xtickmarks-1);
xticks = (xrange(1): xtlinc :xrange(2)) -1;
xtls = {};

switch lower(drawerobj.timeaxisunits)
	case 'seconds'
		str = 'seconds';
		convunit = [drawerobj.disp(:).sfreq];
		for xtli = 1:xtickmarks
			xtls = {xtls{:} num2str(xticks(xtli)/drawerobj.disp(splot).sfreq, '%.1f')};
		end;
	case 'samples'
		str = 'samples';
		convunit = ones(drawerobj.subplots,1);
        xtls = cell(1,xtickmarks) ;
		for xtli = 1:xtickmarks
			xtls{xtli} = num2str(round(xticks(xtli)), '%u');
		end;
	case 'min:sec'
		str = 'minutes';
		convunit = [drawerobj.disp(:).sfreq] .* 60;
		for xtli = 1:xtickmarks
			tmp = xticks(xtli)/drawerobj.disp(splot).sfreq;
			xtls = {xtls{:} sprintf('%02u:%02u',   floor(tmp/60), round(mod(tmp,60)) ) };
		end;
end;

if ~isempty(fh)
	marker_log(fh, '\n%s: Conversion unit: %s', mfilename, mat2str(convunit)); 
end;

drawerobj.timeaxissamplesconv = convunit;

