%% You must use TDevAcc with this code because you need to sort spikes in
%% OpenController using the 'Spike Count (SP0501) with Fake Signal' project

TDT.use_TDevAcc=1;

Init_ActX; % the generic function that initializes the actx connection

    %% To change the buffer size, decimation rate, or sampling rate a new RCO files must be created
    if ~isfield(TDT, 'size_buffer');
        %% Size of TDT serial buffer set in RCO file
        TDT.size_buffer=invoke(TDT.RP,TDT.call_GetTag,[TDT.Dev{1} '.SizeBufR']);
        %% Decimation factor set in RCO file
%        TDT.dec_factor=invoke(TDT.RP,TDT.call_GetTag,[TDT.Dev{1} '.DecRate']);
    end;

test_length=20; % number of iterations in this test program

TDT.num_chan=16; % number of channels being recorded in OpenEx

TDT.last_index=-1; % tells the retrieve data function that it can start getting data from any position on the MC buffer; once program begins to run, it obtains data sequentially from the buffer

%% Tags needed to access the index and data from the MC buffer on the RCO file
TDT.tag_sRate=[TDT.Dev{1} '.sBinRate'];
TDT.tag_dRate=[TDT.Dev{1} '.dBinRateF'];

%% The following matrices are used to convert the float data to the integer
%% counts of the spike rate data

%% This matrix is the bitmask to isolate the first byte in row 1, 
%% the second byte in row 2, etc.
TDT.AndMask=uint32([    (2^8-1)*ones(1,16);
                        (2^16-2^8)*ones(1,16);
                        (2^24-2^16)*ones(1,16);
                        (2^32-2^24)*ones(1,16)      ]);

%% This matrix is for scaling after masking, to read each byte in the range 0-255       
TDT.ShiftMat=uint32([   1   0       0           0;
                        0   1/(2^8) 0           0;
                        0   0       1/(2^16)    0;
                        0   0       0           1/(2^24)    ]);

for i=1:test_length,
    
    [BinCountVect,last_index]=RetrieveRateTDTdataMC(TDT);
    
    disp(num2str(BinCountVect));

end;

Close_ActX; % common function used to close an open actX connection