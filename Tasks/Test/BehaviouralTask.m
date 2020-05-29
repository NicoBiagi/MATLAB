% Clear the workspace and the screen
close all;
clear all;
clc;
rng('shuffle');
format long g;
commandwindow;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Prompt Info
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
prompt = {'Enter ID:','Session Number:', 'Eyetracker:', 'use ViewPixx:'};
run_info = inputdlg(prompt, 'Info', 1, {'BT_', '1', 'Y','Y'});
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
    SecondHalf = xCenter+(xCenter/2);
    
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
%creating some vectors
PressRightTrial = [];
PressLeftTrial =[];
RightWingLengthX =[];
RightWingLengthY =[];
IllusionLengthStartPix = [];

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

%the pedestal will be always presented in the centre of the first half of
%the screen
FirstHalf = xCenter-(xCenter/2);
%the illusion will be always presented in the centre of the second half of
%the screen
SecondHalf = xCenter+(xCenter/2);

%setting the keyboard
KbName('UnifyKeyNames');
KbQueueCreate(); %0 is main keyboard
KbQueueStart();
escapeKey = KbName('ESCAPE');
leftKey = KbName('LeftArrow');
rightKey = KbName('RightArrow');
Space=KbName('space');

%%Rectangle Settings
%Set the intial position of the rectangle to be in the centre of the screen
RectX = xCenter;
RectY = yCenter;

% Sync us and get a time stamp
vbl = Screen('Flip', window);
waitframes = 1;

% Maximum priority level
topPriorityLevel = MaxPriority(window);
Priority(topPriorityLevel);

%%Illusion settings
%Set the width of the main line of the illusion
lineWidthDeg = 0.05 ; %degrees
lineWidthPix = lineWidthDeg * pixPerDeg; %pixels


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
DrawFormattedText(window, 'Your task is to match the length of the line presented on the right part of the screen \n\n to the line presented to the left.\n\n In order to do so you will have to press either the left arrow key (if you want to shrink the length of the right line)\n\n or the right arrow key (if you want to enlarge the line).\n \n Once you think that the length of the two lines match you have to press the spacebar to confirm your choice.\n\n Remember that if you do not press the spacebar \n\n your response will not be recorded and you will be moved to the next trial after 10 seconds.\n\n If you have any questions please ask the experimenter now, \n \n otherwise press any key to start the eye-tracker calibration', 'center', 'center', white);
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
%defining the angle between the arms of the fin. It will always be 135°
alpha = 135/2;

%creating the fin list:
WingList = [0 1 -1];
%>-< 1
%<-> -1
%|-| 0
%repeat the vector so that we have 36 trials (1 for each type)
WingList = repmat(WingList,1,12);
WingList = sort(WingList);
%creating the pedestal shaft vector
%The length of the pedestal will either be 2, 4 or 6 degrees of visual
%angle (dova)
PedestalLength(1:4)= 1;
PedestalLength(5:8)= 2;
PedestalLength(9:12)= 3;
PedestalLength=repmat(PedestalLength,1,3);

%creating the illusion shaft vector.
%the length of the main shaft of the illusion will be a percentage of the
%length of the pedestal. It will be either 50%, 80%, 120% or 150%.
ShaftLength = [0.5 0.8 1.2 1.5];
ShaftLength = repmat(ShaftLength,1,9);
trialListBefore = [WingList; PedestalLength; ShaftLength];

%Shuffle the matrix
ix = randperm(length(ShaftLength));
ShaftLength = ShaftLength(ix);
PedestalLength = PedestalLength(ix);
WingList = WingList(ix);

% %debug mode only, one type of wing only
% WingList(1:12) = 0;
% PedestalLength(1:4)=1;
% PedestalLength(5:8)=2;
% PedestalLength(9:12)=3;
% ShaftLength = [0.5 0.8 1.2 1.5];
% ShaftLength = repmat(ShaftLength, 1, 3);

%creating the trial matrix. we'll have 3 types of illusion (<--->, >---<,
%|---|), 3 possible length of the pedestal line (2, 3, 6 dova) and 4
%possible percentage of length of the main shaft of the illusion (50%, 80%,
%120%, 150%).
trialList = [WingList; PedestalLength; ShaftLength];

% Set the amount of pixels we want our rectangle to move on each button press
pixelsPerPress = 1;

for i = 1:length(trialList)
    %The illusion will be presented for 10 secs (1000 millsecs/600 frames
    %on a 60Hz display)
    IllusionPresentation = 10;
    %before each trial the time the left button was pressed is set to 0
    PressLeft=0;
    %before each trial the time the left button was pressed is set to 0
    PressRight=0;
    
    PLength = PedestalLength(i);
    %length of the pedestal in pixels
    PLengthPix = PLength * pixPerDeg;
    ILength = PLength * ShaftLength(i);
    %length of the illusion shaft in pixels
    ILengthPix = ILength * pixPerDeg;
    IllusionLengthStartPix(i)= ILengthPix;
    
    if WingList(i)==0 %|-|
        
        EndWingXPix = 0;
        EndWingXPix = EndWingXPix * pixPerDeg;
        EndWingYPix = tand(alpha)*ILengthPix/6;
        
        %Coordinates of the two wings of the illusion
        %Right Wings
        xCoordsRightWing = [ILengthPix ILengthPix-EndWingXPix ILengthPix ILengthPix-EndWingXPix];
        yCoordsRightWing = [0 EndWingYPix 0 -EndWingYPix];
        allCoordsRightWing = [xCoordsRightWing; yCoordsRightWing];
        %Left Wings
        xCoordsLeftWing = [-ILengthPix -ILengthPix+EndWingXPix -ILengthPix -ILengthPix+EndWingXPix];
        yCoordsLeftWing = [0 EndWingYPix 0 -EndWingYPix];
        allCoordsLeftWing = [xCoordsLeftWing; yCoordsLeftWing];
        
    elseif WingList(i)==-1 %<->
        
        EndWing = ILengthPix/3;
        EndWingXPix = EndWing*cosd(alpha);
        EndWingYPix = EndWing*sind(alpha);
        
        %Coordinates of the two wings of the illusion
        %Right Wings
        xCoordsRightWing = [ILengthPix ILengthPix-EndWingXPix ILengthPix ILengthPix-EndWingXPix];
        yCoordsRightWing = [0 EndWingYPix 0 -EndWingYPix];
        allCoordsRightWing = [xCoordsRightWing; yCoordsRightWing];
        %Left Wings
        xCoordsLeftWing = [-ILengthPix -ILengthPix+EndWingXPix -ILengthPix -ILengthPix+EndWingXPix];
        yCoordsLeftWing = [0 EndWingYPix 0 -EndWingYPix];
        allCoordsLeftWing = [xCoordsLeftWing; yCoordsLeftWing];
        
    elseif WingList(i)==1 %>-<
        
        EndWing = ILengthPix/3;
        EndWingXPix = EndWing*cosd(alpha);
        EndWingYPix = EndWing*sind(alpha);
        
        %Coordinates of the two wings of the illusion
        %Right Wings
        xCoordsRightWing = [ILengthPix ILengthPix+EndWingXPix ILengthPix ILengthPix+EndWingXPix];
        yCoordsRightWing = [0 EndWingYPix 0 -EndWingYPix];
        allCoordsRightWing = [xCoordsRightWing; yCoordsRightWing];
        %Left Wings
        xCoordsLeftWing = [-ILengthPix -ILengthPix-EndWingXPix -ILengthPix -ILengthPix-EndWingXPix];
        yCoordsLeftWing = [0 EndWingYPix 0 -EndWingYPix];
        allCoordsLeftWing = [xCoordsLeftWing; yCoordsLeftWing];
        
    end
    
    %Coordinates for the pedestal
    xCoordsPedestal = [PLengthPix -PLengthPix];
    yCoords = [0 0];
    allCoordsPedestal = [xCoordsPedestal; yCoords];
    
    %Coordinates for the Illusion
    xCoordinatesIllusion = [ILengthPix -ILengthPix];
    yCoords = [0 0];
    allCoordsIllusion = [xCoordinatesIllusion; yCoords];
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Timing and draw the illusion
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    BlockStartSec = GetSecs;
    timeElapsedSec = 0;
    illusionOnDone = 0;
    exitDemo = false;
    %Coordinates for the Illusion
    xCoordinatesIllusion = [ILengthPix -ILengthPix];
    yCoords = [0 0];
    allCoordsIllusion = [xCoordinatesIllusion; yCoords];
    %Coordinates for the wings of the illusion
    allCoordsLeftWing = [xCoordsLeftWing; yCoordsLeftWing];
    allCoordsRightWing = [xCoordsRightWing; yCoordsRightWing];
    
    %Coordinates for the wings of the illusion
    allCoordsLeftWing = [xCoordsLeftWing; yCoordsLeftWing];
    allCoordsRightWing = [xCoordsRightWing; yCoordsRightWing];
    
    
    
    while exitDemo == false
        % Check the keyboard to see if a button has been pressed
        [keyIsDown,secs, keyCode] = KbCheck;
        %check that the illusion doesn't go out of the screen
        BigBorder = (SecondHalf -xCenter)/2;
        %check that the illusion doesn't go smaller than 1 pixel
        SmallBorder = 1;
        LeftBorder = xCenter;
        RightBorder = SecondHalf + BigBorder;
        
        % Depending on the button press, either move the position of the
        % rectangle or exit the script
        if keyCode(escapeKey)
            %if the press the esc button they stop the experiment
            sca;
        elseif keyCode(Space)
            TrialAnswer(i)= 1;
            PressLeftTrial(i)=PressLeft;
            PressRightTrial(i)=PressRight;
            RightWingLengthX(i)= EndWingXPix;
            RightWingLengthY(i)= EndWingYPix;
            PedestalLengthPix(i)= PLengthPix;
            IllusionLengthPix(i)=ILengthPix;
            exitDemo = true;
        elseif keyCode(leftKey)
            PressLeft= PressLeft+1;
            ILengthPix = ILengthPix-pixelsPerPress;
            %EndWing = ILengthPix/3;
            if WingList(i)==0; %|-|
                if ILengthPix<=SmallBorder
                    ILengthPix = SmallBorder;
                    IllusionWing = SmallBorder/3;
                    %Right Wings
                    xCoordsRightWing = [SmallBorder SmallBorder SmallBorder SmallBorder];
                    yCoordsRightWing = [0 IllusionWing 0 -IllusionWing];
                    %Left Wings
                    xCoordsLeftWing = [-SmallBorder -SmallBorder -SmallBorder -SmallBorder];
                    yCoordsLeftWing = [0 IllusionWing 0 -IllusionWing];
                    %Illusion
                    xCoordinatesIllusion = [SmallBorder -SmallBorder];
                    yCoords = [0 0];
                    allCoordsIllusion = [xCoordinatesIllusion; yCoords];
                else
                    EndWingXPix = 0;
                    %EndWingYPix = tand(alpha)*ILengthPix/3;
                    %Right Wings
                    xCoordsRightWing = [ILengthPix ILengthPix-EndWingXPix ILengthPix ILengthPix-EndWingXPix];
                    yCoordsRightWing = [0 EndWingYPix 0 -EndWingYPix];
                    %Left Wings
                    xCoordsLeftWing = [-ILengthPix -ILengthPix+EndWingXPix -ILengthPix -ILengthPix+EndWingXPix];
                    yCoordsLeftWing = [0 EndWingYPix 0 -EndWingYPix];
                    %Illusion
                    xCoordinatesIllusion = [SmallBorder -SmallBorder];
                    yCoords = [0 0];
                    allCoordsIllusion = [xCoordinatesIllusion; yCoords];
                end
            elseif WingList(i)==-1; %<->
                if ILengthPix<=SmallBorder
                    ILengthPix = SmallBorder;
                    EndWingXPix = SmallBorder*cosd(alpha);
                    WingBorder = ILengthPix-EndWingXPix;
                    xCoordsRightWing = [SmallBorder WingBorder SmallBorder WingBorder];
                    xCoordsLeftWing = [-SmallBorder -WingBorder -SmallBorder -WingBorder];
                    xCoordinatesIllusion = [SmallBorder -SmallBorder];
                    yCoords = [0 0];
                    allCoordsIllusion = [xCoordinatesIllusion; yCoords];
                else
                    EndWingXPix = EndWing*cosd(alpha);
                    EndWingYPix = EndWing*sind(alpha);
                    %Right Wing
                    xCoordsRightWing = [ILengthPix ILengthPix-EndWingXPix ILengthPix ILengthPix-EndWingXPix];
                    yCoordsLeftWing = [0 EndWingYPix 0 -EndWingYPix];
                    %Left Wings
                    xCoordsLeftWing = [-ILengthPix -ILengthPix+EndWingXPix -ILengthPix -ILengthPix+EndWingXPix];
                    yCoordsLeftWing = [0 EndWingYPix 0 -EndWingYPix];
                end
            elseif WingList(i)==1; %>-<
                if ILengthPix<=SmallBorder
                    ILengthPix = SmallBorder;
                    WingBorder = SmallBorder*cosd(alpha);
                    xCoordsRightWing = [SmallBorder SmallBorder+WingBorder SmallBorder SmallBorder+WingBorder];
                    xCoordsLeftWing = [-SmallBorder -SmallBorder-WingBorder -SmallBorder -SmallBorder-WingBorder];
                    xCoordinatesIllusion = [SmallBorder -SmallBorder];
                    yCoords = [0 0];
                    allCoordsIllusion = [xCoordinatesIllusion; yCoords];
                else
                    EndWingXPix = EndWing*cosd(alpha);
                    EndWingYPix = EndWing*sind(alpha);
                    %Right Wing
                    xCoordsRightWing = [ILengthPix ILengthPix+EndWingXPix ILengthPix ILengthPix+EndWingXPix];
                    yCoordsRightWing = [0 EndWingYPix 0 -EndWingYPix];
                    %Left Wing
                    xCoordsLeftWing = [-ILengthPix -ILengthPix-EndWingXPix -ILengthPix -ILengthPix-EndWingXPix];
                    yCoordsLeftWing = [0 EndWingYPix 0 -EndWingYPix];
                end
            end
            
        elseif keyCode(rightKey)
            PressRight=PressRight+1;
            ILengthPix = ILengthPix+pixelsPerPress;
            %EndWing = ILengthPix/3;
            if WingList(i)==0; %|-|
                if ILengthPix>=BigBorder
                    ILengthPix = BigBorder;
                    xCoordsRightWing = [BigBorder BigBorder BigBorder BigBorder];
                    xCoordsLeftWing = [-BigBorder -BigBorder -BigBorder -BigBorder];
                    xCoordinatesIllusion = [BigBorder -BigBorder];
                    yCoords = [0 0];
                    allCoordsIllusion = [xCoordinatesIllusion; yCoords];
                else
                    EndWingXPix = 0;
                    %EndWingYPix = tand(alpha)*End;
                    %Right Wings
                    xCoordsRightWing = [ILengthPix ILengthPix-EndWingXPix ILengthPix ILengthPix-EndWingXPix];
                    yCoordsRightWing = [0 EndWingYPix 0 -EndWingYPix];
                    %Left Wings
                    xCoordsLeftWing = [-ILengthPix -ILengthPix+EndWingXPix -ILengthPix -ILengthPix+EndWingXPix];
                    yCoordsLeftWing = [0 EndWingYPix 0 -EndWingYPix];
                end
            elseif WingList(i)==-1; %<->
                if ILengthPix>=BigBorder
                    ILengthPix=BigBorder;
                    WingBigBorder = (BigBorder/6)*cosd(alpha);
                    xCoordsRightWing = [BigBorder BigBorder-WingBigBorder BigBorder BigBorder-WingBigBorder];
                    xCoordsLeftWing = [-BigBorder -BigBorder+WingBigBorder -BigBorder -BigBorder+WingBigBorder];
                    xCoordinatesIllusion = [BigBorder -BigBorder];
                    yCoords = [0 0];
                    allCoordsIllusion = [xCoordinatesIllusion; yCoords];
                else
                    EndWingXPix = EndWing*cosd(alpha);
                    EndWingYPix = EndWing*sind(alpha);
                    %Right Wing
                    xCoordsRightWing = [ILengthPix ILengthPix-EndWingXPix ILengthPix ILengthPix-EndWingXPix];
                    yCoordsLeftWing = [0 EndWingYPix 0 -EndWingYPix];
                    %Left Wings
                    xCoordsLeftWing = [-ILengthPix -ILengthPix+EndWingXPix -ILengthPix -ILengthPix+EndWingXPix];
                    yCoordsLeftWing = [0 EndWingYPix 0 -EndWingYPix];
                end
            elseif WingList(i)==1; %>-<
                if ILengthPix>=BigBorder
                    ILengthPix = BigBorder;
                    WingBorder = (BigBorder/6)*cosd(alpha);
                    xCoordsRightWing = [BigBorder BigBorder+WingBorder BigBorder BigBorder+WingBorder];
                    xCoordsLeftWing = [-BigBorder -BigBorder-WingBorder -BigBorder -BigBorder-WingBorder];
                    xCoordinatesIllusion = [BigBorder -BigBorder];
                    yCoords = [0 0];
                    allCoordsIllusion = [xCoordinatesIllusion; yCoords];
                else
                    EndWingXPix = EndWing*cosd(alpha);
                    EndWingYPix = EndWing*sind(alpha);
                    %Right Wing
                    xCoordsRightWing = [ILengthPix ILengthPix+EndWingXPix ILengthPix ILengthPix+EndWingXPix];
                    yCoordsRightWing = [0 EndWingYPix 0 -EndWingYPix];
                    %Left Wing
                    xCoordsLeftWing = [-ILengthPix -ILengthPix-EndWingXPix -ILengthPix -ILengthPix-EndWingXPix];
                    yCoordsLeftWing = [0 EndWingYPix 0 -EndWingYPix];
                end
            end
            
        end
        
        %Coordinates for the Illusion
        xCoordinatesIllusion = [ILengthPix -ILengthPix];
        yCoords = [0 0];
        allCoordsIllusion = [xCoordinatesIllusion; yCoords];
        %Coordinates for the wings of the illusion
        allCoordsLeftWing = [xCoordsLeftWing; yCoordsLeftWing];
        allCoordsRightWing = [xCoordsRightWing; yCoordsRightWing];
        
        if timeElapsedSec <= IllusionPresentation
            if Eyetracker=='Y'
                if illusionOnDone == 0
                    Eyelink('Message', 'MULLERON');
                    illusionOnDone = 1;
                end
            else
            end
            % Draw the rect to the screen as well as the illusion
            Screen('DrawLines', window, allCoordsPedestal, lineWidthPix, white, [FirstHalf, yCenter],2);
            Screen('DrawLines', window, allCoordsIllusion, lineWidthPix, white, [SecondHalf, yCenter],2);
            Screen('DrawLines', window, allCoordsRightWing, lineWidthPix, white, [SecondHalf, yCenter],2);
            Screen('DrawLines', window, allCoordsLeftWing, lineWidthPix, white, [SecondHalf, yCenter],2);
            Screen('DrawLines', window, fixCoords, fixWidthPix, white, [xCenter, yCenter],2);
            Screen('DrawLines', window, fixCoords2, fixWidthPix2, black, [xCenter, yCenter],2);
            
            % Flip to the screen
            vbl  = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
            timeElapsedSec = GetSecs - BlockStartSec;
        end
        if timeElapsedSec > IllusionPresentation
            if Eyetracker=='Y'
                %Message for Eyelink
                if illusionOnDone == 1
                    Eyelink('Message', 'MULLEROFF');
                    illusionOnDone = 2;
                end
            else
            end
            
            TrialAnswer(i)= NaN;
            PressLeftTrial(i)=PressLeft;
            PressRightTrial(i)=PressRight;
            RightWingLengthX(i)= EndWingXPix;
            RightWingLengthY(i)= EndWingYPix;
            PedestalLengthPix(i)= PLengthPix;
            IllusionLengthPix(i)=ILengthPix;
            
            %Draw the fixation crosses
            Screen('DrawLines', window, fixCoords, fixWidthPix, white, [xCenter, yCenter],2);
            Screen('DrawLines', window, fixCoords2, fixWidthPix2, black, [xCenter, yCenter],2);
            
            % Flip to the screen
            vbl  = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
        end
        
        %this updates the time
        timeElapsedSec = GetSecs - BlockStartSec;
    end
    
    for frame = 1:numFrames
        Screen('DrawLines', window, fixCoords, fixWidthPix, white, [xCenter, yCenter],2);
        Screen('DrawLines', window, fixCoords2, fixWidthPix2, black, [xCenter, yCenter],2);
        % Flip to the screen
        vbl  = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
    end
    if Eyetracker=='Y'
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

data = [WingList; PedestalLength; ShaftLength; TrialAnswer; PressRightTrial; PressLeftTrial; PedestalLengthPix; IllusionLengthStartPix; IllusionLengthPix]
dataFileName2 = ['ID-' SubID '-BehaviouralTask-' DateT '-Session-' SessionNo];
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
