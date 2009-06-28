function result = tdtSetTriangleWidth( width, units )
% tdtSetTriangleWidth( width, units ) sets width of triangles 
% in Michael Stetner's synchrony detection TDT circuit.
%   width = scalar width of triangle (from start to finish)
%   units = 'ms' if width is in milliseconds, or 'cycles' if width is in
%      sample cycles.
% Returns 1 on success, or anything else on failure.

    result = 0;

    % Check to make sure width is a scalar
    %%%%%%%%%%
    if numel(width) ~= 1
        disp('Width must be a scalar.');
        return;
    end
    
    
    
    % Connect to the TDT and get some basic information
    %%%%%%%%%%
    dsp = actxcontrol('TDevAcc.X'); % create ActiveX control for the TDT
    invoke( dsp, 'ConnectServer', 'Local'); % connect to ActiveX server

    name = invoke(dsp,'GetDeviceName',0); % get the name of the device
    sfreq = invoke(dsp,'GetDeviceSF',name); %get sampling frequency
    partag = [name '.TCoefs']; % the name of the parameter tag we will write to should be 'nameofdevice.TCoefs'
    
    
    % Adjust units if necessary so width is in cycles
    %%%%%%%%%%
    if isequal(units, 'ms') % if width is in ms, must convert it to sample cycles
        width = ceil(width / 1000 * sfreq);
        % width[cycles] = width[ms] * (1s/1000ms) * (sfreq cycles/s)
    elseif ~isequal(units, 'cycles') % if units aren't 'ms' or 'cycles' we have error
        disp('Invalid units.');
        invoke(dsp,'CloseConnection');
        return;
    end
        
        


    % Calculate the coefs! The height of the triangle is always 1.
    % There are 2 possible scenarios:
    % 1. width is odd, so the triangle will have a pointy top (the highest
    %    value is NOT repeated)
    % 2. width is even, so the triangle will have a flattened top (the
    %    highest value IS repeated)
    %%%%%%%%%%
    
    switch ( mod(width,2) )
        case 1
            % scenario 1: width is odd
            
            step = 1 / ( (width+1)/2 );
            coefs = [step:step:1 (1-step):-step:step];

        case 0
            % scenario 2: width is even
            
            step = 1 / (width / 2);
            coefs = [ step:step:1 1:-step:step];
    end
    
    % Pad the coefs with zeros because we cannot change the order of the
    % FIR filter (it should be set to 850, which works out to 34ms)
    if (width <= 500)
        coefs(width+1:501) = 0; % note that an FIR filter of order 850 has 851 coefs
    else % stop if width is too big
        disp('Width is too big.');
        invoke(dsp,'CloseConnection');
        return;
    end
        
        
    % Finally set the coefs on the TDT
    %%%%%%%%%%
    
    coefs = cast(coefs, 'single'); % coefs must be cast as singles because 
    % floats on the TDT are 32 bit words, just like singles in MATLAB
    
    result=coefs;
    
    x = invoke(dsp, 'WriteTargetV', partag, 0, coefs);
    if ~isequal(x,1)
        disp('It did not work!');
    end
        
    invoke(dsp,'CloseConnection');