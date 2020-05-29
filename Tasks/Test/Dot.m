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
run_info = inputdlg(prompt, 'Info', 1, {'AVS_1', '1', 'n','n'});
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
    
    KbWait;
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

% Here we call some default settings for setting up Psychtoolbox
Screen('Preference', 'SkipSyncTests', 2);

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
trialList(1:3)= -1; %inwards <-->
trialList(4:6)= 1; %outwards >--<
trialList(7:9)= 0; %flat |--|

% DEBUG
%trialList(1:4)= 0; %flat |--|

for i =1:(length(trialList))
    Sound1(i) = 0;
end

for i =1:(length(trialList))
    Sound2(i) = 1;
end

Sound = [Sound1 Sound2];
trialList = repmat(trialList, 1, 2);


ShaftLength1(1:(length(trialList))) = 1;
ShaftLength2(1:(length(trialList))) = 2;
ShaftLength = [ShaftLength1 ShaftLength2];

ShaftLength = [ShaftLength1 ShaftLength2];
trialList = repmat(trialList, 1, 2);
Sound = repmat(Sound, 1, 2);

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

% dotSizeDeg = 0.5;
% dotSizePix = dotSizeDeg * pixPerDeg;
% dotSizePix = round(dotSizePix);

dotSizePix = 20;
%setting the keyboard
KbName('UnifyKeyNames');
KbQueueCreate(); %0 is main keyboard
KbQueueStart();
escapeKey = KbName('ESCAPE');
leftKey = KbName('LeftArrow');
rightKey = KbName('RightArrow');
Space=KbName('space');


for i = 1:length(Sound)
    % Check the keyboard to see if a button has been pressed
    [keyIsDown,secs, keyCode] = KbCheck;
    
    % Depending on the button press, either move the position of the
    % rectangle or exit the script
    if keyCode(escapeKey)
        %if the press the esc button they stop the experiment
        sca;
    end
    if Sound(i) == 0
        Color = [1 0 0];
    else
        Color = [0 0 1];
    end
    % Draw the dot to the screen. For information on the command used in
    % this line type "Screen DrawDots?" at the command line (without the
    % brackets) and press enter. Here we used good antialiasing to get nice
    % smooth edges
    for frame = 1:numFrames
        Screen('DrawDots', window, [xCenter yCenter], dotSizePix, Color, [], 2);
        vbl  = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
    end
    for frame = 1:numFrames
        %         Screen('DrawLines', window, fixCoords, fixWidthPix, white, [xCenter, yCenter],2);
        %         Screen('DrawLines', window, fixCoords2, fixWidthPix2, black, [xCenter, yCenter],2);
        % Flip to the screen
        vbl  = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
    end
    
end

% Clear the screen. "sca" is short hand for "Screen CloseAll". This clears
% all features related to PTB. Note: we leave the variables in the
% workspace so you can have a look at them if you want.
% For help see: help sca
sca;