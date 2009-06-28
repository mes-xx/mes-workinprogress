function output = multiplexy(input, base)


base = base(1);

dimen = size(input);

for i=1:dimen(2)
    input(:,i) = input(:,i).*(base^(i-1));
end

output = sum(input, 2);