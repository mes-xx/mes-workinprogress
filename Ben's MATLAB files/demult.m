function output = demult(input, base, factor)

base = base(1);
factor = factor(1);
dimen = size(input);

output = zeros(dimen(1),(dimen(2)*factor));

for i=1:dimen(2)
    offset = (i-1)*factor;
   for j=1:factor
       output(:,(j+offset)) = floor(input(:,i)./(base^(j-1))) - floor(input(:,i)./(base^(j))).*(base);
   end
end