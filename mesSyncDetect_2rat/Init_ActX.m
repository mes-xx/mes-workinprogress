TDT.use_TDevAcc=1;

%For use with Spike Rate 16ch w//w/o fake signal

%%%% Initializes ActiveX protocol
%% To see a list of commands for each activeX control type:
%% 'invoke(TDT.RP)' after creating the control with 'actxcontrol'
%TDT.use_TDevAcc needs to be set to 1 or 0
%for RPco.x, .HPcutoff and .LPcutoff must be set

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
    TDT.call_SetTag='SetTargetVal';
    TDT.call_ReadTag='ReadTargetV'; % used to access a sequence of data from a buffer
    TDT.call_WriteTag='WriteTargetV';
  
    %% Sample rate for this device
    TDT.sample_rate=invoke(TDT.RP,'GetDeviceSF',TDT.Dev{1});%/TDT.dec_factor;

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
 %       TDT.dec_factor=invoke(TDT.RP,TDT.call_GetTag,'DecRate');
    end;
    
    %% Sample rate for this device
    TDT.sample_rate=invoke(TDT.RP,'GetSFreq');%/TDT.dec_factor;

    %% Set the high pass and low pass filters on the TDT
    invoke(TDT.RP, 'SetTagVal', 'HPFreq', TDT.HPcutoff);
    invoke(TDT.RP, 'SetTagVal', 'LPFreq', TDT.LPcutoff);
    
    pause(2); % wait for transient effects to stabilize after initialization of TDT system
    
end;