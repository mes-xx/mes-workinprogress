function setObjectColor(VR, color, obj, TDT)

if (strcmpi(obj, 'cursor') == 1)
    setField(VR.world.Cursor1Color, 'emissiveColor', color);
    setField(VR.world.Cursor1Color, 'diffuseColor', color);
    if (VR.num_dim > 1)
        setField(VR.world.Cursor2Color, 'emissiveColor', color);
        setField(VR.world.Cursor2Color, 'diffuseColor', color);
    end
    
    if (VR.num_dim > 2)
        setField(VR.world.Cursor3Color, 'emissiveColor', color);
        setField(VR.world.Cursor3Color, 'diffuseColor', color);
    end
    
else
    
    setField(VR.world.Target1Color, 'emissiveColor', color);
    setField(VR.world.Target1Color, 'diffuseColor', color);
    if (VR.num_dim > 1)
        setField(VR.world.Target2Color, 'emissiveColor', color);
        setField(VR.world.Target2Color, 'diffuseColor', color);
    end
    
    if (VR.num_dim > 2)
        setField(VR.world.Target3Color, 'emissiveColor', color);
        setField(VR.world.Target3Color, 'diffuseColor', color);
    end
    
end

return