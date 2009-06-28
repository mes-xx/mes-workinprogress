function setObjectColorSpheres(VR, color, obj)

if (strcmpi(obj, 'cursor') == 1)
    setfield(VR.world.CursorColor, 'diffuseColor', color);
else
    setfield(VR.world.TargetColor, 'diffuseColor', color);   
end

return