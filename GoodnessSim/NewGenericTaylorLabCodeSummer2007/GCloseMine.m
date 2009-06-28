%GracefullClose This saves current Adaptive variable and closes all open files
if exist('Parameters')
    save([OutName 'Parameters'],'Parameters')
end

 %   fprintf(fpCO,'\nComments:');
x=fopen('all');
if~isempty(x)
    for i=1:length(x)
        fclose(x(i));
    end
end

try
    -tg;
catch
end
