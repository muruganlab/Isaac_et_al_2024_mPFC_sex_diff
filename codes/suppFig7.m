%%

% Supplementary Figure 7. mPFC neurons in male and female mice are
% responsive to various task events.
clear;
clc;

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
timeWindowBefore = 3; %secs, time slice before behavioral event
timeWindowAfter = 5; %secs, time slice before behavioral event
windowBeforeAll = timeWindowBefore*sampling; %same as above in samples
windowAfterAll = timeWindowAfter*sampling; %same as above in samples
animalNumber = {'m331','m327','m329','m331','m327'}; %example mice numbers
neuronNumber = [24,35,22,23,7]; %neuron numbers from above mice for example
numKerTimePointsAll = windowBeforeAll+windowAfterAll+1;
timeArray = linspace(-timeWindowBefore,timeWindowAfter,numKerTimePointsAll);

inputFolMale = fullfile(dataFolder,"male\full_Water_Access\");
inputFolFemale = fullfile(dataFolder,"female\full_Water_Access\");

timeAlignedResponsesMale = getBehaviorAlignedResponses(inputFolMale,...
    windowBeforeAll,windowAfterAll);
timeAlignedResponsesFemale = getBehaviorAlignedResponses(inputFolFemale,...
    windowBeforeAll,windowAfterAll);
exampleNeuronData = getExampleNeuronData(inputFolMale,animalNumber,...
    neuronNumber,windowBeforeAll,windowAfterAll);
%% Plotting responses
figureSettings();
figure('Position', [50 50 800 1000]);
set(gcf,'Color','w');
textTitle = sprintf("Supplementary Figure 7. mPFC neurons in male and female mice are responsive to various task events");
figure1 = gcf;
annotation(figure1,'textbox',...
    [0.10 0.68 0.32 0.017],...
    'String','Full Water Access : All Imaged Neurons',...
    'Margin',1,...
    'FontWeight','bold',...
    'FitBoxToText','off',...
    'EdgeColor','none',...
    'BackgroundColor',[0.949 0.882 0.141]);

annotation(figure1,'textbox',...
    [0.10 0.947 0.31 0.017],...
    'String','Full Water Access : Example Neurons',...
    'Margin',1,...
    'FontWeight','bold',...
    'FitBoxToText','on',...
    'EdgeColor','none',...
    'BackgroundColor',[0.949 0.882 0.141]);

annotation(figure1,'textbox',...
    [0.026 0.20 0.068 0.024],...
    'Color',[1 1 1],...
    'VerticalAlignment','middle',...
    'String','Female',...
    'HorizontalAlignment','center',...
    'FontWeight','bold',...
    'FitBoxToText','off',...
    'EdgeColor','none',...
    'BackgroundColor',[0.466 0.674 0.188]);

annotation(figure1,'textbox',...
    [0.026 0.514 0.068 0.024],...
    'Color',[1 1 1],...
    'VerticalAlignment','middle',...
    'String','Male',...
    'HorizontalAlignment','center',...
    'FontWeight','bold',...
    'FitBoxToText','off',...
    'EdgeColor','none',...
    'BackgroundColor',[0.494 0.184 0.556]);

annotation(figure1,'textbox',...
    [0.10 0.011 0.810 0.05],...
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
tiledlayout(14,5);
load('redcmap.mat');
load('bluecmap.mat');
redsMap = rcmap;
bluesMap = cmap;
graysMap = flipud(gray());
exampleColormaps = {graysMap,redsMap,bluesMap,redsMap,bluesMap};


figure1 = plotfigure(gcf,exampleNeuronData,...
    numberPlots,timeWindowBefore,timeWindowAfter,timeArray,0,...
    titleNames,1,exampleColormaps);

figure1 = plotfigure(gcf,timeAlignedResponsesMale,...
    numberPlots,timeWindowBefore,timeWindowAfter,timeArray);

figure1 = plotfigure(gcf,timeAlignedResponsesFemale,...
    numberPlots,timeWindowBefore,timeWindowAfter,timeArray,1,...
    titleNames);


figureLocNamePDF = fullfile(figuresFolder,"SuppFig7.pdf");
figureLocNamePNG = fullfile(figuresFolder,"SuppFig7.png");
print(gcf, '-dpdf', figureLocNamePDF);
print(gcf, '-dpng', figureLocNamePNG);


%% Function to optimize plotting 

function figure1 = plotfigure(figure1,timeAlignedResponses,...
    numberPlots,timeWindowBefore,timeWindowAfter,timeArray,femaleFlag,...
    titleNames,exampleFlag,exampleColormaps)

if ~exist('exampleFlag','var')
    exampleFlag=0;
end
if ~exist('femaleFlag','var')
    femaleFlag=0;
end
for fluroscencePlots=1:numberPlots
    if(~exampleFlag)
        nexttile([3,1])
        unsortedAvgFluorescence = [];
        for animalNumbers=1:length(timeAlignedResponses)
            unsortedAvgFluorescence= vertcat(unsortedAvgFluorescence,...
                vertcat(timeAlignedResponses{1,animalNumbers}{:,fluroscencePlots}));
        end
        [m,n] = max(unsortedAvgFluorescence,[],2);
        [~,idx] = sort(n);
        sortedFluorescence = unsortedAvgFluorescence(idx,:);
        imagesc(sortedFluorescence,'Xdata',timeArray,[0,0.5]);
        xline(0,'color','white','LineStyle',':','LineWidth',1.5);
        colormap(gca,flipud(cbrewer2('RdYlBu')));
        if(fluroscencePlots==1)
            ylabel('Neuron Number')
        end
        if(femaleFlag)
            title(titleNames(fluroscencePlots));
        end
    else
        nexttile([2,1])
        sortedFluorescence = timeAlignedResponses{fluroscencePlots};
        imagesc(sortedFluorescence,'Xdata',timeArray,[0,1]);
        xline(0,'color',[0.4,0.4,0.4],'LineStyle',':','LineWidth',1.5);
        colormap(gca,exampleColormaps{fluroscencePlots});
        if(fluroscencePlots==1)
            ylabel('Trial Number')
        end
        title(titleNames(fluroscencePlots));
    end
    set(gca,'xtick',[-timeWindowBefore,0,timeWindowAfter],'TickLength',[0 0])
    box('off')
end
if(~exampleFlag)
    c=colorbar;
    if(femaleFlag)
        c.Position = [0.910,0.233,0.01,0.13];
    else
        c.Position = [0.910,0.545,0.01,0.13];
    end
    ylabel(c,'Normalized Fluorescence','Position',[1.44,0.23,0]);
    c.Ticks = [0,0.5];
end

for averageFluorescencePlots=1:numberPlots
    nexttile([2,1])
    unsortedAvgFluorescence = [];
    if(~exampleFlag)
        for animalNumbers=1:length(timeAlignedResponses)
            unsortedAvgFluorescence= vertcat(unsortedAvgFluorescence,...
                vertcat(timeAlignedResponses{1,animalNumbers}{:,averageFluorescencePlots}));
        end

    else
        unsortedAvgFluorescence = timeAlignedResponses{averageFluorescencePlots};
    end
    averageFluorescence = mean(unsortedAvgFluorescence,1);
    error = std(unsortedAvgFluorescence)/sqrt(size(unsortedAvgFluorescence,1));
    if(exampleFlag)
        currColor = exampleColormaps{averageFluorescencePlots};
        shadedErrorBar(timeArray,averageFluorescence,error,'lineprops',...
            {'LineStyle','-','Color',currColor(end-4,:),...
            'MarkerFaceColor',currColor(end-4,:)})
        set(gca,'xtick',[-timeWindowBefore,0,timeWindowAfter],'TickLength',...
            [0 0],'ylim',[0,0.61],'xlim',[-timeWindowBefore,timeWindowAfter],...
            'ytick',[0,0.6])
    else
        shadedErrorBar(timeArray,averageFluorescence,error,'lineprops',...
            {'LineStyle','-','Color',[0.4,0.4,0.4],...
            'MarkerFaceColor',[0.4,0.4,0.4]})
        set(gca,'xtick',[-timeWindowBefore,0,timeWindowAfter],'TickLength',...
            [0 0],'ylim',[0,0.105],'xlim',[-timeWindowBefore,timeWindowAfter],...
            'ytick',[0,0.1])
    end
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
