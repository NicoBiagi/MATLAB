clear all
clc


%load all the .txt files called 'Eyetracker'
files = dir('/Users/nico/OneDrive - University of Reading/PhD/Undergraduate Project/Kate & Karen/Data/ID-*/**/*-Eyetracker*.txt');
raw1 = {'ID', 'Session', 'Trial1', 'Trial2','Trial3', 'Trial4', 'Trial5','Trial6','Trial7','Trial8', 'Trial9'};

%convert all the files from .txt to .csv [excel files]
for i = 1:length(files)
    cd (files(i).folder);
    data = importdata(files(i).name);
    csvwrite([files(i).name '.csv'],data);
    data= [];
end

clear

files = dir('/Users/nico/OneDrive - University of Reading/PhD/Undergraduate Project/Kate & Karen/Data/ID-*/**/*-Eyetracker*.csv')

%move all the files into a specific folder
for i = 1:length(files)
    copyfile( [files(i).folder '/' files(i).name], '/Users/nico/OneDrive - University of Reading/PhD/Undergraduate Project/Kate & Karen/Eyetracker/MATLAB Output')
end
%%
cd 'C:\Users\zj903545\OneDrive - University of Reading\PhD\Undergraduate Project\Kate & Karen\Eyetracker\MATLAB Output';
a= pwd;
% files = dir('/Users/nico/OneDrive - University of Reading/PhD/Undergraduate Project/Kate & Karen/Eyetracker/MATLAB Output/*.csv');
% Load all the .wav files found in the current working directory
files = dir(strcat(a, '/*.csv'));


for i = 1:length(files)
cd (files(i).folder);
data = csvread(files(i).name);
mat{i} = data;
end

csvwrite('MATLAB-Eyetracker.csv', mat);