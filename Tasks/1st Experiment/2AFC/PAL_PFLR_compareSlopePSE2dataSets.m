% DF Notes: the  demo file this based this on refers to a "2 group
% experiment". Does this mean this is ainapropriate for a within subjects
% experiment?
%Need to check by comparosn with Peters 95% confidence intervlas whether
%the error bars on Fig 1 are 1SE or 95% confidence. Having compared they
%look the same size as Peter's 95% confidence intervals we use fot fitting
%single PF's. But the function help calls them standard errors...



clear all;
close all;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%input file names of two data files containing the 2 indivdual sets of data
%to be fitted and statistically compared here. Data files must be in the
%working directory 
condition1Data = importdata('PP4_Baseline_palymedesReady.txt'); % this line of codes works to import a space delimited text file with no header row from the working directory
condition2Data = importdata('PP4_interval_3_palymedesReady.txt');
%specify the text labeling the two data series in the graph legend here
condition1Name = '1: ISI = 0 sec';
condition2Name = '2: ISI = 2 sec';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% stimLevels = condition1Data(1,:);
% numPos = condition1Data(2,:);
% outOfNum = condition1Data(4,:);
%make vectors combining data from the two experimental conditions
%note that the stimLevels vectors should be the same for both conditions,
%and should be the superset of the stim levesl used across both conditions.
%if in one condition a particular stim level was not used, then it's
%corresponding values in numPos and outOfNum must be set to 0. In this way the script can
%compare 2 sets of data that did not use identical stimuli (AND THIS WILL
%BE necessary WHEN MODIFYING THIS SCRIPT FOR USE WITH DESPINA's DATA. That will require a bit
% of preprocessing on the data files though. An other option is to check if a cell array is an 
%accepteted input to palymedes functions, but i guess it will not be)
StimLevels = [condition1Data(1,:);condition2Data(1,:)];
NumPos = [condition1Data(2,:);condition2Data(2,:)];
OutOfNum = [condition1Data(4,:);condition2Data(4,:)];


% % 
% StimLevels = [75 85 95 105 115 125;75 85 95 105 115 125]; 
% %Number of positive responses (e.g., 'yes' or 'correct' at each of the 
% %   entries of 'StimLevels'  
% 
% NumPos = [0 3 7 12 14 20; 0 1 6 16 19 20];
% 
% %Number of trials at each entry of 'StimLevels'
% OutOfNum = [100 100 100 100 100 100; 100 100 100 100 100 100];
% OutOfNum = OutOfNum ./5;

message = 'Parametric Bootstrap (1) or Non-Parametric Bootstrap? (2): ';
ParOrNonPar = input(message);
message = sprintf('Number of simulations to perform to determine standar');
message = strcat(message, 'd errors: ');
Bse = input(message);
message = sprintf('Number of simulations to perform to determine model c');
message = strcat(message, 'omparison p-values: ');
Bmc = input(message);
% ParOrNonPar = 1; %DF has fixed these 3 values for speed of code development. But give proper values before using this in anger.
% Bse = 60;
% Bmc = 60;

tic


%Plot raw data
ProportionCorrectObserved = NumPos ./ OutOfNum;
%ProportionCorrectObserved = NumPos; %Df use this line instead of one above
%if input data is already converted to proportion correct
StimLevelsFineGrain = [min(min(StimLevels)):(max(max(StimLevels) - ... 
    min(min(StimLevels))))./1000:max(max(StimLevels))];
handleToFig1 = figure('name','Individual Psychometric Functions','units','pixels',...
    'position',[100 100 500 500]);
plot(StimLevels(1,:),ProportionCorrectObserved(1,:),'ko','markersize',...
    10,'markerfacecolor','r');
h1 = gca; %DF gca is a function that gets a handle to the current axis.
set(h1, 'units','pixels','position',[75 300 375 175]);
set(h1, 'fontsize',12);
set(h1, 'Xtick',StimLevels(1,:));
set(h1, 'Ytick',[0:.1:1]); % DF altered 0.5 to 0
axis([min(StimLevels(1, :)) max(StimLevels(1, :)) 0 1]); %DF need to set x and y axis ranges suitably to the type of data
hold on;
plot(StimLevels(2,:),ProportionCorrectObserved(2,:),'ks','markersize',...
    10,'markerfacecolor','g');
xlabel('Angle as % of interval 1 angle');%DF
ylabel('% Larger judgements');%DF
drawnow

% %Fit a Logistic function
% PF = @PAL_Logistic;  %Alternatives: PAL_Gumbel, PAL_Weibull, 
%                      %PAL_CumulativeNormal, PAL_HyperbolicSecant

% DF copying Peter's choice and using Inline cumulative Gaussian function
PF = @PAL_CumulativeNormal;

%Guesses for free parameters, fixed values for fixed parameters
%params = [0 1 .5 0];    %or e.g.: [0 1 .5 0; 0 1 .5 0];

% Lets make a sensible guess as to the magnitude of our slope
% Lowest slope is max / min performance only at extremes
% Highest slope is same over 1/20th of the range
rise = 0.5;
minRun = (max(max(StimLevels)) - min(min(StimLevels))) / 100;
maxRun = max(max(StimLevels)) - min(min(StimLevels));
minSlope = rise / maxRun;
maxSlope = rise / minRun;
slopeGuess = minSlope + maxSlope / 2;

%DF initial guesses are that the threshold will be the mean of the
%StimLevels, that the slope will be betwen the min and MAx values Peter
%uses in his code
params = [mean(mean(StimLevels)), slopeGuess, 0, 0];

%Optional arguments for PAL_PFML_FitMultiple, 
%PAL_PFML_BootstrapParametricMultiple, 
%PAL_PFML_BootstrapNonParametricMultiple, PAL_PFLR_ModelComparison, and
%PAL_PFML_GoodnessOfFitMultiple
options = PAL_minimize('options');   %PAL_minimize search options
options.TolFun = 1e-12;     %Increase desired precision on LL
options.TolX = 1e-12;       %Increase desired precision on parameters
options.MaxFunEvals = 5000; %Allow more function evals
options.MaxIter = 5000;     %Allow more iterations
options.Display = 'off';    %suppress fminsearch messages
lapseLimits = [0 0.05];        %Range on lapse rates. 
maxTries = 4;               %Try each fit at most four times        
rangeTries = [2 1.9 0 0];   %Range of random jitter to apply to initial 
                            %parameter values on retries of failed fits.

                            

%Fit lesser '1PF' model (constrained thresholds, constrained slopes, 
%   fixed guess rates, fixed lapse rates).
[paramsL LL exitflag output trash numParams1T1S] = PAL_PFML_FitMultiple(StimLevels, NumPos, ...
    OutOfNum, params, PF, 'thresholds','constrained','slopes',...
    'constrained','guessrates','fixed','lapserates','fixed',...
    'lapseLimits',lapseLimits,'SearchOptions',options);

%Fit fuller '2PF' model (unconstrained thresholds, unconstrained slopes, 
%   fixed guess rates, fixed lapse rates).
[paramsF LL exitflag output trash numParams2T2S] = PAL_PFML_FitMultiple(StimLevels, NumPos, ...
    OutOfNum, paramsL, PF, 'thresholds','unconstrained','slopes',...
    'unconstrained','guessrates','fixed','lapserates','unconstrained',...
    'lapseLimits',lapseLimits,'SearchOptions',options);





%plot fitted functions
ProportionCorrectModel = PF(paramsF(1,:),StimLevelsFineGrain);
plot(StimLevelsFineGrain,ProportionCorrectModel,'-','linewidth',2,...
    'color',[0.7 .0 0]); %DF made this line red intstead of green
ProportionCorrectModel = PF(paramsF(2,:),StimLevelsFineGrain);
plot(StimLevelsFineGrain,ProportionCorrectModel,'-','linewidth',2,...
    'color',[0 .7 0]);



set(h1, 'HandleVisibility','off');

%%

%Threshold plot (SE bars to be added later)
%plot(1:2,paramsF(1:2,1),'ko','markersize',6,'markerfacecolor','k');
%legend('hide')
plot(1,paramsF(1,1),'ko','markersize',6,'markerfacecolor','r'); % DF plotting points individually so i can color/shape code them
hold on;

plot(2,paramsF(2,1),'ks','markersize',6,'markerfacecolor','g');


%axis([.5 2.5 -1 1]);

axis([.5 2.5 80 110]); %DF need to set x and y axis ranges suitably to the type of data
h2 = gca;
set(h2, 'units','pixels','position',[75 60 150 175]);

hold on;
set(h2, 'fontsize',12); %DF reduced font size for the 2 mini graphs
 set(h2, 'Xtick',[1 2]);
set(h2, 'Ytick',[80:5:110]); % DF 
xlabel('Condition');
ylabel('PSE (% of interval 1)');
set(h2, 'HandleVisibility','off');

%Slope plot (SE bars to be added later)
%plot(1:2,paramsF(1:2,2),'ko','markersize',6,'markerfacecolor','k');
plot(1,paramsF(1,2),'ko','markersize',6,'markerfacecolor','r'); % DF plotting points individually so i can color/shape code them
hold on;
plot(2,paramsF(2,2),'ks','markersize',6,'markerfacecolor','g');
h3 = gca;
%axis([.5 2.5 0 2]);

axis([.5 2.5 minSlope maxSlope/4]); %DF need to set x and y axis ranges suitably to the type of data

set(h3, 'units','pixels','position',[300 60 150 175]);
hold on;
set(h3, 'fontsize',12); %DF reduced font size for the 2 mini graphs
set(h3, 'Xtick',[1 2]);
set(h3, 'Ytick',[minSlope:((maxSlope/4)-minSlope) / 5:maxSlope]); % DF 
xlabel('Condition');
ylabel('Slope');
set(h3, 'HandleVisibility','off');
drawnow



%DF are these 1SE or 95% confidence? We can work it out by comparing to the
%size of the error bar on the graph that the fitFunctionsVisualAngle.m
%spits out
%Determine Standard errors on Thresholds and Slopes
message = 'Determining standard errors......';
disp(message);
if ParOrNonPar == 1
    [SD paramsSim LLSim converged] = ...
        PAL_PFML_BootstrapParametricMultiple(StimLevels, OutOfNum, ...
        paramsF, Bse, PF, 'thresholds','unconstrained','slopes',...
        'unconstrained','guessrates','fixed','lapserates','unconstrained', ...
        'lapseLimits',lapseLimits,'SearchOptions',options,'maxTries',...
        maxTries,'rangeTries',rangeTries); 
else
    [SD paramsSim LLSim converged] = ...
        PAL_PFML_BootstrapNonParametricMultiple(StimLevels, NumPos, ...
        OutOfNum, paramsF, Bse, PF, 'thresholds','unconstrained',...
        'slopes','unconstrained','guessrates','fixed','lapserates',...
        'unconstrained', 'lapseLimits',lapseLimits,'SearchOptions',options,...
        'maxTries',maxTries,'rangeTries',rangeTries); 
end

%Add standard error bars to graphs
set(h2, 'HandleVisibility','on');
axes(h2);
line([1 1],[paramsF(1,1)-SD(1,1) paramsF(1,1)+SD(1,1)],'color','k',...
    'linewidth',2);
line([2 2],[paramsF(2,1)-SD(2,1) paramsF(2,1)+SD(2,1)],'color','k',...
    'linewidth',2);
set(h2, 'HandleVisibility','off');

set(h3, 'HandleVisibility','on');
axes(h3);
line([1 1],[paramsF(1,2)-SD(1,2) paramsF(1,2)+SD(1,2)],'color','k',...
    'linewidth',2);
line([2 2],[paramsF(2,2)-SD(2,2) paramsF(2,2)+SD(2,2)],'color','k',...
    'linewidth',2);
set(h2, 'HandleVisibility','off');
drawnow

%%%%%%%%%DF IMPORTANT NOTE: add legend last when plotting, and reactivate
%%%%%%%%%axis you want to add it to before adding it!
set(h1, 'HandleVisibility','on'); % DF have to make h1 visible again before I can make it current axis
set(handleToFig1,'CurrentAxes',h1)% DF make the large axes at the top of the figure the current ones
%DF add the legend. Seems i have to do it at the end here or it gets moved
%when adding later panels and screws everything up nicely
handleToLegend = legend(condition1Name,condition2Name);
set(handleToLegend, 'Location', 'NorthWest')
set(handleToLegend, 'fontsize', 10)
set(handleToLegend, 'Box', 'off')
set(h1, 'HandleVisibility','off');  %Df make h1 invisible again in case it matters?

%%

%DF this section asks whether 2 PF's do significantly better than 1PF
%where both sope and PSE are free to vary
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

message = 'Performing model comparison: Effect on PSE and/or slope?';
disp(message);

%omnibus test (2 PF vs 1 PF model, same threshold AND same slope?)
[TLR pTLR paramsL paramsF TLRSim converged] = ...
    PAL_PFLR_ModelComparison(StimLevels, NumPos, OutOfNum, params, Bmc, ...
    PF,'maxTries',maxTries, 'rangeTries',rangeTries,'lapseLimits', ...
    lapseLimits,'lesserLapserates', 'unconstrained', 'fullerLapserates','unconstrained','searchOptions',options);

%Plot fits under Fuller and Lesser models
handleToFig2 = figure('name','2 thresholds and 2 slopes vs. 1 threshold and 1 slope',...
    'units','pixels','position',[100 100 500 500]);
plot(StimLevels(1,:),ProportionCorrectObserved(1,:),'ko','markersize',...
    10,'markerfacecolor','r');

h1 = gca;
set(h1, 'units','pixels','position',[75 300 375 175]);
set(h1, 'fontsize',12);
set(h1, 'Xtick',StimLevels(1,:));
set(h1, 'Ytick',[0:.1:1]); % DF altered 0.5 to 0
%axis([-2.5 2.5 .5 1]);
axis([min(StimLevels(1, :)) max(StimLevels(1, :)) 0 1]); %DF need to set x and y axis ranges suitably to the type of data
hold on;
plot(StimLevels(2,:),ProportionCorrectObserved(2,:),'ks','markersize',...
    10,'markerfacecolor','g');

ProportionCorrectModel = PF(paramsF(1,:),StimLevelsFineGrain);
plot(StimLevelsFineGrain,ProportionCorrectModel,'-','linewidth',2,...
    'color',[0 0 .9]);

ProportionCorrectModel = PF(paramsF(2,:),StimLevelsFineGrain);
plot(StimLevelsFineGrain,ProportionCorrectModel,'-','linewidth',2,...
    'color',[0 0 .9]);

ProportionCorrectModel = PF(paramsL(1,:),StimLevelsFineGrain);
plot(StimLevelsFineGrain,ProportionCorrectModel,'-','linewidth',2,...
    'color',[0 0 0]);


xlabel('Angle as % of interval 1 angle');%DF
ylabel('% Larger judgements');%DF
text(-2.3,.95,'2 functions','color',[0 .7 0],'FontSize',12);
text(-2.3,.9,'1 function','color',[.7 0 0],'FontSize',12);
set(gca,'HandleVisibility','off')

%Plot histogram of simulated TLR values and TLR value based on data. If
%function chi2pdf is detected add theoretical chi2 distribution with
%appropriate df.

[n centers] = hist(TLRSim,40);
hist(TLRSim,40)
h = findobj(gca,'Type','patch');
set(gca,'FOntSize',12)
set(h,'FaceColor','y','EdgeColor','k')
set(gca, 'units','pixels','position',[75 60 375 175]);
set(gca,'xlim',[0 1.2*max(TLR,centers(length(centers)))]);
xlim = get(gca, 'Xlim');
hold on
if exist('chi2pdf.m') == 2
    chi2x = xlim(1):xlim(2)/250:xlim(2);
    [maxim I]= max(n);
    chi2 = chi2pdf(chi2x,numParams2T2S-numParams1T1S)*(maxim/chi2pdf(centers(I),numParams2T2S-numParams1T1S));
    plot(chi2x,chi2,'k-','linewidth',2)
end
ylim = get(gca, 'Ylim');
plot(TLR,.05*ylim(2),'kv','MarkerSize',12,'MarkerFaceColor','k')
text(TLR,.15*ylim(2),'TLR data','Fontsize',10,'horizontalalignment',...
    'center');
message = ['p_{simul}: ' num2str(pTLR,'%5.4f')];    
text(.7*xlim(2),.8*ylim(2),message,'horizontalalignment','left',...
    'fontsize',10); %DF increased font size here to 12
if exist('chi2cdf.m') == 2
    message = ['p_{chi2}: ' num2str(1-chi2cdf(TLR,numParams2T2S-numParams1T1S),'%5.4f')];
    text(.7*xlim(2),.7*ylim(2),message,'horizontalalignment','left',...
        'fontsize',10); %DF changed alignment of message to left and moved message left
    message = ['DOF_{chi2}: ' num2str(numParams2T2S-numParams1T1S,'%5.1f')];
    text(.7*xlim(2),.6*ylim(2),message,'horizontalalignment','left',...
        'fontsize',10);   % DF added display of DOF of Chi2 on figure.  
end
xlabel('Simulated TLRs','FontSize',12)
ylabel('frequency','FontSize',12);
drawnow


set(h1, 'HandleVisibility','on'); % DF have to make h1 visible again before I can make it current axis
set(handleToFig2,'CurrentAxes',h1)% DF make the large axes at the top of the figure the current ones
%DF add the legend. Seems i have to do it at the end here or it gets moved
%when adding later panels and screws everything up nicely
handleToLegend = legend(condition1Name,condition2Name, '2PF model', '', '1PF null model');
set(handleToLegend, 'Location', 'NorthWest')
set(handleToLegend, 'fontsize', 10)
set(handleToLegend, 'Box', 'off')
set(h1, 'HandleVisibility','off');  %Df make h1 invisible again in case it matters?

%%
%DF This section tests the null hypothesis that the thresholds of the two PF's
%are the same, but allows two different slopes in the null model
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
message = 'Performing model comparison: Effect on PSE?';
disp(message);

%Fit lesser model (constrained thresholds, unconstrained slopes, 
%   fixed guess rates, fixed lapse rates).
[paramsL LL exitflag output trash numParams1T2S] = PAL_PFML_FitMultiple(StimLevels, NumPos, ...
    OutOfNum, params, PF, 'thresholds','constrained','slopes',...
    'unconstrained','guessrates','fixed','lapserates','unconstrained',...
    'lapseLimits',lapseLimits,'SearchOptions',options);

%thresholds (2 Thresholds, 2 Slopes vs 1 Threshold, 2 Slopes)
[TLR pTLR paramsL paramsF TLRSim converged] = ...
    PAL_PFLR_ModelComparison(StimLevels, NumPos, OutOfNum, params, Bmc, ...
    PF, 'lesserSlopes','unconstrained','maxTries',maxTries, ...
    'rangeTries',rangeTries,'lapseLimits', lapseLimits,'lesserLapserates', 'unconstrained', 'fullerLapserates','unconstrained','searchOptions',...
    options);

%Plot fits under Fuller and Lesser models
handleToFig3 = figure('name','2 thresholds and 2 slopes vs. 1 threshold and 2 slopes',...
    'units','pixels','position',[100 100 500 500]);
plot(StimLevels(1,:),ProportionCorrectObserved(1,:),'ko','markersize',...
    10,'markerfacecolor','r');
h1 = gca;
set(h1, 'units','pixels','position',[75 300 375 175]);
set(h1, 'fontsize',12);
set(h1, 'Xtick',StimLevels(1,:));
set(h1, 'Ytick',[0:.1:1]); % DF altered 0.5 to 0
%axis([-2.5 2.5 .5 1]);
axis([min(StimLevels(1, :)) max(StimLevels(1, :)) 0 1]); %DF need to set x and y axis ranges suitably to the type of data
hold on;
plot(StimLevels(2,:),ProportionCorrectObserved(2,:),'ks','markersize',...
    10,'markerfacecolor','g');
ProportionCorrectModel = PF(paramsF(1,:),StimLevelsFineGrain);
plot(StimLevelsFineGrain,ProportionCorrectModel,'-','linewidth',2,...
    'color',[0 0 .9]);
ProportionCorrectModel = PF(paramsF(2,:),StimLevelsFineGrain);
plot(StimLevelsFineGrain,ProportionCorrectModel,'-','linewidth',2,...
    'color',[0 0 .9]);
ProportionCorrectModel = PF(paramsL(1,:),StimLevelsFineGrain);
plot(StimLevelsFineGrain,ProportionCorrectModel,'-','linewidth',2,...
    'color',[0 0 0]);
ProportionCorrectModel = PF(paramsL(2,:),StimLevelsFineGrain);
plot(StimLevelsFineGrain,ProportionCorrectModel,'-','linewidth',2,...
     'color',[0 0 0]);
xlabel('Angle as % of interval 1 angle');%DF
ylabel('% Larger judgements');%DF
text(-2.3,.95,'2 functions','color',[0 .7 0],'FontSize',12);
text(-2.3,.9,'1 function','color',[.7 0 0],'FontSize',12);
set(gca,'HandleVisibility','off')

%Plot histogram of simulated TLR values and TLR value based on data. If
%function chi2pdf is detected add theoretical chi2 distribution with
%appropriate df.

[n centers] = hist(TLRSim,40);
hist(TLRSim,40)
h = findobj(gca,'Type','patch');
set(gca,'FOntSize',12)
set(h,'FaceColor','y','EdgeColor','k')
set(gca, 'units','pixels','position',[75 60 375 175]);
set(gca,'xlim',[0 1.2*max(TLR,centers(length(centers)))]);
xlim = get(gca, 'Xlim');
hold on
if exist('chi2pdf.m') == 2
    chi2x = xlim(1):xlim(2)/250:xlim(2);
    [maxim I]= max(n);
    chi2 = chi2pdf(chi2x,numParams2T2S-numParams1T1S)*(maxim/chi2pdf(centers(I),numParams2T2S-numParams1T1S));
    plot(chi2x,chi2,'k-','linewidth',2)
end
ylim = get(gca, 'Ylim');
plot(TLR,.05*ylim(2),'kv','MarkerSize',12,'MarkerFaceColor','k')
text(TLR,.15*ylim(2),'TLR data','Fontsize',10,'horizontalalignment',...
    'center');
message = ['p_{simul}: ' num2str(pTLR,'%5.4f')];    
text(.7*xlim(2),.8*ylim(2),message,'horizontalalignment','left',...
    'fontsize',10); %DF increased font size here to 12
if exist('chi2cdf.m') == 2
    message = ['p_{chi2}: ' num2str(1-chi2cdf(TLR,numParams2T2S-numParams1T1S),'%5.4f')];
    text(.7*xlim(2),.7*ylim(2),message,'horizontalalignment','left',...
        'fontsize',10); %DF changed alignment of message to left and moved message left
    message = ['DOF_{chi2}: ' num2str(numParams2T2S-numParams1T1S,'%5.1f')];
    text(.7*xlim(2),.6*ylim(2),message,'horizontalalignment','left',...
        'fontsize',10);   % DF added display of DOF of Chi2 on figure.  
end
xlabel('Simulated TLRs','FontSize',12)
ylabel('frequency','FontSize',12);
drawnow


set(h1, 'HandleVisibility','on'); % DF have to make h1 visible again before I can make it current axis
set(handleToFig3,'CurrentAxes',h1)% DF make the large axes at the top of the figure the current ones
%DF add the legend. Seems i have to do it at the end here or it gets moved
%when adding later panels and screws everything up nicely
handleToLegend = legend(condition1Name,condition2Name, '2 PF model', '', '2 slopes 1 thresh', 'null model');
set(handleToLegend, 'Location', 'NorthWest')
set(handleToLegend, 'fontsize', 10)
set(handleToLegend, 'Box', 'off')
set(h1, 'HandleVisibility','off');  %Df make h1 invisible again in case it matters?

%%
%DF this section tests the null hyp that the slopes of the 2 PF's are the
%same (but allows thresholds of 2PF's to vary in null model)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



message = 'Performing model comparison: Effect on slope?';
disp(message);

%Fit lesser model (unconstrained thresholds, constrained slopes, 
%   fixed guess rates, fixed lapse rates).
[paramsL LL exitflag output trash numParams2T1S] = PAL_PFML_FitMultiple(StimLevels, NumPos, ...
    OutOfNum, params, PF, 'thresholds','unconstrained','slopes',...
    'constrained','guessrates','fixed','lapserates','unconstrained',...
    'lapseLimits',lapseLimits,'SearchOptions',options);


%slopes (2 Thresholds, 2 Slopes vs 2 Thresholds, 1 Slope)
[TLR pTLR paramsL paramsF TLRSim converged] = ...
    PAL_PFLR_ModelComparison(StimLevels, NumPos, OutOfNum, params, Bmc, ...
    PF, 'lesserThresholds','unconstrained','maxTries',maxTries, ...
    'rangeTries',rangeTries,'lapseLimits', lapseLimits,'lesserLapserates', 'unconstrained', 'fullerLapserates','unconstrained','searchOptions',...
    options);

%Plot fits under Fuller and Lesser models
handleToFig4 = figure('name','2 thresholds and 2 slopes vs. 2 threshold and 1 slopes',...
    'units','pixels','position',[100 100 500 500]);
plot(StimLevels(1,:),ProportionCorrectObserved(1,:),'ko','markersize',...
    10,'markerfacecolor','r');
h1 = gca;
set(h1, 'units','pixels','position',[75 300 375 175]);
set(h1, 'fontsize',12);
set(h1, 'Xtick',StimLevels(1,:));
set(h1, 'Ytick',[0:.1:1]); % DF altered 0.5 to 0
%axis([-2.5 2.5 .5 1]);
axis([min(StimLevels(1, :)) max(StimLevels(1, :)) 0 1]); %DF need to set x and y axis ranges suitably to the type of data
hold on;
plot(StimLevels(2,:),ProportionCorrectObserved(2,:),'ks','markersize',...
    10,'markerfacecolor','g');
ProportionCorrectModel = PF(paramsF(1,:),StimLevelsFineGrain);
plot(StimLevelsFineGrain,ProportionCorrectModel,'-','linewidth',2,...
    'color',[0 0 .9]);
ProportionCorrectModel = PF(paramsF(2,:),StimLevelsFineGrain);
plot(StimLevelsFineGrain,ProportionCorrectModel,'-','linewidth',2,...
    'color',[0 0 .9]);
ProportionCorrectModel = PF(paramsL(1,:),StimLevelsFineGrain);
plot(StimLevelsFineGrain,ProportionCorrectModel,'-','linewidth',2,...
    'color',[0 0 0]);
ProportionCorrectModel = PF(paramsL(2,:),StimLevelsFineGrain);
plot(StimLevelsFineGrain,ProportionCorrectModel,'-','linewidth',2,...
     'color',[0 0 0]);
xlabel('Angle as % of interval 1 angle');%DF
ylabel('% Larger judgements');%DF
text(-2.3,.95,'2 functions','color',[0 .7 0],'FontSize',12);
text(-2.3,.9,'1 function','color',[.7 0 0],'FontSize',12);
set(gca,'HandleVisibility','off')

%Plot histogram of simulated TLR values and TLR value based on data. If
%function chi2pdf is detected add theoretical chi2 distribution with
%appropriate df.

[n centers] = hist(TLRSim,40);
hist(TLRSim,40)
h = findobj(gca,'Type','patch');
set(gca,'FOntSize',12)
set(h,'FaceColor','y','EdgeColor','k')
set(gca, 'units','pixels','position',[75 60 375 175]);
set(gca,'xlim',[0 1.2*max(TLR,centers(length(centers)))]);
xlim = get(gca, 'Xlim');
hold on
if exist('chi2pdf.m') == 2
    chi2x = xlim(1):xlim(2)/250:xlim(2);
    [maxim I]= max(n);
    chi2 = chi2pdf(chi2x,numParams2T2S-numParams1T1S)*(maxim/chi2pdf(centers(I),numParams2T2S-numParams1T1S));
    plot(chi2x,chi2,'k-','linewidth',2)
end
ylim = get(gca, 'Ylim');
plot(TLR,.05*ylim(2),'kv','MarkerSize',12,'MarkerFaceColor','k')
text(TLR,.15*ylim(2),'TLR data','Fontsize',10,'horizontalalignment',...
    'center');
message = ['p_{simul}: ' num2str(pTLR,'%5.4f')];    
text(.7*xlim(2),.8*ylim(2),message,'horizontalalignment','left',...
    'fontsize',10); %DF increased font size here to 12
if exist('chi2cdf.m') == 2
    message = ['p_{chi2}: ' num2str(1-chi2cdf(TLR,numParams2T2S-numParams1T1S),'%5.4f')];
    text(.7*xlim(2),.7*ylim(2),message,'horizontalalignment','left',...
        'fontsize',10); %DF changed alignment of message to left and moved message left
    message = ['DOF_{chi2}: ' num2str(numParams2T2S-numParams1T1S,'%5.1f')];
    text(.7*xlim(2),.6*ylim(2),message,'horizontalalignment','left',...
        'fontsize',10);   % DF added display of DOF of Chi2 on figure.  
end
xlabel('Simulated TLRs','FontSize',12)
ylabel('frequency','FontSize',12);
drawnow


set(h1, 'HandleVisibility','on'); % DF have to make h1 visible again before I can make it current axis
set(handleToFig4,'CurrentAxes',h1)% DF make the large axes at the top of the figure the current ones
%DF add the legend. Seems i have to do it at the end here or it gets moved
%when adding later panels and screws everything up nicely
handleToLegend = legend(condition1Name,condition2Name, '2 PF model', '', '1 slope 2 thresh', 'null model');
set(handleToLegend, 'Location', 'NorthWest')
set(handleToLegend, 'fontsize', 10)
set(handleToLegend, 'Box', 'off')
set(h1, 'HandleVisibility','off');  %Df make h1 invisible again in case it matters?

% %%
% %DF I have decided that we currently do not need to do gooodness of fit for
% %these multi-parameter multi-functoin models as we already have goodness of
% %fit for individual PF's fitted to individual data series that we can use.
% %This script just needs to tell us whether the slopes or thresholds of two
% %data series are significantly different or not.
% 
% % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % %DF Goodness-of-fit,  this section currently set up to measure how well 2 thresholds model
% % %explains data compared to saturated model. If interested in goodness of
% % %fit for the two slopes model a new section of code will have to be added
% % %below this
% 
% message = sprintf('Performing model comparison: 2 thresholds, 1 slope v');
% message = strcat(message,'s. saturated model (i.e., Goodness-of-Fit)');
% disp(message);
% 
% numParamsSat = sum(sum(OutOfNum~=0));
% 
% 
% [TLR pTLR TLRSim converged] =PAL_PFML_GoodnessOfFitMultiple(StimLevels, ...
%     NumPos, OutOfNum, paramsL, Bmc, PF, 'Thresholds', 'unconstrained', ...
%     'Slopes', 'constrained', 'GuessRates', 'fixed', 'LapseRates', ...
%     'fixed','maxTries',maxTries, 'rangeTries',rangeTries,'lapseLimits', ...
%     lapseLimits,'searchOptions', options);
% 
% 
% %Plot fits under Fuller and Lesser models
% figure('name','Saturated vs. 2 threshold and 1 slopes','units','pixels',...
%     'position',[100 100 500 500]);
% plot(StimLevels(1,:),ProportionCorrectObserved(1,:),'o','color',...
%     [0 .7 0],'markersize',10,'markerfacecolor',[0 .7 0]);
% h1 = gca;
% set(h1, 'units','pixels','position',[75 300 375 175]);
% set(h1, 'fontsize',16);
% set(h1, 'Xtick',StimLevels(1,:));
% set(h1, 'Ytick',[.5:.1:1]);
% axis([-2.5 2.5 .5 1]);
% hold on;
% plot(StimLevels(2,:),ProportionCorrectObserved(2,:),'s','color',...
%     [0 .7 0],'markersize',10,'markerfacecolor',[0 .7 0]);
% ProportionCorrectModel = PF(paramsL(1,:),StimLevelsFineGrain);
% plot(StimLevelsFineGrain,ProportionCorrectModel,'-','linewidth',2,...
%     'color',[.7 0 0]);
% ProportionCorrectModel = PF(paramsL(2,:),StimLevelsFineGrain);
% plot(StimLevelsFineGrain,ProportionCorrectModel,'-','linewidth',2,...
%     'color',[.7 0 0]);
% xlabel('Stimulus Intensity');
% ylabel('Proportion Correct');
% text(-2.3,.95,'fuller','color',[0 .7 0],'FontSize',16);
% text(-2.3,.9,'lesser','color',[.7 0 0],'FontSize',16);
% set(gca,'HandleVisibility','off')
% 
% %Plot histogram of simulated TLR values, TLR value based on data. If
% %function chi2pdf is detected add theoretical chi2 distribution with
% %appropriate df.
% [n centers] = hist(TLRSim,40);
% hist(TLRSim,40)
% set(gca,'FOntSize',12)
% h = findobj(gca,'Type','patch');
% set(h,'FaceColor','y','EdgeColor','k')
% set(gca, 'units','pixels','position',[75 60 375 175]);
% set(gca,'xlim',[0 1.2*max(TLR,centers(length(centers)))]);
% xlim = get(gca, 'Xlim');
% hold on
% if exist('chi2pdf.m') == 2
%     chi2x = xlim(1):xlim(2)/250:xlim(2);
%     [maxim I]= max(n);
%     chi2 = chi2pdf(chi2x,numParamsSat-numParams2T1S)*(maxim/chi2pdf(centers(I),numParamsSat-numParams2T1S));
%     plot(chi2x,chi2,'k-','linewidth',2)
% end
% ylim = get(gca, 'Ylim');
% plot(TLR,.05*ylim(2),'kv','MarkerSize',12,'MarkerFaceColor','k')
% text(TLR,.15*ylim(2),'TLR data','Fontsize',11,'horizontalalignment',...
%     'center');
% message = ['p_{simul}: ' num2str(pTLR,'%5.4f')];
% text(.95*xlim(2),.8*ylim(2),message,'horizontalalignment','right',...
%     'fontsize',10);
% if exist('chi2cdf.m') == 2
%     message = ['p_{chi2}: ' num2str(1-chi2cdf(TLR,numParamsSat-numParams2T1S),'%5.4f')];
%     text(.95*xlim(2),.7*ylim(2),message,'horizontalalignment','right',...
%         'fontsize',10);
% end
% xlabel('Simulated TLRs','FontSize',16)
% ylabel('frequency','FontSize',16);
% 
% drawnow

toc