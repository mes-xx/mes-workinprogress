try
    if(TDTSet(1)=='Y')
        eval(Funk.PauseDSP);
    end
catch
end
try
    a = exist([OutName 'params']);
    if a~=7
        mkdir([OutName 'params'])
    end
    try
        save([OutName 'params\ParametersFinal'], 'Parameters','VR', 'SigProc','decode', 'timing','Funk');
    catch
        if exist('Parameters')
            save([OutName 'params\ParametersFinal'], 'Parameters');
        end
    end
catch
end
try
    eval(Funk.CloseOptotrak);
catch
end
try
    fprintf(fpCO,'\nComments:');
catch
end
%This closes all open files before terminating the program. If you crash
%early, run 'GClose' to close all open programs so that files don't get
%corrupted and data isn't lost
x=fopen('all');
if~isempty(x)
    for i=1:size(x,2)
        fclose(x(i));
    end
end

try
    -tg;
catch
end
