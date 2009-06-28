SNR = [];
SignalScale = [];
NoiseScale = [];
NoiseCorrelation = [];
Baseline = [];


for i = 117:306
    
    filename = ['Neurons_' int2str(i)];
    
    try
        load(filename)
        
        SNR = vertcat(SNR, Neurons.SignalScale ./ Neurons.NoiseScale' );
        SignalScale = vertcat(SignalScale, Neurons.SignalScale);
        NoiseScale = vertcat(NoiseScale, Neurons.NoiseScale');
        NoiseCorrelation = vertcat(NoiseCorrelation, Neurons.NoiseCorrelation(:));
        Baseline = vertcat(Baseline, Neurons.Baseline');
    catch
        continue
    end
end
        