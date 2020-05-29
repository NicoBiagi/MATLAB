%files = dir('~/OneDrive - University of Reading/PhD/Undergraduate Project/Data/ID*/**/*outliers.csv');
files = dir('C:\Users\zj903545\OneDrive - University of Reading\PhD\Undergraduate Project\Kate & Karen\Data\ID*\**\*.txt');
for i = 1:length(files)
copyfile( [files(i).folder '/' files(i).name], 'C:\Users\zj903545\OneDrive - University of Reading\PhD\Undergraduate Project\Kate & Karen\Eyetracker')
end