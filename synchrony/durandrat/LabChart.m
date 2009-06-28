%LABCHART Plots the output of ADInstruments LabChart Export MATLAB
%         extension. 
%
%         For more information visit http://www.adinstruments.com/

function labchart(fname)

pathname='';
if(nargin == 0)
   [fname, pathname] = uigetfile('*.mat', 'Select a MAT-file');
end

if fname==0,
   return
end

load([pathname fname])

block=1;
datablock=sprintf('data_block%d',block);

% look for 'Matrix Per Block'
if exist(datablock), 
	while (exist(datablock)),
		figure(block);
		clf
		y=eval(datablock);
		ticks=sprintf('ticktimes_block%d',block);
		units=sprintf('units_block%d',block);
		comments=sprintf('comchan_block%d',block);
		range=sprintf('range_block%d',block);
		titles=sprintf('titles_block%d',block);
		scales=sprintf('scale_block%d',block);

		s=size(y);
		for i=1:s(1),
			subplot(s(1),1,i);
			if exist(scales), %scale data to physical units
				scale=eval(scales);
				y(i,:)=scale(i,1).*(y(i,:)+scale(i,2));
				end
			if exist(ticks),
 				x=eval(ticks);
			else
				x=(0:length(y)-1);
				end
			plot(x,y(i,:));
			V=axis;
			V(1)=x(1);
			V(2)=x(length(x));
			if exist(range),
				r=eval(range);
				% If the range is finite then set axis
				if ( isfinite(r(i,1)) & isfinite(r(i,2)) )
					V(3)=r(i,1)-eps;
					V(4)=r(i,2)+eps;					
					end
				end
			axis(V);
			if exist(units),
				u=eval(units);
				ylabel(u(i,:))
				end
			if exist(titles),
				t=eval(titles);
				title(t(i,:));
				end
			end

		% Label the bottom x axis 
		if exist(ticks),
			xlabel('Time (s)');
		else
			xlabel('Sample Number');
			end

		% Display the comments if they exist
		if exist(comments),
			chan=eval(comments);
			if prod(size(chan)) ~= 0 ,
				txt=eval(sprintf('comtext_block%d',block));
				tick=eval(sprintf('comtick_block%d',block));
				index=eval(sprintf('index_block%d',block));
				for i=1:length(chan),
					if chan(i)>0,	% then comment applies to this channel only
						if  index(chan(i))~=0, %then labchart channel chan(i) was included in data matrix
							subplot(s(1),1,index(chan(i)));
							V=axis;
							%text(x(tick(i)),V(3)+0.1*(V(4)-V(3)),txt(i,:));
							hold on;
							plot([x(tick(i)) x(tick(i))],[V(3) V(4)],'r:');
							hold off;
							end
					else		% comment applies to all channels 
						subplot(s(1),1,s(1));
						V=axis;
						%text(x(tick(i)),V(3)+0.1*(V(4)-V(3)),txt(i,:));
						for j=1:s(1),
							subplot(s(1),1,j);
							V=axis;
							hold on;
							plot([x(tick(i)) x(tick(i))],[V(3) V(4)],'r:');
							hold off;
							end
						end
					end
				end
			end

		% Increment block counter
		block=block+1;
		datablock=sprintf('data_block%d',block);
	end % end of while loop

else %look for combined matrix
	if exist('data'),
		figure(1);
		clf
 
		s=size(data);
     
		x=(0:length(data)-1);
		% But use ticktimes if it exists and is continuous
		if ( exist('ticktimes') & exist('boundary') ),
			if length(boundary) == 1,
				x=ticktimes;
				end
			end
      
		for i=1:s(1),
			subplot(s(1),1,i);
			if exist('scale'), %scale data to physical units
				data(i,:)=scale(i,1).*(data(i,:)+scale(i,2));
				end
			plot(x,data(i,:));
			V=axis;
			V(1)=x(1);
			V(2)=x(length(x));
			if exist('range'),
				% If the range is finite then set axis
				if ( isfinite(range(i,1)) & isfinite(range(i,2)) )
					V(3)=range(i,1)-eps;
					V(4)=range(i,2)+eps;
					end
				end
			axis(V);
			if exist('boundary'),
				if length(boundary) > 1,
					hold on;
					
					t=V(4);
					b=V(3);
					for j=2:length(boundary),
						plot([boundary(j) boundary(j)],[b t],'b')
						end
					hold off;
					end
				end
			if exist('units'),
				ylabel(units(i,:))
				end
			if exist('titles'),
				title(titles(i,:));
				end
			end

		% Label the bottom x axis if ticktimes exist and is continuous
		timelabel='Sample Number';
		if ( exist('ticktimes') & exist('boundary') ),
			if length(boundary) == 1,
				timelabel='Time (s)';
				end
			end
		xlabel(timelabel);

		% Display the comments if they exist
		if exist('comchan'),
			chan=eval('comchan');
			if prod(size(chan)) ~= 0 ,
				
				
				for i=1:length(chan),
					if chan(i)>0,
						if  index(chan(i))~=0, %then labchart channel chan(i) was included in data matrix
							subplot(s(1),1,index(chan(i)));
							V=axis;
							%text(x(comtick(i)),V(3)+0.1*(V(4)-V(3)),comtext(i,:));
							hold on;
							plot([x(comtick(i)) x(comtick(i))],[V(3) V(4)],'r:');
							hold off;
							end;
					else
						subplot(s(1),1,s(1));
						V=axis;
						%text(x(comtick(i)),V(3)+0.1*(V(4)-V(3)),comtext(i,:));
						for j=1:s(1),
							subplot(s(1),1,j);
							V=axis;
							hold on;
							plot([x(comtick(i)) x(comtick(i))],[V(3) V(4)],'r:');
							hold off;
							end
						end
					end
				end
			end
		end
	end
  







keyboard



