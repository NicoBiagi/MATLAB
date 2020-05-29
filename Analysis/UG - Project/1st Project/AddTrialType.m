clear
clc
sys= computer
sys = string(sys);
if (sys =='MAC164')==1
    cd '/Users/nico/OneDrive - University of Reading/PhD/Undergraduate Project/Kate & Karen/Eyetracker';
elseif (sys == 'PCWIN64')==1
    cd 'C:\Users\zj903545\OneDrive - University of Reading\PhD\Undergraduate Project\Kate & Karen\Eyetracker';
end
a= pwd;

files0 = dir(strcat(a, '/*.xlsx'));
x=1;
t =1;

for i = 1:length(files0)
    if contains(files0(i).name, 'OUTPUT')==1
        files_exp = files0(i);
    elseif contains(files0(i).name, 'TrialType')==1
        files_trial = files0(i);
    end
end

data_exp = xlsread([files_exp.folder '/' files_exp.name]);

data_trial = xlsread([files_trial.folder '/' files_trial.name]);

% find all the rows that belong to task 1 (i.e., Bisection) and session 1
task1_ses1_data_loc = find((data_exp(:,16)==1) & (data_exp(:,2)==1));
task1_ses1_trial_loc = find((data_trial(:,1)==1)& (data_trial(:,3)==1));
task1_ses1_exp = data_exp(task1_ses1_data_loc,:);
task1_ses1_trial = data_trial(task1_ses1_trial_loc,:);

% get all the PP IDs
PPs_task1_ses1 = unique(task1_ses1_exp(:,1));
% get the trial ID from the MATLAB output file
Trials_task1_ses1 = unique (task1_ses1_trial(:,4));

% long= trial-ID and participant-ID from the MATLAB
long_task1_ses1 = [task1_ses1_trial(:,4) task1_ses1_trial(:,2)];

% short= trial-ID and participant-ID from ET file
short_task1_ses1 =[task1_ses1_exp(:,15) task1_ses1_exp(:,1)];

all_direction1 = 0;
all_direction2 = 0;
all_direction3 =0;
all_direction4 =0;
all_direction5 =0;
idx_long = 0;
idx_short =0;


for T = 1:length(PPs_task1_ses1)
    t= PPs_task1_ses1(T);
    for j = 1:length(Trials_task1_ses1)
        
        idx_long = find(long_task1_ses1(:,1) == j & long_task1_ses1(:,2)==t);
        idx_short = find(short_task1_ses1(:,1) == j & short_task1_ses1(:,2)==t);
        
        all_direction1(end+1:end+length(idx_short),1) = repmat(task1_ses1_trial(idx_long,3), length(idx_short),1);
        all_direction2(end+1:end+length(idx_short),1) = repmat(task1_ses1_trial(idx_long,4), length(idx_short),1);
        all_direction3(end+1:end+length(idx_short),1) = repmat(task1_ses1_trial(idx_long,5), length(idx_short),1);
        all_direction4(end+1:end+length(idx_short),1) = repmat(task1_ses1_trial(idx_long,6), length(idx_short),1);
        
    end
    
end
all_direction1 = all_direction1(2:end);
all_direction2 = all_direction2(2:end);
all_direction3 = all_direction3(2:end);
all_direction4 = all_direction4(2:end);
final = [all_direction1 all_direction2 all_direction3 all_direction4];
data_task1_ses1 = [task1_ses1_exp all_direction2 all_direction3 all_direction4];

% find all the rows that belong to task 1 (i.e., Bisection) and session 2
task1_ses2_data_loc = find((data_exp(:,16)==1) & (data_exp(:,2)==2));
task1_ses2_trial_loc = find((data_trial(:,1)==1)& (data_trial(:,3)==2));
task1_ses2_exp = data_exp(task1_ses2_data_loc,:);
task1_ses2_trial = data_trial(task1_ses2_trial_loc,:);

% get all the PP IDs
PPs_task1_ses2 = unique(task1_ses2_exp(:,1));
% get the trial ID from the MATLAB output file
Trials_task1_ses2 = unique (task1_ses2_trial(:,4));

% long= trial-ID and participant-ID from the MATLAB
long_task1_ses2 = [task1_ses2_trial(:,4) task1_ses2_trial(:,2)];

% short= trial-ID and participant-ID from ET file
short_task1_ses2 = [task1_ses2_exp(:,15) task1_ses2_exp(:,1)];

all_direction1 = 0;
all_direction2 = 0;
all_direction3 =0;
all_direction4 =0;
all_direction5 =0;
idx_long = 0;
idx_short =0;


for T = 1:length(PPs_task1_ses2)
    t= PPs_task1_ses2(T);
    for j = 1:length(Trials_task1_ses2)
        
        idx_long = find(long_task1_ses2(:,1) == j & long_task1_ses2(:,2)==t);
        idx_short = find(short_task1_ses2(:,1) == j & short_task1_ses2(:,2)==t);
        
        all_direction1(end+1:end+length(idx_short),1) = repmat(task1_ses2_trial(idx_long,3), length(idx_short),1);
        all_direction2(end+1:end+length(idx_short),1) = repmat(task1_ses2_trial(idx_long,4), length(idx_short),1);
        all_direction3(end+1:end+length(idx_short),1) = repmat(task1_ses2_trial(idx_long,5), length(idx_short),1);
        all_direction4(end+1:end+length(idx_short),1) = repmat(task1_ses2_trial(idx_long,6), length(idx_short),1);
        
    end
    
end
all_direction1 = all_direction1(2:end);
all_direction2 = all_direction2(2:end);
all_direction3 = all_direction3(2:end);
all_direction4 = all_direction4(2:end);
final = [all_direction1 all_direction2 all_direction3 all_direction4];
data_task1_ses2 = [task1_ses2_exp all_direction2 all_direction3 all_direction4];

% find all the rows that belong to task 2 (i.e., Eyelink) and session 1
task2_ses1_data_loc = find((data_exp(:,16)==2) & (data_exp(:,2)==1));
task2_ses1_trial_loc = find((data_trial(:,1)==2)& (data_trial(:,3)==1));
task2_ses1_exp = data_exp(task2_ses1_data_loc,:);
task2_ses1_trial = data_trial(task2_ses1_trial_loc,:);

% get all the PP IDs
PPs_task2_ses1 = unique(task2_ses1_exp(:,1));
% get the trial ID from the MATLAB output file
Trials_task2_ses1 = unique (task2_ses1_trial(:,4));

% long= trial-ID and participant-ID from the MATLAB
long_task2_ses1 = [task2_ses1_trial(:,4) task2_ses1_trial(:,2)];

% short= trial-ID and participant-ID from ET file
short_task2_ses1 =[task2_ses1_exp(:,15) task2_ses1_exp(:,1)];

all_direction1 = 0;
all_direction2 = 0;
all_direction3 =0;
all_direction4 =0;
all_direction5 =0;
idx_long = 0;
idx_short =0;

for T = 1:length(PPs_task2_ses1)
    t= PPs_task2_ses1(T);
    for j = 1:length(Trials_task2_ses1)
        
        idx_long = find(long_task2_ses1(:,1) == j & long_task2_ses1(:,2)==t);
        idx_short = find(short_task2_ses1(:,1) == j & short_task2_ses1(:,2)==t);
        
        all_direction1(end+1:end+length(idx_short),1) = repmat(task2_ses1_trial(idx_long,3), length(idx_short),1);
        all_direction2(end+1:end+length(idx_short),1) = repmat(task2_ses1_trial(idx_long,4), length(idx_short),1);
        all_direction3(end+1:end+length(idx_short),1) = repmat(task2_ses1_trial(idx_long,5), length(idx_short),1);
        all_direction4(end+1:end+length(idx_short),1) = repmat(task2_ses1_trial(idx_long,6), length(idx_short),1);
        
    end
    
end
all_direction1 = all_direction1(2:end);
all_direction2 = all_direction2(2:end);
all_direction3 = all_direction3(2:end);
all_direction4 = all_direction4(2:end);
final = [all_direction1 all_direction2 all_direction3 all_direction4];
data_task2_ses1 = [task2_ses1_exp all_direction2 all_direction3 all_direction4];

% find all the rows that belong to task 2 (i.e., Eyelink) and session 2
task2_ses2_data_loc = find((data_exp(:,16)==2) & (data_exp(:,2)==2));
task2_ses2_trial_loc = find((data_trial(:,1)==2)& (data_trial(:,3)==2));
task2_ses2_exp = data_exp(task2_ses2_data_loc,:);
task2_ses2_trial = data_trial(task2_ses2_trial_loc,:);

% get all the PP IDs
PPs_task2_ses2 = unique(task2_ses2_exp(:,1));
% get the trial ID from the MATLAB output file
Trials_task2_ses2 = unique (task2_ses2_trial(:,4));

% long= trial-ID and participant-ID from the MATLAB
long_task2_ses2 = [task2_ses2_trial(:,4) task2_ses2_trial(:,2)];

% short= trial-ID and participant-ID from ET file
short_task2_ses2 = [task2_ses2_exp(:,15) task2_ses2_exp(:,1)];

all_direction1 = 0;
all_direction2 = 0;
all_direction3 =0;
all_direction4 =0;
all_direction5 =0;
idx_long = 0;
idx_short =0;

for T = 1:length(PPs_task2_ses2)
    t= PPs_task2_ses2(T);
    for j = 1:length(Trials_task2_ses2)
        
        idx_long = find(long_task2_ses2(:,1) == j & long_task2_ses2(:,2)==t);
        idx_short = find(short_task2_ses2(:,1) == j & short_task2_ses2(:,2)==t);
        
        all_direction1(end+1:end+length(idx_short),1) = repmat(task2_ses2_trial(idx_long,3), length(idx_short),1);
        all_direction2(end+1:end+length(idx_short),1) = repmat(task2_ses2_trial(idx_long,4), length(idx_short),1);
        all_direction3(end+1:end+length(idx_short),1) = repmat(task2_ses2_trial(idx_long,5), length(idx_short),1);
        all_direction4(end+1:end+length(idx_short),1) = repmat(task2_ses2_trial(idx_long,6), length(idx_short),1);
        
    end
    
end
all_direction1 = all_direction1(2:end);
all_direction2 = all_direction2(2:end);
all_direction3 = all_direction3(2:end);
all_direction4 = all_direction4(2:end);
final = [all_direction1 all_direction2 all_direction3 all_direction4];
data_task2_ses2 = [task2_ses2_exp all_direction2 all_direction3 all_direction4];

% find all the rows that belong to task 3 (i.e., NewIllusion) and session 1
task3_ses1_data_loc = find((data_exp(:,16)==3) & (data_exp(:,2)==1));
task3_ses1_trial_loc = find((data_trial(:,1)==3)& (data_trial(:,3)==1));
task3_ses1_exp = data_exp(task3_ses1_data_loc,:);
task3_ses1_trial = data_trial(task3_ses1_trial_loc,:);

% get all the PP IDs
PPs_task3_ses1 = unique(task3_ses1_exp(:,1));
% get the trial ID from the MATLAB output file
Trials_task3_ses1 = unique (task3_ses1_trial(:,4));

% long= trial-ID and participant-ID from the MATLAB
long_task3_ses1 = [task3_ses1_trial(:,4) task3_ses1_trial(:,2)];

% short= trial-ID and participant-ID from ET file
short_task3_ses1 =[task3_ses1_exp(:,15) task3_ses1_exp(:,1)];

all_direction1 = 0;
all_direction2 = 0;
all_direction3 =0;
all_direction4 =0;
all_direction5 =0;
idx_long = 0;
idx_short =0;

for T = 1:length(PPs_task3_ses1)
    t= PPs_task3_ses1(T);
    for j = 1:length(Trials_task3_ses1)
        
        idx_long = find(long_task3_ses1(:,1) == j & long_task3_ses1(:,2)==t);
        idx_short = find(short_task3_ses1(:,1) == j & short_task3_ses1(:,2)==t);
        
        all_direction1(end+1:end+length(idx_short),1) = repmat(task3_ses1_trial(idx_long,3), length(idx_short),1);
        all_direction2(end+1:end+length(idx_short),1) = repmat(task3_ses1_trial(idx_long,4), length(idx_short),1);
        all_direction3(end+1:end+length(idx_short),1) = repmat(task3_ses1_trial(idx_long,5), length(idx_short),1);
        all_direction4(end+1:end+length(idx_short),1) = repmat(task3_ses1_trial(idx_long,6), length(idx_short),1);
        
    end
    
end
all_direction1 = all_direction1(2:end);
all_direction2 = all_direction2(2:end);
all_direction3 = all_direction3(2:end);
all_direction4 = all_direction4(2:end);
final = [all_direction1 all_direction2 all_direction3 all_direction4];
data_task3_ses1 = [task3_ses1_exp all_direction2 all_direction3 all_direction4];

% find all the rows that belong to task 3 (i.e., NewIllusion) and session 2
task3_ses2_data_loc = find((data_exp(:,16)==3) & (data_exp(:,2)==2));
task3_ses2_trial_loc = find((data_trial(:,1)==3)& (data_trial(:,3)==2));
task3_ses2_exp = data_exp(task3_ses2_data_loc,:);
task3_ses2_trial = data_trial(task3_ses2_trial_loc,:);

% get all the PP IDs
PPs_task3_ses2 = unique(task3_ses2_exp(:,1));
% get the trial ID from the MATLAB output file
Trials_task3_ses2 = unique (task3_ses2_trial(:,4));

% long= trial-ID and participant-ID from the MATLAB
long_task3_ses2 = [task3_ses2_trial(:,4) task3_ses2_trial(:,2)];

% short= trial-ID and participant-ID from ET file
short_task3_ses2 = [task3_ses2_exp(:,15) task3_ses2_exp(:,1)];

all_direction1 = 0;
all_direction2 = 0;
all_direction3 =0;
all_direction4 =0;
all_direction5 =0;
idx_long = 0;
idx_short =0;

for T = 1:length(PPs_task3_ses2)
    t= PPs_task3_ses2(T);
    for j = 1:length(Trials_task3_ses2)
        
        idx_long = find(long_task3_ses2(:,1) == j & long_task3_ses2(:,2)==t);
        idx_short = find(short_task3_ses2(:,1) == j & short_task3_ses2(:,2)==t);
        
        all_direction1(end+1:end+length(idx_short),1) = repmat(task3_ses2_trial(idx_long,3), length(idx_short),1);
        all_direction2(end+1:end+length(idx_short),1) = repmat(task3_ses2_trial(idx_long,4), length(idx_short),1);
        all_direction3(end+1:end+length(idx_short),1) = repmat(task3_ses2_trial(idx_long,5), length(idx_short),1);
        all_direction4(end+1:end+length(idx_short),1) = repmat(task3_ses2_trial(idx_long,6), length(idx_short),1);
        
    end
    
end
all_direction1 = all_direction1(2:end);
all_direction2 = all_direction2(2:end);
all_direction3 = all_direction3(2:end);
all_direction4 = all_direction4(2:end);
final = [all_direction1 all_direction2 all_direction3 all_direction4];
data_task3_ses2 = [task3_ses2_exp all_direction2 all_direction3 all_direction4];

FINAL_DATA = [data_task1_ses1 ; data_task1_ses2 ; data_task2_ses1 ; data_task2_ses2 ; data_task3_ses1 ; data_task3_ses2];
csvwrite("FINAL_Trial.csv", FINAL_DATA);
xlswrite("FINAL_Trial.xlsx", FINAL_DATA);