%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% THIS IS THE MAIN CORTICAL TRAINING
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('running master control')
eval(Funk.InitializeVRWorld);
eval(Funk.InitializeCommandSource);
eval(Funk.InitializeDAS);
eval(Funk.InitializeExperimentVariables);
eval(Funk.InitializeMisc);

eval(Funk.RunExperiment);

eval(Funk.ProcessBaseline)

eval(Funk.TerminateMisc);
