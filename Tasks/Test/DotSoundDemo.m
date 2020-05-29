clearvars;
close all;
clear;
sca;
clc;

%%%%%%%%%%%%%
%Sound Setup%
%%%%%%%%%%%%%
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

%%%%%%%%%%%%%%
%Screen Setup%
%%%%%%%%%%%%%%

% Here we call some default settings for setting up Psychtoolbox
Screen('Preference', 'SkipSyncTests', 1);

% Get the screen numbers. This gives us a number for each of the screens
% attached to our computer. For help see: Screen Screens?
screens = Screen('Screens');

% Draw we select the maximum of these numbers. So in a situation where we
% have two screens attached to our monitor we will draw to the external
% screen. When only one screen is attached to the monitor we will draw to
% this. For help see: help max
screenNumber = max(screens);

% Define black and white (white will be 1 and black 0). This is because
% luminace values are (in general) defined between 0 and 1.
% For help see: help WhiteIndex and help BlackIndex
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);

% Open an on screen window and color it black.
% For help see: Screen OpenWindow?
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, black);

% Enable alpha blending for anti-aliasing
% For help see: Screen BlendFunction?
% Also see: Chapter 6 of the OpenGL programming guide
Screen('BlendFunction', window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

% Get the size of the on screen window in pixels
[screenXpixels screenYpixels] = Screen('WindowSize', window);

% Query the frame duration
ifi = Screen('GetFlipInterval', window);

% Sync us and get a time stamp
vbl = Screen('Flip', window);
waitframes = 1;

% Get the centre coordinate of the window in pixels
% For help see: help RectCenter
[xCenter, yCenter] = RectCenter(windowRect);

soundLengthFrames = round(soundLength/ ifi);
numSecs= 1;
numFrames = round(numSecs/ ifi);



dotSizePix = 20;
numberDots= 2;
for i = 1:numberDots
    t1 = PsychPortAudio('Start', pahandle, [], 0, 1);
for i = 1:soundLengthFrames
    Screen('DrawDots', window, [xCenter yCenter], dotSizePix, [], [], 2);
    vbl  = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
end
PsychPortAudio('Stop', pahandle);
for i = 1:numFrames
        vbl  = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
end
end 

PsychPortAudio('Close', pahandle);
sca;