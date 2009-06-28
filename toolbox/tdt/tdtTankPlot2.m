function dat = tdtTankPlot2( tankHandle, store, channels, fig )
%tdtTankPlot reads and plots data from a TDT tank.
%tdtTankPlot( tankHandle, storeName, channel )
%   tankHandle = TTankX ActiveX control (REQUIRED)
%   store      = Four-letter name of the store from which to get data
%                  (REQUIRED)
%   channels   = List of channels to plot, like [1 2 4] to plot channels
%                   1, 2 and 4, or [5] to plot just channel 5, or 0 to plot
%                   all channels. Defaults to all channels.
%   figure     = Figure number to draw on. Defaults to 1.
%Note that a tank must already be open and a block selected (try using
%tdtOpenTank).

switch nargin
    case {0,1}
        disp('Too few arguments.')
        return;
    case 2
        %channels and figure not provided; use defaults
        disp('Defaulting to all channels and plotting to figure 1')
        channels = 0;
        fig   = 1;
    case 3
        %figure not provided; use default
        disp('Defaulting to plotting on figure 1')
        fig   = 1;
end

figure(fig)
hold all; % if we end up plotting more than one line,
% they should all appear together on the same graph


data = cell(0);
% as long as there are more record to be read, read them!

for k = 1:numel(channels)
    chan = channels(k)
    
    nRet = 1000;

    while (nRet == 1000)
        nRet = invoke(tankHandle, 'ReadEventsV', 1000, store, chan,0,0,0,'NEW');

        %get data from those records we just read
        newdata = invoke(tankHandle, 'ParseEvV', 0, nRet);

        newtime = invoke(tankHandle, 'ParseEvInfoV',0,nRet, 6);

        %get channels from those records we just read
        %(if chan=0, not all records will be for the same channel)
        newchan = invoke(tankHandle, 'ParseEvInfoV',0, nRet, 4);

        %add the new data to the proper cell based on channel (ch)
        for i = 1:nRet
            ch = newchan(i);
            try
                data{ch} = [data{ch}; newdata(:,i)];
            catch
                data{ch} = newdata(:,i);
            end %try/catch
        end %for (i)

    end %while

end %for (k)

%now we have all the data, so plot what we need to plot
for j = 1:numel(data)
    try
        plot( data{j} );
    catch
        disp('error when plotting')
        keyboard
    end
end %for (j)

dat = data;