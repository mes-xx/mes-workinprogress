% I would think you could generate a valid covariance matrix by:
% 1) assigning each neuron a random point in 2D space in a circle centered around zero
% 2) taking the dot product of all pairs and using that value as the covariance.
% That should result in a consistent set of values.
% Just a thought.
% Dawn

N = 25 %number of neurons

for k = 1:N %for each neuron
    
    %generate a random point in 2D space
    point = rand(1,2)*2 -1;
    
    %normalize to unit circle
    point = point ./ sqrt(point * point');
    
    points(k,:) = point;
end

correlation_matrix = eye(N);

for x = 1:N     %
    for y = (x+1):N %for each combination of neurons
        
        correlation = dot(points(x,:), points(y,:));
        
        correlation_matrix(x,y) = correlation;
        correlation_matrix(y,x) = correlation;
    end
end

copularnd('Gaussian', correlation_matrix, 1)