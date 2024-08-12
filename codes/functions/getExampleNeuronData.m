function exampleNeuronData = getExampleNeuronData(inputFol,animalNumber,...
    neuronNumber,windowBeforeAll,windowAfterAll)
%
% function exampleNeuronData = getExampleNeuronData(animalNumber,neuronNumber)
%
% Purpose 
% get fluroscence trace of example neurons that are aligned to each
% behavioral attribute. Currently, the order in which these plots go are
% "Trial start", "Social choice", "Sucorse choice", "Social reward", and
% "Sucrose reward"
%
% Inputs
% inputFol - directory in which the animal's data is stored as
% individual folders. In this code, it is programmed to identify folders
% that start with the letter 'm'. Please change that as necessary.
% animalNumber - the animal number corresponding to the example neurons, in
% the order specified above.
% neuronNumber - the neuron numbers for each behavioral event (within each
% animal's data)
%
% Output
% exampleNeuronData - a cell array with 1 x number of behaviors/animals. 
% Each cell array contains the fluroscence traces of an example neuron 
% aligned to the behavioral event of choice and sliced from 
% windowBeforeAll to windowAfterAll.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

choiceForPlot = {'aligned_Poke_prime','aligned_Social_reward_times',...
'aligned_Sucrose_choice_times','Social_reward_consumption_start',...
'aligned_Sucrose_reward_consumption_start'};

fileName = 'variables_for_analysis_tracklight.mat';

numKerTimePointsAll = windowBeforeAll+windowAfterAll+1;
exampleNeuronData = cell(1,length(choiceForPlot));
filePattern = fullfile(inputFol, 'm*');
matFiles = dir(filePattern);
numberAnimals = length(matFiles);
fprintf(1, 'Extracting time-locked activity for example neurons\n');
for events=1:length(choiceForPlot)
    for eachRec = 1:numberAnimals
        baseFileName = matFiles(eachRec).name;
        if(baseFileName==animalNumber{events})
            fullFileName = fullfile(inputFol, baseFileName,fileName);            
            fprintf(1, 'Animal Number : %s', baseFileName);
            load(fullFileName);
            currNeuronNumber = neuronNumber(events);
            avgCellGcamp = mapminmax(alldeltaf_C(currNeuronNumber,:),0,1);
            fprintf(1, '\tNeuron Number : %d\n', currNeuronNumber);
            currEvent = eval(choiceForPlot{events});            
            numTrials = size(currEvent,1);
            eachEventGcamp = zeros(numTrials,numKerTimePointsAll);
            for trial=1:numTrials
                currTimeIdx = find(time>=currEvent(trial));
                eachEventGcamp(trial,:) = avgCellGcamp(...
                currTimeIdx(1,1)-windowBeforeAll:currTimeIdx(1,1)+windowAfterAll);
            end
            exampleNeuronData(1,events) = {eachEventGcamp};
        end
    end
end