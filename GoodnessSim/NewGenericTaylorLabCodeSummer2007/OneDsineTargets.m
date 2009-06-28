NumBits=VR.num_dim
output = ones( (2^NumBits) , NumBits )*-1;
VR.targets=ones(size(output,1),size(VR.modes,2));

clear NumBits output