clear all;%close all
%load('C:\research\MATLAB\synchrony\results20080612a.mat')
load('C:\research\MATLAB\synchrony\results20080703a.mat')
for ii = 1:size(averaged,1)
    lumped(:,ii) = reshape(averaged(ii,:,:), [], 1);
end
figure
boxplot(lumped)
