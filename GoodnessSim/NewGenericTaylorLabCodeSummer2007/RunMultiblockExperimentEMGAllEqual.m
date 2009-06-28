set(VR.fig,'NavPanel','none');
vrdrawnow;
VR.fig
%pause(5)
while KeepRunningFlag 
% This section runs one or more blocks of movements until it is time to
% update the weights. Weights are updated after one or more blocks depending on how many were set in the configuration file.
% It also keeps track of the hit rate (Phit) and the
% time it took to complete each block (BlockTime). The averages of these
% are printed out after each weight update
    
    for i= 1:Parameters.NBlocksPerUpdate
        eval(Funk.RunBlock); % This runs one complet block of movements to all targets
         
    end
     
% this function updates the weights using values accumulated throughout the last one or more blocks.
  %  save([OutName 'params\Parameters' num2str(UpdateBlockNum)], 'Parameters');
   % eval(Funk.UpdateDecoder);
%==========================================================================
%=======================================================================
% allows you to stop or continue after a certain number of blocks.
    if ~mod(VR.BlockNum,Parameters.MinBlocksBeforeBreak)
%         if strcmp(questdlg('Adjust for Correlations?'),'Yes')    
%            eval(Funk.FixCorrelations);
%         end
       if ~strcmp(questdlg('Continue testing?'),'Yes')
            KeepRunningFlag=0;
            TDT.last_index=-1;
%             fprintf(fpCO,'%f\t %f\n', Parameters.BlockTime(iUpdateBlock), Parameters.Phit(iUpdateBlock));
       end
        
       if strcmp(questdlg('Go to keyboard?'),'Yes')
           keyboard
       end
     end
end;%While running blocks