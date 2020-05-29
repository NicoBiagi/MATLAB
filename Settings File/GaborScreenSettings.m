global screenNumber white black grey screenXpixels screenYpixels window windowRect ifi xCenter yCenter degPerPix fixCrossDimPix2 lineWidthPix2;
global pixPerDeg fixCrossDimPix xCoords yCoords allCoords lineWidthPix radiusPix allCoords2 driftSpeedDegPerSecDown driftSpeedDegPerSecUp orientationGaborDown;
global orientationGaborUp screenDegY screenDegX distCm screenXcm screenYcm pixPerDegX pixPerDegY degPerPixX degPerPixY xCenterDeg yCenterDeg;
global fixCrossDimDeg lineWidthDeg fixCrossDimDeg2 xCoords2 yCoords2 lineWidthDeg2 radius vbl waitframes;

%Calling the default setup
PsychDefaultSetup(2);

%Hiding the cursor
HideCursor();

% Set the screen number to the external secondary monitor if there is one connected
screenNumber = max(Screen('Screens'));

% Skip sync tests for demo purposes only
Screen('Preference', 'SkipSyncTests', 2);

% Define black, white and grey
white = WhiteIndex(screenNumber);
grey = white / 2;
black = BlackIndex(screenNumber);

% Open the screen
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, grey, [], 32, 2,[], [],  kPsychNeed32BPCFloat);

%Some values copied and pasted from the Gabor Function
driftSpeedDegPerSecDown = 0.0;
driftSpeedDegPerSecUp = 0.0;
orientationGaborDown = 0.0;
orientationGaborUp = 0.0;

% Query the frame duration
ifi = Screen('GetFlipInterval', window);

% Get the centre coordinate of the window in units of pixels
[xCenter, yCenter] = RectCenter(windowRect);

% Get the size of the on screen window in pixels
[screenXpixels, screenYpixels] = Screen('WindowSize', window);

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

%%Set the size of the arms of the fixation cross
%Fixation Cross in degress
fixCrossDimDeg = 0.3;
%Fixation Cross in pixels
fixCrossDimPix = fixCrossDimDeg * pixPerDeg;
xCoords = [-fixCrossDimPix fixCrossDimPix 0 0];
yCoords = [0 0 -fixCrossDimPix fixCrossDimPix];
allCoords = [xCoords; yCoords];

%%Set the line width for our fixation cross
%Width in degrees
lineWidthDeg = 0.1;
%Width in pixels
lineWidthPix = lineWidthDeg * pixPerDeg;

%Second fixation cross
fixCrossDimDeg2 = 0.2; %degrees
fixCrossDimPix2 = fixCrossDimDeg2 * pixPerDeg;

xCoords2 = [-fixCrossDimPix2 fixCrossDimPix2 0 0];
yCoords2 = [0 0 -fixCrossDimPix2 fixCrossDimPix2];
allCoords2 = [xCoords2; yCoords2];

lineWidthDeg2 = 0.05 ; %degrees
lineWidthPix2 = lineWidthDeg2 * pixPerDeg;

%Set the radius, i.e. the distance from the centre of the screen (without
%the offset
%Radius in degrees
radius = 5;
%Radius in pixels
radiusPix = radius * pixPerDeg;
