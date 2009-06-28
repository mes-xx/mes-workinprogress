try
    if(TDTSet(1)=='Y')
        eval(Funk.PauseDSP);
    end
catch
end
a = exist([OutName 'params']);
if a~=7
    mkdir([OutName 'params'])
end

% %add comments
% bCommentsDone = 0;
% while bCommentsDone==0
%     comment = input('Comments: ')
%     bCommentsDone = strcmp(questdlg('Satisfied with your comments'),'Yes');
% end

     


save([OutName 'params\ParametersFinal'], 'Parameters','VR', 'SigProc','decode', 'timing','Funk', 'comment');
%eval(Funk.SetFinalBaselineValues);
eval(Funk.CloseOptotrak);
fprintf(fpCO,['\nComments:' comment]);
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
    close(VR.fig)
catch
end