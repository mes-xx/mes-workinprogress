%WriteCursorFileLineDMT
for i=1:2:size(WriteLine,2)
   eval(['n=length(' WriteLine{i} ');']  );
    if n>1
        for j=1:n
            eval(['fprintf(fpCurs, ''' WriteLine{i+1} WriteLine{i} '(j) );']);
        end
    else
        eval(['fprintf(fpCurs, ''' WriteLine{i+1} WriteLine{i} ');']);
    end
end
for j=1:decode.num_totalchan
fprintf(fpCurs, '%f\t', data.power_buffer(iTargetTally(VR.target_num),j, VR.target_num) );
end
fprintf(fpCurs, '\n');