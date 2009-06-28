%This file:
%  1. Gets rate and synchrony information from the TDT
%  2. Smooths the data
%  3. References the data to the baseline


% Continuously check with the TDT until it has a new cov value for us
% (indicated by ReadReady tag going high)
while ~invoke(TDT.RP, TDT.call_GetTag, [TDT.Dev{1} '.ReadReady'])
end
 
% now the TDT has latched the data, so we can read it
Data.Covariance = invoke( TDT.RP, TDT.call_GetTag, [TDT.Dev{1} '.Covar']);
Data.Rate1      = invoke( TDT.RP, TDT.call_GetTag, [TDT.Dev{1} '.Rate1']);
Data.Rate2      = invoke( TDT.RP, TDT.call_GetTag, [TDT.Dev{1} '.Rate2']);

% Now that we are done, we activate ReadDone to tell the TDT that we are
% done reading (this causes ReadReady to be reset until the next cov value
% is ready)
tdtDoneReading;

% smooth the data
if exist('Data.Last.Covariance') == 1
    Data.Covariance = (Parameters.SmoothingCoef * Data.Last.Covariance) + ((1-Parameters.SmoothingCoef) * Data.Covariance);
end
if exist('Data.Last.Rate1') == 1
    Data.Rate1 = (Parameters.SmoothingCoef * Data.Last.Rate1) + ((1-Parameters.SmoothingCoef) * Data.Rate1);
end
if exist('Data.Last.Rate2') == 1
    Data.Rate2 = (Parameters.SmoothingCoef * Data.Last.Rate2) + ((1-Parameters.SmoothingCoef) * Data.Rate2);
end

% set the last values to be the current values so they are ready for the
% next cycle
Data.Last.Covariance = Data.Covariance;
Data.Last.Rate1 = Data.Rate1;
Data.Last.Rate2 = Data.Rate2;

% reference the data to the baseline
Data.Referenced.Covariance = Data.Covariance - Baseline.Covariance;
Data.Referenced.Rate1 = Data.Rate1 - Baseline.Rate1;
Data.Referenced.Rate2 = Data.Rate2 - Baseline.Rate2;