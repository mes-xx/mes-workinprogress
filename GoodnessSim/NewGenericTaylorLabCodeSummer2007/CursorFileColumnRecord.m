eval(Funk.DefineWriteLine);
fprintf(fpCO,'\nCursorFileColumnRecord\n');
k=1;
q=1;
for i=1:2:size(WriteLine,2)
   eval(['n=length(' WriteLine{i} ');']  );
   j=k+n-1;
   fprintf(fpCO,'%i\t%i\t%s\n',k,j,WriteLine{i});
   VR.CursorColumnRecord{q,1}=[k j];
   VR.CursorColumnRecord{q,2}=WriteLine{i};
   k=k+n;
   q=q+1;
end
if WriteRawPower
    j=k+decode.num_totalchan-1;
    fprintf(fpCO,'%i\t%i\t%s\n',k,j,'RawPower');
    VR.CursorColumnRecord{q,1}=[k j];
    VR.CursorColumnRecord{q,2}='RawPower';
end
 