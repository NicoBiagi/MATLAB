% Clear the workspace and the screen
close all;
clear all;
clc;
sca;
rng('shuffle');
commandwindow;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Prompt Info
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
prompt = {'Enter ID:','Session Number:', 'Eyetracker:', 'ViewPIXX:'};
run_info = inputdlg(prompt, 'Info', 1, {'E_', '1', '','' });
SubID = run_info{1};
SessionNo = run_info{2};
EyeLink = run_info{3};
ViewPIXX = run_info{4};
DateT = date;


if EyeLink == 'Y'
    
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

useViewPixx = 0;



% Parameters for using the ViewPixx
if useViewPixx == 1
    
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
    
end

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

%setting the keyboard
KbName('UnifyKeyNames');
KbQueueCreate(); %0 is main keyboard
KbQueueStart();
escapeKey = KbName('ESCAPE');
leftKey = KbName('LeftArrow');
rightKey = KbName('RightArrow');
Space=KbName('space');

%%Rectangle Settings
% Set the intial position of the rectangle to be in the centre of the screen
RectX = xCenter;
RectY = yCenter;


% Sync us and get a time stamp
vbl = Screen('Flip', window);
waitframes = 1;

% Maximum priority level
topPriorityLevel = MaxPriority(window);
Priority(topPriorityLevel);

%%Illusion settings
%Set the length of the main line of the illusion
CrossDimDeg = 5; %degrees
CrossDimPix = CrossDimDeg * pixPerDeg; %pixels

%Set the width of the main line of the illusion
lineWidthDeg = 0.05 ; %degrees
lineWidthPix = lineWidthDeg * pixPerDeg; %pixels

% % %In each trial the outer wings will be either inwards or outwards
% % trialList(1:3)= 1; %inwards <->
% % trialList(4:6)= -1; %outwards >-<
% % trialList(7:9)= 0; %flat |-|
% %
% % trialList= Shuffle(trialList);
trialList = -1;

%defining the angle between the arms of the fin.
alpha = 45/2;

% Coordinates of the main line of the illusion
xCoords = [CrossDimPix -CrossDimPix];
yCoords = [0 0];
allCoords = [xCoords; yCoords];

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

% Length of time and number of frames we will use for each drawing test
numSecs = 1;
numFrames = round(numSecs / ifi);

for i=1:numFrames
    %Draw the fixation cross
    Screen('DrawLines', window, fixCoords, fixWidthPix, white, [xCenter, yCenter],2);
    Screen('DrawLines', window, fixCoords2, fixWidthPix2, black, [xCenter, yCenter],2);
    vbl  = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
end

trialNumberVector=[];
RandomNumber=[];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if EyeLink == 'Y'
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

for i= 1:length(trialList)
    if EyeLink == 'Y'
        % Sending a 'TRIALID' message to mark the start of a trial in Data
        % Viewer.  This is different than the start of recording message
        % START that is logged when the trial recording begins. The viewer
        % will not parse any messages, events, or samples, that exist in
        % the data file prior to this message.
        Eyelink('Message', 'TRIALID %d', i);
    else
    end
    
    %The illusion will be presented for 10 secs (1000 millsecs/600 frames
    %on a 60Hz display)
    IllusionPresentation = 10;
    
    EndWingxCm = CrossDimDeg/3*trialList(i);
    EndWingxPix = EndWingxCm * pixPerDeg;
    EndWingYCm = sind(alpha)*CrossDimDeg;
    EndWingYCm = EndWingYCm /3;
    EndWingYPix = EndWingYCm * pixPerDeg;
    
    %Coordinates of the two wings of the illusion
    %Right Wings
    xCoords2 = [CrossDimPix CrossDimPix-EndWingxPix CrossDimPix CrossDimPix-EndWingxPix];
    yCoords2 = [0 EndWingYPix 0 -EndWingYPix];
    allCoords2 = [xCoords2; yCoords2];
    %Left Wings
    xCoords3 = [-CrossDimPix -CrossDimPix+EndWingxPix -CrossDimPix -CrossDimPix+EndWingxPix];
    yCoords3 = [0 EndWingYPix 0 -EndWingYPix];
    allCoords3 = [xCoords3; yCoords3];
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Timing and draw the illusion
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    BlockStartSec = GetSecs;
    timeElapsedSec = 0;
    dotsOnDone = 0;
    exitDemo = false;
    
    while timeElapsedSec <= IllusionPresentation
        % Check the keyboard to see if a button has been pressed
        [keyIsDown,secs, keyCode] = KbCheck;
        
        % Depending on the button press, either move the position of the
        % rectangle or exit the script
        if keyCode(escapeKey)
            %if the press the esc button they stop the experiment
            sca;
        end
        
        if EyeLink == 'Y'
            if dotsOnDone == 0
                Eyelink('Message', 'MULLERON');
                dotsOnDone = 1;
            end
        else
        end
        % Draw the rect to the screen as well as the illusion
        Screen('DrawLines', window, allCoords, lineWidthPix, white, [xCenter, yCenter],2);
        Screen('DrawLines', window, allCoords2, lineWidthPix, white, [xCenter, yCenter],2);
        Screen('DrawLines', window, allCoords3, lineWidthPix, white, [xCenter, yCenter],2);
        
        
        % Flip to the screen
        vbl  = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
        % GetImage call. Alter the rect argument to change the location of the screen shot
        imageArray = Screen('GetImage', window);
        
        % imwrite is a Matlab function, not a PTB-3 function
        imwrite(imageArray, 'test.jpg')
        timeElapsedSec = GetSecs - BlockStartSec;
    end
    if timeElapsedSec > IllusionPresentation
        
        if EyeLink == 'Y'
            %Message for Eyelink
            if dotsOnDone == 1
                Eyelink('Message', 'MULLEROFF');
                dotsOnDone = 2;
            end
        else
        end
        
        %Draw the fixation crosses
        Screen('DrawLines', window, fixCoords, fixWidthPix, white, [xCenter, yCenter],2);
        Screen('DrawLines', window, fixCoords2, fixWidthPix2, black, [xCenter, yCenter],2);
        
        % Flip to the screen
        vbl  = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
    end
    %this updates the time
    timeElapsedSec = GetSecs - BlockStartSec;
    
    
    for frame = 1:numFrames
        Screen('DrawLines', window, fixCoords, fixWidthPix, white, [xCenter, yCenter],2);
        Screen('DrawLines', window, fixCoords2, fixWidthPix2, black, [xCenter, yCenter],2);
        % Flip to the screen
        vbl  = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
    end
    if EyeLink =='Y'
        % Sending a 'TRIAL_RESULT' message to mark the end of a trial in
        % Data Viewer. This is different than the end of recording message
        % END that is logged when the trial recording ends. The viewer will
        % not parse any messages, events, or samples that exist in the data
        % file after this message.
        Eyelink('Message', 'TRIAL_RESULT 0')
    else
    end
    
    
end


sca;

data = [trialNumberVector; trialList]
dataFileName2 = ['ID-' SubID '-Eyetracker-' DateT '-Session-' SessionNo];
dlmwrite(strcat(dataFileName2,'.txt'), data, 'delimiter', '\t', 'precision', 6);

% Cose datapixx
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if useViewPixx == 1
    Datapixx('DisableVideoLcd3D60Hz');
    Datapixx('RegWr');
    %     DataPixx('Close');
end

if EyeLink =='Y'
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