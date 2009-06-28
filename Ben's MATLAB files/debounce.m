function output = debounce(input, window)
%function takes an input column of values, takes an average and rounds up
%to the next integer

dimen = size(input);
window = window(1);

output = zeros((dimen(1) - window + 1), dimen(2));

for i=1:(dimen(1) - window + 1)
    output(i,:) = ceil( mean(   input((i:(i + window - 1)),:) ) );
end