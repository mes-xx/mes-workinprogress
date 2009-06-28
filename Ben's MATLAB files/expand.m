function output = expand(input, factor)

dimen = size(input);
output = zeros(dimen(1), dimen(2)*factor);

for i=1:dimen(2)
    offset = (i-1)*factor;
    for j=1:factor
        output(:,(offset + j)) = (input(:,i)==(j-1));
    end
end