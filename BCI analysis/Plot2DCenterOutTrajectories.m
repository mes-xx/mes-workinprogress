

clear all
close all;
BaseDir = 'F:\school\research\data\GoodnessSim\GS032408\GS032408025'

blockStart = 30;
blockStop = 40;

cenOutFileName = [BaseDir  '.cen_out']
cursorFileName = [BaseDir  '.cursor']

%this next while loop could be replaced with something that gets
%VR.targets and Parameters.cursorfilecolumnrecord data from the start parameters file

fCO = fopen(cenOutFileName, 'rt');
line = fgetl(fCO);
while (line ~= -1)


    if ~isempty(findstr(line,'Actual Target Values'))==1
        [targs] = fscanf(fCO, '%f', [3, 4]);%this specific code will need to be changed for different numbers of dimensions/targets
        targs = targs';
    elseif findstr(line,'CursorFileColumnRecord')==1


        for i = 1:13%could be longer/shorter if you have more/less column topics but probably number could be larger
            line = fgetl(fCO);
            if ~isempty(findstr(line,'VR.BlockNum'))==1
                blockNumCols = str2num(line(1:findstr(line, 'VR.BlockNum')-1));
                blockNumCols=blockNumCols(1);
            elseif ~isempty(findstr(line,'VR.target_num'))==1
                targetNumCols = str2num(line(1:findstr(line, 'VR.target_num')-1));
                targetNumCols=targetNumCols(1):targetNumCols(2);
            elseif ~isempty(findstr(line,'VR.in_target'))==1
                inTargetCols = str2num(line(1:findstr(line, 'VR.in_target')-1));
                inTargetCols=inTargetCols(1);
            elseif ~isempty(findstr(line,'VR.cursor_position'))==1
                cursorPosCols = str2num(line(1:findstr(line, 'VR.cursor_position')-1));
                cursorPosCols=cursorPosCols(1):cursorPosCols(2);
            elseif ~isempty(findstr(line,'VR.target_position'))==1
                targetPosCols = str2num(line(1:findstr(line, 'VR.target_position')-1));
                targetPosCols=targetPosCols(1):targetPosCols(2);
            elseif ~isempty(findstr(line,'data.normalized'))==1
                firingRateCols = str2num(line(1:findstr(line, 'data.normalized')-1));
                firingRateCols=firingRateCols(1):firingRateCols(2);
            elseif ~isempty(findstr(line,'VR.BC_flag'))==1
                BC_flagCols = str2num(line(1:findstr(line, 'VR.BC_flag')-1));
                BC_flagCols=BC_flagCols(1);
            end
        end
    end
    line = fgetl(fCO);
end

fclose(fCO);


cursorData = dlmread(cursorFileName, '\t');

%This section plots the trajectories color coded by target

figure
blockrange=blockStart:blockStop
goodi=find((cursorData(:,blockNumCols)>=blockStart) & (cursorData(:,blockNumCols)<= blockStop ));%& (cursorData(:,BC_flagCols)==1))
cursorData = cursorData( goodi,:);% ind(abs(cursorData(:, blockNumCols(1, 1)) - blockStop/2 - blockStart) <= (blockStop/2)), :);


colors = ['r-'; 'b-'; 'g-'; 'm-';'r-'; 'b-'; 'g-'; 'm-';'r-'; 'b-'; 'g-'; 'm-'];
colorsHit = ['r.'; 'b.'; 'g.'; 'm.';'r.'; 'b.'; 'g.'; 'm.';'r.'; 'b.'; 'g.'; 'm.'];
BC=cursorData(:,BC_flagCols);
InSphere=cursorData(:,inTargetCols);
Cursor=cursorData(:,cursorPosCols(1:2));
Cursor(find(Cursor>=100))=NaN;
% GoalCursor=cursorData(:,GoalcursorPosCols(1:2));
Target=cursorData(:,targetPosCols(1:2));
Targetnum=cursorData(:,targetNumCols);
BlockNum=cursorData(:,blockNumCols);
istarts= find(diff(BC)==1)+1;
istops=find(diff(BC)==-1);
istops=istops-1;
if(length(istarts)> length(istops))
    istops=[istops;size(BC,1)];
end
newstarts=[]
newstops=[]
ccode=['r';'g';'b';'c';'r';'g';'b';'c';'r';'g';'b';'c']
k=0
for i=1:length(istarts)

    if(~isempty(find(BlockNum(istarts(i))==blockrange)))
        %%uncomment the following if you want to make separate plots for each block
        %%otherwise all trajectories will be on the same plot
        %             h=figure;
        %             if(~mod(k,12))
        %                 h=figure(BlockNum(istarts(i)));
        %                 k=0
        %                 title(num2str(BlockNum(istarts(i))))
        %             end
        %             k=k+1;

        %%=========================


        plot([0 ;Cursor(istarts(i):istops(i)-1,1)],[0 ;Cursor(istarts(i):istops(i)-1,2)], [ccode(Targetnum(istarts(i)+2),:) '-'],'linewidth', 1);
        hold on
        plot([Target(istarts(i)+3,1)],[Target(istarts(i)+3,2)], [ccode(Targetnum(istarts(i)+2),:) 'o'],'linewidth', 6);%This is just a place holder and size doesnt represents actual target size
        hold on

        trajectory = Cursor(istarts(i):istops(i)-1,:);
        ihits=find(InSphere(istarts(i):istops(i)-1)==1);
        plot(trajectory(ihits,1), trajectory(ihits,2), 'k.', 'linewidth', 2);
        axis([-.3 .3 -.3 .3])
        axis square


    end
end


