%update hit status for Spheres


if (sqrt((VR.target_position(1:min(3,VR.ND))-VR.cursor_position(1:min(3,VR.ND)))*(VR.target_position(1:min(3,VR.ND))-VR.cursor_position(1:min(3,VR.ND)))')>VR.hit_dist)
   % if  VR.in_target==1
        eval([Funk.SetObjectColor '(VR, VR.color.miss, ''target'')']);
        VR.in_target=0;
    %end
else
  %  if  VR.in_target==0
        eval([Funk.SetObjectColor '(VR, VR.color.hit, ''target'')']);
        VR.in_target=1;
   % end
end