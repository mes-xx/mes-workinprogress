%%%% Initializes ActiveX protocol
%% To see a list of commands for each activeX control type:
%% 'invoke(TDT.RP)' after creating the control with 'actxcontrol'

if TDT.use_TDevAcc==1,
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Create an Active-X control:
    TDT.RP = actxcontrol('TDevAcc.X');
    %% Connect to local server
    invoke(TDT.RP,'ConnectServer', 'Local');
    %% Get device name (needed for tag names to access parameters on pentusa)
    TDT.Dev{1}=invoke(TDT.RP,'GetDeviceName',0);
    TDT.Dev{2}=invoke(TDT.RP,'GetDeviceName',1); 
    
	%% Determine tag names and function calls to access TDT pentusa
    TDT.tag_zTime=[TDT.Dev{1} '.zTime'];
    TDT.call_GetTag='GetTargetVal'; % used to access a single variable
    TDT.call_ReadTag='ReadTargetV'; % used to access a sequence of data from a buffer
    TDT.call_SetTag='SetTargetVal'; % used to access a single variable
    TDT.call_WriteTag='WriteTargetV'; % used to access a sequence of data from a buffer
    
    %% To change the buffer size, decimation rate, or sampling rate a new RCO files must be created
%     if ~isfield(TDT, 'size_buffer');
%         %% Size of TDT serial buffer set in RCO file
%         TDT.size_buffer=invoke(TDT.RP,TDT.call_GetTag,[TDT.Dev{1} '.BufSize']);
%         %% Decimation factor set in RCO file
%         TDT.dec_factor=invoke(TDT.RP,TDT.call_GetTag,[TDT.Dev{1} '.DecRate']);
%     end;
    
    %% Sample rate for this device
    TDT.sample_rate=1/timing.loop_intervalS;
    %% Get the high pass and low pass filters on the TDT
    %% Set the high pass and low pass filters on the TDT
   if(~invoke(TDT.RP, 'SetTargetVal', [TDT.Dev{1} '.LPFreq'], TDT.LPcutoff))
       disp('Could not set TDT.LPcutoff. please fix')
       keyboard
   end
   if(~invoke(TDT.RP, 'SetTargetVal', [TDT.Dev{1} '.HPFreq'], TDT.HPcutoff))
       disp('Could not set TDT.HPcutoff. please fix')
       keyboard
   end 
   

            
                
   
%    if(TDT.RecordTank)
%     eval(Funk.SendDSPFlags);
%    end
%     the following is old code that got filter values that were preset in
%     TDT open controller. However, by preseting them in the Configuration file, the same
%     config file will give consistent results with each session.
%     TDT.HPcutoff=invoke(TDT.RP, TDT.call_GetTag, [TDT.Dev{1} '.EEGhp']);
%     TDT.LPcutoff=invoke(TDT.RP, TDT.call_GetTag, [TDT.Dev{1} '.EEGlp']);
     %fprintf(fpCO,'TDT.size_buffer \t%i\n',TDT.size_buffer);
     %fprintf(fpCO,'TDT.dec_factor \t%i\n',TDT.dec_factor);
     fprintf(fpCO,'TDT.sample_rate \t%i\n',TDT.sample_rate);
     fprintf(fpCO,'TDT.HPcutoff \t%i\n',TDT.HPcutoff);
     fprintf(fpCO,'TDT.LPcutoff \t%i\n',TDT.LPcutoff);
     TDT.tag_sIndex=[TDT.Dev{1} '.rt_Index'];
     TDT.tag_data=[TDT.Dev{1} '.rt_Data'];
     %SigProc.size_buffer =TDT.size_buffer;
     %SigProc.dec_factor = TDT.dec_factor;
     SigProc.sample_rate=TDT.sample_rate;
     SigProc.HPcutoff=TDT.HPcutoff;
     SigProc.LPcutoff=TDT.LPcutoff;
elseif TDT.use_TDevAcc==0,
    
   
end;