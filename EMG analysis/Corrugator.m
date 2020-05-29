%% SCIPT FOR THE CORRIGATOR EMG
% the .txt file for the corrugator has been resampled, 20 time-stamps = 1
% second
clear all
clc
format long g

% this tells us which OS we are using and goes to the right folder
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
    if contains(files0(i).name, 'Corrugator')==1
        files(x) = files0(i);
        x=x+1;
    end
end

% this generates a loop for each participant, so that all the participants
% can be analysed together
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
        if contains(all_marker(i), "cue") ==1 && contains(all_marker(i), "sound")==0
            sound(y) = all_marker(i);
            y = y+1;
        end
    end
    
    % this is a loop that will analyse all the different marker, one at the
    % time
    for i = 1:length(sound)
        MARKER = sound(i);
        INDEX = find(marker2 == MARKER);
        
        % this generates a bunch of empty vectors
        BASELINE = [];
        RESPONSE1=[];
        RESPONSE2=[];
        RESPONSE3=[];
        RESPONSE4=[];
        RESPONSE5=[];
        RESPONSE6=[];
        
        % this creates a loop for each time that the cue was
        % presented
        for z = 1:length(INDEX)
            % this gives the EMG mean value for the 2 seconds BEFORE the
            % cue onset
            BASELINE{z} = mean(values(INDEX(z)-40:INDEX(z)));
            
            % this gives the EMG mean value for the 1st second after the
            % cue onset
            RESPONSE1{z} = mean(values(INDEX(z):INDEX(z)+20));
            
            % this gives the EMG mean value for the 2nd second after the
            % cue onset
            RESPONSE2{z} = mean(values(INDEX(z)+20:INDEX(z)+40));
            
            % this gives the EMG mean value for the 3rd second after the
            % cue onset
            RESPONSE3{z} = mean(values(INDEX(z)+40:INDEX(z)+60));
            
            % this gives the EMG mean value for the 4th second after the
            % cue onset
            RESPONSE4{z} = mean(values(INDEX(z)+60:INDEX(z)+80));
            
            % this gives the EMG mean value for the 5th second after the
            % cue onset
            RESPONSE5{z} = mean(values(INDEX(z)+80:INDEX(z)+100));
            
            % this gives the EMG mean value for the 6th second after the
            % cue onset
            RESPONSE6{z} = mean(values(INDEX(z)+100:INDEX(z)+120));
        end
        
        BASELINE = cat(1,BASELINE{:});
        RESPONSE1 = cat(1,RESPONSE1{:});
        RESPONSE2= cat(1,RESPONSE2{:});
        RESPONSE3 = cat(1,RESPONSE3{:});
        RESPONSE4 = cat(1,RESPONSE4{:});
        RESPONSE5 = cat(1,RESPONSE5{:});
        RESPONSE6 = cat(1,RESPONSE6{:});
        
        % this repeats the condition name
        COND = repelem(MARKER, length(INDEX),1);
        
        % this gives the time stamp for the cue onset
        ONSET = data(INDEX);
        
        % this combines all together in a matrix
        FINAL = [COND, ONSET, BASELINE, RESPONSE1, RESPONSE2, RESPONSE3, RESPONSE4, RESPONSE5 ,RESPONSE6];
        
        % this saves the result for this condition for later, so that we can have
        % just one loop for all the conditions
        d{i} = FINAL;
        
    end
    
    d = cat(1,d{:});
    
    % this creates the header for the matrix
    headers = {"Condition", "Onset", "Baseline", "1 Second After onset", "2 Seconds After onset", "3 Seconds After onset", "4 Seconds After onset", "5 Seconds After onset", "6 Seconds After onset"};
    
    % this combines the headers and the matrix with the EMG value
    d =[headers; d];
    
    % this saves a .xlsx file with the data
    xlswrite(strcat(files(x).name(1:end-4),'.xlsx'), d);
    
end

