function[Duration]=taskduration_v1(Labels)

n=1;k=1;
while(n<length(Labels)-1)
    if(Labels(n)~=Labels(n+1))
        if(k==1)
            Duration(k,1)=1;
            Duration(k,2)=n;
        else
            Duration(k,1)=Duration(k-1,2)+1;
            Duration(k,2)=n+1;
        end
    k=k+1;
    end
    n=n+1;
end

Duration(k,1)=Duration(k-1)+1;
Duration(k,2)=length(Labels);
