% Clear the workspace and the screen
close all;
clear all;
clc;
sca;
rng('shuffle')
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Prompt Info
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
prompt = {'Enter ID:','Session Number:', 'Intensity of Stimulation:'};
run_info = inputdlg(prompt, 'Info', 1, {' ', '1', '0'});
SubID =run_info{1};
SessionNo = run_info{2};
intensity = str2num(run_info{3});
DateT = date;

AFCScreenSettings;

gamma= 1.4924; %ViewPixx gamma

PsychColorCorrection('SetEncodingGamma', window, 1 ./ gamma);

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

%Draw the fixation cross
Screen('DrawLines', window, allCoords, lineWidthPix, white, [xCenter, yCenter],2);
Screen('DrawLines', window, allCoords2, lineWidthPix2, black, [xCenter, yCenter],2);
Screen('Flip',window);
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

%size of the dots
dotSizeDeg = 0.2;
dotSizePix = dotSizeDeg * pixPerDeg;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
time = 0;
pause(1)

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%Long Experiment, 240 trials, 30 for each value
% trialList(1:30) = .70;
% trialList(31:60)= .79;
% trialList(61:90)= .88;
% trialList(91:120)= .97;
% trialList(121:150)= 1.03;
% trialList(151:180)= 1.12;
% trialList(181:210)= 1.21;
% trialList(211:240)= 1.30;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%SuperFast Experiment, debug only 10 trials, always down
trialList(1:10)= 1.30;

trialList = Shuffle(trialList);
numTrials = length(trialList);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%loop through the set of trials (could just be a list of one trial if we
%make this script into a function that we call from another script that
%does the palamedes bit
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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
    
    %Timing and draw the dots
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    BlockStartSec = GetSecs;
    timeElapsedSec = 0;
    
    %The dots will be presented for 200 millisecs/12frames on a 60Hz display
    DotPresentation = 0.2;
    blockDurationSec = 4;
    pressed = 0;
    
    while pressed == 0
        [keyIsDown,secs, keyCode] = KbCheck;
        if keyCode(escapeKey)
            sca;
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
            %drawing the fixation cross
            Screen('DrawLines', window, allCoords, lineWidthPix, white, [xCenter, yCenter],2);
            Screen('DrawLines', window, allCoords2, lineWidthPix2, black, [xCenter, yCenter],2);
            vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
        end
        
        if timeElapsedSec > DotPresentation
            StartTrial = GetSecs;
            %drawing the fixation cross
            Screen('DrawLines', window, allCoords, lineWidthPix, white, [xCenter, yCenter],2);
            Screen('DrawLines', window, allCoords2, lineWidthPix2, black, [xCenter, yCenter],2);
            vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
        end
        %this updates the time
        timeElapsedSec = GetSecs - BlockStartSec;
        
    end
    
    Screen('DrawLines', window, allCoords, lineWidthPix, white, [xCenter, yCenter],2);
    Screen('DrawLines', window, allCoords2, lineWidthPix2, black, [xCenter, yCenter],2);
    vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
    
    %Defining the time that took to the participant to produce a response
    TimeToRespond = ResponseTime-BlockStartSec;
    
    %Recording the reaction time for posterity
    Response_Time(i) = TimeToRespond;
    
    
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
    
end


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