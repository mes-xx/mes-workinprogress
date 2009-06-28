LoadSPSortData 

TDTSet= questdlg('Record Data To TDT Tank?','Record Data To TDT Tank?','Yes','No','No');
switch TDTSet,
    case 'Yes',
        if (invoke(TDT.RP,'GetSysMode')==0|invoke(TDT.RP,'GetSysMode')==2)
            invoke(TDT.RP,'SetSysMode',3)
        end
        TDT.FlagUpdate=1;
    case 'No',
        TDT.FlagUpdate=0;
end
pause(1);

