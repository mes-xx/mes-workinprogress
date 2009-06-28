setfield(VR.world.Cursor, 'translation', ((VR.BarCenters(1, :) + [0 VR.cursor_position(1) 0])));

if VR.num_dim > 1
	setfield(VR.world.Cursor2, 'translation', (VR.BarCenters(2, :) + [0 VR.cursor_position(2) 0]));
end
if VR.num_dim > 2
    setfield(VR.world.Cursor3, 'translation', (VR.BarCenters(3, :) + [0 VR.cursor_position(3) 0]));
end

if VR.num_dim > 3
    setfield(VR.world.Cursor4, 'translation', (VR.BarCenters(4, :) + [0 VR.cursor_position(4) 0]));
end

if VR.num_dim > 4
    setfield(VR.world.Cursor5, 'translation', (VR.BarCenters(5, :) + [0 VR.cursor_position(5) 0]));
end

if VR.num_dim > 5
    setfield(VR.world.Cursor6, 'translation', (VR.BarCenters(6, :) + [0 VR.cursor_position(6) 0]));
end


