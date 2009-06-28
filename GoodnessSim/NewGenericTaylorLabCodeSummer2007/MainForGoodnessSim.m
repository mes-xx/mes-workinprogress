close all
clear all

% name of m-files containing goodness ranking code
GoodnessMeasures = [ 'GoodnessAvgAngleDifference' ...
    'GoodnessAvgEndDistance' 'GoodnessBlockTimeEndDistance' ...
    'GoodnessEndingAngleDifference' 'GoodnessMaxEndDistance' ...
    'GoodnessMeanA' 'GoodnessPhitBlockTime' 'GoodnessPhitEndDistance'];
% for each goodness measure...
for nGM = 1:length(GoodnessMeasures)

    % set the goodness function
    Funk.BestByGoodness = GoodnessMeasures(nGM);
    
    % repeat each simulation
    for nrepeats = 1:10
        
        % all relevant data will be stored in ParametersXX files, so be
        % sure that none of them get overwritten! The data directory for
        % the 8th repeat of the 4th goodness measure would be
        % GoodnessSim\GM4R8\
        Data_Location = ['C:\data\GoodnessSim\GM' int2str(nGM) 'R' int2str(nrepeats) '\'];
        
        % RUN THE SIMULATION!!!
        ConfigureExperimentForFakeDataSimulationLooped

        disp(['Simulation complete: Goodness measure ' int2str(nGM) '; repeat ' int2str(nrepeats)]);
        
        % clean up for the next one
        save('temp', 'GoodnessMeasures', 'nGM', 'nrepeats');
        clear Parameters
        GClose
        clear all
        load('temp');
        pause(1);
    end %repeats
end %goodness measures