
while KeepRunningFlag
    eval(Funk.RunBlock); % This runs one complet block of movements to all targets
    
    
    %==========================================================================
    %=======================================================================
    % allows you to stop or continue after a certain number of blocks.
    if ~mod(event.BlockNum,Parameters.MinBlocksBeforeBreak)
        if ~strcmp(questdlg('Continue testing?'),'Yes')
            KeepRunningFlag=0;
            fprintf(fpCO,'%f\t %f\n', Parameters.BlockTime(iUpdateBlock), Parameters.Phit(iUpdateBlock));
        end
        if strcmp(questdlg('Go to keyboard?'),'Yes')
           keyboard
       end
          
    end
  
end;%While running blocks
