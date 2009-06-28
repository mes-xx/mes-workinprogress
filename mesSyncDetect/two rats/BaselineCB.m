% callback function for baseline recording

GetData; % get new data from the TDT

% add the new data to the buffer. each data reading is a row in the buffer
% matrix, and there is a column for each channel in the reading
Baseline.Buffer.Covariance(end + 1,:) = Data.Covariance;
Baseline.Buffer.Rate(end + 1,:) = Data.Rate;
