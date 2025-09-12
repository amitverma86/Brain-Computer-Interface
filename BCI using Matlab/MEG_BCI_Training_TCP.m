%% MEG/EEG based BCI paradigm for arm exoskeleton
% created by Nandani K. Roma(IITK) for UKIERI project 28 February 2018
% Acknowlegment - Dheeraj Rathee
% Modified by - Sujit Roy-03/03/2020
% Modified by - Alain Bigirimana 01/10/2020
% Modified by - Kaniska Samanta 27/10/2024
% Modified by - Amit Verma 30/08/2025

% Dependencies are - Cogent toolbox, Psychtoolbox and Fieldtrip toolbox

%% Add path
prePath = 'C:\Users\AmitVerma\OneDrive - Ulster University\Documents\UlsterUni\ISRC Hackathon\ISRC_build\ISRC_build\Hackathon_matlab\Hackathon';
addpath(genpath('C:\Users\AmitVerma\OneDrive - Ulster University\Documents\UlsterUni\ISRC Hackathon\ISRC_build\ISRC_build\Hackathon_matlab\Hackathon\'));

%% Please rename the file before starting the recording
% filename = ['TrainingData_sub_', ParticipantID, '_ses_',Session,'.mat'];
% pathsave= [prePath,'\mat_files\'];

%% Paradigm details:
no_of_trials = 25;%Runs_tr*NumTrials_per_run;
In_Blocks = false;
if ~In_Blocks
    blockSize = 1;
else
    blockSize = BlockSize;
end
%% Timing information
rest_duration = 1; %in secs
getready_duration = 1; %get ready instruction duration
prep_duration = 2; %preparation/planning duration
stim_duration = 5; % imagery task duration
InterTrialRestTime = 3; % Resting duration after fatigue confirmation (in minutes)

iti_values = [1,2]; % maximum duration of post-stim ITI in secs (in each condition)

% generate the trial order
classes = [1,2]; % 1 = right, 2 = left hand imagery
numberOfClasses = numel(classes);
numberOfBlocks = round(no_of_trials/blockSize);
blocks = Shuffle(repmat(classes,1,round(numberOfBlocks/numberOfClasses))); % blockSize/numel(classes)))
for i=1:length(blocks)
    icode((i-1)*blockSize+1:(i-1)*blockSize+blockSize)= blocks(i);
end
iti_duration = Shuffle(repmat(iti_values,1,ceil(numel(icode)/numel(iti_values))));


%% PARADIGM

%-----------------------Fixation cross definitions------------------------%
% Here we set the size of the arms of our fixation cross
fixCrossDimPix = 200;

% Now we set the coordinates (these are all relative to zero we will let
% the drawing routine center the cross in the center of our monitor for us)
xCoords = [-fixCrossDimPix fixCrossDimPix 0 0];
yCoords = [0 0 -fixCrossDimPix fixCrossDimPix];
allCoords = [xCoords; yCoords];
% Set the line width for our fixation cross
lineWidthPix = 5;

%---------------------------Triangle definitions--------------------------%

% Number of sides for our polygon
numSides = 3;

% Angles at which our polygon vertices endpoints will be. We start at zero
% and then equally space vertex endpoints around the edge of a circle. The
% polygon is then defined by sequentially joining these end points.
anglesDeg = linspace(0, 360, numSides + 1);
anglesRad = anglesDeg * (pi / 180);
radius = 35;

% X and Y coordinates of the points defining out polygon, centred on the
% centre of the screen
yPosVector1 = sin(anglesRad) .* radius + yCenter;
xPosVector1 = cos(anglesRad) .* radius + xCenter;
xPosVector2 = -cos(anglesRad) .* radius + xCenter;
% xPosVector2 = [880 940 940 880];

% Set the color of the ploygon to be black
rectColor = [0 0 0];

%---------------------------Image and Graphic details---------------------------------%
carim = im2double(imresize(imread('Car.png'),1.4));

leftvid = [prePath,'\pictures\LEFT_CAR_2.mp4'];
rightvid = [prePath,'\pictures\RIGHT_CAR_2.mp4'];

% Get the size of the image
size_carim = size(carim);

% Make the image into a texture
texture_carim = Screen('MakeTexture', window, carim);

yPos_lr = screenYpixels*0.75;
xPos_lr = linspace(screenXpixels * 0.1, screenXpixels * 0.9, 2.5);

%---------------------------To take the dataset---------------------------%
data=[];

%present initial instructions
Screen('TextSize', window, 70);
DrawFormattedText(window, 'Please keep still.\nGet ready!', 'center', 'center', black, [], [], [], 2);
Screen('Flip', window);
Speak('Please keep still and Get ready');
WaitSecs(3);
DrawFormattedText(window, 'Please keep fixating the center position \nthroughout the experiment. \nLeft arrow indicates left turn \nand right arrow indicates right turn.', 'center', 'center', black, [], [], [], 2);
Screen('Flip', window);
Speak('Please keep fixating the center position throughout the experiment. Left arrow indicates left turn and right arrow indicates right turn.');
WaitSecs(5);

%-------------------------------------------------------------------------%
                              %%%  START   %%%%          
                          %%% 1 -right & 2 -left  %%%
HideCursor;
trial_counter = 0; % initialize the trial counter for subjective mental fatigue scoring
j = 1; k = 1;
IntraRunRestingData = [];
red_flag = false; % Flag for mental fatigue monitoring
fatigued_trial_counter = 0;
IntraSession_FatigueScore = []; IntraSession_MotivationScore = []; IntraSession_BoredomScore = [];
IntraSession_confirmatory_FatigueScore = []; IntraSession_confirmatory_MotivationScore = []; IntraSession_confirmatory_BoredomScore = [];
channels_to_disregard = 1:3:306; % Magnetometers
all_channels = 1:306;
channels_to_consider = setdiff(all_channels,channels_to_disregard); % Only Gradiometers
for indtrial=1:numel(icode) % no_of_trials
    trial_counter = trial_counter + 1;
    WaitSecs(1)
    %-----------------------------RESTING---------------------------------%
    % Draw the fixation cross in white, set it to the center of our screen    
    Screen('DrawLines', window, allCoords,lineWidthPix, white, [xCenter yCenter], 2);
    Screen('DrawTexture', window, texture_carim);
    
    % Flip to the screen
    rest_onset_time = Screen('Flip', window);
    current_time = GetSecs - rest_onset_time;    
    while current_time <= rest_duration
        current_time = GetSecs - rest_onset_time;
    end
    %-----------------------------GET READY-------------------------------%
    %show get ready sign with change in color of the fixation cross
    Screen('DrawLines', window, allCoords,lineWidthPix, black, [xCenter yCenter], 2);  
    Screen('DrawTexture', window, texture_carim);
    
    % Flip to the screen
    getready_onset_time = Screen('Flip', window);
    current_time = GetSecs - getready_onset_time;    
    while current_time <= getready_duration
        current_time = GetSecs - getready_onset_time;
    end
   %-------------------------PLANNING & EXECUTION-------------------------%   
    if (icode(indtrial)==1) %Right        
        Screen('FillPoly', window, rectColor, [xPosVector1+390; yPosVector1]'); 
        Screen('DrawTexture', window, texture_carim);
        
        stim_time = Screen('Flip', window);
        Speak('Think Right Turn like this');
        playStim(rightvid,0.4,window,screenXpixels,screenYpixels);
        WaitSecs(2);
        % =======================================
        current_time = GetSecs - stim_time;
        while current_time <= stim_duration
            current_time = GetSecs - stim_time;
        end
    
    elseif (icode(indtrial)==2) %Left        
        Screen('FillPoly', window, rectColor, [xPosVector2-390; yPosVector1]');
        Screen('DrawTexture', window, texture_carim);
        
        stim_time = Screen('Flip', window);
        Speak('Think Left Turn like this');
        playStim(leftvid,0.6,window,screenXpixels,screenYpixels);
        WaitSecs(2);
        % ================================================
        current_time = GetSecs - stim_time;
        while current_time <= stim_duration
            current_time = GetSecs - stim_time;
        end
    end
    
    % Fetch the data from the LSL buffer
    tmp=[]; % temporary data chunk
    tmp = inlet.pull_chunk();
    data(:,:,indtrial) = tmp(1:numChn,end-((getready_duration+prep_duration+stim_duration)*fs-1):end);
    Labels(indtrial,:) = icode(indtrial);
    clear tmp;

    % ==============================================
    CheckQuitButton;
    
    %Inter trial interval
    %Screen('FillRect', window, grey);
    Screen('DrawTexture', window, texture_carim);
   
    iti_onset_time = Screen('Flip', window);
    current_time = GetSecs - iti_onset_time;
    while current_time <= iti_duration(indtrial)
        current_time = GetSecs - iti_onset_time;
    end
    % ==============================================
end
    
% Build the Classifier
MEEG_BCI_ClassifierModelling_LSL
dt = char(datetime('now','Format','MMdd-HHmm'));
fnm = ['EEG', dt, '.mat'];
save(fnm, 'data','Labels')
%%
sca
ShowCursor