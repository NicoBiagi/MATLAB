% Clear the workspace and the screen
sca;
close all;
clearvars;

% Here we call some default settings for setting up Psychtoolbox
PsychDefaultSetup(2);

% Seed the random number generator. Here we use the an older way to be
% compatible with older systems. Newer syntax would be rng('shuffle').
% For help see: help rand
rand('seed', sum(100 * clock));

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

% Get the size of the on screen window in pixels.
% For help see: Screen WindowSize?
[screenXpixels, screenYpixels] = Screen('WindowSize', window);

% Get the centre coordinate of the window in pixels
% For help see: help RectCenter
[xCenter, yCenter] = RectCenter(windowRect);

% Enable alpha blending for anti-aliasing
% For help see: Screen BlendFunction?
% Also see: Chapter 6 of the OpenGL programming guide
Screen('BlendFunction', window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

% Set the color of our dot to full red. Color is defined by red green
% and blue components (RGB). So we have three numbers which
% define our RGB values. The maximum number for each is 1 and the minimum
% 0. So, "full red" is [1 0 0]. "Full green" [0 1 0] and "full blue" [0 0
% 1]. Play around with these numbers and see the result.
%dotColor = [1 0 0];
trialList = 10;
dotColor1(1:trialList) = 1;
dotColor2(1:trialList) = 2;

dotColor = [dotColor1 dotColor2];
% Determine a random X and Y position for our dot. NOTE: As dot position is
% randomised each time you run the script the output picture will show the
% dot in a different position. Similarly, when you run the script the
% position of the dot will be randomised each time. NOTE also, that if the
% dot is drawn at the edge of the screen some of it might not be visible.
dotXpos = rand * screenXpixels;
dotYpos = rand * screenYpixels;

% Query the frame duration
ifi = Screen('GetFlipInterval', window);

numSecs = 1;
numFrames = round(numSecs / ifi);
% Sync us and get a time stamp
vbl = Screen('Flip', window);
waitframes = 1;

% Dot size in pixels
dotSizePix = 20;
%setting the keyboard
KbName('UnifyKeyNames');
KbQueueCreate(); %0 is main keyboard
KbQueueStart();
escapeKey = KbName('ESCAPE');
leftKey = KbName('LeftArrow');
rightKey = KbName('RightArrow');
Space=KbName('space');

for i = 1:length(dotColor)
    % Check the keyboard to see if a button has been pressed
    [keyIsDown,secs, keyCode] = KbCheck;
    
    % Depending on the button press, either move the position of the
    % rectangle or exit the script
    if keyCode(escapeKey)
        %if the press the esc button they stop the experiment
        sca;
    end
    
    % Draw the dot to the screen. For information on the command used in
    % this line type "Screen DrawDots?" at the command line (without the
    % brackets) and press enter. Here we used good antialiasing to get nice
    % smooth edges
    if dotColor(i) == 1
        Color = [1 0 0];
    else
        Color = [0 0 1];
    end
    
    for frame = 1:numFrames
        Screen('DrawDots', window, [xCenter yCenter], dotSizePix, Color, [], 2);
        % Flip to the screen. This command basically draws all of our previous
        % commands onto the screen. See later demos in the animation section on more
        % timing details. And how to demos in this section on how to draw multiple
        % rects at once.
        % For help see: Screen Flip?
        vbl  = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
    end
    for frame = 1:numFrames
        %Screen('DrawLines', window, fixCoords, fixWidthPix, white, [xCenter, yCenter],2);
        %Screen('DrawLines', window, fixCoords2, fixWidthPix2, black, [xCenter, yCenter],2);
        % Flip to the screen
        vbl  = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
    end
end

% Clear the screen. "sca" is short hand for "Screen CloseAll". This clears
% all features related to PTB. Note: we leave the variables in the
% workspace so you can have a look at them if you want.
% For help see: help sca
sca;