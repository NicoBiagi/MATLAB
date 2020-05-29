close all;
clear all;
clc;
rng('Shuffle');

DateT = date;

data = importdata('CT-ID-1-22-Sep-2017-Session-1.txt');

trialNumberVector = data(1,:);
contrastUp = data(2,:);
contrastDown= data(3,:);
trialList= data(4,:);
setTarget = data(5,:);
TrialAnswer = data(6,:);
subjectPerformanceVector = data(7,:);
Response_Time = data(8,:);
ID= data(9,:);
Intensity = data(10,:);
Session = data(11,:);
TrialLength = data(12,:);

SubID= unique(ID);
SessionNo = unique(Session);
SubID=num2str(SubID);
SessionNo= num2str(SessionNo);

dataFileName = ['CT-ID-' SubID '-' DateT '-Session-' SessionNo];

xAxisValues = unique(data(4,:)); %return a vector of the unique stimulus values used in the data collection
for i = 1: length(xAxisValues)
    indices = find(data(4,:)== xAxisValues(i));
    trialsPerXAxisValue(i) = length(indices); %num trials per x axis value
    totalssCorrect(i) = sum(data(7,indices)); % total correct at each x axis value
    totalsLarger(i) = sum(data(6,indices)); % total of times judged larger (right arrow key) at each x axis value
end

SubID=repmat(str2num(SubID),1,8);
SessionNo = repmat(str2num(SessionNo),1,8);
%now write the pre-processed data to another file
forPalymedes = [xAxisValues; totalsLarger; totalssCorrect; trialsPerXAxisValue; SubID; SessionNo];
dlmwrite(strcat(dataFileName, '-PAL.txt'), forPalymedes, 'delimiter', '\t', 'precision', 6)

