% update target position based on first 3 dimensions
setfield(VR.world.Main, 'rotation', [0 0 1 VR.BarRotAngle]);
setfield(VR.world.Target, 'translation', (VR.BarCentersT(1, :) + [0 VR.target_position(1) 0]));
if VR.num_dim > 1
	setfield(VR.world.Target2, 'translation', (VR.BarCentersT(2, :) + [0 VR.target_position(2) 0]));
end
if VR.num_dim > 2
    setfield(VR.world.Target3, 'translation', (VR.BarCentersT(3, :) + [0 VR.target_position(3) 0]));
end

if VR.num_dim > 3
    setfield(VR.world.Target4, 'translation', (VR.BarCentersT(4, :) + [0 VR.target_position(4) 0]));
end

if VR.num_dim > 4
    setfield(VR.world.Target5, 'translation', (VR.BarCentersT(5, :) + [0 VR.target_position(5) 0]));
end

if VR.num_dim > 5
    setfield(VR.world.Target6, 'translation', (VR.BarCentersT(6, :) + [0 VR.target_position(6) 0]));
end

