    
    % Adjust units so width is in cycles
    %%%%%%%%%%
    width = ceil(Parameters.TriangleWidth / 1000 * TDT.sample_rate);
    % width[cycles] = width[ms] * (1s/1000ms) * (sfreq cycles/s)        
        


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
    if (width <= 400)
        coefs(width+1:401) = 0; % note that an FIR filter of order 850 has 851 coefs
    else % stop if width is too big
        disp('Triangle width is too big.');
    end
        
        
    % Finally set the coefs on the TDT
    %%%%%%%%%%
    
    coefs = cast(coefs, 'single'); % coefs must be cast as singles because 
    % floats on the TDT are 32 bit words, just like singles in MATLAB
    
    x = invoke(TDT.RP, TDT.call_WriteTag, [TDT.Dev{1} '.TCoefs' Parameters.ParTagSuffix], 0, coefs);