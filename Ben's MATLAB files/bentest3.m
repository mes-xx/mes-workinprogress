TDT.use_TDevAcc=1;

Init_ActX;

TDT.tag_dCODE=[TDT.Dev{1} '.dCODE~'];
TDT.tag_BufGo=[TDT.Dev{1} '.BufGo'];

invoke(TDT.RP, TDT.call_SetTag, TDT.tag_BufGo, 0);

for i=1:4
    BinData(i,:)=double(invoke(TDT.RP, TDT.call_ReadTag, [TDT.tag_dCODE int2str(i)], 0, 1024));
end

invoke(TDT.RP, TDT.call_SetTag, TDT.tag_BufGo, 1);
Close_ActX;

Data=zeros(16, 1024);
for i=4:4:16
    Data(i,:)=floor((BinData((i/4),:)/512));
    Data((i-1),:)=floor(mod(BinData((i/4),:),512)/64);
    Data((i-2),:)=floor(mod(BinData((i/4),:),64)/8);
    Data((i-3),:)=mod(BinData((i/4),:),8);
end