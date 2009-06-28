%
% Applies NeuroXidence to cockroach data. Roughly based on
% Example_call_NX_Restricted_Dataset_1.m from the NeuroXidence package

close all
clear all

% load in cockroach data
load('C:\research\data\cockroach\cockroach6-19-2008.mat')
n_neurons = 10; %number of neurons

% separate into neurons and cues
sim_left = data(:,11);
sim_left = sim_left(~isnan(sim_left)); %remove nans
sim_right = data(:,12);
sim_right = sim_right(~isnan(sim_right)); %remove nans
sim_in = data(:,13);
sim_in = sim_in(~isnan(sim_in)); %remove nans
sim_out = data(:,14);
sim_out = sim_out(~isnan(sim_out)); %remove nans
spikes = []; %this will hold spike information. first row will be time, the second row will be the neuron #
for neuron = 1:n_neurons
    column = data(:,neuron); % one column represents one neuron
    times = column(~isnan(column)); % only keep points that are NOT nan
    temp = zeros(2,size(times,1));
    temp(2,:) = neuron;
    temp(1,:) = times;
    spikes = [spikes temp];
end

%% separate spikes into trials

% find the start of trials
if min(sim_left) < min(sim_right) %if this is true, then trials start with left movement
    trial_times = sort(sim_left);
else % then trials start with a right movement
    trial_times = sort(sim_right);
end

T_trial = min(diff(trial_times)); % length of one trial

for trial = 1:length(trial_times) % for each trial
    t_start = trial_times(trial); % starts at first movement
    t_end = t_start + T_trial; % ends after T_trial
    cols = find( spikes(1,:) >= t_start & spikes(1,:) < t_end ); % find spikes in this trial

    if ~isempty(cols)
        GDF_all_trials_leftright{trial} = spikes(:,cols); % add spikes to the trial cell array
        GDF_all_trials_leftright{trial}(1,:) = GDF_all_trials_leftright{trial}(1,:) - t_start; %subtract start time
    end
end

% do the same thing for in/out trials
% find the start of trials
if min(sim_in) < min(sim_out) %if this is true, then trials start with left movement
    trial_times = sort(sim_in);
else % then trials start with a right movement
    trial_times = sort(sim_out);
end

T_trial = min(diff(trial_times)); % length of one trial

for trial = 1:length(trial_times) % for each trial
    t_start = trial_times(trial); % starts at first movement
    t_end = t_start + T_trial; % ends after T_trial
    cols = find( spikes(1,:) >= t_start & spikes(1,:) < t_end ); % find spikes in this trial
    if ~isempty(cols)
        GDF_all_trials_inout{trial} = spikes(:,cols); % add spikes to the trial cell array
        GDF_all_trials_inout{trial}(1,:) = GDF_all_trials_inout{trial}(1,:) - t_start; %subtract start time
    end
end


for set = 2:2

    switch set
        case 1
            Input.GDF_all_trials                = GDF_all_trials_leftright;
        case 2
            Input.GDF_all_trials                = GDF_all_trials_inout;
    end


    Input.Selected_Neurons              = [3 8];           % Units selected for the analysis
    Input.dt                            = 2e-4;                             % time Resolution of your Data in sec
    eta                                 = 3;                                % Tau_R = Tau_c * eta ;
    Input.tau_c                         = 5;                                % Tau_C in units of Input.dt - Timescale of Joint Spike Events
    Input.tau_r                         = eta*Input.tau_c ;                 % Tau_R in units of Input.dt - Lower bound of Timescale of Rate co-variations
    Input.Nr_Surrogate                  = 25;                               % Number of Surrogates
    Input.test_level                    = 0.01;                             % Testlevel
    Input.Times_of_occurences_flag      = 1;
    Nr_trials                           = size(Input.GDF_all_trials,2);

    
    % not sure what these are, but i copied them from the example
    Period_of_interest  = [0 T_trial];
    PSTH_bin_width      = 0.05;                                             % 10 ms = 0.01s bins for computing the PSTH
    PSTH_grid           = Period_of_interest(1):PSTH_bin_width:Period_of_interest(2);
    time_ticks          = PSTH_grid(1:10:length(PSTH_grid));
    time_ticks_label    = num2str((time_ticks)');
    
    
    
    % I didn't change these at all from the example
    formats.Fig                 = 1;            % Printing Format flag for Figures 1/0
    formats.JPG                 = 1;            % Printing Format flag for Figures 1/0
    formats.Res                 = 150;          % Printing resolution for jpg Figures
    formats.PDF                 = 1;            % Printing Format flag for Figures 1/0
    formats.eps                 = 1;            % Printing Format flag for

    % I'm not sure what to do with the window, so I just made the window cover
    % the whole time
    Input.Window                        = [0 T_trial];    % Window to be analysed, the first period of the example data set does not contain correlated firing (0-1.5s), but the second period between 1.5 and 3 sec is coorelated

    % Call the unrestricted version of NeuroXidence
    NeuroXidenceStat   = NeuroXidence_Windowed_V3_34_unrestricted(Input);

    % Save results
    filename           = ['NeuroXidence_Results_Cockroach' int2str(now)];
    save(filename,'NeuroXidenceStat')
        Window_IDX=set;

    % -------------------------------------------------------------------------
    % -------------------------------------------------------------------------
    % Plot Neuroxidence Results +++++++++++++++++++++++++++++++++++++++++++++++
    % ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
    complexities                     = unique(sum(NeuroXidenceStat.Pattern,2));
    filename                         = ['Raster_plot_with_Joint_spike_Events_window' num2str(Window_IDX)];

    
    
    % ---------------------------------------------------------------------
    % ## plot all Joint-spike pattern
    Addon           =['All_joint_spike_events_Window_ID' num2str(Window_IDX) ] ;
    title_string    =['All joints-pike events - window ID' num2str(Window_IDX)];
    plot_Raster_Pattern_GDF_V31(NeuroXidenceStat,time_ticks,time_ticks_label,Addon,title_string,formats,complexities,Period_of_interest,-1);
    % ------------------------------------------------------------------------
    % ------------------------------------------------------------------------
    % ## plot only significant Joint-spike pattern
    Addon           =['Significant_joint_spike_events_Window_ID' num2str(Window_IDX) ] ;
    IDX_significant                  = find(NeuroXidenceStat.Pval_Excess<Input.test_level);
    filename                         = ['Raster_plot_with_significant_Joint_spike_Events_Window_ID' num2str(Window_IDX)];
    title_string    =['Only signifcant joints-pike events (excess)- window ID' num2str(Window_IDX)];
    plot_Raster_Pattern_GDF_V31(NeuroXidenceStat,time_ticks,time_ticks_label,Addon,title_string,formats,complexities,Period_of_interest,IDX_significant);
    % --------------------------------------------------------------------
    % --------------------------------------------------------------------
    % --------------------------------------------------------------------
    pwd_old =pwd;
    mkdir('jpg_toy_data_1')
    cd('jpg_toy_data_1')
    !move ..\*.jpg .
    cd(pwd_old)

    mkdir('eps_toy_data_1')
    cd('eps_toy_data_1')
    !move ..\*.eps .
    cd(pwd_old)

    mkdir('fig_toy_data_1')
    cd('fig_toy_data_1')
    !move ..\*.fig .
    cd(pwd_old)

    mkdir('pdf_toy_data_1')
    cd('pdf_toy_data_1')
    !move ..\*.pdf .
    cd(pwd_old)

    mkdir('Results_toy_data_1')
    cd('Results_toy_data_1')
    !move ..\NeuroXidence_Results*.mat .
    cd(pwd_old)
end