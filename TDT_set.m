function [ success ] = TDT_set( TDT, partag, value )
%TDT_SET Sets a partag to value on first TDT device using TDevAcc
%   TDT structure must be initialized (as in InitializeDSP script) to
%   include at least fields RP and Dev. Uses 'SetTargetVal' as the command
%   to the ActiveX control. Returns the result of the invoke function call.
%   If this number is interpreted as 'false' AND nargout=0, this function
%   gives you a warning beause it thinks you are ignoring the failure.

target = [TDT.Dev{1} '.' partag];

success = invoke(TDT.RP, 'SetTargetVal', target, value);

if nargout==0 && ~success
    warning(['Unable to set ' target ' to ' num2str(value) ' in TDT_set().'])
end