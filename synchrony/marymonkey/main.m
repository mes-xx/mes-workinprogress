% This is some analysis I did with the data from Mary the Parkinsonian
% monkey.

clear all
close all

tt = tdtOpenTank('Mary081905', 'Block-1');

stores = ['PDec';'EEGx';'Tick'];
store = stores(1,:);

chan = 1:16;
fig = 2;
data = tdtTankPlot2(tt,store,chan,fig);

tdtCloseTank(tt)

