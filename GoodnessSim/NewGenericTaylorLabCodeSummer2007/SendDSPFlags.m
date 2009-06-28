function errormessage=  SendDSPFlags(ActiveXHandle, Devicename, TDTflagname, MatlabFlagVal, UpdateYesNo)
%SendDSPFlags(TDT.RP, TDT.Dev{1}, Mode, VR.modeflag , TDT.FlagUpdate)
errormessage=0;
if(UpdateYesNo)
  if(~invoke(ActiveXHandle, 'SetTargetVal', [Devicename TDTflagname], MatlabFlagVal))
       disp(['Could not set ' TDTflagname '. please fix'])
       errormessage=-1;
%        keyboard
  end 
    if(~invoke(ActiveXHandle, 'SetTargetVal', [Devicename '.WriteFlag'], 1))
       disp('Could not set 1 for edge detect. please fix')
       errormessage=-1;
    end 
   if(~invoke(ActiveXHandle, 'SetTargetVal', [Devicename '.WriteFlag'], 0))
       disp('Could not set 0 for edge detect. please fix')
        errormessage=-1;
   end 
end