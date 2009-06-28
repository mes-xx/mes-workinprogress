function [ angles ] = angleBetween( w, v )
%ANGLEBETWEEN finds the angles (in radians) between row vectors
%   angles = angleBetween(w,v) finds the angle between vectors w and v. w
%   and v can also be a 2-D matrix, which is interpreted as an array of row
%   vectors. In that case, w and v must have the same number of rows.

dotProduct = dot(w,v,2);

wMagnitude = sqrt(sum( w.^2, 2) );
vMagnitude = sqrt(sum( w.^2, 2) );

angles = acos( dotProduct ./ (wMagnitude .* vMagnitude));
