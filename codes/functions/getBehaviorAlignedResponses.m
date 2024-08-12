function timeAlignedResponses = getBehaviorAlignedResponses(inputFol,...
    windowBeforeAll,windowAfterAll)
%
% function originalGcampAll = getBehaviorAlignedGcamp(inputFol,...
% windowBeforeAll,windowAfterAll)
%
% Purpose 
% get fluroscence trace aligned to the different behavioral attributes
%
% Inputs (required)
% inputFol - directory in which the each animal's data is stored as
% individual folders. In this code, it finds animal folders that begins
% with m*
% windowBeforeAll - the time window in secs, before behavioral event 
% windowAfterAll - the time window in secs, after behavioral event 
%
% Output
% originalGcampAll - a cell array with 1 x number of animals. Each cell
% array contains the fluroscence traces of each neuron aligned to the
% behavioral events and sliced from windowBeforeAll to windowAfterAll.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

numKerTimePointsAll = windowBeforeAll+windowAfterAll+1;
filePattern = fullfile(inputFol, 'm*');
matFiles = dir(filePattern);
numberAnimals = length(matFiles);
timeAlignedResponses = cell(1,numberAnimals);
fprintf(1, 'Extracting time-locked activity for below animals\n');
for eachRec = 1:numberAnimals
    baseFileName = matFiles(eachRec).name;
    fileName = 'variables_for_analysis_tracklight.mat';
    fullFileName = fullfile(inputFol, baseFileName,fileName);
    fprintf(1, 'Animal Number : %s\n', baseFileName);
    load(fullFileName);
    choiceForPlot = {aligned_Poke_prime,aligned_Social_reward_times,...
        aligned_Sucrose_choice_times,Social_reward_consumption_start,...
        aligned_Sucrose_reward_consumption_start};
    totalcell = size(alldeltaf_C,1);
    avgCellGcamp = alldeltaf_C;
    for ll=1:totalcell
        avgCellGcamp(ll,:)=mapminmax(alldeltaf_C(ll,:),0,1);
    end
    numNeurons = size(avgCellGcamp,1);
    originalGcampAllT = cell(numNeurons,length(choiceForPlot));
    for cells=1:numNeurons
        for events=1:length(choiceForPlot)
            currEvent = choiceForPlot{events};
            numTrials = size(currEvent,1);
            eachEventGcamp = zeros(numTrials,numKerTimePointsAll);
            if(numTrials>2)
                for trial=1:numTrials
                    currTimeIdx = find(time>=currEvent(trial));
                    eachEventGcamp(trial,:) = avgCellGcamp(cells, ...
                    currTimeIdx(1,1)-windowBeforeAll:currTimeIdx(1,1)+windowAfterAll);
                end
            else
                eachEventGcamp = [];
            end
            originalGcampAllT(cells,events) = {squeeze(mean(eachEventGcamp,1))};
        end
    end
    timeAlignedResponses(eachRec) = {originalGcampAllT};
end