%WriteRawDMT

if WriteRawPower
    iRaw=mod(LoopIndex, WriteRaw);
    if(iRaw)
        Raw(iRaw).LoopIndex=LoopIndex;
        Raw(iRaw).TDTLast_Index=TDT.last_index;
        Raw(iRaw).TDTsize_download=TDT.size_download;
        Raw(iRaw).VRtarget_position=VR.target_position;
        Raw(iRaw).datatemp=datatemp;
    else
        Raw(WriteRaw).LoopIndex=LoopIndex;
        Raw(WriteRaw).TDTLast_Index=TDT.last_index;
        Raw(WriteRaw).TDTsize_download=TDT.size_download;
        Raw(WriteRaw).VRtarget_position=VR.target_position;
        Raw(WriteRaw).datatemp=datatemp;
        save( [OutName 'Raw\'  num2str(LoopIndex)],  'Raw' );
    end
end