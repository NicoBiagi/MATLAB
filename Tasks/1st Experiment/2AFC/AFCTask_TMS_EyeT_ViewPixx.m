% Clear the workspace and the screen
close all;
clear all;
clc;
sca;
rng('shuffle');
commandwindow;

%DF: I have put this here for same reason Peter sets up his viewpixx
%configuration above
%enable bit stealing to assist with low contrast stimuli - note that
%window has to be opened with Psychimaging() not Screen() for this to
%work
PsychImaging('PrepareConfiguration');
PsychImaging('AddTask', 'General', 'FloatingPoint32Bit');
%PsychImaging('AddTask', 'General', 'EnablePseudoGrayOutput');
PsychImaging('AddTask', 'General', 'EnableDataPixxM16OutputWithOverlay');

PsychImaging('AddTask', 'FinalFormatting', 'DisplayColorCorrection', 'SimpleGamma');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Prompt Info
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
prompt = {'Enter ID:','Session Number:', 'Intensity of Stimulation:'};
run_info = inputdlg(prompt, 'Info', 1, {'AF_', '1', '0'});
SubID =run_info{1};
SessionNo = run_info{2};
intensity = str2num(run_info{3});
DateT = date;

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
sca;

%calling the Eyetracker Settings
EyeTrackerSettings;

%DF: I have put this here for same reason Peter sets up his viewpixx
%configuration above
%enable bit stealing to assist with low contrast stimuli - note that
%window has to be opened with Psychimaging() not Screen() for this to
%work
PsychImaging('PrepareConfiguration');
PsychImaging('AddTask', 'General', 'FloatingPoint32Bit');
%PsychImaging('AddTask', 'General', 'EnablePseudoGrayOutput');
PsychImaging('AddTask', 'General', 'EnableDataPixxM16OutputWithOverlay');

PsychImaging('AddTask', 'FinalFormatting', 'DisplayColorCorrection', 'SimpleGamma');

AFCScreenSettings;

gamma= 1.4924; %ViewPixx gamma

PsychColorCorrection('SetEncodingGamma', window, 1 ./ gamma);

% Draw text in the middle of the screen in Times in white
Screen('TextSize', window, 100);
Screen('TextFont', window, 'Times');
DrawFormattedText(window, 'Welcome to the main task', 'center', 'center', white);
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
DrawFormattedText(window, 'In this task two different sets of dots will be presented, in each trial, to the right of the fixation cross. \n \n The gap between one pair of dots will be slightly larger than the gap between the other pair of dots. \n \n  Your task is to stare at the fixation cross and decide for which pair of dots the gap is larger. \n \n Press the ''up arrow'' if this is the upper pair of dots and the ''down arrow'' if this is the lower pair of dots. \n \n No feedback will be provided during this task. \n \n If you have any questions please ask the experimenter now, \n \n otherwise press any key to start the experiment', 'center', 'center', white);

% Flip to the screen
Screen('Flip', window);

KbWait
WaitSecs(0.2);

Screen('DrawLines', window, allCoords, lineWidthPix, white, [xCenter, yCenter],2);
Screen('DrawLines', window, allCoords2, lineWidthPix2, black, [xCenter, yCenter],2);


Screen('Flip',window);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%initialize data collection variables to build up data on a trial by trial basis
%note that a lot of variables in this code (and comments) refer to , or the need to offset stimuli from screen centre
%this is because this code was made by modifying a previous version that used 2 pairs of stimuli
%ignore the reerences to " / right"
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
subjectPerformanceVector = [];
targetLocationVector = [];
trialNumberVector = [];
ResponseTime = [];
Response_Time = [];
DC = [];
BA= [];
Percentage = [];
TrialStart = [];
TrialLength = [];
lengthCD= [];
lengthAB = [];
TrialAnswer = [];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%some important variables controlling some randomised and fixed parameters of the
%trials
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

intervalDurationSec = 1.0;
%how long they have to wait between two trails
interTrialIntervalSec = 2;
%size of the dots
dotSizeDeg = 0.2;
dotSizePix = dotSizeDeg * pixPerDeg;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
time = 0;
HideCursor()
pause(1)

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Long Experiment, 240 trials, 30 for each value
trialList(1:30) = .70;
trialList(31:60)= .79;
trialList(61:90)= .88;
trialList(91:120)= .97;
trialList(121:150)= 1.03;
trialList(151:180)= 1.12;
trialList(181:210)= 1.21;
trialList(211:240)= 1.30;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%SuperFast Experiment, debug only 10 trials, always down
% trialList(1:10)= 1.30;

trialList = Shuffle(trialList);
numTrials = length(trialList);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%loop through the set of trials (could just be a list of one trial if we
%make this script into a function that we call from another script that
%does the palamedes bit
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%TMS
device=0;
pulse_shape=1;
pulse_time=[0 50 100 150];
display=1;
PM100=PM100_Class;

% create COM port object
obj=PM100.create_COM_object(display,5);

% reset stimulator interface
PM100.reset(obj);

% get ID
ID=PM100.get_ID(obj,device,display);

% get status
STATUS=PM100.get_status(obj,device,display);

% get coil temperature
[CT,coil_temp]=PM100.get_coil_temperature(obj,device,display);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%setting the keyboard
KbName('UnifyKeyNames');
KbQueueCreate(); %0 is main keyboard
KbQueueStart();
%defining whihc key will be used
escapeKey = KbName('ESCAPE');
upKey = KbName('UpArrow');
downKey = KbName('DownArrow');
%This line will set which keys are active in the keyboard during the task.
%All the other keys won't be used
RestrictKeysForKbCheck([downKey upKey escapeKey]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Eyelink('StartRecording');
eye_used = Eyelink('EyeAvailable'); % get eye that's tracked
% returns 0 (LEFT_EYE), 1 (RIGHT_EYE) or 2 (BINOCULAR) depending on what data is
if eye_used == 2
    eye_used = 1; % use the right_eye data
end
% record a few samples before we actually start displaying
% otherwise you may lose a few msec of data
WaitSecs(0.1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for i = 1: numTrials
    
    % Sending a 'TRIALID' message to mark the start of a trial in Data
    % Viewer.  This is different than the start of recording message
    % START that is logged when the trial recording begins. The viewer
    % will not parse any messages, events, or samples, that exist in
    % the data file prior to this message.
    Eyelink('Message', 'TRIALID %d', i);
    
    trialNumberVector = [trialNumberVector, i];
    TrialStart(i) = GetSecs;
    
    %FIRST SET OF DOTS
    %%Drawing the first dot
    %Rho is rand angle between pi/6 (30°) and pi/3(60°)
    rh = [pi/6:pi/1000:pi/3];
    rh_pos= randi(length(rh));
    rho = rh(rh_pos);
    %The first two dots will be presented in the 1st quadrant (up)
    rho = -rho;
    %rho is middle point between the first two dots
    
    %AB is a rand angle between pi/36(10°) and pi/9(30°)
    th= [pi/18:pi/100:pi/12];
    th_pos=randi(length(th));
    AB= th(th_pos);
    %The angle between the first two dots will be the double of AB
    %for posterity
    lengthAB(i) = 2*AB;
    %Theta is AB+rho
    theta = rho+AB;
    %transforming from polar coordinates into cartesian
    [Dot1X, Dot1Y] = pol2cart(theta, radius);
    %position dot relative to screen centre
    Dot1X = xCenter + Dot1X;
    Dot1Y = yCenter + Dot1Y;
    
    %%Drawing the second dot
    %Theta2 is equal to AB - rho
    theta2 = rho-AB;
    %transforming from polar coordinates into cartesian
    [Dot2X, Dot2Y] = pol2cart(theta2, radius);
    %position dot relative to screen centre
    Dot2X = xCenter + Dot2X;
    Dot2Y = yCenter + Dot2Y;
    
    %%%SECOND SET OF DOTS
    %Rho2 is randomly chosen between pi/6(30°) and pi/3(60°)
    rh2 = [pi/6:pi/1000:pi/3];
    rh2_pos= randi(length(rh2));
    %the second set of dots will be presented in the fourth quadrant (down)
    rho2 = rh2(rh2_pos);
    %CD is a percentage of the distance between the first set of dots
    CD = trialList(i) .* (AB);
    %for posterity
    lengthCD(i) = 2*CD;
    
    %Right answer
    if CD> AB
        %the second interval is larger
        RightAnswer(i)= 1;
    elseif AB>CD
        %the second interval is smaller
        RightAnswer(i) = 0;
    end
    %alpha is equal to rho2 plus hal of the chosen distance
    alpha = rho2 + CD;
    %alpha2 is equal to rho2  minus half of the chosen distance
    alpha2 = rho2 - CD;
    
    %transforming from polar coordinates into cartesian
    [Dot3X, Dot3Y] = pol2cart(alpha, radius);
    %position dot relative to screen centre
    Dot3X = Dot3X + xCenter;
    Dot3Y = Dot3Y + yCenter;
    
    % %transforming from polar coordinates into cartesian
    [Dot4X, Dot4Y] = pol2cart(alpha2, radius);
    %position dot relative to screen centre
    Dot4X = Dot4X + xCenter;
    Dot4Y = Dot4Y + yCenter;
    
    %put the dot coords into a 2 row matrix (top row is x, bottom row y) for faster drawing)
    dotCoordListPix2 = [Dot1X, Dot2X, Dot3X, Dot4X; Dot1Y, Dot2Y, Dot3Y, Dot4Y];
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %below we define the second interval, in which the subject must try to detect the
    %relevant change
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    if CD > AB
        setTarget(i) = 1; % subject must press the DOWN arrow if the second interval is bigger
    end
    if AB > CD
        setTarget(i) = 0; %subject must press the UP arrow if the second interval is smaller
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % activate stimulator
    PM100.activate(obj,device)
    
    % setup stimulation protocol
    PM100.setup_protocol(obj,device,pulse_shape,intensity,pulse_time,1)
    
    % start stimulation (run protocol)
    PM100.start_stimulation(obj,device)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %after stimuli presented wait for a keypress (escape to quit program)
    %evaluate whether subject response is correct or incorrect
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Timing and draw the dots
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    BlockStartSec = GetSecs;
    timeElapsedSec = 0;
    
    %The dots will be presented for 200 millisecs/12frames on a 60Hz display
    DotPresentation = 0.2;
    blockDurationSec = 4;
    pressed = 0;
    
    dotsOnDone = 0;
    while pressed == 0
        [keyIsDown,secs, keyCode] = KbCheck;
        if keyCode(escapeKey)
            sca;
            PM100.deactivate(obj,device);
        elseif keyCode(upKey)
            ResponseTime= GetSecs;
            pressed = 1;
            TrialAnswer(i) = 0;
            %if the target is equal to zero, then they are wrong
            if setTarget(i) == 1
                subjectPerformanceVector(i) = 0;
            end
            %if the target is equal to 1 then they are right
            if setTarget(i) == 0
                subjectPerformanceVector(i) = 1;
            end
        elseif keyCode(downKey)
            ResponseTime= GetSecs;
            pressed = 1;
            TrialAnswer(i) = 1;
            %if the target is equal to 1, then they are wrong
            if setTarget(i) == 0
                subjectPerformanceVector(i) = 0;
            end
            %if the target is equal to 0, then they are right
            if setTarget(i) == 1
                subjectPerformanceVector(i) = 1;
            end
        end
        
        if timeElapsedSec <= DotPresentation
            %drawing the two sets of dots
            Screen('DrawDots', window, dotCoordListPix2, dotSizePix, white, [], 2);
            %Message for Eyelink
            if dotsOnDone == 0
                Eyelink('Message', 'DOTSON');
                dotsOnDone = 1;
            end
            %drawing the fixation cross
            Screen('DrawLines', window, allCoords, lineWidthPix, white, [xCenter, yCenter],2);
            Screen('DrawLines', window, allCoords2, lineWidthPix2, black, [xCenter, yCenter],2);
            vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
        end
        
        if timeElapsedSec > DotPresentation
            StartTrial = GetSecs;
            %Message for Eyelink
            if dotsOnDone == 1
                Eyelink('Message', 'DOTSOFF');
                dotsOnDone = 2;
            end
            %drawing the fixation cross
            Screen('DrawLines', window, allCoords, lineWidthPix, white, [xCenter, yCenter],2);
            Screen('DrawLines', window, allCoords2, lineWidthPix2, black, [xCenter, yCenter],2);
            vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
        end
        %this updates the time
        timeElapsedSec = GetSecs - BlockStartSec;
        
    end
    
    %Defining the time that took to the participant to produce a response
    TimeToRespond = ResponseTime-BlockStartSec;
    
    %Recording the reaction time for posterity
    Response_Time(i) = TimeToRespond;
    %Message for Eyelink
    Eyelink('Message', 'RESPONSE');
    
    %Defining the inter-trial interval.
    %If it took more than 5 second to the participant to produce a response, then there is no inter-trial
    %interval
    if TimeToRespond>=5
        interTrialPause =0.2;
        %If it took less than 5 seconds to the participant to produce a response,
        %then the inter-trial interval is the remaining seconds to add up to 5
        %seconds
    else
        interTrialPause = (5- TimeToRespond);
    end
    WaitSecs(interTrialPause);
    
    TrialLength(i) = GetSecs - TrialStart(i);
    
    % Sending a 'TRIAL_RESULT' message to mark the end of a trial in
    % Data Viewer. This is different than the end of recording message
    % END that is logged when the trial recording ends. The viewer will
    % not parse any messages, events, or samples that exist in the data
    % file after this message.
    Eyelink('Message', 'TRIAL_RESULT 0')
end

PM100.deactivate(obj,device)

%Cleaning the COM port
s=instrfind;
fclose(s)
delete(s)

% Draw text in the middle of the screen in Times in white
Screen('TextSize', window, 85);
Screen('TextFont', window, 'Times');
DrawFormattedText(window, 'This is the end of the experiment', 'center', 'center', white);
% Draw text in the bottom of the screen in Times in white
Screen('TextSize', window, 50);
Screen('TextFont', window, 'Times');
DrawFormattedText(window, 'Press any key to continue', 'center',...
    screenYpixels * 0.85, white);

% Flip to the screen
Screen('Flip', window);

KbWait
WaitSecs(0.1);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Clear the screen. "sca" is short hand for "Screen CloseAll". This clears
% all features related to PTB. Note: we leave the variables in the
% workspace so you can have a look at them if you want.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sca;
DC = lengthCD;
BA = lengthAB;
Percentage = (lengthCD./lengthAB )*100;
IDs = repmat(str2num(SubID), numTrials, 1)';
IntensityNo = repmat(intensity, numTrials, 1)';
Session = repmat(str2num(SessionNo), numTrials, 1)';

data = [trialNumberVector; lengthAB; lengthCD; Percentage; setTarget; TrialAnswer; subjectPerformanceVector; Response_Time; IDs; IntensityNo; Session; TrialLength]

percentCorrect = sum(data(7,:)) / length(data(7,:)) * 100

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Process the data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%write the raw data to the current working directory. Give a filename here.
%WARNING: if you use the same file name twice it will overwrite the first
%set of data
dataFileName = ['2AFC-ID-' SubID '-' DateT '-Session-' SessionNo];
dlmwrite(strcat(dataFileName,'.txt'), data, 'delimiter', '\t', 'precision', 6)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Stop eyetracking
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
