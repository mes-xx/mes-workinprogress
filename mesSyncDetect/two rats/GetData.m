%This file:
%  1. Gets rate and synchrony information from the TDT
%  2. Smooths the data
%  3. References the data to the baseline


% Continuously check with the TDT until it has a new cov value for us
% (indicated by ReadReady tag going high)
while ~invoke(TDT.RP, TDT.call_GetTag, [TDT.Dev{1} '.ReadReady' Parameters.ParTagSuffix])
end
 
% now the TDT has latched the data, so we can read it
for x=1:numel(Parameters.MyRates)
    Data.Rate(1,x) = invoke( TDT.RP, TDT.call_GetTag, [TDT.Dev{1} '.Rate' Parameters.ParTagSuffix int2str(Parameters.MyRates(x))]);    
end

for x=1:numel(Parameters.MyCovariances)
    Data.Covariance(1,x) = invoke( TDT.RP, TDT.call_GetTag, [TDT.Dev{1} '.Covar' Parameters.ParTagSuffix int2str(Parameters.MyCovariances(x))]);    
end

% Now that we are done, we activate ReadDone to tell the TDT that we are
% done reading (this causes ReadReady to be reset until the next cov value
% is ready)
tdtDoneReading;

% smooth the data
if exist('Data.Last.Covariance') == 1
    Data.Covariance = (Parameters.SmoothingCoef * Data.Last.Covariance) + ((1-Parameters.SmoothingCoef) * Data.Covariance);
end
if exist('Data.Last.Rate') == 1
    Data.Rate = (Parameters.SmoothingCoef .* Data.Last.Rate) + ((1-Parameters.SmoothingCoef) .* Data.Rate);
end


% set the last values to be the current values so they are ready for the
% next cycle
Data.Last.Covariance = Data.Covariance;
Data.Last.Rate = Data.Rate;


% reference the data to the baseline
Data.Referenced.Covariance = Data.Covariance - Baseline.Covariance;
Data.Referenced.Rate = Data.Rate - Baseline.Rate;
