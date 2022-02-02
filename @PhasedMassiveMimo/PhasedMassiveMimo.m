classdef PhasedMassiveMimo < MassiveMimo
    
    properties
    end
    
    methods       
        %% Методы
        [H_estim] = channelSounding(obj, snr)
        [numErrors, numBits] = simulateOneSNR(obj, snr)  
    end
end