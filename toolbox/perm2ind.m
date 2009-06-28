function ind = perm2ind(perm, n)
% perm2ind converts a permutation to a single number
% ind = perm2ind(perm,n) 
% perm is a permutation of a list of n elements. It does not need to
% include all of the elements. For example, a valid 

perm = sort(perm);

if any(perm>n)
    error('Perm is too big. Must be less than n.')
end

if any(diff(perm) == 0)
    error('Invalid perm. Cannot pick the same number twice.')
end

ind = p2i_helper(perm,n,0,1,1);

function ind = p2i_helper(perm,n,ind,x0,depth)

% disp('starting helper')
% disp(['perm  = ' int2str(perm)])
% disp(['ind   = ' int2str(ind)])
% disp(['x0    = ' int2str(x0)])
% disp(['depth = ' int2str(depth)])

if depth < length(perm)
    for x = (x0):(perm(depth)-1)
        ind = p2i_helper(n*ones(size(perm)),n,ind,x+1,depth+1);
    end
    ind = p2i_helper(perm,n,ind,perm(depth)+1,depth+1);
else
    for x = x0:perm(depth)
        ind = ind+1;
    end
end