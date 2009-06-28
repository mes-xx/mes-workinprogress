basePath = 'F:\school\research\data\ballistic\';

for i = [117:306]

    number = int2str(i);
    directory = [basePath 'M0' number '\'];
    
    if ( exist(directory,'dir') )
        path = [directory 'M0' number 'R.mpars'];
        Neurons  = neuronPropertiesFromMpars( path );
        save(['Neurons_' number], 'Neurons')
    end
end