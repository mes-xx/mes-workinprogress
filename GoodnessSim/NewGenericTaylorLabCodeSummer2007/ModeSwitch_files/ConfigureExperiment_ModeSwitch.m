%. It asks you to load a configuration file that has all the
%settings needed for your particular experiment including the specific
%versions of the modular functions that can be interchanged per experiment.
%You can add new parameters to your configuratioulon file and add 'read-in'
%lines in %ConfigureExperiment%this is the initiating file that starts all other
%files running this file without this messing up older code. If an unrecognized 
%parameter is read in, this file simply ignores it. If a newly added parameter is missing 
%from a configuration file for an older experiment, that unused variable simply won't be defined.
clear Parameters
% GClose
clear all

%---MODE SWITCH---
    addpath 'C:\das\6D_Decoder\ModeSwitch'

    % Load Parameter Files
    load('C:\Data\Test\DMT071707\DMT07170701raw_Parameters');
    ModeSwitch_flg=0;
%     timing.loop_interval=30;% Shouldn't have to do this!
%     loop_interval=30; % Shouldn't have to do this!
%---END MODE SWITCH---

global VR;
global event;
global BC;
global COMM;
global V;
% these are here to allow for the loading of optotrak center positions.
% This way we do not need to reset the optotrak positions each time. For
% exps not using optotrak, these wont hurt -- they will just be ignored.
% OPTO.CENTERX = NaN;
% OPTO.CENTERY = NaN;
% OPTO.CENTERZ = NaN;

%cd  'C:\Marathe\Matlab Code\Optotrak Linear Rotation Control' %This should be altered for each major program and the code for that program kept in its own folder...Hmmm...except for general functions..we should make a folder and add a path for general functions 
KeepRunningFlag=1;
%This first section opens a configuration file and then defines the output
%directories and files based on subject's initials and data and file number
%for that day
[ConfigFileName PATHNAME, FILTERINDEX] = uigetfile('*.config','get configuration file');%'C:\Apanius\Matlab Code\DMTsEEG_Coadaptive_Flex_5-10\DMT_EEGCoadaptive.config';
ConfigFileName=[ PATHNAME ConfigFileName];
[fConfig message]=fopen(ConfigFileName,'r');
if(fConfig==-1)
        disp(['ERROR: Could not open'  ConfigFileName]);
        disp(message);
        KeepRunningFlag=0;
else
    line=fgetl(fConfig);
    while(line~=-1)
        while KeepRunningFlag 
            if ~isempty(findstr(line,'Subject_Code'))==1
                Subject_Code =line(length('Subject_Code ')+1:length(line));
                D=date;
                D=datestr(D, 2); 
                D=D([1 2 4 5 7 8]);
            elseif ~isempty(findstr(line,'Data_Location'))==1
                FOutBase=[line(length('Data_Location ')+1:length(line)) Subject_Code D '\'];
                a = exist(FOutBase);
                if a~=7
                    mkdir(FOutBase)
                end
                i='01';
                while exist([FOutBase Subject_Code D i '.cen_out'])
                      i=num2str(101+ str2num(i));
                      i=i(2:3);
                   
                end
                
                OutName=[FOutBase Subject_Code D i];
                [SUCCESS,MESSAGE,MESSAGEID] = copyfile(ConfigFileName,[OutName '.config']);
                if ~SUCCESS
                    disp('could not copy config file')
                end
                OutFileBase=[Subject_Code D i];
                [fpCO message]=fopen([OutName '.cen_out'],'wt');
                if fpCO==-1
                    disp(['could not open' OutName '.cen_out']);
                    KeepRunningFlag=0;
                else
                    fprintf(fpCO,'Subject_Code \t%s\n',Subject_Code);
                    fprintf(fpCO,'DataStored in \t%s\n',[FOutBase Subject_Code D i]);
                    fprintf(fpCO,'Collected on\t%s\n',datestr(now));
                end
                [fpCurs message]=fopen([OutName '.cursor'],'wb');
                if fpCurs==-1
                    disp(['could not open' OutName '.cursor']);
                    KeepRunningFlag=0;
                end
                
                FOptoFileName = [FOutBase 'OptoCenter.dat'];
                %The next part saves raw data as matlab variables in its
                %own folder within the main experimental folder for that
                %day. This is all the streaming data coming in from tdt
            elseif ~isempty(findstr(line,'WriteRaw '))==1
                WriteRaw  =line(length('WriteRaw ')+1:length(line)); 
                WriteRaw=str2num(line(length('WriteRaw')+1:length(line)));
                fprintf(fpCO,'WriteRaw \t%i\n',WriteRaw);
                if WriteRaw
                    mkdir([FOutBase '\' OutFileBase 'Raw']);
                end
             elseif ~isempty(findstr(line,'WriteRawPower '))==1
                WriteRawPower  =line(length('WriteRawPower ')+1:length(line)); 
                WriteRawPower=str2num(line(length('WriteRawPower')+1:length(line)));
                fprintf(fpCO,'WriteRawPower \t%i\n',WriteRawPower);     
 %This section reads in the program module names and the
              %folder where they are kept into the structure 'Funk'. This allows you to swap out
              %modules in the configuration file without redoing the whole
              %program
            elseif ~isempty(findstr(line,'Funk.Folder '))==1
                Funk.Folder  =line(length('Funk.Folder ')+1:length(line)); 
                fprintf(fpCO,'Funk.Folder \t%s\n',Funk.Folder);
            elseif ~isempty(findstr(line,'Funk.MasterControl '))==1
                Funk.MasterControl  = line(length('Funk.MasterControl ')+1:length(line));
                fprintf(fpCO,'Funk.MasterControl \t%s\n',Funk.MasterControl);
            elseif ~isempty(findstr(line,'Funk.GetData '))==1
                Funk.GetData  = line(length('Funk.GetData ')+1:length(line)); 
                fprintf(fpCO,'Funk.GetData \t%s\n',Funk.GetData);
            elseif ~isempty(findstr(line,'Funk.InitializeOptotrak '))==1
                Funk.InitializeOptotrak  = line(length('Funk.InitializeOptotrak ')+1:length(line));
                fprintf(fpCO,'Funk.InitializeOptotrak \t%s\n',Funk.InitializeOptotrak); 
            elseif ~isempty(findstr(line,'Funk.CloseOptotrak '))==1
                Funk.CloseOptotrak  = line(length('Funk.CloseOptotrak ')+1:length(line));
                fprintf(fpCO,'Funk.CloseOptotrak \t%s\n',Funk.CloseOptotrak); 
            elseif ~isempty(findstr(line,'Funk.InitializeDSP '))==1
                Funk.InitializeDSP  = line(length('Funk.InitializeDSP ')+1:length(line));
                fprintf(fpCO,'Funk.InitializeDSP \t%s\n',Funk.InitializeDSP); 
            elseif ~isempty(findstr(line,'Funk.InitializeExperiment '))==1
                Funk.InitializeExperiment  = line(length('Funk.InitializeExperiment ')+1:length(line));
                fprintf(fpCO,'Funk.InitializeExperiment \t%s\n',Funk.InitializeExperiment);
            elseif ~isempty(findstr(line,'Funk.RunBlock '))==1
                Funk.RunBlock  = line(length('Funk.RunBlock ')+1:length(line));
                fprintf(fpCO,'Funk.RunBlock \t%s\n',Funk.RunBlock);
            elseif ~isempty(findstr(line,'Funk.WriteBlockData '))==1
                Funk.WriteBlockData  = line(length('Funk.WriteBlockData ')+1:length(line)); 
                fprintf(fpCO,'Funk.WriteBlockData \t%s\n',Funk.WriteBlockData);
            elseif ~isempty(findstr(line,'Funk.UpdateDecoder '))==1
                Funk.UpdateDecoder  = line(length('Funk.UpdateDecoder ')+1:length(line)); 
                fprintf(fpCO,'Funk.UpdateDecoder \t%s\n',Funk.UpdateDecoder);
            elseif ~isempty(findstr(line,'Funk.WriteLoopData '))==1
                Funk.WriteLoopData  = line(length('Funk.WriteLoopData ')+1:length(line)); 
                fprintf(fpCO,'Funk.WriteLoopData \t%s\n',Funk.WriteLoopData);
            elseif ~isempty(findstr(line,'Funk.GetDeltaPosition '))==1
                Funk.GetDeltaPosition  = line(length('Funk.GetDeltaPosition ')+1:length(line)); 
                fprintf(fpCO,'Funk.GetDeltaPosition \t%s\n',Funk.GetDeltaPosition);
            elseif ~isempty(findstr(line,'Funk.ConvertSecToSamples '))==1
                Funk.ConvertSecToSamples  = line(length('Funk.ConvertSecToSamples ')+1:length(line)); 
                fprintf(fpCO,'Funk.ConvertSecToSamples \t%s\n',Funk.ConvertSecToSamples);    
            elseif ~isempty(findstr(line,'Funk.WriteRawData '))==1
                 Funk.WriteRawData  = line(length('Funk.WriteRawData ')+1:length(line)); 
                 fprintf(fpCO,'Funk.WriteRawData \t%s\n',Funk.WriteRawData); 
            elseif ~isempty(findstr(line,'Funk.CalcOutputAdjust '))==1
                 Funk.CalcOutputAdjust  = line(length('Funk.CalcOutputAdjust ')+1:length(line)); 
                 fprintf(fpCO,'Funk.CalcOutputAdjust \t%s\n',Funk.CalcOutputAdjust); 
            elseif ~isempty(findstr(line,'Funk.ConfigureTargets '))==1
                 Funk.ConfigureTargets  = line(length('Funk.ConfigureTargets ')+1:length(line)); 
                 fprintf(fpCO,'Funk.ConfigureTargets \t%s\n',Funk.ConfigureTargets); 
            elseif ~isempty(findstr(line,'Funk.Reward '))==1
                 Funk.Reward  = line(length('Funk.Reward ')+1:length(line)); 
                 fprintf(fpCO,'Funk.Reward \t%s\n',Funk.Reward); 
            elseif ~isempty(findstr(line,'Funk.UpdateTargetPosition '))==1
                 Funk.UpdateTargetPosition  = line(length('Funk.UpdateTargetPosition ')+1:length(line)); 
                 fprintf(fpCO,'Funk.UpdateTargetPosition \t%s\n',Funk.UpdateTargetPosition); 
            elseif ~isempty(findstr(line,'Funk.UpdateCursorPosition '))==1
                 Funk.UpdateCursorPosition  = line(length('Funk.UpdateCursorPosition ')+1:length(line)); 
                 fprintf(fpCO,'Funk.UpdateCursorPosition \t%s\n',Funk.UpdateCursorPosition); 
            elseif ~isempty(findstr(line,'Funk.InitializeVRWorld '))==1
                 Funk.InitializeVRWorld  = line(length('Funk.InitializeVRWorld ')+1:length(line)); 
                 fprintf(fpCO,'Funk.InitializeVRWorld \t%s\n',Funk.InitializeVRWorld); 
            elseif ~isempty(findstr(line,'Funk.OpenVRWorld '))==1
                 Funk.OpenVRWorld  = line(length('Funk.OpenVRWorld ')+1:length(line)); 
                 fprintf(fpCO,'Funk.OpenVRWorld \t%s\n',Funk.OpenVRWorld); 
            elseif ~isempty(findstr(line,'Funk.SelectTarget '))==1
                 Funk.SelectTarget = line(length('Funk.SelectTarget ')+1:length(line)); 
                 fprintf(fpCO,'Funk.SelectTarget \t%s\n',Funk.SelectTarget); 
            elseif ~isempty(findstr(line,'Funk.SetObjectColor '))==1
                 Funk.SetObjectColor = line(length('Funk.SetObjectColor ')+1:length(line)); 
                 fprintf(fpCO,'Funk.SetObjectColor \t%s\n',Funk.SetObjectColor); 
            elseif ~isempty(findstr(line,'Funk.UpdateShoulderPosition '))==1
                 Funk.UpdateShoulderPosition = line(length('Funk.UpdateShoulderPosition ')+1:length(line)); 
                 fprintf(fpCO,'Funk.UpdateShoulderPosition  \t%s\n',Funk.UpdateShoulderPosition ); 
            elseif ~isempty(findstr(line,'Funk.Calibrate3D '))==1
                 Funk.Calibrate3D = line(length('Funk.Calibrate3D ')+1:length(line)); 
                 fprintf(fpCO,'Funk.Calibrate3D  \t%s\n',Funk.Calibrate3D );      
             elseif ~isempty(findstr(line,'Funk.ReadOptotrakCenter '))==1
                 Funk.ReadOptotrakCenter = line(length('Funk.ReadOptotrakCenter ')+1:length(line)); 
                 fprintf(fpCO,'Funk.ReadOptotrakCenter  \t%s\n',Funk.ReadOptotrakCenter);      
             elseif ~isempty(findstr(line,'Funk.FixCorrelations '))==1
                 Funk.FixCorrelations = line(length('Funk.FixCorrelations ')+1:length(line)); 
                 fprintf(fpCO,'Funk.FixCorrelations  \t%s\n',Funk.FixCorrelations);      
             elseif ~isempty(findstr(line,'Funk.WriteBaselineData '))==1
                 Funk.WriteBaselineData = line(length('Funk.WriteBaselineData ')+1:length(line)); 
                 fprintf(fpCO,'Funk.WriteBaselineData  \t%s\n',Funk.WriteBaselineData);        
            elseif ~isempty(findstr(line,'Funk.UpdateHitStatus '))==1
                 Funk.UpdateHitStatus = line(length('Funk.UpdateHitStatus ')+1:length(line)); 
                 fprintf(fpCO,'Funk.UpdateHitStatus  \t%s\n',Funk.UpdateHitStatus);  
            elseif ~isempty(findstr(line,'Funk.SendDSPFlags '))==1
                 Funk.SendDSPFlags = line(length('Funk.SendDSPFlags ')+1:length(line)); 
                 fprintf(fpCO,'Funk.SendDSPFlags  \t%s\n',Funk.SendDSPFlags); 
            elseif ~isempty(findstr(line,'Funk.StartDSPRecord '))==1
                 Funk.StartDSPRecord = line(length('Funk.StartDSPRecord ')+1:length(line)); 
                 fprintf(fpCO,'Funk.StartDSPRecord  \t%s\n',Funk.StartDSPRecord); 
            elseif ~isempty(findstr(line,'Funk.PauseDSP '))==1
                 Funk.PauseDSP = line(length('Funk.PauseDSP ')+1:length(line)); 
                 fprintf(fpCO,'Funk.PauseDSP  \t%s\n',Funk.PauseDSP); 
            elseif ~isempty(findstr(line,'Funk.InitializeCommandSource '))==1
                 Funk.InitializeCommandSource = line(length('Funk.InitializeCommandSource ')+1:length(line)); 
                 fprintf(fpCO,'Funk.InitializeCommandSource  \t%s\n',Funk.InitializeCommandSource); 
            elseif ~isempty(findstr(line,'Funk.InitializeExperimentVariables '))==1
                 Funk.InitializeExperimentVariables = line(length('Funk.InitializeExperimentVariables ')+1:length(line)); 
                 fprintf(fpCO,'Funk.InitializeExperimentVariables  \t%s\n',Funk.InitializeExperimentVariables); 
           elseif ~isempty(findstr(line,'Funk.InitializeMisc '))==1
                 Funk.InitializeMisc = line(length('Funk.InitializeMisc ')+1:length(line)); 
                 fprintf(fpCO,'Funk.InitializeMisc  \t%s\n',Funk.InitializeMisc);
           elseif ~isempty(findstr(line,'Funk.TerminateMisc '))==1
                 Funk.TerminateMisc = line(length('Funk.TerminateMisc ')+1:length(line)); 
                 fprintf(fpCO,'Funk.TerminateMisc  \t%s\n',Funk.TerminateMisc);
          elseif ~isempty(findstr(line,'Funk.RunExperiment '))==1
                 Funk.RunExperiment = line(length('Funk.RunExperiment ')+1:length(line)); 
                 fprintf(fpCO,'Funk.RunExperiment  \t%s\n',Funk.RunExperiment);
          elseif ~isempty(findstr(line,'Funk.CursorFileColumnRecord '))==1
                 Funk.CursorFileColumnRecord = line(length('Funk.CursorFileColumnRecord ')+1:length(line)); 
                 fprintf(fpCO,'Funk.CursorFileColumnRecord  \t%s\n',Funk.CursorFileColumnRecord);
         elseif ~isempty(findstr(line,'Funk.DefineWriteLine '))==1
                 Funk.DefineWriteLine = line(length('Funk.DefineWriteLine ')+1:length(line)); 
                 fprintf(fpCO,'Funk.DefineWriteLine  \t%s\n',Funk.DefineWriteLine);
         elseif ~isempty(findstr(line,'Funk.SetFinalBaselineValues '))==1
                 Funk.SetFinalBaselineValues = line(length('Funk.SetFinalBaselineValues ')+1:length(line)); 
                 fprintf(fpCO,'Funk.SetFinalBaselineValues  \t%s\n',Funk.SetFinalBaselineValues);
         elseif ~isempty(findstr(line,'Funk.InitializeDAS '))==1
                 Funk.InitializeDAS = line(length('Funk.InitializeDAS ')+1:length(line)); 
                 fprintf(fpCO,'Funk.InitializeDAS  \t%s\n',Funk.InitializeDAS);
                %The rest of these elseif's read in and define parameters
                 %or initial variable values. Some variables are used to
                 %define and initialize other variables that are functions
                 %of the first variables

              % VR parameters - these parameters define constants about the
              % VR environment  
             elseif ~isempty(findstr(line,'VR.filename '))==1
                VR.filename =line(length('VR.filename ')+1:length(line));
                fprintf(fpCO,'VR.filename\t%s\n',VR.filename);
            elseif ~isempty(findstr(line,'VR.modes'))==1
                VR.modes =str2num(line(length('VR.modes')+1:length(line)));
                VR.num_modes = size(VR.modes, 1);
                VR.ND=size(VR.modes,2);
                fprintf(fpCO,'VR.modes =');
               
                for i=1:VR.num_modes
                    fprintf(fpCO,'\n');
                    for j=1:size(VR.modes,2)
                        fprintf(fpCO,'%i\t',VR.modes(i,j));
                    end
                end
                fprintf(fpCO,'\nTarget number and unit values=');
                    if(size(VR.modes,1)==1)
                        VR.num_dim=length(find(VR.modes>0));
                    else
                        VR.num_dim=length(find(sum(VR.modes)>0));
                    end
                    eval(Funk.ConfigureTargets)
                    VR.num_targets=size(VR.targets,1);
                    for j=1:VR.num_targets
                        fprintf(fpCO,'\n%i\t',j);
                        for i=1:VR.ND
                            fprintf(fpCO,'%i\t',VR.targets(j,i));
                        end
                    end
                fprintf(fpCO,'\n');
%                 VR.NumDimPerMode=max(reshape(VR.modes,[],1));
%                 for i=1:VR.num_modes
%                     VR.ModeMap{i}= [];
%                     for j=1:VR.NumDimPerMode
%                         VR.ModeMap{i}= [VR.ModeMap{i} find(VR.modes(i,:)==j) ];
%                     end
%                 end
                
            elseif ~isempty(findstr(line,'VR.modeflag'))==1
                VR.modeflag=str2num(line(length('VR.modeflag')+1:length(line)));
                fprintf(fpCO,'VR.modeflag\t%2.5f\n',VR.modeflag);
            elseif ~isempty(findstr(line,'VR.dT'))==1
                VR.dT=str2num(line(length('VR.dT')+1:length(line)));
                fprintf(fpCO,'VR.dT\t%2.5f\n',VR.dT);
            elseif ~isempty(findstr(line,'VR.Rotate'))==1
                VR.Rotate=str2num(line(length('VR.Rotate')+1:length(line)));
                fprintf(fpCO,'VR.Rotate\t%2.5f\n',VR.Rotate);
            elseif ~isempty(findstr(line,'VR.humoral_length'))==1
                VR.humoral_length=str2num(line(length('VR.humoral_length')+1:length(line)));
                fprintf(fpCO,'VR.humoral_length\t%2.5f\n',VR.humoral_length);
            elseif ~isempty(findstr(line,'VR.forearm_length'))==1
                VR.forearm_length=str2num(line(length('VR.forearm_length')+1:length(line)));
                fprintf(fpCO,'VR.forearm_length\t%2.5f\n',VR.forearm_length);
            elseif ~isempty(findstr(line,'VR.world_scale'))==1
                VR.world_scale=str2num(line(length('VR.world_scale')+1:length(line)));
                fprintf(fpCO,'VR.world_scale\t%2.5f\n',VR.world_scale);
           elseif ~isempty(findstr(line,'VR.movement.center'))==1
                VR.movement.center =str2num(line(length('VR.movement.center')+1:length(line)));
                VR.target_position=VR.movement.center;
                VR.cursor_position=VR.movement.center;
                
                fprintf(fpCO,'VR.movement.center\t');
                for i=1:VR.ND
                    fprintf(fpCO,'%2.5f\t',VR.movement.center(i));
                end
                fprintf(fpCO,'\n');
            elseif ~isempty(findstr(line,'VR.movement.range'))==1
                VR.movement.range =str2num(line(length('VR.movement.range')+1:length(line)));
                fprintf(fpCO,'VR.movement.range\t');
                for i=1:VR.ND
                    fprintf(fpCO,'%2.5f\t',VR.movement.range(i));
                end
                fprintf(fpCO,'\n');
                    VR.targets=VR.targets.*(ones(size(VR.targets,1),1)*VR.movement.range);
                    VR.targets=VR.targets+ (ones(size(VR.targets,1),1)*VR.movement.center);
                   fprintf(fpCO,'Actual Target Values:', VR.num_dim);
                    for j=1:VR.num_targets
                        fprintf(fpCO,'\n%i\t',j);
                        for k=1:VR.ND
                            fprintf(fpCO,'%i\t',VR.targets(j,k));
                        end
                    end
       
                fprintf(fpCO,'\n');
            elseif ~isempty(findstr(line,'VR.Vscale'))==1% normalize Vscale to even increments across dimensions if 1D
                VR.Vscale=str2num(line(length('VR.Vscale')+1:length(line)));
%                 if length(VR.Vscale==1)
%                    % VR.Vscale= [VR.Vscale VR.Vscale VR.Vscale VR.Vscale/VR.movement.range(1)*VR.movement.range(4) VR.Vscale/VR.movement.range(1)*VR.movement.range(5) VR.Vscale/VR.movement.range(1)*VR.movement.range(6)];
%                     VR.Vscale= ones(1,VR.ND)*VR.Vscale;
%                 end
                    fprintf(fpCO,'VR.Vscale\t%2.5f\n',VR.Vscale);
%                     for i=1:VR.ND
%                         fprintf(fpCO,'%2.5f\t',VR.Vscale(i));
%                     end
%                         fprintf(fpCO,'\n');
             elseif ~isempty(findstr(line,'VR.MaxTargRad'))==1
                 if ~isempty(findstr(line,'VR.MaxTargRadP'))==1
                     VR.MaxTargRadP =str2num(line(length('VR.MaxTargRadP')+1:length(line)));
                     VR.MaxTargRad = VR.MaxTargRadP*VR.movement.range(1,1);
                     fprintf(fpCO,'VR.MaxTargRadP\t%2.3f\nVR.MaxTargRad\t%2.3f\n',VR.MaxTargRadP, VR.MaxTargRad);
                 else
                     VR.MaxTargRad =str2num(line(length('VR.MaxTargRad')+1:length(line)));
                     fprintf(fpCO,'VR.MaxTargRad\t%2.3f\n',VR.MaxTargRad);
                 end
             elseif ~isempty(findstr(line,'VR.MinTargRad'))==1
                 if ~isempty(findstr(line,'VR.MinTargRadP'))==1
                     VR.MinTargRadP =str2num(line(length('VR.MinTargRadP')+1:length(line)));
                     VR.MinTargRad = VR.MinTargRadP*VR.movement.range(1,1);
                     fprintf(fpCO,'VR.MinTargRadP\t%2.3f\nVR.MinTargRad\t%2.3f\n',VR.MinTargRadP, VR.MinTargRad);
                 else
                     VR.MinTargRad =str2num(line(length('VR.MinTargRad')+1:length(line)));
                     fprintf(fpCO,'VR.MinTargRad\t%2.3f\n',VR.MinTargRad);
                 end
              elseif ~isempty(findstr(line,'VR.TargRad'))==1
                 if ~isempty(findstr(line,'VR.TargRadP'))==1
                     VR.TargRadP =str2num(line(length('VR.TargRadP')+1:length(line)));
                     VR.TargRad = VR.TargRadP*VR.movement.range(1,1);
                     if exist('VR.CursRad')
                         VR.hit_dist=VR.CursRad+VR.TargRad;
                     end
                         
                     fprintf(fpCO,'VR.TargRadP\t%2.3f\nVR.TargRad\t%2.3f\n',VR.TargRadP, VR.TargRad);
                 else
                     VR.TargRad =str2num(line(length('VR.TargRad')+1:length(line)));
                     fprintf(fpCO,'VR.TargRad\t%2.3f\n',VR.TargRad);
                 end
              elseif ~isempty(findstr(line,'VR.TargRdStepSize'))==1
                 if ~isempty(findstr(line,'VR.TargRdStepSizeP'))==1
                     VR.TargRdStepSizeP =str2num(line(length('VR.TargRdStepSizeP')+1:length(line)));
                     VR.TargRdStepSize = VR.TargRdStepSizeP*VR.movement.range(1,1);
                     fprintf(fpCO,'VR.TargRdStepSizeP\t%2.3f\nVR.TargRdStepSize\t%2.3f\n',VR.TargRdStepSizeP, VR.TargRdStepSize);
                 else
                     VR.TargRdStepSize =str2num(line(length('VR.TargRdStepSize')+1:length(line)));
                     fprintf(fpCO,'VR.TargRdStepSize\t%2.3f\n',VR.TargRdStepSize);
                 end   
              elseif ~isempty(findstr(line,'VR.MaxCursRad'))==1
                 if ~isempty(findstr(line,'VR.MaxCursRadP'))==1
                     VR.MaxCursRadP =str2num(line(length('VR.MaxCursRadP')+1:length(line)));
                     VR.MaxCursRad = VR.MaxCursRadP*VR.movement.range(1,1);
                     fprintf(fpCO,'VR.MaxCursRadP\t%2.3f\nVR.MaxCursRad\t%2.3f\n',VR.MaxCursRadP, VR.MaxCursRad);
                 else
                     VR.MaxCursRad =str2num(line(length('VR.MaxCursRad')+1:length(line)));
                     fprintf(fpCO,'VR.MaxCursRad\t%2.3f\n',VR.MaxCursRad);
                 end
             elseif ~isempty(findstr(line,'VR.MinCursRad'))==1
                 if ~isempty(findstr(line,'VR.MinCursRadP'))==1
                     VR.MinCursRadP =str2num(line(length('VR.MinCursRadP')+1:length(line)));
                     VR.MinCursRad = VR.MinCursRadP*VR.movement.range(1,1);
                     fprintf(fpCO,'VR.MinCursRadP\t%2.3f\nVR.MinCursRad\t%2.3f\n',VR.MinCursRadP, VR.MinCursRad);
                 else
                     VR.MinCursRad =str2num(line(length('VR.MinCursRad')+1:length(line)));
                     fprintf(fpCO,'VR.MinCursRad\t%2.3f\n',VR.MinCursRad);
                 end
              elseif ~isempty(findstr(line,'VR.CursRad'))==1
                 if ~isempty(findstr(line,'VR.CursRadP'))==1
                     VR.CursRadP =str2num(line(length('VR.CursRadP')+1:length(line)));
                     VR.CursRad = VR.CursRadP*VR.movement.range(1,1);
                     if exist('VR.TargRad')
                         VR.hit_dist=VR.CursRad+VR.TargRad;
                     end
                     fprintf(fpCO,'VR.CursRadP\t%2.3f\nVR.CursRad\t%2.3f\n',VR.CursRadP, VR.CursRad);
                 else
                     VR.CursRad =str2num(line(length('VR.CursRad')+1:length(line)));
                     fprintf(fpCO,'VR.CursRad\t%2.3f\n',VR.CursRad);
                 end
              elseif ~isempty(findstr(line,'VR.CursRdStepSize'))==1
                 if ~isempty(findstr(line,'VR.CursRdStepSizeP'))==1
                     VR.CursRdStepSizeP =str2num(line(length('VR.CursRdStepSizeP')+1:length(line)));
                     VR.CursRdStepSize = VR.CursRdStepSizeP*VR.movement.range(1,1);
                     fprintf(fpCO,'VR.CursRdStepSizeP\t%2.3f\nVR.CursRdStepSize\t%2.3f\n',VR.CursRdStepSizeP, VR.CursRdStepSize);
                 else
                     VR.CursRdStepSize =str2num(line(length('VR.CursRdStepSize')+1:length(line)));
                     fprintf(fpCO,'VR.CursRdStepSize\t%2.3f\n',VR.CursRdStepSize);
                 end   
              elseif ~isempty(findstr(line,'VR.movement.limit'))==1
                 if ~isempty(findstr(line,'VR.movement.limitP'))==1
                     VR.movement.limitP =str2num(line(length('VR.movement.limitP')+1:length(line)));
                     VR.movement.limit = VR.movement.limitP.*VR.movement.range;
                     
                     fprintf(fpCO,'VR.movement.limitP\t');
                     for i=1:VR.ND
                         fprintf(fpCO,'%2.3f\t',VR.movement.limitP(i));
                     end
                     fprintf(fpCO,'\nVR.movement.limit\t');
                     for i=1:VR.ND
                         fprintf(fpCO,'%2.3f\t',VR.movement.limit(i));
                     end
                     fprintf(fpCO,'\n');
                 else
                     VR.movement.limit =str2num(line(length('VR.movement.limit')+1:length(line)));
                     fprintf(fpCO,'VR.movement.limit\t');
                     for i=1:VR.ND
                         fprintf(fpCO,'%2.3f\t',VR.movement.limit(i));
                     end
                     fprintf(fpCO,'\n');
                 end
             elseif ~isempty(findstr(line,'VR.movement.earlylimit'))==1
                 if ~isempty(findstr(line,'VR.movement.earlylimitP'))==1
                     VR.movement.earlylimitP =str2num(line(length('VR.movement.earlylimitP')+1:length(line)));
                     VR.movement.earlylimit = VR.movement.earlylimitP.*VR.movement.range;
                     fprintf(fpCO,'VR.movement.earlylimitP\t');
                     for i=1:VR.ND
                         fprintf(fpCO,'%2.3f\t',VR.movement.earlylimitP(i));
                     end
                     fprintf(fpCO,'\nVR.movement.earlylimit\t');
                     for i=1:VR.ND
                         fprintf(fpCO,'%2.3f\t',VR.movement.earlylimit(i));
                     end
                     fprintf(fpCO,'\n');
                 else
                     VR.movement.earlylimit =str2num(line(length('VR.movement.earlylimit')+1:length(line)));
                     fprintf(fpCO,'VR.movement.earlylimit\t');
                     for i=1:VR.ND
                         fprintf(fpCO,'%2.3f\t',VR.movement.earlylimit(i));
                     end
                     fprintf(fpCO,'\n');
                 end
            elseif ~isempty(findstr(line,'VR.hit.max'))==1
                 if ~isempty(findstr(line,'VR.hit.maxP'))==1
                     VR.hit.maxP =str2num(line(length('VR.hit.maxP')+1:length(line)));
                     VR.hit.max = VR.hit.maxP.*VR.movement.range;
                     fprintf(fpCO,'VR.hit.maxP\t');
                     for i=1:VR.ND
                         fprintf(fpCO,'%2.3f\t',VR.hit.maxP(i));
                     end
                     fprintf(fpCO,'\nVR.hit.max\t');
                     for i=1:VR.ND
                         fprintf(fpCO,'%2.3f\t',VR.hit.max(i));
                     end
                     fprintf(fpCO,'\n');
                 else
                     VR.hit.max =str2num(line(length('VR.hit.max')+1:length(line)));
                     fprintf(fpCO,'VR.hit.max\t%2.3f\t%2.3f\t%2.3f\t%2.3f\t%2.3f\t%2.3f\n',VR.hit.max);
                 end
            elseif ~isempty(findstr(line,'VR.hit.min'))==1
                 if ~isempty(findstr(line,'VR.hit.minP'))==1
                     VR.hit.minP =str2num(line(length('VR.hit.minP')+1:length(line)));
                     VR.hit.min = VR.hit.minP.*VR.movement.range;
                     fprintf(fpCO,'VR.hit.minP\t');
                     for i=1:VR.ND
                         fprintf(fpCO,'%2.3f\t',VR.hit.minP(i));
                     end
                     fprintf(fpCO,'\nVR.hit.min\t');
                     for i=1:VR.ND
                         fprintf(fpCO,'%2.3f\t',VR.hit.min(i));
                     end
                     fprintf(fpCO,'\n');
                 else
                     VR.hit.min =str2num(line(length('VR.hit.min')+1:length(line)));
                     fprintf(fpCO,'VR.hit.min\t');
                     for i=1:VR.ND
                         fprintf(fpCO,'%2.3f\t',VR.hit.min(i));
                     end
                     fprintf(fpCO,'\n');
                 end
            elseif ~isempty(findstr(line,'VR.hit.dist'))==1
                 if ~isempty(findstr(line,'VR.hit.distP'))==1
                     VR.hit.distP =str2num(line(length('VR.hit.distP')+1:length(line)));
                     VR.hit.dist = VR.hit.distP.*VR.movement.range;
                     fprintf(fpCO,'VR.hit.distP\t');
                     for i=1:VR.ND
                         fprintf(fpCO,'%2.3f\t',VR.hit.distP(i));
                     end
                     fprintf(fpCO,'\nVR.hit.dist\t');
                     for i=1:VR.ND
                         fprintf(fpCO,'%2.3f\t',VR.hit.dist(i));
                     end
                     fprintf(fpCO,'\n');
                 else
                     VR.hit.dist =str2num(line(length('VR.hit.dist')+1:length(line)));
                    fprintf(fpCO,'VR.hit.dist\t');
                     for i=1:VR.ND
                         fprintf(fpCO,'%2.3f\t',VR.hit.dist(i));
                     end
                     fprintf(fpCO,'\n');
                 end
             elseif ~isempty(findstr(line,'VR.AccuracyStepSize'))==1
                 if ~isempty(findstr(line,'VR.AccuracyStepSizeP'))==1
                     VR.AccuracyStepSizeP =str2num(line(length('VR.AccuracyStepSizeP')+1:length(line)));
                     VR.AccuracyStepSize = VR.AccuracyStepSizeP*VR.movement.range(1,1);
                     fprintf(fpCO,'VR.AccuracyStepSizeP\t%2.3f\nVR.AccuracyStepSize\t%2.3f\n',VR.AccuracyStepSizeP, VR.AccuracyStepSize);
                 else
                     VR.AccuracyStepSize =str2num(line(length('VR.AccuracyStepSize')+1:length(line)));
                     fprintf(fpCO,'VR.AccuracyStepSize\t%2.3f\n',VR.AccuracyStepSize);
                 end   
            elseif ~isempty(findstr(line,'VR.camera'))==1
                VR.camera=str2num(line(length('VR.camera')+1:length(line)));
                fprintf(fpCO,'VR.camera\t%2.5f\t%2.5f\t%2.5f\n',VR.camera);
            elseif ~isempty(findstr(line,'VR.DAS'))==1
                VR.DAS=str2num(line(length('VR.DAS')+1:length(line)));
                fprintf(fpCO,'VR.DAS\t%i\n',VR.DAS);   
            elseif ~isempty(findstr(line,'VR.Use3rdCursor'))==1
                VR.Use3rdCursor=str2num(line(length('VR.Use3rdCursor')+1:length(line)));
                fprintf(fpCO,'VR.Use3rdCursor\t%i\n',VR.Use3rdCursor);  
            elseif ~isempty(findstr(line,'VR.color.miss'))==1
                VR.color.miss=str2num(line(length('VR.color.miss')+1:length(line)));
                fprintf(fpCO,'VR.color.miss\t%2.5f\t%2.5f\t%2.5f\n',VR.color.miss);
            elseif ~isempty(findstr(line,'VR.color.hit'))==1
                VR.color.hit =str2num(line(length('VR.color.hit')+1:length(line)));
                fprintf(fpCO,'VR.color.hit\t%2.5f\t%2.5f\t%2.5f\n',VR.color.hit);
           elseif ~isempty(findstr(line,'VR.shoulder_position'))==1
                VR.shoulder_position =str2num(line(length('VR.shoulder_position')+1:length(line)));
                fprintf(fpCO,'VR.shoulder_position\t%2.5f\t%2.5f\t%2.5f\n',VR.shoulder_position);
           elseif ~isempty(findstr(line,'VR.CoordinateSystemOffSet'))==1
                VR.CoordinateSystemOffSet =str2num(line(length('VR.CoordinateSystemOffSet')+1:length(line)));
                fprintf(fpCO,'VR.CoordinateSystemOffSet\t%2.5f\t%2.5f\t%2.5f\n',VR.CoordinateSystemOffSet);
           elseif ~isempty(findstr(line,'VR.cam_fov'))==1
                VR.camera_fov =str2num(line(length('VR.cam_fov')+1:length(line)));
                fprintf(fpCO,'VR.camera_fov\t%2.5f\n',VR.camera_fov);
           elseif ~isempty(findstr(line,'VR.BarRotNumAngles'))==1
                VR.BarRotNumAngles =str2num(line(length('VR.BarRotNumAngles')+1:length(line)));
                fprintf(fpCO,'VR.BarRotNumAngles\t%2.5f\n',VR.BarRotNumAngles);
                VR.BarRotAngle = 0;
           elseif ~isempty(findstr(line,'VR.BarRotInc'))==1
                VR.BarRotInc =str2num(line(length('VR.BarRotInc')+1:length(line)));
                fprintf(fpCO,'VR.BarRotInc\t%2.5f\n',VR.BarRotInc);
                
                 
                
            % Parameter structure - defines constants for the coadaptive algorithm    
            elseif ~isempty(findstr(line,'Parameters.Ca1'))==1
                Parameters.Ca1=str2num(line(length('Parameters.Ca1')+1:length(line)));
                fprintf(fpCO,'Parameters.Ca1\t%1.3f\n',Parameters.Ca1);
               % Parameters.Ca1 = validateInputSize(Parameters.Ca1, VR, 'Parameters.Ca1', 1);
            elseif ~isempty(findstr(line,'Parameters.Ca2'))==1
                Parameters.Ca2=str2num(line(length('Parameters.Ca2')+1:length(line)));
                fprintf(fpCO,'Parameters.Ca2\t%1.3f\n',Parameters.Ca2);
                %Parameters.Ca2 = validateInputSize(Parameters.Ca2, VR, 'Parameters.Ca2', 1);
            elseif ~isempty(findstr(line,'Parameters.Amax'))==1
                Parameters.Amax=str2num(line(length('Parameters.Amax')+1:length(line)));
                fprintf(fpCO,'Parameters.Amax\t%1.3f\n',Parameters.Amax);
               % Parameters.Amax = validateInputSize(Parameters.Amax, VR, 'Parameters.Amax',1);
            elseif ~isempty(findstr(line,'Parameters.Cb'))==1
                Parameters.Cb=str2num(line(length('Parameters.Cb')+1:length(line)));
                fprintf(fpCO,'Parameters.Cb\t%1.3f\n',Parameters.Cb);
                %Parameters.Cb = validateInputSize(Parameters.Cb, VR, 'Parameters.Cb', 1);
            elseif ~isempty(findstr(line,'Parameters.NumBlocksHeld'))==1
                Parameters.NumBlocksHeld =str2num(line(length('Parameters.NumBlocksHeld')+1:length(line)));
                fprintf(fpCO,'Parameters.NumBlocksHeld\t%i\n',Parameters.NumBlocksHeld);
                %Parameters.NumBlocksHeld = validateInputSize(Parameters.NumBlocksHeld, VR, 'Parameters.NumBlocksHeld', 4);
            elseif ~isempty(findstr(line,'Parameters.NBlocksPerUpdate'))==1
                Parameters.NBlocksPerUpdate =str2num(line(length('Parameters.NBlocksPerUpdate')+1:length(line)));
                fprintf(fpCO,'Parameters.NBlocksPerUpdate\t%i\n',Parameters.NBlocksPerUpdate);
                %Parameters.NBlocksPerUpdate = validateInputSize(Parameters.NBlocksPerUpdate, VR, 'Parameters.NBlocksPerUpdate', 4);
            elseif ~isempty(findstr(line,'Parameters.NumTriesPerTarg'))==1
                Parameters.NumTriesPerTarg =str2num(line(length('Parameters.NumTriesPerTarg')+1:length(line)));
                fprintf(fpCO,'Parameters.NumTriesPerTarg\t%i\n',Parameters.NumTriesPerTarg);
               % Parameters.NumTriesPerTarg = validateInputSize(Parameters.NumTriesPerTarg, VR, 'Parameters.NumTriesPerTarg', 4);
            elseif ~isempty(findstr(line,'Parameters.MaintainPercentHit'))==1
                Parameters.MaintainPercentHit =str2num(line(length('Parameters.MaintainPercentHit')+1:length(line)));
                fprintf(fpCO,'Parameters.MaintainPercentHit\t%2.3f\n',Parameters.MaintainPercentHit);
               % Parameters.MaintainPercentHit = validateInputSize(Parameters.MaintainPercentHit, VR, 'Parameters.MaintainPercentHit', 3);
            elseif ~isempty(findstr(line,'Parameters.MinBlocksBeforeBreak'))==1
                Parameters.MinBlocksBeforeBreak =str2num(line(length('Parameters.MinBlocksBeforeBreak')+1:length(line)));
                fprintf(fpCO,'Parameters.MinBlocksBeforeBreak\t%i\n',Parameters.MinBlocksBeforeBreak);
               % Parameters.MinBlocksBeforeBreak = validateInputSize(Parameters.MinBlocksBeforeBreak, VR, 'Parameters.MinBlocksBeforeBreak', 4);
            elseif ~isempty(findstr(line,'Parameters.NumBlocksEarlyLimit'))==1
                Parameters.NumBlocksEarlyLimit =str2num(line(length('Parameters.NumBlocksEarlyLimit')+1:length(line)));
                fprintf(fpCO,'Parameters.NumBlocksEarlyLimit\t%i\n',Parameters.NumBlocksEarlyLimit);
              %  Parameters.NumBlocksEarlyLimit = validateInputSize(Parameters.NumBlocksEarlyLimit, VR, 'Parameters.NumBlocksEarlyLimit', 1);
            elseif ~isempty(findstr(line,'Parameters.NNNumIntoTrial'))==1
                Parameters.NNNumIntoTrial =str2num(line(length('Parameters.NNNumIntoTrial')+1:length(line)));
                fprintf(fpCO,'Parameters.NNNumIntoTrial\t%i\n',Parameters.NNNumIntoTrial);
            elseif ~isempty(findstr(line,'COMM.decoder_ip '))==1
                COMM.decoder_ip =line(length('COMM.decoder_ip ')+1:length(line));
                fprintf(fpCO,'COMM.decoder_ip\t%s\n',COMM.decoder_ip);  
            elseif ~isempty(findstr(line,'COMM.decoder_port1 '))==1
                COMM.decoder_port1 =str2num(line(length('COMM.decoder_port1 ')+1:length(line)));
                fprintf(fpCO,'COMM.decoder_port1\t%i\n',COMM.decoder_port1);   
            elseif ~isempty(findstr(line,'COMM.decoder_port2 '))==1
                COMM.decoder_port2 =str2num(line(length('COMM.decoder_port2 ')+1:length(line)));
                fprintf(fpCO,'COMM.decoder_port2\t%i\n',COMM.decoder_port2); 
            elseif ~isempty(findstr(line,'COMM.DAS_IP_String '))==1
                COMM.DAS_IP_String =line(length('COMM.DAS_IP_String ')+1:length(line));
                fprintf(fpCO,'COMM.DAS_IP_String\t%s\n',COMM.DAS_IP_String); 
            elseif ~isempty(findstr(line,'COMM.ParamFileName '))==1
                COMM.ParamFileName =line(length('COMM.ParamFileName ')+1:length(line));
                fprintf(fpCO,'COMM.ParamFileName\t%s\n',COMM.ParamFileName); 
            elseif ~isempty(findstr(line,'COMM.ParamFilePath '))==1
                COMM.ParamFilePath =line(length('COMM.ParamFilePath ')+1:length(line));
                fprintf(fpCO,'COMM.ParamFilePath\t%s\n',COMM.ParamFilePath); 
            elseif ~isempty(findstr(line,'COMM.VariableFileName '))==1
                COMM.VariableFileName =line(length('COMM.VariableFileName ')+1:length(line));
                fprintf(fpCO,'COMM.VariableFileName\t%s\n',COMM.VariableFileName); 
            elseif ~isempty(findstr(line,'COMM.ModelPath '))==1
                COMM.ModelPath =line(length('COMM.ModelPath ')+1:length(line));
                fprintf(fpCO,'COMM.ModelPath\t%s\n',COMM.ModelPath); 
            elseif ~isempty(findstr(line,'COMM.configDelay'))==1
                COMM.configDelay =str2num(line(length('COMM.configDelay ')+1:length(line)));
                fprintf(fpCO,'COMM.configDelay\t%f\n',COMM.configDelay); 
            elseif ~isempty(findstr(line,'COMM.receiveDelay '))==1
                COMM.receiveDelay =str2num(line(length('COMM.receiveDelay ')+1:length(line)));
                fprintf(fpCO,'COMM.receiveDelay\t%f\n',COMM.receiveDelay);
            elseif ~isempty(findstr(line,'timing.loop_intervalS '))==1
                timing.loop_intervalS =str2num(line(length('timing.loop_intervalS')+1:length(line)));
                fprintf(fpCO,'timing.loop_intervalS\t%1.3f\n',timing.loop_intervalS);
                %timing.loop_intervalS = validateInputSize(timing.loop_intervalS, VR, 'timing.loop_intervalS', 4);
            elseif ~isempty(findstr(line,'timing.max_movement_timeS'))==1
                timing.max_movement_timeS =str2num(line(length('timing.max_movement_timeS')+1:length(line)));
                fprintf(fpCO,'timing.max_movement_timeS\t%1.3f\n',timing.max_movement_timeS);
               % timing.max_movement_timeS = validateInputSize(timing.max_movement_timeS, VR, 'timing.max_movement_timeS', 3);
            elseif ~isempty(findstr(line,'timing.target_delayS'))==1
                timing.target_delayS =str2num(line(length('timing.target_delayS')+1:length(line)));
                fprintf(fpCO,'timing.target_delayS\t%1.3f\n',timing.target_delayS);
               % timing.target_delayS = validateInputSize(timing.target_delayS, VR, 'timing.target_delayS', 3);
            elseif ~isempty(findstr(line,'timing.intertrial_intervalS'))==1
                timing.intertrial_intervalS =str2num(line(length('timing.intertrial_intervalS')+1:length(line)));
                fprintf(fpCO,'timing.intertrial_intervalS\t%1.3f\n',timing.intertrial_intervalS);
                %timing.intertrial_intervalS = validateInputSize(timing.intertrial_intervalS, VR, 'timing.intertrial_intervalS', 3);
            elseif ~isempty(findstr(line,'timing.cursorcontrol_delayS'))==1
                timing.cursorcontrol_delayS =str2num(line(length('timing.cursorcontrol_delayS')+1:length(line)));
                fprintf(fpCO,'timing.cursorcontrol_delayS\t%1.3f\n',timing.cursorcontrol_delayS);
                %timing.cursorcontrol_delayS = validateInputSize(timing.cursorcontrol_delayS, VR, 'timing.cursorcontrol_delayS', 4);
            elseif ~isempty(findstr(line,'timing.target_holdS'))==1
                timing.target_holdS =str2num(line(length('timing.target_holdS')+1:length(line)));
                fprintf(fpCO,'timing.target_holdS\t%1.3f\n',timing.target_holdS);
                %timing.target_holdS = validateInputSize(timing.target_holdS, VR, 'timing.target_holdS', 3);
            elseif ~isempty(findstr(line,'timing.mean_update_intervalS'))==1
                timing.mean_update_intervalS =str2num(line(length('timing.mean_update_intervalS')+1:length(line)));
                fprintf(fpCO,'timing.mean_update_intervalS\t%1.3f\n',timing.mean_update_intervalS);
             %   timing.mean_update_intervalS = validateInputSize(timing.mean_update_intervalS, VR, 'timing.mean_update_intervalS', 4);
            elseif ~isempty(findstr(line,'timing.mean_windowS'))==1
                timing.mean_windowS =str2num(line(length('timing.mean_windowS')+1:length(line)));     
                fprintf(fpCO,'timing.mean_windowS\t%1.3f\n',timing.mean_windowS);
               % timing.mean_windowS = validateInputSize(timing.mean_windowS, VR, 'timing.mean_windowS', 4);
            elseif ~isempty(findstr(line,'timing.baselineS'))==1
                timing.baselineS  =str2num(line(length('timing.baselineS')+1:length(line)))
                fprintf(fpCO,'timing.baselineS\t%1.3f\n',timing.baselineS);
               % timing.baselineS = validateInputSize(timing.baselineS, VR, 'timing.baselineS', 4);
               elseif ~isempty(findstr(line,'timing.baselinetargetS'))==1
                timing.baselinetargetS  =str2num(line(length('timing.baselinetargetS')+1:length(line)))
                fprintf(fpCO,'timing.baselinetargetS\t%1.3f\n',timing.baselinetargetS);
               % timing.baselinetargetS = validateInputSize(timing.baselinetargetS, VR,
               % 'timing.baselinetargetS', 4);
            elseif ~isempty(findstr(line,'timing.feederS'))==1
                timing.feederS  =str2num(line(length('timing.feederS')+1:length(line))); 
                fprintf(fpCO,'timing.feederS\t%1.3f\n',timing.feederS);
               % timing.feederS = validateInputSize(timing.feederS, VR, 'timing.feederS', 4);
                
            elseif ~isempty(findstr(line,'TDT.use_TDevAcc'))==1
                TDT.use_TDevAcc  =str2num(line(length('TDT.use_TDevAcc ')+1:length(line)));
                fprintf(fpCO,'TDT.use_TDevAcc\t%i\n',TDT.use_TDevAcc);
            elseif ~isempty(findstr(line,'TDT.num_chan'))==1
                TDT.num_chan  =str2num(line(length('TDT.num_chan')+1:length(line)));
                fprintf(fpCO,'TDT.num_chan\t%i\n',TDT.num_chan);
            elseif ~isempty(findstr(line,'TDT.filename_RCO'))==1
                TDT.filename_RCO  =line(length('TDT.filename_RCO ')+1:length(line));
                fprintf(fpCO,'TDT.filename_RCO \t%s\n',TDT.filename_RCO);
            elseif ~isempty(findstr(line,'TDT.HPcutoff'))==1
                TDT.HPcutoff  =str2num(line(length('TDT.HPcutoff')+1:length(line))); 
                fprintf(fpCO,'TDT.HPcutoff \t%i\n',TDT.HPcutoff);
            elseif ~isempty(findstr(line,'TDT.LPcutoff'))==1
                TDT.LPcutoff  =str2num(line(length('TDT.LPcutoff')+1:length(line))); 
                fprintf(fpCO,'TDT.LPcutoff \t%i\n',TDT.LPcutoff);
           elseif ~isempty(findstr(line,'SigProc.CursorLowPass'))==1
                SigProc.CursorLowPass  =str2num(line(length('SigProc.CursorLowPass')+1:length(line))); 
                fprintf(fpCO,'SigProc.CursorLowPass \t%0.3f\n',SigProc.CursorLowPass);
           elseif ~isempty(findstr(line,'SigProc.ElectrodeList'))==1% for a given experimental EEG setup, you should have an electrode name list eg (CZ C1 C3 F3, Cp2...)so that we can easily relate weights and values to actual electrode locations
                SigProc.ElectrodeList  =line(length('SigProc.ElectrodeList ')+1:length(line));
                namestuff=SigProc.ElectrodeList;
                fprintf(fpCO,'SigProc.ElectrodeList \t%s\n',SigProc.ElectrodeList);
                [fpEL message]=fopen(SigProc.ElectrodeList,'rt');
                if fpEL==-1
                    disp(['could not open ' SigProc.ElectrodeList]);
                    KeepRunningFlag=0;
                else
                    lineEL=1;
                    ElectrodeList=[];
                    lineEL=fgetl(fpEL);
                    while lineEL~=-1
                        l=length(lineEL);
                        if(l==3)
                            ElectrodeList=[ElectrodeList;lineEL];
                        else
                            ElectrodeList=[ElectrodeList;lineEL ' '];
                        end
                        lineEL=fgetl(fpEL);
                    end
                end
                fclose(fpEL);
            elseif ~isempty(findstr(line,'SigProc.ReRefMat'))==1% For a given EEG experimental set up, this is the .txt file that is read in and defines the referencing (e.g. CAR, Laplacian, etc)
                rerefname=line(length('SigProc.ReRefMat ')+1:length(line));
                fprintf(fpCO,'SigProc.ReRefMat \t%s\n',rerefname);
                SigProc.ReRefMat=load(rerefname);
                if(size(SigProc.ReRefMat,1)~=TDT.num_chan)
                    size(SigProc.ReRefMat)
                    disp ('Warning: TDT.num_chan does not match num rows in rerefMat')
                    KeepRunningFlag=0;
                else
                    for i=1:size(SigProc.ReRefMat,1)
                        try
                            fprintf(fpCO,'%s\t',ElectrodeList(i,:));
                        catch
                            fprintf(fpCO,'%i\t',i);
                        end
                        for j=1:size(SigProc.ReRefMat,2)
                            fprintf(fpCO,'%1.5f\t',SigProc.ReRefMat(i,j));
                        end%j
                        fprintf(fpCO,'\n');
                    end%i
                end
                decode.num_RerefChan=size(SigProc.ReRefMat,2);
            elseif ~isempty(findstr(line,'SigProc.SpReRefMat'))==1% For a given EEG experimental set up, this is the .txt file that is read in and defines the referencing (e.g. CAR, Laplacian, etc)
                rerefname=line(length('SigProc.SpReRefMat ')+1:length(line));
                fprintf(fpCO,'SigProc.ReRefMat \t%s\n',rerefname);
                SigProc.SpReRefMat=load(rerefname);
               
                if(size(SigProc.SpReRefMat,1) * size(SigProc.SpReRefMat,2)~=TDT.num_chan*4)
                    size(SigProc.SpReRefMat)
                    disp ('Warning: TDT.num_chan does not match num rows in rerefMat')
                    KeepRunningFlag=0;
                else
                    for i=1:size(SigProc.SpReRefMat,1)
                        try
                            fprintf(fpCO,'%s\t',ElectrodeList(i,:));
                        catch
                            fprintf(fpCO,'%i\t',i);
                        end
                        for j=1:size(SigProc.SpReRefMat,2)
                            fprintf(fpCO,'%1.5f\t',SigProc.SpReRefMat(i,j));
                        end%j
                        fprintf(fpCO,'\n');
                    end%i
                end
                decode.num_SpRerefChan=sum(sum(SigProc.SpReRefMat));
            elseif ~isempty(findstr(line,'SigProc.freq_bin'))==1
                SigProc.freq_bin  =str2num(line(length('SigProc.freq_bin')+1:length(line)));
                fprintf(fpCO,'SigProc.freq_bin \t');
                for i=1:length(SigProc.freq_bin)
                    fprintf(fpCO,'%i\t',SigProc.freq_bin(i));
                end
                fprintf(fpCO,'\n');
                decode.num_totalchan = length(SigProc.freq_bin)*decode.num_RerefChan;
            elseif ~isempty(findstr(line,'decode.fft_size'))==1
                decode.fft_size   =str2num(line(length('decode.fft_size ')+1:length(line)));
                fprintf(fpCO,'decode.fft_size \t%i\n',decode.fft_size );
                    TotalNumFreqBin=floor(decode.fft_size/2);
            elseif ~isempty(findstr(line,'decode.LogTransform'))==1
                decode.LogTransform   =str2num(line(length('decode.LogTransform ')+1:length(line)));
                fprintf(fpCO,'decode.LogTransform \t%i\n',decode.LogTransform );
            elseif ~isempty(findstr(line,'event.BlockNum'))==1
                event.BlockNum  =str2num(line(length('event.BlockNum')+1:length(line)));
                fprintf(fpCO,'event.BlockNum \t%i\n',event.BlockNum);
            elseif ~isempty(findstr(line,'event.TargNum'))==1
                event.TargNum  =str2num(line(length('event.TargNum')+1:length(line))); 
                fprintf(fpCO,'event.TargNum \t%i\n',event.TargNum);
            elseif ~isempty(findstr(line,'event.record_baseline'))==1
                event.record_baseline  =str2num(line(length('event.record_baseline')+1:length(line))); 
                fprintf(fpCO,'event.record_baseline \t%i\n',event.record_baseline);
            elseif ~isempty(findstr(line,'WriteLine'))==1
                eval(line); 
                fprintf(fpCO,'%s',line);
            end
				line=fgetl(fConfig);
            if line==-1
                KeepRunningFlag=0;
                
            end
        end%Keep running
        if line==-1
                KeepRunningFlag=1;
        end
    end%while line exists
end%if file opened

% start the hiResTimer
try
HiResTimer('startTimer');
VR.startTime = 0;
catch
    disp('Could not start timer')
end
%now that the configuration file has been read, this starts the main
%program which runs all the other programs
eval( Funk.MasterControl);
%==================


