c
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Prompt Info
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
prompt = {'Enter ID:','Session Number:', 'Intensity of Stimulation:'};
run_info = inputdlg(prompt, 'Info', 1, {'CT_', '1', '0'});
SubID = run_info{1};
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


GaborScreenSettings;

gamma= 1.4924; %ViewPixx gamma

PsychColorCorrection('SetEncodingGamma', window, 1 ./ gamma);


%Creating a few varaiables
subjectPerformanceVector = [];
targetLocationVector = [];
trialNumberVector = [];
setTarget = [];
TrialAnswer = [];
IDs = [];
TrialStart = [];
TrialLength = [];
Percentage = [];
subjectPerformanceVector=[];

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
Screen('TextSize', window, 28);
Screen('TextFont', window, 'Times');
DrawFormattedText(window, 'In this task two patches of light and dark stripes called Gabor patches will be presented, in each trial, to the right of the fixation cross. \n \n One of the Gabor patches will have a bigger difference in brightness between the light and dark stripes than the other one (higher contrast). \n \n  Your task is to stare at the fixation cross and decide for which Gabor patch the contrast is higher. \n \n Press the ''up arrow'' if this is the upper Gabor patch and the ''down arrow'' if this is the lower Gabor patch. \n \n No feedback will be provided during this task. \n \n If you have any questions please ask the experimenter now, \n \n otherwise press any key to start the training session', 'center', 'center', white);
% Flip to the screen
Screen('Flip', window);

KbWait
WaitSecs(0.2);

%Draw the Fixation Cross
Screen('DrawLines', window, allCoords, lineWidthPix, white, [xCenter, yCenter]);
Screen('DrawLines', window, allCoords2, lineWidthPix2, grey, [xCenter, yCenter]);
Screen('Flip', window);

%how long they have to wait between two trails
interTrialIntervalSec = 2;

%Set the contrast for the 2 patches
trialList = [];
cUp = [];
cDown = [];
contrastMatrix = [];

%One of the two patches will be always equal to one value included in "a"
a = [0.4 0.5 0.6 0.7];
% %One of the two patches will be always equal to one value included in "a"
% a = [0.5 0.5 0.5 0.5];

%Replicating "a" 60 times, so length(a)=240
a = repmat(a,1,60);
%Shuffling the order of "a"
a = Shuffle(a);

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%Long Experiment, 240 trials, 30 for each value
trialList(1:30) = .70;
trialList(31:60)= .79;
trialList(61:90)= .88;
trialList(91:120)= .97;
trialList(121:150)= 1.03;
trialList(151:180)= 1.12;
trialList(181:210)= 1.21;
trialList(211:240)= 1.30;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%SuperFast Experiment, debug only, always down
% trialList(1:10) = 1.30;

%Shuffling the order of "trialList"
trialList = Shuffle(trialList);

%Creating two vectors with the values of contrast for the two patches
for i = 1:length(trialList)
    %This random value will be the contrast for the first patch
    cUp= a(i);
    %The value for the first patch times the value from the "trialList". This will be the contrast for the second patch
    cDown= trialList(i) * cUp;
    contrastUp(i)= cUp;
    contrastDown(i) = cDown;
    if cUp == cDown
        break
    elseif cUp > cDown
        setTarget(i) = 0;
    elseif cUp<cDown
        setTarget(i) = 1;
    end
end

%Creating a matrix with the contrast values for the two patches
contrastMatrix = [contrastUp ; contrastDown];

% %Shuffling the order of the matrix
% contrastMatrix= Shuffle(contrastMatrix);

%The contrast values for the up patch will be taken from the first raw of
%the matrix
contrastUp = contrastMatrix(1,:);

%The contrast values for the up patch will be taken from the first raw of
%the matrix
ccontrastDown = contrastMatrix(2,:);

%Set the number of trials to be equal to the length of the contrasts that
%will be used
numTrials = length(contrastUp);

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%TMS
% device=0;
% pulse_shape=1;
% pulse_time=[0 50 100 150];
% display=1;
% PM100=PM100_Class;
% 
% % create COM port object
% obj=PM100.create_COM_object(display,5);
% 
% % reset stimulator interface
% PM100.reset(obj);
% 
% % get ID
% ID=PM100.get_ID(obj,device,display);
% 
% % get status
% STATUS=PM100.get_status(obj,device,display);
% 
% % get coil temperature
% [CT,coil_temp]=PM100.get_coil_temperature(obj,device,display);


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
    
    %record for posterity
    trialNumberVector = [trialNumberVector, i];
    TrialStart(i) = GetSecs;
    
    % basic parameters
    % orientationGaborLeft = 0;
    % orientationGaborRight = 90;
    % contrastGaborLeft = 0.8;
    %contrastGaborRight = 0.1;
    aspectRatio = 1.0;
    phaseGaborUp = 0;
    phaseGaborDown = 0;
    %DF this var controls the size of the stimulus patch, independantly of the spatial freq of the Gabor
    stimulusRadiusDeg = 3;
    %DF the distance of the inner edge of the stimulus from screen centre/fixation point
    stimulusOffsetFromFixationDeg = 5.0;
    %DF this var controls the spatial frequency of the Gabor, with lower numbers producing thicker stripes (One Cycle = Grey-Black-Grey-White-Grey i.e. One Black and One White Lobe)
    cyclePerDeg = 1;
    
    %DF to verify that I was getting the spatial frequency I hoped I was
    %getting as well as the size of patch I hoped I was getting I set stimulusRadiusDeg = screenDegY/2.0; and cyclePerDeg = 1; and
    %stimulusOffsetFromFixationDeg = 0.0; and sigma = gaborDimPix; then I can
    %count the number of white lobes (or black lobes) and check it is equal to
    %screenDegY.
    
    stimulusDurationSec = 0.2;
    %driftSpeedDegPerSecLeft = 2.0; %positive value drifts top to bottom, negative bottom to top
    %driftSpeedDegPerSecRight = -2.0;
    
    %Dimension of the region where we will draw the Gabor texture in degrees
    gaborDimDeg = stimulusRadiusDeg * 2;
    
    % Dimension of the region where we will draw the Gabor in pixels
    gaborDimPix = round(gaborDimDeg * pixPerDeg); %
    
    % Sigma of Gaussian DF: set sigma = gaborDimPix if you want just a square
    % grating, which is helpful to see for debugging purposes when you want to
    % count the stripes
    %sigma = gaborDimPix;
    sigma = gaborDimPix / 7;
    
    sigmaTemporal = stimulusDurationSec / 6;
    
    %setting sigmaTemporal tostimulusDurationSec / 6 will scale the fade in/out so that you get 3 SD
    % of the gaussain either side of the peak contrast in time, which will fade
    % the stimulus right down to invisibility with a bit of time to spare
    %setting it to  4 will mean that that on it's final frame the stimulus is
    %just over 1/10 of its peak contrast. Setting it to 2 will leave the
    %stimulus at just over half its peak contrast on it's final frame
    %IF WE WANT TO HAVE A FULL FADE OUT TO 0 CONTRAST BUT WITH A LATER AND FASTER FADE
    %THAN YOU GET BY SETTING SIGMATEMPORAL TO 6 THEN I NEED TO FIGURE OUT HOW
    %TO MAKE temporalGaussian into a KURTOTIC NORMAL DISTRIBUTION
    xTemporalGaussian = [-stimulusDurationSec/2:ifi:stimulusDurationSec/2]; % make a vector with the right numberof elements
    temporalGaussian = normpdf(xTemporalGaussian,0, sigmaTemporal);% make a vector containing a  normal distribution with the correct number of elements
    temporalGaussian = temporalGaussian .*(1/max(temporalGaussian)); %rescale so that the maximum value in the probability density function will be 1
    
    %if the fading is not used, then "noFading" should be equal to 0
    noFading = 1;
    if noFading == 1
        temporalGaussian = temporalGaussian.^0;
    end
    
    
    % % Spatial Frequency calculation (Cycles Per Pixel)
    % % One Cycle = Grey-Black-Grey-White-Grey i.e. One Black and One White Lobe
    numCycles = cyclePerDeg * gaborDimDeg;
    numCyclesPerPixel = numCycles / gaborDimPix;
    freq = numCyclesPerPixel;
    
    %Drift speed of motion
    degPerSecUp = 360 * driftSpeedDegPerSecUp;
    degPerFrameUp =  degPerSecUp * ifi;
    degPerSecDown = 360 * driftSpeedDegPerSecDown;
    degPerFrameDown =  degPerSecDown * ifi;
    
    % Build a procedural gabor texture (Note: to get a "standard" Gabor patch
    % we set a grey background offset, disable normalisation, and set a
    % pre-contrast multiplier of 0.5.
    % For full details see:
    % https://groups.yahoo.com/neo/groups/psychtoolbox/conversations/topics/9174
    backgroundOffset = [0.5 0.5 0.5 0.0]; %%grey patches
    
    % backgroundOffset = [0.0 0.0 0.0 0.0]; %black patches
    disableNorm = 1;
    
    preContrastMultiplier = 0.5;
    gabortex = CreateProceduralGabor(window, gaborDimPix, gaborDimPix, [],backgroundOffset, disableNorm, preContrastMultiplier);
    contrastGaborDown = contrastDown(i);
    contrastGaborUp = contrastUp(i);
    
    % make a properties matrix.
    propertiesMatGaborDown = [phaseGaborDown, freq, sigma, contrastGaborDown * temporalGaussian(1), aspectRatio, 0, 0, 0];
    propertiesMatGaborUp = [phaseGaborUp, freq, sigma, contrastGaborUp * temporalGaussian(1), aspectRatio, 0, 0, 0];
    
    %Set up two rectangles on the screen to position the left and right gabor
    %patches in
    baseRectUp = [0 0 (stimulusRadiusDeg*2) (stimulusRadiusDeg*2)];
    baseRectUp = baseRectUp .* pixPerDeg;
    baseRectDown = [0 0 (stimulusRadiusDeg*2) (stimulusRadiusDeg*2)];
    baseRectDown = baseRectUp .* pixPerDeg;
    
    downGaborRect = CenterRectOnPoint(baseRectUp,[xCenter + (cos(45) * radiusPix)],[yCenter + (sin(45)*radiusPix)]);
    
    upGaborRect = CenterRectOnPoint(baseRectUp,[xCenter + (cos(45) * radiusPix)],[yCenter - (sin(45)*radiusPix)]);
    
    %Draw the fixation cross
    Screen('DrawLines', window, allCoords, lineWidthPix, white, [xCenter, yCenter]);
    Screen('DrawLines', window, allCoords2, lineWidthPix2, grey, [xCenter, yCenter]);
    
    % % Perform initial flip to gray background and sync us to the retrace:
    vbl = Screen('Flip', window);
    
    % Numer of frames to wait before re-drawing
    waitframes = 1;
    
    time = 0;
    frameNumber = 1;
    
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     % activate stimulator
%     PM100.activate(obj,device)
%     
%     % setup stimulation protocol
%     PM100.setup_protocol(obj,device,pulse_shape,intensity,pulse_time,1)
%     
%     % start stimulation (run protocol)
%     PM100.start_stimulation(obj,device)
%     
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    BlockStartSec = GetSecs;
    timeElapsedSec = 0;
    pressed = 0;
    dotsOnDone = 0;
    while pressed == 0
        [keyIsDown,secs, keyCode] = KbCheck;
        if keyCode(escapeKey)
            sca;
        elseif keyCode(upKey)
            ResponseTime= GetSecs;
            pressed = 1;
            TrialAnswer(i) = 0;
            %if the target is equal to 1, then they are wrong
            if setTarget(i) == 1
                subjectPerformanceVector(i) = 0;
            end
            %if the target is equal to 0 then they are right
            if setTarget(i) == 0
                subjectPerformanceVector(i) = 1;
            end
        elseif keyCode(downKey)
            ResponseTime= GetSecs;
            pressed = 1;
            TrialAnswer(i) = 1;
            %if the target is equal to 0, then they are wrong
            if setTarget(i) == 0
                subjectPerformanceVector(i) = 0;
            end
            %if the target is equal to 1, then they are right
            if setTarget(i) == 1
                subjectPerformanceVector(i) = 1;
            end
        end
        
        
        % Animation loop
        while time < stimulusDurationSec
            
            % Set the right blend function for drawing the gabors
            Screen('BlendFunction', window, 'GL_ONE', 'GL_ZERO');
            %Message for Eyelink
            if dotsOnDone == 0
                Eyelink('Message', 'DOTSON');
                dotsOnDone = 1;
            end
            
            % Draw the fixation cross
            Screen('DrawLines', window, allCoords, lineWidthPix, white, [xCenter, yCenter]);
            Screen('DrawLines', window, allCoords2, lineWidthPix2, grey, [xCenter, yCenter]);
            
            % Draw the Gabor. By default PTB will draw this in the center of the screen
            % for us.
            Screen('DrawTextures', window, gabortex, [], upGaborRect, orientationGaborUp, [], [], [], [],kPsychDontDoRotation, propertiesMatGaborUp');
            Screen('DrawTextures', window, gabortex, [], downGaborRect, orientationGaborDown, [], [], [], [],kPsychDontDoRotation, propertiesMatGaborDown');
            
            % Change the blend function to draw an antialiased fixation point
            % in the centre of the array
            Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
            
            % Flip our drawing to the screen
            vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
            
            % Increment the phase of our Gabors
            phaseGaborUp = phaseGaborUp + degPerFrameUp;
            phaseGaborDown = phaseGaborDown + degPerFrameDown;
            propertiesMatGaborDown(:, 1) = phaseGaborDown';
            propertiesMatGaborUp(:, 1) = phaseGaborUp';
            
            % Increment the contrast of our Gabors acccording to achieve the gaussian fade
            % in and fade out
            propertiesMatGaborDown(:, 4) = contrastGaborDown * temporalGaussian(frameNumber);
            propertiesMatGaborUp(:, 4) = contrastGaborUp * temporalGaussian(frameNumber);
            
            time = time + ifi;
            frameNumber = frameNumber + 1;
        end
        
        Screen('FillRect', window, grey, windowRect);
        %Message for Eyelink
        if dotsOnDone == 1
            Eyelink('Message', 'DOTSOFF');
            dotsOnDone = 2;
        end
        
        % Draw the fixation point
        Screen('DrawLines', window, allCoords, lineWidthPix, white, [xCenter, yCenter]);
        Screen('DrawLines', window, allCoords2, lineWidthPix2, grey, [xCenter, yCenter]);
        Screen('Flip', window);
        
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

% PM100.deactivate(obj,device)
% 
% %Cleaning the COM port
% s=instrfind;
% fclose(s)
% delete(s)

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
sca;
IDs = repmat(str2num(SubID), numTrials, 1)';
IntensityNo = repmat(intensity, numTrials, 1)';
Session = repmat(str2num(SessionNo), numTrials, 1)';
Percentage = trialList .* 100;

data = [trialNumberVector; contrastUp; contrastDown; Percentage; setTarget; TrialAnswer; subjectPerformanceVector; Response_Time; IDs; IntensityNo; Session; TrialLength]
percentCorrect = sum(data(7,:)) / length(data(7,:)) * 100
dataFileName = ['CT-ID-' SubID '-' DateT '-Session-' SessionNo];

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