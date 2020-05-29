%%section 1 read in datga from a text file
close all
clear all
rng('default');
rng('shuffle');

DateT = date;

doDeviance = 1;
doBoot = 1;
% 
minMarkerSize = 30; %DF size of dots on graph min
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
forPalymedes = importdata('ID-1-sette-15-Sep-2017-Session-1-PAL.txt'); % this line of codes works to import a space delimited text file with no header row from the working directory

stimLevels = forPalymedes(1,:);
numPos = forPalymedes(2,:);
outOfNum = forPalymedes(4,:); %3rd row has number correct on it, which we don't need so ignore it.

ID = num2str(unique(forPalymedes(5,:)));
Session = num2str(unique(forPalymedes(6,:)));

%input and output file names here

OutputFileName = ['CT-ID-' ID '-' DateT '-Session-' Session '-fitted'];%no need to include .txt at the end. it will be added when the file is saved

observer = ['CT-ID-' ID '-' DateT '-Session-' Session]; % title for graph DF
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% The matrix
dataMat = [stimLevels; numPos; outOfNum];

% Lets make a sensible guess as to the magnitude of our slope
% Lowest slope is max / min performance only at extremes
% Highest slope is same over 1/20th of the range
rise = 0.5;
minRun = (max(stimLevels) - min(stimLevels)) / 100;
maxRun = max(stimLevels) - min(stimLevels);
minSlope = rise / maxRun;
maxSlope = rise / minRun;

% Steps for the search grid values
numStepsLarge = 20;

% Number of bootstraps
B = 100;

% Inline cumulative Gaussian function
PF = @PAL_CumulativeNormal;

% Threshold and slope are free parameters, guess and lapse rate are fixed
% Threshold, Slope, Guess, Lapse
paramsFree = [1 1 0 1];

% Specify parameter grid to be searched by brute force
% Typical values for varying Gamma and Lambda would be
searchGrid.alpha = linspace(0, max(stimLevels), numStepsLarge);
searchGrid.beta = 10.^linspace(log10(minSlope), log10(maxSlope), numStepsLarge);
searchGrid.gamma = 0.0; %DF HAS REDUCECD THIS FROM 0.5 TO 0, WHICH SEEMS TO BE THE RIGHT THING TO DO WHEN MODELLING % LARGER JUDGMENTS
searchGrid.lambda = 0;%linspace(0, 0.05, numStepsLarge);

% Minimisation options
options = PAL_minimize('options');
options.TolFun = 1e-12;
options.TolX = 1e-12;
options.MaxFunEvals = 15000;
options.MaxIter = 15000;
options.Display = 'notify';

% Fit using maximum likelihood, with Gamma and Lambda equal to zero
[paramsValues, LL, exitFlag, output] = PAL_PFML_Fit(stimLevels, numPos, outOfNum,...
    searchGrid, paramsFree, PF, 'searchOptions', options, 'lapselimits', [0 0.05]);

% Grab the PSE and Slope
pse = paramsValues(1);
slope = paramsValues(2);
pseHeight = 0.5 - paramsValues(4);
pseY = 0.5; % + pseHeight * 0.5;
%%
% Report PSE and Slope
if doBoot == 1
    
    disp('Fitted Parameters...')
    message = sprintf('Threshold estimate: %6.4f', pse);
    disp(message);
    message = sprintf('Slope estimate: %6.4f\r', slope);
    disp(message);
    
    % Do a parametric bootstrap
    disp('Parametric Bootstrapping.....');

    % This is the line which does the bootstrapping
    [SD, paramsSim, LLSim, converged] = PAL_PFML_BootstrapParametric(stimLevels, outOfNum, paramsValues, paramsFree, B, PF,...
        'searchGrid', searchGrid, 'searchOptions', options, 'lapseLimits', [0 0.05]);
    
    % These are the parameter values for the bootstrapped PSE estimates
    simData = paramsSim(:, 1);
    simDataSlope = paramsSim(:, 2);
    
    % Get the lower and upper 95% percentiles of these estimates
    lowerPercentile = prctile(simData, 5);
    upperPercentile = prctile(simData, 95);
    lowerPercentileSlope = prctile(simDataSlope, 5);
    upperPercentileSlope = prctile(simDataSlope, 95);
    
    % Convert this into an upper and lower error bar length
    lowerBar = pse - lowerPercentile;
    upperBar = upperPercentile - pse;
    lowerBarSlope = slope - lowerPercentileSlope;
    upperBarSlope = upperPercentileSlope - slope;
    
    % Report the percentiles
    message = sprintf('Lower Limit: %6.4f', lowerPercentile);
    disp(message);
    message = sprintf('Upper Limit: %6.4f\r', upperPercentile);
    disp(message);
    
end

% Determine Goodness-of-Fit
if doDeviance == 1
    disp('Determining Goodness-of-fit.....');
    
    [Dev, pDev] = PAL_PFML_GoodnessOfFit(stimLevels, numPos, outOfNum, ...
        paramsValues, paramsFree, B, PF,'searchOptions', options, ...
        'searchGrid', searchGrid, 'lapseLimits', [0 0.05]);
    
    % Report the goordness of fit
    message = sprintf('Deviance: %6.4f', Dev);
    disp(message);
    message = sprintf('p-value: %6.4f', pDev);
    disp(message);
end
%%

% Report that we have finished fitting
disp('Finished');

% Make the fine grained function
propCorrect = numPos ./ outOfNum;
fineX = linspace(60, max(stimLevels)+10, 1000); %DF set x axis range here
fittedFunction = PAL_CumulativeNormal(paramsValues, fineX);

%%
tri = delaunayn(fittedFunction');%DF this is a bit of magic i found on google to do a nearest neighbour search
%no idea how it works! I find the nearest neighbour on the X axis to 25% larger presses and 75% larger presses
indexOfThresholdSmaller =dsearchn(fittedFunction',tri,.25);
thresholdSmaller = fineX(indexOfThresholdSmaller)
indexOfThresholdLarger = dsearchn(fittedFunction',tri,.75);
thresholdLarger = fineX(indexOfThresholdLarger)

thresholdSmallerRelativeToPSE = thresholdSmaller - pse
thresholdLargerRelativeToPSE = thresholdLarger - pse




% Scale the marker sizes
markerSizes = outOfNum ./ min(outOfNum) * minMarkerSize;
scaleMarkerSize = 1;

% Make the figure to display the function
figure
hold on;

% Plot the data
if scaleMarkerSize == 0
    plot(stimLevels, propCorrect, 'ro','MarkerSize', 32, 'MarkerFaceColor', 'r');
elseif scaleMarkerSize == 1
    scatter(stimLevels, propCorrect, markerSizes,'ro', 'MarkerFaceColor', 'r');
end

% Set the scale of the X and Y axis
axis([min(fineX) max(fineX) 0 1]);

% Plot the fitted function
plot(fineX,fittedFunction ,'g-','linewidth', 4);

% Plot the PSE
plot(pse, pseY, 'bs', 'MarkerSize', 12, 'MarkerFaceColor', 'b');

% Plot the error bar
if doBoot == 1
    plot([pse - lowerBar pse + upperBar], [pseY pseY], 'b-');
end

% Label the graph and release the graph
title(['Observer: ' observer]);
xlabel('Value of the second patch as % of the contrast of the first patch');
ylabel('% Higher contrast judgements');

% Add text showing various information related to the function
tx = 62;%max(stimLevels) * 0.1; DF this variable is locating the text on the graph
text(tx, 0.9, ['Num Boot Samples: ' num2str(B)]);
text(tx, 0.85, ['PSE: ' num2str(pse) ' (95% CI: ' num2str(lowerPercentile) ' to ' num2str(upperPercentile) ')']);
text(tx, 0.8, ['Slope: ' num2str(slope) ' (95% CI: ' num2str(lowerPercentileSlope) ' to ' num2str(upperPercentileSlope) ')']);
text(tx, 0.75, ['Thresh small rel2PSE: ' num2str(thresholdSmallerRelativeToPSE)]);
text(tx, 0.7, ['Thresh large rel2PSE: ' num2str(thresholdLargerRelativeToPSE)]);
if doDeviance == 0
    Dev = NaN;
    pDev = NaN;
end
text(tx, 0.65, ['Dev: ' num2str(Dev) ' (pDev:' num2str(pDev) ')']);
%note that pDev is like R2 in regression. The larger the number the better
%the fit.
    
fig = gcf;
fig.PaperPositionMode = 'auto';
set(gcf, 'InvertHardCopy', 'off');
print('-painters','-djpeg', '-r600', [observer '.jpg']);
    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%save summary of psychometric function that has been fitted to the data to a text file in the working directory
summaryOfPsychometricFunction = [pse,lowerPercentile, upperPercentile, slope,lowerPercentileSlope, upperPercentileSlope, thresholdSmaller, thresholdLarger,thresholdSmallerRelativeToPSE, thresholdLargerRelativeToPSE, Dev];
dlmwrite(strcat(OutputFileName, '.txt'), summaryOfPsychometricFunction, 'delimiter', '\t', 'precision', 6);

