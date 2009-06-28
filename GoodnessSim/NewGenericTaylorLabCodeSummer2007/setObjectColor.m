function setObjectColor(VR, color, obj, TDT)
%WaitForEvenFrame;
if (strcmpi(obj, 'cursor') == 1)
    setField(VR.world.CWristMaterial, 'emissiveColor', color);
    setField(VR.world.CThumbMaterial, 'emissiveColor', color);
    setField(VR.world.CFingerMaterial, 'emissiveColor', color);
    setField(VR.world.CWristMaterial, 'diffuseColor', color);
    setField(VR.world.CThumbMaterial, 'diffuseColor', color);
    setField(VR.world.CFingerMaterial, 'diffuseColor', color);
else
    
    setField(VR.world.TWristMaterial, 'emissiveColor', color);
    setField(VR.world.TThumbMaterial, 'emissiveColor', color);
    setField(VR.world.TFingerMaterial, 'emissiveColor', color);
    setField(VR.world.TWristMaterial, 'diffuseColor', color);
    setField(VR.world.TThumbMaterial, 'diffuseColor', color);
    setField(VR.world.TFingerMaterial, 'diffuseColor', color);
end

return