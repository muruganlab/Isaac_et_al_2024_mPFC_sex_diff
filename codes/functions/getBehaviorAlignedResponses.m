function timeAlignedResponses = getBehaviorAlignedResponses(inputFol,...
    windowBeforeAll,windowAfterAll,sigNeuronsOnly)
%
% function originalGcampAll = getBehaviorAlignedGcamp(inputFol,...
% windowBeforeAll,windowAfterAll)
%
% Purpose
% get fluroscence trace aligned to the different behavioral attributes.
% Behavioral attributes chosen here are -
% 1. Trial start - stored as aligned_Poke_prime
% 2. Social choice poke - aligned_Social reward_times
% 3. Sucrose choice poke - aligned_Sucrose_choice_times
% 4. Social reward - Social_reward_consumption_start
% 5. Sucrose reward - aligned_Sucrose_reward_consumption_start
%
% Inputs (required)
% inputFol - directory in which the each animal's data is stored as
% individual folders. In this code, it finds animal folders that begins
% with m*
% windowBeforeAll - the time window in secs, before behavioral event
% windowAfterAll - the time window in secs, after behavioral event
% 
% Inputs (optional)
% sigNeuronsOnly - either a 0 or 1. If plots need to be made just for sig
% neurons, then set sigNeuronsOnly = 1, else default is 0
%
% Output
% originalGcampAll - a cell array with 1 x number of animals. Each cell
% array contains the fluroscence traces of each neuron aligned to the
% behavioral events and sliced from windowBeforeAll to windowAfterAll.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~exist('sigNeuronsOnly','var')
    sigNeuronsOnly=0;
end
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
    if(~sigNeuronsOnly)
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
    else
        fileName2 = [baseFileName +'_sigNeuron.mat'];
        fullFileName2 = fullfile(inputFol, baseFileName,fileName2);
        load(fullFileName2);  
        for events=1:length(choiceForPlot)
            currEvent = choiceForPlot{events};
            sigNeurons = find(sigNeuronIdentity(:,events)~=0);
            numNeurons = size(sigNeurons,1);
            numTrials = size(currEvent,1);
            originalGcampAllT = cell(numNeurons,1);
            for cells=1:numNeurons
                eachEventGcamp = zeros(numTrials,numKerTimePointsAll);
                if(numTrials>2)
                    for trial=1:numTrials
                        currTimeIdx = find(time>=currEvent(trial));
                        eachEventGcamp(trial,:) = avgCellGcamp(sigNeurons(cells), ...
                            currTimeIdx(1,1)-windowBeforeAll:currTimeIdx(1,1)+windowAfterAll);
                    end
                else
                    eachEventGcamp = [];
                end
                originalGcampAllT(cells,1) = {squeeze(mean(eachEventGcamp,1))};
            end
            originalGcampAllTT(events,1) = {originalGcampAllT};
        end
        timeAlignedResponses(eachRec) = {originalGcampAllTT};
    end
end