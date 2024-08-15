function getSignificantNeurons(inputFol,windowBefore,windowAfter)
%
% function getSignificantNeurons(inputFol,windowBefore,windowAfter)
%
% Purpose
% Identify neurons in each recording that respond significantly to
% behavioral events of interest.
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
% windowBefore - [1 x number of behaviors] the time window in secs,
% before behavioral event
% windowAfter - [1 x number of behaviors] the time window in secs,
% after behavioral event
%
% Output (void)
% The function stores a .mat file in every subject's folder that is a
% matrix of [number of neurons x number of behaviors]. Elements in the
% matrix are either 0 (unresponsive to the behavior), 1 (signficant
% increase in response to behavior), or -1 (significant decrease in
% response to behavior)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
rng(1000);
randomRepeats = 1000;
filePattern = fullfile(inputFol, 'm*');
matFiles = dir(filePattern);
numberAnimals = length(matFiles);
fprintf(1, 'Identifying significant neurons for below animals\n');
numKerTimePoints = windowBefore(1)+windowAfter(1)+1;
for eachRec = 1:numberAnimals
    maxValGcamp = [];
    meanValGcamp = [];
    percentile995 = [];
    percentile05 = [];
    baseFileName = matFiles(eachRec).name;
    fileName = 'variables_for_analysis_tracklight.mat';
    fullFileName = fullfile(inputFol, baseFileName,fileName);
    fprintf(1, 'Animal Number : %s\n', baseFileName);
    load(fullFileName);
    choiceForPlot = {aligned_Poke_prime,aligned_Social_reward_times,...
        aligned_Sucrose_choice_times,Social_reward_consumption_start,...
        aligned_Sucrose_reward_consumption_start};
    numEvents = length(choiceForPlot);
    avgCellGcamp = alldeltaf_C;
    numNeurons = size(avgCellGcamp,1);
    for eachNeuron=1:numNeurons
        avgCellGcamp(eachNeuron,:)=mapminmax(avgCellGcamp(eachNeuron,:),0,1);
    end
    indexOfAll = getTimeIndex(choiceForPlot,time);
    sigNeuronIdentity = zeros(numNeurons,numEvents);
    maxValShuff = zeros(numNeurons,numEvents,randomRepeats);
    meanValShuff = zeros(numNeurons,numEvents,randomRepeats);
    for numRand = 1:randomRepeats
        randNum = randi([1,10000]);
        shuffledGcampArray = circshift(avgCellGcamp,randNum,2);
        for cells=1:numNeurons
            for events=1:numEvents
                currEvent = choiceForPlot{events};
                numTrials = size(currEvent,1);
                eachShuffledGcamp = zeros(numTrials,numKerTimePoints);
                currEventsAll = indexOfAll{events,1};
                for trial=1:numTrials
                    eachShuffledGcamp(trial,:) = shuffledGcampArray(cells, ...
                        currEventsAll(trial)-windowBefore(events):currEventsAll(trial)+windowAfter(events));
                end
                maxValShuff(cells,events,numRand) = max(squeeze(mean(eachShuffledGcamp)));
                meanValShuff(cells,events,numRand) = mean(squeeze(mean(eachShuffledGcamp)));
            end
        end        
    end
    for cells=1:numNeurons
        for events=1:length(choiceForPlot)
            currEvent = choiceForPlot{events};
            numTrials = size(currEvent,1);
            eachEventGcamp = zeros(numTrials,numKerTimePoints);
            currEventsAll = indexOfAll{events,1};
            for trial=1:numTrials
                eachEventGcamp(trial,:) = avgCellGcamp(cells, ...
                    currEventsAll(trial)-windowBefore(events):currEventsAll(trial)+windowAfter(events));
            end
            maxValGcamp(cells,events) = max(squeeze(mean(eachEventGcamp,1)));
            meanValGcamp(cells,events) = mean(squeeze(mean(eachEventGcamp,1)));
            currmaxValShuff = squeeze(maxValShuff(cells,events,:));
            currMeanValShuff = squeeze(meanValShuff(cells,events,:));
            percentile995(cells,events) = prctile(currmaxValShuff,99.5);
            percentile05(cells,events) = prctile(currMeanValShuff,0.5);
            if(maxValGcamp(cells,events)>percentile995(cells,events))
                sigNeuronIdentity(cells,events) = 1;
            end
            if(meanValGcamp(cells,events)<percentile05(cells,events))
                sigNeuronIdentity(cells,events) = -1;
            end        
        end
    end
    name = sprintf('%s_sigNeuron.mat',baseFileName);
    fullSaveName = fullfile(inputFol,baseFileName,name);
    save(fullSaveName,'sigNeuronIdentity','maxValGcamp','percentile995');
end
end

function indexOfAll = getTimeIndex(choiceForPlot,time)
numEvents = length(choiceForPlot);
for events=1:numEvents
    currEvent = choiceForPlot{events};
    numTrials = size(currEvent,1);
    for trial=1:numTrials
        currTimeIdx = find(time>=currEvent(trial));
        firstVal = currTimeIdx(1,1);
        currEventsAll(trial) = firstVal;
    end
    indexOfAll{events,1} = currEventsAll;
end
end