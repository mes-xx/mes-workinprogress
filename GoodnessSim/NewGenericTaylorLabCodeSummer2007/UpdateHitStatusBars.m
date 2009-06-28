%update hit status for bars


if (sum(abs(VR.cursor_position - VR.target_position) <= VR.hit_dist) == VR.num_dim)
    eval([Funk.SetObjectColor '(VR, VR.color.hit, ''target'')']);
    VR.in_target=1;
else
    eval([Funk.SetObjectColor '(VR, VR.color.miss, ''target'')']);
    VR.in_target=0;
end