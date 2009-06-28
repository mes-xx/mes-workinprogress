function myMovie = centerOutMovie(cursor,target)

% % initialize movie array
% myMovie = cell(size(cursor,1),1);

% create the figure that we will use to make the movie
figureHandle = figure;
axesHandle  = axes;

% find the size of the image
xmin = min( [cursor(:,1); target(:,1)] );
xmax = max( [cursor(:,1); target(:,1)] );
ymin = min( [cursor(:,2); target(:,2)] );
ymax = max( [cursor(:,2); target(:,2)] );



% at each timestep
for n = 1:size(cursor,1)
    
    % plot the cursor and target positions at this timestep
    scatter(target(n,1), target(n,2), 'ob', 'LineWidth', 20)
    set(gca,'nextplot','add');
    scatter(cursor(n,1), cursor(n,2), 'xr', 'LineWidth', 10)
    axis( [xmin xmax ymin ymax] )
    set(axesHandle,'nextplot','replacechildren');
    
    % capture the frame 
    myMovie(n) = getframe(axesHandle);
    
end