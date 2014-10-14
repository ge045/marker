function ok = WAVPlayer(samples, rate, verbose)
% function ok = WAVPlayer(samples, rate, verbose)
%
% WAVPlayer for PC and Unix
%
%   samples:            wav data
%   rate:               sampling rate (supported by most sound cards are
%                       8000, 11025, 22050, and 44100 Hz)

% Copyright 2005 Oliver Amft, ETH Zurich, Wearable Computing Lab.

% -------------------------------------------------------------------
%     This program is free software; you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation; either version 2 of the License, or
%     (at your option) any later version.
% 
%     This program is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
% 
%     You should have received a copy of the GNU General Public License
%     along with this program; if not, write to the Free Software
%     Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
% -------------------------------------------------------------------

% Matlab will not play chunks that are shorter than 0.5 sec properly. Hence
% the signal vector is extended to 0.75sec here.
minplaysize = round(rate*0.75); % see comments below
%minplaysize = 0;

ok = true;

if (exist('verbose','var')~=1), verbose = 0; end;

if (nargin < 2)
    disp('INFO: Assuming sample rate (44100 Hz).');
    rate = 44100;
end;

% extend signal vector to 0.75sec
if (length(samples) < minplaysize)
	samples = [ samples; zeros(minplaysize -length(samples), size(samples,2)) ];
end;

% play it
ph = audioplayer(samples, rate, 16);
play(ph);
% OAM REVISIT:
% found a way to detect that sound device hangs/blocks so far
% playblocking() is not blocking as expected
while ~isplaying(ph); end;
while isplaying(ph); end;

if (verbose), fprintf('Done.\n'); end;
return;


% % old implementation, this was needed for earlier versions of Matlab that
% % could not play more than ~10 sec of audio
% playseg = 10 * rate; j = 1;
% if (verbose), fprintf('playseg: %u (%.1fs), iterations: ', playseg, playseg/rate); end;
% 
% for i= 1 : playseg : size(samples,1)
%     if (i+playseg < size(samples,1))
%         playend = i+playseg;
%     else
%         playend = size(samples,1);
%     end;
% 
%     temp = samples(i+1:playend,:);
% 
%     ph = audioplayer(temp, rate, 16);
%     if exist('phold','var')
%         while ~isplaying(phold); end;
%         while isplaying(phold); end;
%     end;
% 
%     play(ph);
%     if (verbose), fprintf('%u ', j); end;
%     phold = ph; j = j+1;
% end;
% 
% while ~isplaying(phold); end;
% while isplaying(phold); end;
% clear ph phold;
% if (verbose), fprintf('Done.\n'); end;
