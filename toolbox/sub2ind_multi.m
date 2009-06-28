function [ inds ] = sub2ind_multi( siz, subs )
%SUB2IND Multiple indices from subscripts
%   Just like MATLAB's built-in sub2ind function, except it works on more
%   than one set of subscripts at a time. Right now, it only works on 2
%   dimensions

inds = (subs(:,2)-1)*siz(1) + subs(:,1);
