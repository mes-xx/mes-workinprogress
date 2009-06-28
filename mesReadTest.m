covar = 0;
rates = [];

tdtSetTriangleWidth(250, 'cycles');

% create the timer and set its properties
t = timer;
t.BusyMode = 'error'; % if matlab falls behind, throw an error
t.ErrorFcn = 'mesError'; % what to do in case of error
t.ExecutionMode = 'fixedRate'; % execute callback function at fixed rate
t.Period = 0.050; % timer period in seconds
t.TasksToExecute = Inf; % execute the call back function infinite times
t.TimerFcn = 'tdtGetCov';

% start the timer
start(t);

pause(5); % wait for 10 seconds

% stop and delete the timer
stop(t);
delete(t);

% throw out the first cov value
covar = covar(2:end);
rates = rates(2:end,:);

mesAnal;