clearvars;
close all;
clear;
sca;
clc;

commandwindow;

% Query the current working directory
a = pwd;

% Load all the .wav files found in the current working directory
files = dir(strcat(a, '/*.wav'));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Prompt Info
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
prompt = {'Enter ID:','Session Number:', 'Eyetracker:', 'use ViewPixx:'};
run_info = inputdlg(prompt, 'Info', 1, {'AVS_', '1', 'Y','Y'});
SubID = run_info{1};
SessionNo = run_info{2};
Eyetracker = run_info{3};
useViewPixx = run_info{4};
DateT = date;

if Eyetracker == 'Y'
    
    % Skip sync tests for demo only
    Screen('Preference', 'SkipSyncTests', 2);
    
    % Get the screen numbers. This gives us a number for each of the screens
    % attached to our computer.
    screens = Screen('Screens');
    
    % Draw we select the maximum of these numbers.
    screenNumber = max(screens);
    
    % Define black and white (white will be 1 and black 0).
    white = WhiteIndex(screenNumber);
    black = BlackIndex(screenNumber);
    
    % Open an on screen window and color it black
    [window, windowRect] = PsychImaging('OpenWindow', screenNumber, black);
    
    
    % Enable alpha blending for anti-aliasing
    Screen('BlendFunction', window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    % Query the frame duration
    ifi = Screen('GetFlipInterval', window);
    
    
    % Get the size of the on screen window in pixels
    [screenXpixels, screenYpixels] = Screen('WindowSize', window);
    
    % Get the centre coordinate of the window in pixels
    [xCenter, yCenter] = RectCenter(windowRect);
    
    % Draw text in the middle of the screen in Times in white
    Screen('TextSize', window, 100);
    Screen('TextFont', window, 'Times');
    DrawFormattedText(window, 'Welcome to the experiment', 'center', 'center', white);
    % Draw text in the bottom of the screen in Times in white
    Screen('TextSize', window, 50);
    Screen('TextFont', window, 'Times');
    DrawFormattedText(window, 'Press any key to continue', 'center',...
        screenYpixels * 0.85, white);
    
    % Flip to the screen
    Screen('Flip', window);
    
    KbWait
    WaitSecs(0.2);
    
    % Draw text in the middle of the screen in Times in white
    Screen('TextSize', window, 35);
    Screen('TextFont', window, 'Times');
    DrawFormattedText(window,'Before doing the task the eye-tracker calibration will be performed.\n\n Your task is to look at the small black dot within the white circle, \n \n and follow its movements with your eyes without moving your head.\n\n After the calibration the main task will start. \n \n If you have any questions please ask the experimenter now, \n \n otherwise press any key to start the eye-tracker calibration', 'center', 'center', white);
    
    % Flip to the screen
    Screen('Flip', window);
    
    KbWait
    WaitSecs(0.2);
    
    %calling the Eyetracker Settings
    EyeTrackerSettings;
else
end

%Calling a function with all the screen settings
AFCScreenSettings;

% Parameters for using the ViewPixx
if useViewPixx == 'Y'
    
    PsychImaging('PrepareConfiguration');
    PsychImaging('AddTask', 'General', 'UseDataPixx');
    
    % Open Datapixx
    Datapixx('Open');
    
    % Setup scanning backlight
    Datapixx('EnableVideoScanningBacklight');
    
    % Calling this as we are presenting primes which are effectively
    % flickering (Check if you need this)
    %     if Datapixx('IsViewpixx3D')
    %         Datapixx('EnableVideoLcd3D60Hz');
    %     end
    
    % Regisetr this
    Datapixx('RegWr');
    
else
end

%%%%%%%%%%%%%%
%Screen Setup%
%%%%%%%%%%%%%%

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

numSecs= 1;
numFrames = round(numSecs/ ifi);

% %In each trial the outer wings will be either inwards or outwards
% % >-< 1
% % <-> -1
% % |-| 0
trialList(1:24)= -1; %inwards <-->
trialList(25:48)= 1; %outwards >--<
trialList(49:72)= 0; %flat |--|

% DEBUG
%trialList(1:4)= 0; %flat |--|

for i =1:(length(trialList)/6)
    Sound1(i) = 0;
end

for i =1:(length(trialList)/6)
    Sound2(i) = 1;
end

Sound = [Sound1 Sound2]
Sound = repmat(Sound, 1, 3)
b = [trialList;Sound]

for i =1:(length(Sound1)/2)
    ShaftLength1(i) = 1;
end

for i =1:(length(Sound1)/2)
    ShaftLength2(i) = 2;
end

ShaftLength = [ShaftLength1 ShaftLength2]
ShaftLength = repmat(ShaftLength, 1, 6)

ix = randperm(length(trialList));
trialList = trialList(ix);
Sound = Sound(ix);
ShaftLength = ShaftLength(ix);

%defining the angle between the arms of the fin.
alpha = 45/2;

%%FIXATION CROSSES SETTINGS
%Set the size of the arms of the big fixation cross
fixCrossDimDeg = 0.3; %degrees
fixCrossDimPix = fixCrossDimDeg * pixPerDeg;

% Coordinates for the big fixation cross
fixX = [-fixCrossDimPix fixCrossDimPix 0 0];
fixY = [0 0 -fixCrossDimPix fixCrossDimPix];
fixCoords = [fixX; fixY];

% Set the line width for the big fixation cross
fixWidthDeg = 0.1 ; %degrees
fixWidthPix = fixWidthDeg * pixPerDeg;

%Second fixation cross
fixCrossDimDeg2 = 0.2; %degrees
fixCrossDimPix2 = fixCrossDimDeg2 * pixPerDeg;

% Coordinates for the small fixation cross
fixX2 = [-fixCrossDimPix2 fixCrossDimPix2 0 0];
fixY2 = [0 0 -fixCrossDimPix2 fixCrossDimPix2];
fixCoords2 = [fixX2; fixY2];

fixWidthDeg2 = 0.05 ; %degrees
fixWidthPix2 = fixWidthDeg2 * pixPerDeg;

dotSizeDeg = 0.5;
dotSizePix = dotSizeDeg * pixPerDeg;
dotSizePix = 20;

%setting the keyboard
KbName('UnifyKeyNames');
KbQueueCreate(); %0 is main keyboard
KbQueueStart();
escapeKey = KbName('ESCAPE');
leftKey = KbName('LeftArrow');
rightKey = KbName('RightArrow');
Space=KbName('space');

% Draw text in the middle of the screen in Times in white
Screen('TextSize', window, 100);
Screen('TextFont', window, 'Times');
DrawFormattedText(window, 'Welcome to the experiment', 'center', 'center', white);
% Draw text in the bottom of the screen in Times in white
Screen('TextSize', window, 50);
Screen('TextFont', window, 'Times');
DrawFormattedText(window, 'Press any key to continue', 'center',...
    screenYpixels * 0.85, white);

% Flip to the screen
Screen('Flip', window);

KbWait;
WaitSecs(0.2);
% Draw text in the middle of the screen in Times in white
Screen('TextSize', window, 40);
Screen('TextFont', window, 'Times');
DrawFormattedText(window, 'In each trial of this task a ML stimulus will be presented.\n\n Before that a white dot will be presented in the centre of the screen.\n\n After one second the white dot will change colour and become either red or blue.\n\n If the dot becomes red you should ignore the ML stimulus and move your eyes towards the left part of the screen;\n\n while if the dot becomes blue you should move your eyes to the right part of the screen\n\n and look at the end point of the ML stimulus.\n\n If you have any questions please ask the experimenter now, \n\n otherwise press any key to start the eye-tracker calibration', 'center', 'center', white);% Flip to the screen
Screen('Flip', window);

KbWait;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if Eyetracker=='Y'
    Eyelink('StartRecording');
    eye_used = Eyelink('EyeAvailable'); % get eye that's tracked
    % returns 0 (LEFT_EYE), 1 (RIGHT_EYE) or 2 (BINOCULAR) depending on what data is
    if eye_used == 2
        eye_used = 1; % use the right_eye data
    end
    % record a few samples before we actually start displaying
    % otherwise you may lose a few msec of data
    WaitSecs(0.1);
else
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for i = 1:length(Sound)
       
    if Eyetracker=='Y'
        % Sending a 'TRIALID' message to mark the start of a trial in Data
        % Viewer.  This is different than the start of recording message
        % START that is logged when the trial recording begins. The viewer
        % will not parse any messages, events, or samples, that exist in
        % the data file prior to this message.
        Eyelink('Message', 'TRIALID %d', i);
    else
    end
    % Check the keyboard to see if a button has been pressed
    [keyIsDown,secs, keyCode] = KbCheck;
    if keyCode(escapeKey)
        %if the press the esc button they stop the experiment
        sca;
    end
    
    CrossDimDeg = ShaftLength(i);
    %Set the length of the main line of the illusion
    CrossDimPix = CrossDimDeg * pixPerDeg; %pixels
    
    %Set the width of the main line of the illusion
    lineWidthDeg = 0.1 ; %degrees
    lineWidthPix = lineWidthDeg * pixPerDeg; %pixels
    
    % Coordinates of the main line of the illusion
    xCoords = [0 2*CrossDimPix];
    yCoords = [0 0];
    allCoords = [xCoords; yCoords];
    
    if trialList(i)==0 %|--|
        
        EndWingXPix = 0;
        EndWingYPix = (CrossDimPix)/3;
        
        %Coordinates of the two wings of the illusion
        %Right Wings
        xCoordsRightWing = [2*CrossDimPix 2*CrossDimPix-EndWingXPix 2*CrossDimPix 2*CrossDimPix-EndWingXPix];
        yCoordsRightWing = [0 EndWingYPix 0 -EndWingYPix];
        allCoordsRightWing = [xCoordsRightWing; yCoordsRightWing];
        %Left Wings
        xCoordsLeftWing = [EndWingXPix EndWingXPix EndWingXPix EndWingXPix];
        yCoordsLeftWing = [0 EndWingYPix 0 -EndWingYPix];
        allCoordsLeftWing = [xCoordsLeftWing; yCoordsLeftWing];
        
    elseif trialList(i)==-1 %<-->
        
        EndWing = (2*CrossDimPix)/3;
        EndWingXPix = EndWing*cosd(alpha);
        EndWingYPix = EndWing*sind(alpha);
        
        %Coordinates of the two wings of the illusion
        %Right Wings
        xCoordsRightWing = [2*CrossDimPix 2*CrossDimPix-EndWingXPix 2*CrossDimPix 2*CrossDimPix-EndWingXPix];
        yCoordsRightWing = [0 EndWingYPix 0 -EndWingYPix];
        allCoordsRightWing = [xCoordsRightWing; yCoordsRightWing];
        %Left Wings
        xCoordsLeftWing = [0 0+EndWingXPix 0 0+EndWingXPix];
        yCoordsLeftWing = [0 EndWingYPix 0 -EndWingYPix];
        allCoordsLeftWing = [xCoordsLeftWing; yCoordsLeftWing];
        
    elseif trialList(i)==1 %>--<
        
        EndWing = (2*CrossDimPix)/3;
        EndWingXPix = EndWing*cosd(alpha);
        EndWingYPix = EndWing*sind(alpha);
        
        %Coordinates of the two wings of the illusion
        %Right Wings
        xCoordsRightWing = [2*CrossDimPix 2*CrossDimPix+EndWingXPix 2*CrossDimPix 2*CrossDimPix+EndWingXPix];
        yCoordsRightWing = [0 EndWingYPix 0 -EndWingYPix];
        allCoordsRightWing = [xCoordsRightWing; yCoordsRightWing];
        %Left Wings
        xCoordsLeftWing = [0 0-EndWingXPix 0 0-EndWingXPix];
        yCoordsLeftWing = [0 EndWingYPix 0 -EndWingYPix];
        allCoordsLeftWing = [xCoordsLeftWing; yCoordsLeftWing];
        
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Timing and draw the illusion
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    BlockStartSec = GetSecs;
    timeElapsedSec = 0;
    dotsOnDone = 0;
    
    %%%%%%%%%%%%%
    %Sound Setup%
    %%%%%%%%%%%%%
    if Sound(i) == 0
        [y, freq] = psychwavread(files(1).name);
        info = audioinfo(files(1).name);
    else
        [y, freq] = psychwavread(files(2).name);
        info = audioinfo(files(2).name);
    end
    soundLength = info.Duration;
    soundLengthFrames = round(soundLength/ ifi);
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
    for l = 1:numFrames
        %Draw the fixation cross
        Screen('DrawDots', window, [xCenter yCenter], dotSizePix, white, [], 2);
        vbl  = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
    end
    
    t1 = PsychPortAudio('Start', pahandle, [], 0, 1);
    for l = 1:soundLengthFrames
        %Draw the fixation cross
        Screen('DrawDots', window, [xCenter yCenter], dotSizePix, white, [], 2);
        vbl  = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
    end
    
    PsychPortAudio('Stop', pahandle);
    
    for l = 1:numFrames
        %Draw the fixation cross
        Screen('DrawDots', window, [xCenter yCenter], dotSizePix, [], [], 2);
        vbl  = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
    end
    
    %The illusion will be presented for 0.1 secs (1000 millsecs/600 frames
    %on a 60Hz display)
    IllusionPresentation = 1;
    vbl  = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
    WaitSecs(0.2);
    while timeElapsedSec <= IllusionPresentation
        
        if Eyetracker=='Y'
            if dotsOnDone == 0
                Eyelink('Message', 'MULLERON');
                dotsOnDone = 1;
            end
        else
        end
        % Draw the main saft of the illusion and the two wings
        Screen('DrawLines', window, allCoords, lineWidthPix, white, [xCenter, yCenter],2);
        Screen('DrawLines', window, allCoordsRightWing, lineWidthPix, white, [xCenter, yCenter],2);
        Screen('DrawLines', window, allCoordsLeftWing, lineWidthPix, white, [xCenter, yCenter],2);
        
        % Flip to the screen
        vbl  = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
        timeElapsedSec = GetSecs - BlockStartSec;
    end
    %         for l = 1:numFrames
    %             %Draw the fixation point#
    %             Screen('DrawDots', window, [xCenter yCenter], dotSizePix, [], [], 2);
    %             vbl  = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
    %         end
    
    clear y freq info soundLength soundLengthFrames wavedata nrchannels;
end


PsychPortAudio('Close', pahandle);
sca;

data = [trialList; ShaftLength; Sound]
dataFileName2 = ['ID-' SubID '-Eyetracker-' DateT '-Session-' SessionNo];
dlmwrite(strcat(dataFileName2,'.txt'), data, 'delimiter', '\t', 'precision', 6);

if Eyetracker=='Y'
    % Close datapixx
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if useViewPixx == 1
        Datapixx('DisableVideoLcd3D60Hz');
        Datapixx('RegWr');
        %     DataPixx('Close');
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Stop eyetracking
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % add 100 msec of data to catch final events and blank display
    WaitSecs(0.1);
    Eyelink('StopRecording');
    WaitSecs(0.1);
    Eyelink('CloseFile');
    
    % download data file
    try
        fprintf('Receiving data file ''%s''\n', edfFile );
        status=Eyelink('ReceiveFile');
        if status > 0
            fprintf('ReceiveFile status %d\n', status);
        end
        if 2==exist(edfFile, 'file')
            fprintf('Data file ''%s'' can be found in ''%s''\n', edfFile, pwd );
        end
    catch %#ok<*CTCH>
        fprintf('Problem receiving data file ''%s''\n', edfFile );
    end
else
end