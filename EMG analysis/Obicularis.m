%% SCIPT FOR THE ORBICULARIS EMG
% BEFORE RUNNING THE SCRIPT CHECK THE SAMPLING RATE OF THE EMG DATA [AT THE MOMENT THE IBNTERVAL IS 0.001, SO A SAMPLE EVERY MILLISECOND, 20 SAMPLES MAKE A SECOND]
clear all
clc
format long g

sys= computer;
sys = string(sys);
if (sys =='MAC164')==1
    cd '/Users/nico/OneDrive - University of Reading/Jayne/Scripts';
elseif (sys == 'PCWIN64')==1
    cd 'C:\Users\zj903545\OneDrive - University of Reading\Jayne\Scripts\';
end
% Query the current working directory
a = pwd;

% Load all the .txt files found in the current working directory
files0 = dir(strcat(a, '/*.txt'));

% Remove the .txt files that do not include the word "Orbicularis" in the
% filename
x= 1;
for i = 1:length(files0)
    if contains(files0(i).name, 'Obicularis')==1
        files(x) = files0(i);
        x=x+1;
    end
end

for x = 1:length(files)
    %  Open the .txt file
    fid = fopen(files(x).name);
    
    % Load each column of the .txt file as a separate cell array
    C= textscan(fid, '%s%s%s%s');
    C = [C{:}];
    
    % convert the second colum (EMG values) from cell to string
    a = string(C(:,2));
    
    % get the index(es) of all the time the experiment was started
    START = find(a == "StartOfBlock");
    % we will use just the bigger value (i.e, the last time the experiment was
    % started)
    START = max(START);
    
    % we will get rid of all that was recorded before the start of the
    % experiment
    data = C((START+4:end),:);
    
    % convert the first column (time stamps) from cell to double
    time = str2double(data(:,1));
    
    % convert the second column (EMG values) from cell to double
    values = str2double(data(:,2));
    
    % convert the thrid coulm (first part of the markers) from cell to string
    marker1 = string(data(:,3));
    
    % convert the fourth column (second part of the marker, the one with the
    % name of the conditions) from cell to string
    marker2 = string(data(:,4));
    
    % get all the markers that were used in the experiment
    all_marker = unique(marker2);
    
    % save just the marker that were sent at the onset of the sound
    y = 1;
    for i = 1:length(all_marker)
        if contains(all_marker(i), "sound") ==1
            sound(y) = all_marker(i);
            y = y+1;
        end
    end
    
    % this is a loop that will analyse all the different marker, one at the
    % time
    for i = 1:length(sound)
        MARKER = sound(i);
        INDEX = find(marker2 == MARKER);
        BASELINE = [];
        RESPONSE=[];
        
        % this creates a loop for each time that the sound was presented
        for z = 1:length(INDEX)
            
            % this gives the mean values for the 25ms BEFORE the sound
            % onset
            BASELINE{z} = mean(values(INDEX(z)-25:INDEX(z)));
            
            % this gives the max values for the 20-120 ms interval AFTER
            % the sound onset
            RESPONSE{z} = max(values(INDEX(z)+20:INDEX(z)+120));
        end
        
        BASELINE = cat(1,BASELINE{:});
        RESPONSE = cat(1,RESPONSE{:});
        
        % this does the baseline correction
        CORRECTED = RESPONSE - BASELINE;
        
        % this repeats the condition name
        COND = repelem(MARKER, length(INDEX),1);
        
        % this gives the time stamp for the cue onset
        ONSET = data(INDEX);
        
        % this combines all together in a matrix
        FINAL = [COND, ONSET, BASELINE, RESPONSE, CORRECTED];
        
        % this saves the result for this condition for later, so that we can have
        % just one loop for all the conditions
        d{i} = FINAL;
        
    end
    
    d = cat(1,d{:});
    
    % this creates the header for the matrix
    headers = {"Condition", "Onset", "Baseline", "Max EMG 20-120 ms After onset", "EMG Bseline Corrected"};
    
    % this combines the headers and the matrix with the EMG value
    d =[headers; d];
    
    % this saves a .xlsx file with the data
    xlswrite(strcat(files(x).name(1:end-4),'.xlsx'), d);
    
end
