%COMPARECURSORTOHAND Summary of this function goes here
%   Detailed explanation goes here

close all;
clear all;

%% Initialize variables

% hand position
load('F:\school\research\MATLAB\neuron tuning analysis\M010904interp.mat');
handPosition = HCposinterp;

% path to .cursor file
cursorFilePath = 'F:\school\research\data\ballistic\Vrbalistic\M0109\M0109R04.cursor';

% load .cursor file
cursorFileData = load(cursorFilePath);

% Crop the cursor file data just like ComparePathsforfig2.m does, so that
% the firing rates and hand positions match up.
[r c] = size(cursorFileData);
r = r - 2;
getstart=find(abs(diff(cursorFileData(1:1000,c-7)))>(200));
if(isempty(getstart))
    start = 1;
else
    start = getstart(1)+1;
end
cursorFileData = cursorFileData(start:r,:);

% Cursor position
cursorPosition = [  cursorFileData(:,end-11), ... % X position
                    cursorFileData(:,end-9), ... % Y position
                    cursorFileData(:,end-7)]; % Z position

% Flag that is 1 when cursor is under brain control, 0 when cursor is under
% hand control
brainControlFlag = cursorFileData(:,end-1);

% plot differences between cursor and hand, overlayed with brain control
% flag
figure;
hold all;
plot( DistanceMag(cursorPosition, handPosition ))
plot( 10*brainControlFlag )
