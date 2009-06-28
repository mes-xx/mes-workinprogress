CursorFileName= ' '
dat=load(CursorFileName);
VR.cursor_position= dat(:,  :);
VR.target_position= dat(:, :);
data.normalized=dat(:, : );

goodi1=find(VR.target_position(:,1)<1000&& VR.cursor_position(:,1)<1000)
plot(VR.cursor_position(:,1))
hold on
plot(VR.target_position(:,1))
display('define which data to use in calculating new weights; eg goodi2= [xxx:xxx xxx:xxx]')
keyboard
goodi= intersect(goodi1,goodi2);

Y=VR.target_position(goodi,1)-VR.cursor_position(goodi,1);
X=[ones(size(Y)) data.normalized(goodi,:)];
[B,BINT,R,RINT] = REGRESS(Y,X)
load('...ParametersFinal')
for i =1: size(Parameters.Wp,3)
Parameters.Wp(:,1,i)=B(2:length(B));
Parameters.Wn(:,1,i)=B(2:length(B));
end
save('....RegressionParametersFinal')
