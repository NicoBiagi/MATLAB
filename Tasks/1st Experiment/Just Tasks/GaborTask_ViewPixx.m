% Clear the workspace and the screen
close all;
clear all;
clc;
sca;
rng('shuffle');
commandwindow


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
run_info = inputdlg(prompt, 'Info', 1, {' ', '1', '0'});
SubID = run_info{1};
SessionNo = run_info{2};
intensity = str2num(run_info{3});
DateT = date;

GaborScreenSettings;

gamma= 1.4924; %ViewPixx gamma

PsychColorCorrection('SetEncodingGamma', window, 1 ./ gamma);

%Creating a few varaiables
subjectPerformanceVector = [];
targetLocationVector = [];
trialNumberVector = [];
setTarget = [];
IDs = [];
TrialAnswer = [];
TrialStart = [];
TrialLength = [];


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

for i = 1: numTrials
    
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
    
    Screen('DrawLines', window, allCoords, lineWidthPix, white, [xCenter, yCenter]);
    Screen('DrawLines', window, allCoords2, lineWidthPix2, grey, [xCenter, yCenter]);
    
    % % Perform initial flip to gray background and sync us to the retrace:
    vbl = Screen('Flip', window);
    
    % Numer of frames to wait before re-drawing
    waitframes = 1;
    
    time = 0;
    frameNumber = 1;
    
    BlockStartSec = GetSecs;
    timeElapsedSec = 0;
    pressed = 0;
    
    while pressed == 0
        [keyIsDown,secs, keyCode] = KbCheck;
        if keyCode(escapeKey)
            sca;
        elseif keyCode(upKey)
            ResponseTime= GetSecs;
            pressed = 1;
            TrialAnswer(i) = 0;
            %if the target is equal to 1, then they are wrong
            if setTarget(i)== 1
                subjectPerformanceVector(i) = 0;
            end
            %if the target is equal to 0 then they are right
            if setTarget(i)== 0
                subjectPerformanceVector(i) = 1;
            end
        elseif keyCode(downKey)
            ResponseTime= GetSecs;
            pressed = 1;
            TrialAnswer(i) = 1;
            %if the target is equal to 0, then they are wrong
            if setTarget(i)== 0
                subjectPerformanceVector(i) = 0;
            end
            %if the target is equal to 1, then they are right
            if setTarget(i)== 1
                subjectPerformanceVector(i) = 1;
            end
        end
        
        
        % Animation loop
        while time < stimulusDurationSec
            
            % Set the right blend function for drawing the gabors
            Screen('BlendFunction', window, 'GL_ONE', 'GL_ZERO');
            
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
    
    %     %Defining the inter-trial interval.
    %     %If it took more than 5 second to the participant to produce a response, then there is no inter-trial
    %     %interval
    %     if TimeToRespond>=5
    %         interTrialPause =0.2;
    %         %If it took less than 5 seconds to the participant to produce a response,
    %         %then the inter-trial interval is the remaining seconds to add up to 5
    %         %seconds
    %     else
    %         interTrialPause = (5- TimeToRespond);
    %     end
    %     WaitSecs(interTrialPause);
    WaitSecs(2);
    
    TrialLength(i) = GetSecs - TrialStart(i);
    
    
end
sca;


IDs = repmat(str2num(SubID), numTrials, 1)';
IntensityNo = repmat(intensity, numTrials, 1)';
Session = repmat(str2num(SessionNo), numTrials, 1)';
trialListPercentage = trialList .* 100;

data = [trialNumberVector; contrastUp; contrastDown; trialListPercentage; setTarget; TrialAnswer; subjectPerformanceVector; Response_Time; IDs; IntensityNo; Session; TrialLength]
percentCorrect = sum(data(7,:)) / length(data(7,:)) * 100
dataFileName = ['CT-ID-' SubID '-' DateT '-Session-' SessionNo];

dlmwrite(strcat(dataFileName,'.txt'), data, 'delimiter', '\t', 'precision', 6)



