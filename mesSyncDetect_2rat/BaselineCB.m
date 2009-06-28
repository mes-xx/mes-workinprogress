% callback function for baseline recording

GetData; % get new data from the TDT

% add the new data to the buffer
Baseline.Buffer.Covariance(end + 1) = Data.Covariance;
Baseline.Buffer.Rate1(end + 1) = Data.Rate1;
Baseline.Buffer.Rate2(end + 1) = Data.Rate2;