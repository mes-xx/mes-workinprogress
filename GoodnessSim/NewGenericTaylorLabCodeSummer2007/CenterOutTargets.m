%This code (Based on Ben's AllBitVectors' creates a standard center out target array (-1, 1) for any numer of
%dimensions listed in  VR.num_dim(i)
%It clears all uneccesary variables at the end
NumBits=VR.num_dim
output = ones( (2^NumBits) , NumBits )*-1;
for ( column = 1:NumBits );
    index = (column - 1)*(2^NumBits) + 1;
    while ( index <= ( column*(2^NumBits) ) );
        for ( trash = 1:( 2^(column - 1) ) );
            output( index ) = 1;
            index = index + 1;
        end;
        for ( trash = 1:( 2^(column - 1) ) );
            index = index + 1;
        end;
    end; 
end;
            

VR.targets=zeros(size(output,1),size(VR.modes,2))
if(size(VR.modes,1)==1)
    VR.targets(:,find(VR.modes>0))=output;
else
    VR.targets(:,find(sum(VR.modes)>0))=output;
end
%VR.targets{i}(find(VR.targets{i}==0))=-1;
clear index NumBits column output trash