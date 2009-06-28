%tdtFakeRead doesnt get covariance from the TDT running Michael Stetner's
%synchrony detection circuit, but it resets the timer like it did

% set 'ReadCov' high to tell the TDT we are reading
if invoke( TDT.RP, TDT.call_SetTag, [TDT.Dev{1} '.ReadCov'], 1) ~= 1
    disp('Could not set ReadCov high.');
    return;
end

% now the TDT has latched the covariance, so we can read it
%cov = [cov invoke( TDT.RP, TDT.call_GetTag, [TDT.Dev{1} '.Covar'])];
%newcov = invoke( TDT.RP, TDT.call_GetTag, [TDT.Dev{1} '.Covar']);
%smoothcov = 0.7 .* newcov + 0.3 .* covar(numel(covar));

%covar = [covar smoothcov];

% during the time that the output has been latched, the TDT has recorded
% the same Covar value to the tank.

% Now that we are done, we set 'ReadCov' low to let the TDT know that we
% are done. The TDT will unlatch the covariance. The reset the covariance 
% and sum values were reset when we first latched the output
if invoke( TDT.RP, TDT.call_SetTag, [TDT.Dev{1} '.ReadCov'], 0) ~= 1
    disp('Could not set ReadCov low.');
    return;
end