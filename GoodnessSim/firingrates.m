%% FiringRates 
% evaluates the performance of different ways of calculating firing rates

nNeurons = 50;

%define preferred directions of nNeurons neurons in 3 dimensions
PreferredDirections = rand(nNeurons,3);

%normalize directions to unit vectors
for row = 1:nNeurons
    PreferredDirections(row,:) = PreferredDirections(row,:) ...
        ./ sqrt(sum(PreferredDirections(row,:).^2));
end

%set intended movement direction
MovementDirection = rand(1,3);

%% for-loop method
% Calculate the firing rate of each neuron individually in a for loop.

%some declarations
counter1 = [];
firingrates1 = [];

%repeat the calculation 1000 times to get a good average
for iter1 = 1:1000
    tic; %start the timer
    
    %find firing rates for one neuron at a time
    for n = 1:nNeurons
        firingrates1(n,1) = dot(PreferredDirections(n,:), ...
            MovementDirection);
    end
    
    counter1(iter1) = toc; %stop the timer
end

%% all-at-once method
% Calculate all of the firing rates at once my expanding the movement
% direction matrix to match the size of the preferred direction matrix.

%some declarations
counter2 = [];
firingrates2 = [];

%repeat the calculation 1000 times to get a good average
for iter2 = 1:1000
    tic; %start the timer
    
    %expand movement direction matrix
    MovementDirection(2:nNeurons,1) = MovementDirection(1,1);
    MovementDirection(2:nNeurons,2) = MovementDirection(1,2);
    MovementDirection(2:nNeurons,3) = MovementDirection(1,3);
    
    %find firing rates all at once
    firingrates2 = dot(PreferredDirections, MovementDirection, 2);
    
    counter2(iter2) = toc; %stop the timer
end

%% report results

mean(counter1)
mean(counter2)

%how well firing rates match up (0 is good!)
sum(firingrates1 - firingrates2)