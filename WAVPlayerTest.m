function ok = WAVPlayerTest(verbose)
% function ok = WAVPlayerTest
% 
% Test audio play

ok = false;
if ~exist('verbose','var'), verbose = 1; end;

if (verbose), fprintf('\n%s: Loading audio data...', mfilename); end;
load handel;

if (verbose), fprintf('\n%s: Preparing player...', mfilename); end;
player = audioplayer(y, Fs);

try
	if (verbose), fprintf('\n%s: Start playing...', mfilename); end;
	%play(player,[1 (get(player, 'SampleRate')*3)]);
	play(player);
	
	if (verbose), fprintf('\n%s: Waiting for player to finish...', mfilename); end;
	while ~isplaying(player); end;
	while isplaying(player); end;
	
	ok =true;
	if (verbose), fprintf('\n%s: Success.', mfilename); end;
catch
	errorlog = lasterror;
	fprintf('\n%s: Error message: \n%s\n', mfilename, errorlog.message);
	
	ok = false;
end;
