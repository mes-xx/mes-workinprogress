%VR.BarCenters = [0.0, -VR.cursor_rad / 2, 0.0];



VR.modeflag=1;% InitVRWorld
VR.in_target=0;
VR.world = vrworld(VR.filename);
open(VR.world);
% calcuate the cursor radius in screen coordinates
% VR.cursor_rad = VR.hit.max(1) - VR.InitAccuracyAdjustment(1);

%WaitForEvenFrame;
setfield(VR.world.Cursor, 'scale', [VR.CursRad VR.CursRad VR.CursRad ]);
setfield(VR.world.Target, 'scale', [VR.TargRad VR.TargRad VR.TargRad ]);
setfield(VR.world.Camera, 'position', VR.camera);
VR.target_position(1)=100000;
VR.cursor_position(1)=10000;
eval([Funk.SetObjectColor '(VR, VR.color.miss, ''target'')']);
VR.in_target=0;
eval(Funk.UpdateTargetPosition);
eval(Funk.UpdateCursorPosition);

% 
% %training specific -- remove this line and all subsequent references
% iUpdateBlock = 1;
% 
% loop = 0;
%Code below used to be in its own openVRWorld code
VR.fig=view(VR.world);
set(VR.fig,'NavPanel','none');
vrdrawnow;



% allow the operator to reposition the VR window onto the second monitor
% and initiate stereo display -- this should be replaced by the
% initialization UI 
disp('Reposition the VR window, and press any key to continue');
pause;
