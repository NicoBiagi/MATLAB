[y, freq] = psychwavread('left.wav');
info = audioinfo('left.wav');
soundLength = info.Duration;
wavedata = y';
nrchannels = size(wavedata,1);
InitializePsychSound(1);
try
    % Try with the 'freq'uency we wanted:
    pahandle = PsychPortAudio('Open', [], [], 0, freq, nrchannels);
catch
    % Failed. Retry with default frequency as suggested by device:
    fprintf('\nCould not open device at wanted playback frequency of %i Hz. Will retry with device default frequency.\n', freq);
    fprintf('Sound may sound a bit out of tune, ...\n\n');
    
    psychlasterror('reset');
    pahandle = PsychPortAudio('Open', [], [], 0, [], nrchannels);
end

% Fill the audio playback buffer with the audio data 'wavedata':
PsychPortAudio('FillBuffer', pahandle, wavedata);
% Start audio playback for 'repetitions' repetitions of the sound data,
% start it immediately (0) and wait for the playback to start, return onset
% timestamp.

t1 = PsychPortAudio('Start', pahandle, [], 0, 1);
WaitSecs(soundLength);
PsychPortAudio('Stop', pahandle);

PsychPortAudio('Close', pahandle);

