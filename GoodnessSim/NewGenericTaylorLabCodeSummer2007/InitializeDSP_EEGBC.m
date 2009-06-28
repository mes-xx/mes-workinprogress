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
    
    %% Determine tag names and function calls to access TDT pentusa
    TDT.tag_zTime=[TDT.Dev{1} '.zTime'];
    TDT.call_GetTag='GetTargetVal'; % used to access a single variable
    TDT.call_ReadTag='ReadTargetV'; % used to access a sequence of data from a buffer
    
    %% To change the buffer size, decimation rate, or sampling rate a new RCO files must be created
    if ~isfield(TDT, 'size_buffer');
        %% Size of TDT serial buffer set in RCO file
        TDT.size_buffer=invoke(TDT.RP,TDT.call_GetTag,[TDT.Dev{1} '.BufSize']);
        %% Decimation factor set in RCO file
        TDT.dec_factor=invoke(TDT.RP,TDT.call_GetTag,[TDT.Dev{1} '.DecRate']);
    end;
    
    %% Sample rate for this device
    TDT.sample_rate=invoke(TDT.RP,'GetDeviceSF',TDT.Dev{1})/TDT.dec_factor;
    %% Get the high pass and low pass filters on the TDT
    %% Set the high pass and low pass filters on the TDT
   if(~invoke(TDT.RP, 'SetTargetVal', [TDT.Dev{1} '.EEGlp'], TDT.LPcutoff))
       disp('Could not set TDT.LPcutoff. please fix')
       keyboard
   end
   if(~invoke(TDT.RP, 'SetTargetVal', [TDT.Dev{1} '.EEGhp'], TDT.HPcutoff))
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
     fprintf(fpCO,'TDT.size_buffer \t%i\n',TDT.size_buffer);
     fprintf(fpCO,'TDT.dec_factor \t%i\n',TDT.dec_factor);
     fprintf(fpCO,'TDT.sample_rate \t%i\n',TDT.sample_rate);
     fprintf(fpCO,'TDT.HPcutoff \t%i\n',TDT.HPcutoff);
     fprintf(fpCO,'TDT.LPcutoff \t%i\n',TDT.LPcutoff);
     TDT.tag_sIndex=[TDT.Dev{1} '.sMCEEG'];
     TDT.tag_data=[TDT.Dev{1} '.dMCEEG'];
     SigProc.size_buffer =TDT.size_buffer;
     SigProc.dec_factor = TDT.dec_factor;
     SigProc.sample_rate=TDT.sample_rate;
     SigProc.HPcutoff=TDT.HPcutoff;
     SigProc.LPcutoff=TDT.LPcutoff;
elseif TDT.use_TDevAcc==0,
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Create an Active-X control for TDT Pentusa
    TDT.RP = actxcontrol('RPco.x', [5 5 26 26]);
    %% Connect to the first pentusa(1) via gigabit connection(GB)
    invoke(TDT.RP, 'ConnectRX5', 'GB', 1);
    %% Load RCO circuit
    invoke(TDT.RP, 'LoadCOF', TDT.filename_RCO);
    %% Runs the DSP circuit
    invoke(TDT.RP, 'Run');
    
    %% Determine tag names and function calls to access TDT pentusa
    TDT.tag_zTime='zTime';
    TDT.call_GetTag='GetTagVal';
    TDT.call_ReadTag='ReadTagV';
    
    %% To change the buffer size, decimation rate, or sampling rate a new RCO files must be created
    if ~isfield(TDT, 'size_buffer');
        %% Size of TDT serial buffer set in RCO file
        TDT.size_buffer=invoke(TDT.RP,TDT.call_GetTag,'BufSize');
        %% Decimation factor set in RCO file
        TDT.dec_factor=invoke(TDT.RP,TDT.call_GetTag,'DecRate');
    end;
    
    %% Sample rate for this device
    TDT.sample_rate=invoke(TDT.RP,'GetSFreq')/TDT.dec_factor;
      fprintf(fpCO,'TDT.size_buffer \t%i\n',TDT.size_buffer);
     fprintf(fpCO,'TDT.dec_factor \t%i\n',TDT.dec_factor);
     fprintf(fpCO,'TDT.sample_rate \t%i\n',TDT.sample_rate);

    %% Set the high pass and low pass filters on the TDT
    invoke(TDT.RP, 'SetTagVal', 'EEGhp', TDT.HPcutoff);
    invoke(TDT.RP, 'SetTagVal', 'EEGlp', TDT.LPcutoff);
    TDT.tag_sIndex='sMCEEG';
    TDT.tag_data='dMCEEG';
    
    pause(2); % wait for transient effects to stabilize after initialization of TDT system
    
end;