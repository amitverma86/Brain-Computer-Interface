clear
COM = 'COM7';
addpath(genpath('C:\Users\AmitVerma\OneDrive - Ulster University\Documents\UlsterUni\ISRC Hackathon\ISRC_build\ISRC_build\Hackathon_matlab\Hackathon'));

objs = instrfindall;
% Close any that are open
if ~isempty(objs)
    fclose(objs);
    % Delete them from MATLAB's memory
    delete(objs);
end
% Clear variables
clear objs

% LSL_Name = 'Unicorn_LSLStream';
LSL_type = 'EEG';
% Defining the LSL library and buffer
disp('Loading the LSL library...');
lib = lsl_loadlib();
% resolve a stream...xx
disp('Resolving an M/EEG stream...');
result= {};
restries = 0;
while isempty(result) && restries <= 3
    result = lsl_resolve_byprop(lib,'type',LSL_type);%'name',LSL_Name);
    restries = restries + 1; % Increment
end
if restries >= 3
    warning('LSL stream unavailable! Please start LSL stream')
    return;
end
% create a new inlet
disp('Opening an inlet...');
inlet = lsl_inlet(result{1});
disp('Inlet opened, checking connection...');
% Make sure a valid LSL stream has been established.
% LSL sometime takes time to established a streaming connection. 
% It is a good practice to validate the connection by pulling some 
% data out of the buffer before starting the experiment.
while true
    [chunk, stamps] = inlet.pull_chunk();
    if ~isempty(chunk)
        break;
    end
end
disp('LSL Connection established!!');

try
    s = serial(COM);
    set(s,'BaudRate',9600);
    set(s,'DataBits',8);
    set(s,'StopBits',1);
    set(s,'Parity','non');
    fopen(s);
    disp('SP Connection established!!');
    spOpen = true;
catch
    warning('Serial port not opened! Continuing without serial port')
    spOpen = false;
end

numChn = 8;
fs = 250;


Psychtoolbox_screen_setup
MEG_BCI_Training_TCP
Car_ctrl_rt
fclose(s);
delete(s);