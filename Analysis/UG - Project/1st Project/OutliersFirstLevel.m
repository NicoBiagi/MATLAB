close all;
clear all;
clc;
rng('Shuffle');

files = dir('~/OneDrive - University of Reading/PhD/Undergraduate Project/Data/ID*/**/*.txt');
% files = dir('*.txt');
Nfiles = length(files) ;  % number of xl files

for i = 1:length(files)
    if contains(files(i).name, "Eyetracker") ==1
        files(i)= [];
    end
end
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for i = 1:Nfiles
    cd (files(i).folder);
    data = importdata(files(i).name);
    ID= str2num(files(i).name(4:5));
    
    if contains(files(i).name, "Bisection") == 1
        task = 'Bisection';
        type=1;
    elseif contains(files(i).name, "NewIllusion") == 1
        task = 'NewIllusion';
        type=2;
    else
        task = 'ERROR';
        type=0;
    end
    
    if contains(files(i).name, "Session-1")==1
        session =1;
    elseif contains(files(i).name, "Session-2")==1
        session =2;
    else
        session= 0;
    end
    
    
    trialNumberVector = data(1,:)';
    trialList = data(2,:)';
    FinList=data(3,:)';
    Response=data(4,:)';
    StartX=data(5,:)';
    FinalLocationX=data(6,:)';
    PressRightTrial=data(7,:)';
    PressLeftTrial=data(8,:)';
    RandomNumber=data(9,:)';
    Offset=data(10,:)';
    
    IDs= repmat(ID,1,length(trialNumberVector))';
    sessions = repmat(session,1,length(trialNumberVector))';
    
    OUTPUT= [IDs sessions trialNumberVector trialList FinList Offset];
    
    SubID= num2str(ID);
    SessionNo = num2str(session)';
    
    dataFileName = [task '-ID-' SubID '-Session-' SessionNo '-outliers.xlsx'];
    xlswrite(dataFileName,OUTPUT); 
end