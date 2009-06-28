function tdtCloseTank( tankHandle )
% tdtCloseTank( tankHandle ) Closes a tank and releases TTank server 
% attached to tankHandle.

invoke(tankHandle, 'CloseTank');
invoke(tankHandle, 'ReleaseServer');
