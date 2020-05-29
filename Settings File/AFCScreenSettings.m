global screenNumber white black screenXpixels screenYpixels window windowRect ifi xCenter yCenter degPerPix fixCrossDimPix2 lineWidthPix2;
global pixPerDeg fixCrossDimPix xCoords yCoords allCoords lineWidthPix  allCoords2 vbl waitframes deg screens;
global screenDegY screenDegX distCm screenXcm screenYcm pixPerDegX pixPerDegY degPerPixX degPerPixY xCenterDeg yCenterDeg;
global fixCrossDimDeg lineWidthDeg fixCrossDimDeg2 xCoords2 yCoords2 lineWidthDeg2 radius;

% Skip sync tests for demo only
Screen('Preference', 'SkipSyncTests', 2);

%hide cursor
HideCursor();

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

%Monitor in 202: 
distCm = 65;
screenXcm = 53.35;
screenYcm = 30.10;

% Angular subtence of the screen (degrees)
screenDegY = 2 * atand((screenYcm / 2) / distCm);
screenDegX = 2 * atand((screenXcm / 2) / distCm);

% Calculate pixels per degree and degrees per pixel
pixPerDegX = screenXpixels /screenDegX;
pixPerDegY = screenYpixels /screenDegY;
pixPerDeg = mean([pixPerDegX pixPerDegY]);
degPerPixX = screenDegX /screenXpixels;
degPerPixY = screenDegY /screenYpixels;
degPerPix = mean([degPerPixX degPerPixY]);

%need these in Deg becasue stimuli will be defined in degrees until last step before drawing, when they will be converted to pixels
xCenterDeg = xCenter * degPerPix;
yCenterDeg = yCenter * degPerPix;

% Sync us and get a time stamp
vbl = Screen('Flip', window);
waitframes = 1;

%Set the size of the arms of the fixation cross
fixCrossDimDeg = 0.3; %degrees
fixCrossDimPix = fixCrossDimDeg * pixPerDeg;

% Now we set the coordinates (these are all relative to zero we will let
% the drawing routine center the cross in the center of our monitor for us)
xCoords = [-fixCrossDimPix fixCrossDimPix 0 0];
yCoords = [0 0 -fixCrossDimPix fixCrossDimPix];
allCoords = [xCoords; yCoords];

% Set the line width for our fixation cross
lineWidthDeg = 0.1 ; %degrees
lineWidthPix = lineWidthDeg * pixPerDeg;

%Second fixation cross
fixCrossDimDeg2 = 0.2; %degrees
fixCrossDimPix2 = fixCrossDimDeg2 * pixPerDeg;

xCoords2 = [-fixCrossDimPix2 fixCrossDimPix2 0 0];
yCoords2 = [0 0 -fixCrossDimPix2 fixCrossDimPix2];
allCoords2 = [xCoords2; yCoords2];

lineWidthDeg2 = 0.05 ; %degrees
lineWidthPix2 = lineWidthDeg2 * pixPerDeg;


%Set the radius of the circonference
%size in degress
deg = 5;
%size in pixels
radius = deg * pixPerDeg;