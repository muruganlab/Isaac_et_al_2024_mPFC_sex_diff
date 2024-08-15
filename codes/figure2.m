%%

% Figure 2. Cellular resolution calcium imaging of mPFC neurons
% during the two choice operant assay.
clear;
clc;
% IMPORTANT :
% This code calls function "getSignificantNeurons.m" that uses a random
% number generator to shuffle the dataset. Using such method can cause
% differences in the number of neurons identified as significant. Hence
% either setting the seed number ahead of time or noticing the discrepancy
% can be helpful with interpreting the results. 
%
% Get the data folder from our figshare path (found in Readme.md)
% Make sure to place the unzipped data folder in the main directory i.e.
% [path_to_local_dir]\Isaac_et_al_2024_mPFC_sex_diff\data
% Please note : Running the code in "Run and Advance" mode naviagtes to a
% temp folder within your computer, hence we recommend using the "Run"
% Command. However, if you wish to debug, make sure to manually add all
% the codes, functions, and data folders to the MATLAB path and do not
% run the section below.

currentFolder = fileparts(mfilename('fullpath'));
codesFolder = currentFolder;
functionsFolder = fullfile(codesFolder, 'functions');
addpath(codesFolder);
addpath(functionsFolder);

mainFolder = fileparts(currentFolder);
dataFolder = fullfile(mainFolder, 'data');
figuresFolder = fullfile(mainFolder, 'figures');
%% Getting the data into structured files for plotting
sampling = 20; %hz,sampling rate of the fluroscence (Inscopix : 20hz)
% Plot variables
timeWindowBeforeAll = 3; %secs, time slice before behavioral event (plot)
timeWindowAfterAll = 5; %secs, time slice before behavioral event (plot)
windowBeforeAll = timeWindowBeforeAll*sampling; %same as above in samples
windowAfterAll = timeWindowAfterAll*sampling; %same as above in samples
numKerTimePointsAll = windowBeforeAll+windowAfterAll+1;
timeArray = linspace(-timeWindowBeforeAll,timeWindowAfterAll,numKerTimePointsAll);
% Sig neuron variables
timeWindowBefore = [1.5,2.5,2.5,0.5,0.5]; %secs, time slice before behavioral
% event (sig neuron calc)
timeWindowAfter = [1.5,0.5,0.5,2.5,2.5]; %secs, time slice after behavioral
% event (sig neuron calc)
windowBefore = timeWindowBefore*sampling; %same as above in samples
windowAfter = timeWindowAfter*sampling; %same as above in samples

inputFolMale = fullfile(dataFolder,"male\full_Water_Access\");
inputFolFemale = fullfile(dataFolder,"female\full_Water_Access\");

getSignificantNeurons(inputFolMale,windowBefore,windowAfter);
getSignificantNeurons(inputFolFemale,windowBefore,windowAfter);
%%
timeAlignedResponsesMale = getBehaviorAlignedResponses(inputFolMale,...
    windowBeforeAll,windowAfterAll,1);
timeAlignedResponsesFemale = getBehaviorAlignedResponses(inputFolFemale,...
    windowBeforeAll,windowAfterAll,1);
%% Plotting responses
figureSettings();
figure('Position', [50 50 800 700]);
set(gcf,'Color','w');
textTitle = sprintf("Figure 2. Cellular resolution calcium imaging of mPFC neurons during the two choice operant assay.");
figure1 = gcf;

annotation(figure1,'textbox',...
    [0.020 0.361 0.068 0.024],...
    'Color',[1 1 1],...
    'VerticalAlignment','middle',...
    'String','Female',...
    'HorizontalAlignment','center',...
    'FontWeight','bold',...
    'FitBoxToText','off',...
    'EdgeColor','none',...
    'BackgroundColor',[0.466 0.674 0.188]);

annotation(figure1,'textbox',...
    [0.020 0.749 0.068 0.024],...
    'Color',[1 1 1],...
    'VerticalAlignment','middle',...
    'String','Male',...
    'HorizontalAlignment','center',...
    'FontWeight','bold',...
    'FitBoxToText','off',...
    'EdgeColor','none',...
    'BackgroundColor',[0.494 0.184 0.556]);

annotation(figure1,'textbox',...
    [0.088 0.092 0.810 0.05],...
    'String',textTitle,...
    'FontWeight','bold',...
    'FontSize',12,...
    'FitBoxToText','off',...
    'EdgeColor','none');

hold on;
subplotID=1;
titleNames = ["Trial Start";"Social Choice";"Sucrose Choice";"Social Reward";
    "Sucrose Reward"];
numberPlots = size(titleNames,1);
tiledlayout(9,5);

figure1 = plotfigure(gcf,timeAlignedResponsesMale,...
    numberPlots,timeWindowBeforeAll,timeWindowAfterAll,timeArray,1,...
    titleNames);

figure1 = plotfigure(gcf,timeAlignedResponsesFemale,...
    numberPlots,timeWindowBeforeAll,timeWindowAfterAll,timeArray);


figureLocNamePDF = fullfile(figuresFolder,"Figure2.pdf");
figureLocNamePNG = fullfile(figuresFolder,"Figure2.png");
print(gcf, '-dpdf', figureLocNamePDF);
print(gcf, '-dpng', figureLocNamePNG);


%% Function to optimize plotting

function figure1 = plotfigure(figure1,timeAlignedResponses,...
    numberPlots,timeWindowBefore,timeWindowAfter,timeArray,maleFlag,...
    titleNames)

if ~exist('maleFlag','var')
    maleFlag=0;
end
for fluroscencePlots=1:numberPlots
    nexttile([2,1])
    unsortedAvgFluorescence = [];
    for animalNumbers=1:length(timeAlignedResponses)
        unsortedAvgFluorescence= vertcat(unsortedAvgFluorescence,...
            cell2mat(timeAlignedResponses{1,animalNumbers}{fluroscencePlots,1}));
    end
    [m,n] = max(unsortedAvgFluorescence,[],2);
    [~,idx] = sort(n);
    sortedFluorescence = unsortedAvgFluorescence(idx,:);
    imagesc(sortedFluorescence,'Xdata',timeArray,[0,0.6]);
    xline(0,'color','white','LineStyle',':','LineWidth',1.5);
    colormap(gca,flipud(cbrewer2('RdYlBu')));
    if(fluroscencePlots==1)
        ylabel('Neuron Number')
    end
    if(maleFlag)
        title(titleNames(fluroscencePlots));
    end
    set(gca,'xtick',[-timeWindowBefore,0,timeWindowAfter],'TickLength',[0 0])
    box('off')
end

c=colorbar;
if(maleFlag)
    c.Position = [0.914,0.794,0.01,0.13]; 
else
    c.Position = [0.914,0.400,0.01,0.13];
end
ylabel(c,{'Normalized';'Fluorescence'},'Position',[1.44,0.289,0]);
c.Ticks = [0,0.6];

for averageFluorescencePlots=1:numberPlots
    nexttile([2,1])
    unsortedAvgFluorescence = [];
    for animalNumbers=1:length(timeAlignedResponses)
        unsortedAvgFluorescence= vertcat(unsortedAvgFluorescence,...
            cell2mat(timeAlignedResponses{1,animalNumbers}{averageFluorescencePlots,1}));
    end
    averageFluorescence = mean(unsortedAvgFluorescence,1);
    error = std(unsortedAvgFluorescence)/sqrt(size(unsortedAvgFluorescence,1));
    shadedErrorBar(timeArray,averageFluorescence,error,'lineprops',...
        {'LineStyle','-','Color',[0.4,0.4,0.4],...
        'MarkerFaceColor',[0.4,0.4,0.4]})
    set(gca,'xtick',[-timeWindowBefore,0,timeWindowAfter],'TickLength',...
        [0 0],'ylim',[0,0.3],'xlim',[-timeWindowBefore,timeWindowAfter],...
        'ytick',[0,0.3])
    xline(0,'color',[0.4,0.4,0.4],'LineStyle','--','LineWidth',1.5);
    xlabel('Time(sec)')
    if(averageFluorescencePlots~=1)
        h=gca;
        h.YAxis.Visible = 'off';
    else
        ylabel('Fluorescence')
    end
end
end
