% Resamples data and eliminates artifacts

%% Set these parameters

filename = 'c:\data\durandrat\U081217-5Sel2.mat';

Fs_in = 40e3; %Hz, sampling rate of incoming "unclean" data
Fs_out = 24414; %Hz, desired sampling rate for clean data

thresh = 5e-3;
% any portion of the signal that is above +thresh or below -thresh will be
% set to zero. this eliminates artifacts

%%

% load data
load(filename)

% calculate time vectors
t_in = ((1:size(data_block1,2))-1)/Fs_in;
t_out = 0:1/Fs_out:t_in(end);

% resample by interpolation
N_chan = size(data_block1,1); % number of channels in data
y = zeros(N_chan,length(t_out)); % initialize output matrix
for chan = 1:N_chan
    y(chan,:) = interp1(t_in,data_block1(chan,:),t_out);


    % eliminate artifacts
    % y(abs(y)>thresh) = 0;

    % find all threshold crossings
    xThresh = find(abs(y(chan,:))>thresh);
    ind = find(diff(xThresh)>1);
    xThresh = [xThresh(1) xThresh(ind+1)];

    % find all zero crossings
    temp = sign(y(chan,1:end-1)) .* sign(y(chan,2:end));
    % this compares the sign of the value at each point with the sign of the
    % value at the next point. if these two consecutive points have the same
    % sign, then the corresponding value in temp will be 1 (because 1*1=1 and
    % -1*-1=1). If two consecutive points do not have the same sign or one of
    % them is zero, then the corresponding value of temp will not be 1.
    xZero = find(temp~=1);
    clear temp


    % for each threshold crossing, find the nearest zero crossing on either
    % side
    for n =1:length(xThresh)
        start = max(xZero(xZero<xThresh(n)));
        finish = min(xZero(xZero>xThresh(n)));


        % zero out all data between the closest zero crossings. this prevents us
        % from getting a false spike at the beginning of each artefact
        y(chan,start:finish) = 0;

    end
end

% save data
save([filename '_clean'], 'y', 't_out');