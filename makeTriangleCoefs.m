function makeTriangleCoefs( width, filename )
% makeTriangleCoefs generates coefficients and writes them to a file.
% makeTriangleCoefs(width,filename) makes the FIR coefficient table for 
% the triangle function in Michael Stetner's SyncDetect RCO circuit with
% width specified as an integer greater than 1 and filename as a string for
% the name of the file to which the coefficients will be written.

    % Check to make sure that width is a scalar
    if ~isscalar(width)
        'Failed to generate coefficients: width must be a scalar.'
        return;
    end
    
    % Check to make sure that width is a number that makes sense
    if width <= 1 
        'Failed to generate coefficients: width must be greater than 1.'
        return;
    end

    % Check to make sure that filename is a character array
    if ~ischar(filename)
        'Failed to generate coefficients: filename must be a string.'
    end
    
    % There are 2 possible scenarios:
    % 1. width is odd, so the triangle will have a pointy top (the highest
    %    value is NOT repeated)
    % 2. width is even, so the triangle will have a flattened top (the
    %    highest value IS repeated)
    
    
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
    
    dlmwrite( filename, coefs' );