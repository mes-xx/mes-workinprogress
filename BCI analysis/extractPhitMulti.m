numBlocks = 50;
bufSize = 3;

paths = {};

Phit = [];

for x = 1091:1810
    number = num2str(x);
    number = number(2:4);

    paths{end+1} = ['F:\school\research\data\GoodnessSim\GS042408\GS042408' number 'params\Parameters'];
end

for nFile = 1:numel(paths)

    filename = paths{nFile};




    for n = 1:numBlocks
        load([filename num2str(n)]);

        bufIndex = mod(n,bufSize);

        if bufIndex == 0
            bufIndex = 3;
        end



        Phit(nFile,n) = Parameters.Phit(bufIndex);

    end
end