function output = sharpen(input)
%goes along the columns of a matrix, replacing doubles with zero in the second
%instance

dimen = size(input);

for i=1:dimen(2)
    for j=1:(dimen(1)-1)
        if input(j,i)==input((j+1),i)
            input((j+1),i)=0;
        end
    end
end

output=input;