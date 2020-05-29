% Clear the workspace and the screen
close all;
clear all;
clc;
sca;
rng('shuffle')
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


AFCScreenSettings;

gamma= 1.4924; %ViewPixx gamma

PsychColorCorrection('SetEncodingGamma', window, 1 ./ gamma);

% Draw text in the middle of the screen in Times in white
Screen('TextSize', window, 100);
Screen('TextFont', window, 'Times');
DrawFormattedText(window, 'Welcome to the training session', 'center', 'center', white);
% Draw text in the bottom of the screen in Times in white
Screen('TextSize', window, 50);
Screen('TextFont', window, 'Times');
DrawFormattedText(window, 'Press any key to continue', 'center',...
    screenYpixels * 0.85, white);

% Flip to the screen
Screen('Flip', window);

KbWait
WaitSecs(0.1);
% Draw text in the middle of the screen in Times in white
Screen('TextSize', window, 35);
Screen('TextFont', window, 'Times');
DrawFormattedText(window, 'In this task two different sets of dots will be presented, in each trial, to the right of the fixation cross. \n \n The gap between one pair of dots will be slightly larger than the gap between the other pair of dots. \n \n  Your task is to stare at the fixation cross and decide for which pair of dots the gap is larger. \n \n Press the ''up arrow'' if this is the upper pair of dots and the ''down arrow'' if this is the lower pair of dots. \n \n In this training session after each trial you will receive correct/incorrect feedback about your performance. \n \n If you have any questions please ask the experimenter now, \n \n otherwise press any key to start the training session', 'center', 'center', white);

% Flip to the screen
Screen('Flip', window);

KbWait
WaitSecs(0.2);

%Draw the fixation cross
Screen('DrawLines', window, allCoords, lineWidthPix, white, [xCenter, yCenter],2);
Screen('DrawLines', window, allCoords2, lineWidthPix2, black, [xCenter, yCenter],2);
Screen('Flip',window);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Dots info
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%size of the dots
dotSizeDeg = 0.2;
dotSizePix = dotSizeDeg * pixPerDeg;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
time = 0;

pause(1);

%Distance of the second pair of dorts, as a percentage of the distance
%betqween the first pair of dots

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Training, 24 trials, 3 for each value
trialList(1:3) = 70;
trialList(4:6)= 79;
trialList(5:9)= 88;
trialList(10:12)= 97;
trialList(13:15)= 103;
trialList(16:18)= 112;
trialList(19:21)= 121;
trialList(22:24)= 130;

%Randomising the order of presentation
trialList = Shuffle(trialList);
%the number of trials is equal to the length of the trialList
numTrials = length(trialList);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Creating a few variables
trialNumberVector =[];
ResponseTime = [];
Response_Time = [];
targetLocationVector =[];
subjectPerformanceVector = [];
setTarget = [];
DC = [];
BA = [];
lengthCD= [];
lengthAB = [];
TrialAnswer = [];

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

for i = 1:numTrials
    
    trialNumberVector = [trialNumberVector, i];
    %Rho is rand angle between pi/6 (30°) and pi/3(60°)
    rh = [pi/6:pi/1000:pi/3];
    rh_pos= randi(length(rh));
    rho = rh(rh_pos);
    %The first two dots will be presented in the 1st quadrant (up)
    rho = -rho;
    %AB is a rand angle between pi/36(10°) and pi/9(30°)
    th= [pi/18:pi/100:pi/12];
    th_pos=randi(length(th));
    AB= th(th_pos);
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
    %%%SECOND PART
    %Rho2 is randomly chosen between pi/6(30°) and pi/3(60°)
    rh2 = [pi/6:pi/1000:pi/3];
    rh2_pos= randi(length(rh2));
    %the second set of dots will be presented in the fourth quadrant (down)
    rho2 = rh2(rh2_pos);
    %P is the distance between the first to dots in rad
    P = theta - theta2;
    %P_P is 1% of the distance between the first two dots
    P_P= P/100;
    CD = trialList(i) .* P_P;
    %alpha is equal to rho2 plus hal of the chosen distance
    alpha = rho2 + CD/2;
    %alpha2 is equal to rho2  minus half of the chosen distance
    alpha2 = rho2 - CD/2;
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
    
    lengthCD(i) = CD;
    lengthAB(i) = 2*AB;
    
    %Right answer
    if CD> 2*AB
        %the second interval is larger
        %The target is the second set of dots
        targetLocationVector(i)= 1;
    elseif 2*AB>CD
        %the second interval is smaller
        %the target is NOT the second set of dots
        targetLocationVector(i)= 0;
    end
    
    %defining the correct response
    if CD > 2*AB
        setTarget = 1; % subject must press the DOWN arrow if the second interval is bigger
    end
    if 2*AB > CD
        setTarget = 0; %subject must press the UP arrow if the second interval is smaller
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Timing and draw the dots
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    BlockStartSec = GetSecs;
    timeElapsedSec = 0;
    
    %The dots will be presented for 200 millisecs/12frames on a 60Hz display
    DotPresentation = 0.2;
    pressed = 0;
    
    while pressed == 0
        [keyIsDown,secs, keyCode] = KbCheck;
        if keyCode(escapeKey)
            sca;
        elseif keyCode(upKey)
            ResponseTime= GetSecs;
            pressed = 1;
            TrialAnswer(i) = 0;
            %if the target is equal to 1, then they are wrong. Larger
            %interval is DOWN
            if setTarget == 1
                subjectPerformanceVector = [subjectPerformanceVector, 0];
            end
            %if the target is equal to 0 then they are right. LArger
            %interval is UP
            if setTarget == 0
                subjectPerformanceVector = [subjectPerformanceVector, 1];
            end
        elseif keyCode(downKey)
            ResponseTime= GetSecs;
            pressed = 1;
            TrialAnswer(i) = 1;
            %if the target is equal to 0, then they are wrong.Larger
            %interval is UP
            if setTarget == 0
                subjectPerformanceVector = [subjectPerformanceVector, 0];
            end
            %if the target is equal to 0, then they are right.Larger
            %interval is DOWN.
            if setTarget == 1
                subjectPerformanceVector = [subjectPerformanceVector, 1];
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
    % Length of time and number of frames we will use for each drawing test
    numSecs = 1;
    numFrames = round(numSecs / ifi);
        
    % Numer of frames to wait when specifying good timing. Note: the use of
    % wait frames is to show a generalisable coding. For example, by using
    % waitframes = 2 one would flip on every other frame. See the PTB
    % documentation for details. In what follows we flip every frame.
    waitframes = 1;
    for frame = 1:numFrames
        if subjectPerformanceVector(i) == 1
            Screen('TextSize', window, 80);
            Screen('TextFont', window,  'Times');
            DrawFormattedText(window, 'CORRECT', 'center', 'center', white);
        else
        Screen('TextSize', window, 80);
        Screen('TextFont', window,  'Times');
        DrawFormattedText(window, 'INCORRECT', 'center', 'center', white);
        end
    
        % Flip to the screen
        vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
        
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
    
end

% Draw text in the middle of the screen in Times in white
Screen('TextSize', window, 85);
Screen('TextFont', window, 'Times');
DrawFormattedText(window, 'This is the end of the training session', 'center', 'center', white);
% Draw text in the bottom of the screen in Times in white
Screen('TextSize', window, 50);
Screen('TextFont', window, 'Times');
DrawFormattedText(window, 'Press any key to continue', 'center',...
    screenYpixels * 0.85, white);

% Flip to the screen
Screen('Flip', window);

KbWait;
WaitSecs(0.1);

sca;

DC = lengthCD';
BA = lengthAB';
Percentage = (lengthCD./lengthAB)*100;


data = [trialNumberVector; lengthAB; lengthCD; Percentage; targetLocationVector; TrialAnswer; subjectPerformanceVector; Response_Time]

percentCorrect = sum(data(7,:)) / length(data(7,:)) * 100