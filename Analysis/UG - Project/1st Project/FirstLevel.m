close all;
clear all;
clc;
rng('Shuffle');

files = dir('~/OneDrive - University of Reading/PhD/Undergraduate Project/Data/ID*/**/*.txt');
% files = dir('*.txt');
Nfiles = length(files) ;  % number of xl files

Bisection=[];
NewIllusion=[];

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
    
    
    trialNumberVector = data(1,:);
    trialList = data(2,:);
    FinList=data(3,:);
    Response=data(4,:);
    StartX=data(5,:);
    FinalLocationX=data(6,:);
    PressRightTrial=data(7,:);
    PressLeftTrial=data(8,:);
    RandomNumber=data(9,:);
    Offset=data(10,:);
    
    %6 different groups: <-> & <, <-> & >, <-> & |, >-< & <, >-< & >, >-< &|
    %<-> & >
    a= find((trialList == 1) & (FinList==1) & (Response==1));
    GroupA= mean(Offset(a));
    A= [ID, session,1,1, GroupA];
    
    %<-> & <
    b= find((trialList == 1) & (FinList==-1) & (Response==1));
    GroupB= mean(Offset(b));
    B= [ID, session,1,-1, GroupB];
    
    %<-> & |
    c=find((trialList == 1) & (FinList==0) & (Response==1));
    GroupC= mean(Offset(c));
    C= [ID, session,1,0, GroupC];
    
    %>-< & >
    d= find((trialList == -1) & (FinList==1) & (Response==1));
    GroupD= mean(Offset(d));
    D= [ID, session,-1,1, GroupD];
    
    %>-< & <
    e= find((trialList == -1) & (FinList==-1) & (Response==1));
    GroupE= mean(Offset(e));
    E= [ID, session,-1,-1, GroupE];
    
    %>-< & |
    f=find((trialList == -1) & (FinList==0) & (Response==1));
    GroupF= mean(Offset(f));
    F= [ID, session,-1,0, GroupF];
    
    SubID= num2str(ID);
    SessionNo = num2str(session);
    
    dataFileName = [task '-ID-' SubID '-Session-' SessionNo '.xlsx'];
    AVERAGE = [A; B;C;D;E;F];
    xlswrite(dataFileName,AVERAGE);
    
    if type==1
        Bisection=[AVERAGE i+rand];
    elseif type ==2
        NewIllusion= AVERAGE(i);
    end
    
    
    
    
        
end


%%
BisectionFileName = ['Final-Bisection.xlsx'];
NewIllusionFileName = ['Final-NewIllusion.xlsx'];

xlswrite(BisectionFileName, Bisection);

xlswrite(NewIllusionFileName, NewIllusion);