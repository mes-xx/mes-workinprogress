
length    = 1000;

wave1     = zeros(1,length+period1);
wave2     = zeros(1,length+period2);

step = 1/halfwidth;
triangle = [step:step:1 1:-step:step];

for i = 1:length-1-offset
    
%    endindex = min( i + 2*halfwidth - 1, length);
    endindex = i + 2*halfwidth - 1;
    if ( mod(i, period1) == 0 )
        wave1(i:endindex) = wave1(i:endindex) + triangle;
    end %if
    
    if ( mod(i+offset, period2) == 0 )
        wave2(i:endindex) = wave2(i:endindex) + triangle;
    end %if
    
end %for

wave1 = wave1(1:length);
wave2 = wave2(1:length);