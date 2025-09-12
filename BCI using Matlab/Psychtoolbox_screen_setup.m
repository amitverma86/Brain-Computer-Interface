%% ====== Screen setup ====== %%
PsychDefaultSetup(2);

% Get the screen numbers. 
screens = Screen('Screens');

% To draw we select the maximum of these numbers. So in a situation where we
% have two screens attached to our monitor we will draw to the external
% screen.

screenNumber = max(screens);

% Define black and white (white will be 1 and black 0). 
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);

% Do a simply calculation to calculate the luminance value for grey. This
% will be half the luminace values for white
grey = white / 2;
% ================= skip calibrations ======================
Screen('Preference', 'SkipSyncTests', 1); 
% ===========================================
% Open an on screen window using PsychImaging and color it black.
PsychImaging('PrepareConfiguration');
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, grey);

% Set the blend function for the screen
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

% Get the size of the on screen window in pixels, these are the last two
% numbers in "windowRect" and "rect"
[screenXpixels, screenYpixels] = Screen('WindowSize', window);

% Query the inter-frame-interval. This refers to the minimum possible time
% between drawing to the screen
ifi = Screen('GetFlipInterval', window);

% Get the centre coordinate of the window in pixels
[xCenter, yCenter] = RectCenter(windowRect);

Screen('TextSize', window, 35);
Screen('TextFont', window, 'Times');

%retrieve refresh rate and abort if it's not 60hz (we want to use same-rate projectors)
hz=Screen('NominalFrameRate',0);
if hz ~= 60
    error('warning: Refresh rate of projector should be 60 Hz');
end