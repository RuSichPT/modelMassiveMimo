classdef HybridMassiveMimo < MassiveMimo
    
    properties
    end
    
    methods
        %% Конструктор
        function obj = HybridMassiveMimo()
            %% Параметры системы
            obj.main.hybridType = 'full';           % Тип архитектуры Full-Fully-connected hybrid beamforming
            obj.main.numRF = obj.main.numSTS;       % Кол-во RF цепочек
        end
        
        %% Методы
        [H_estim, H_estimUsers] = channelSounding(obj, snr)
        [digitalData, Frf] = applyPrecod(obj, inputData, estimateChannel)
        [numErrors, numBits] = simulateOneSNR(obj, snr) 
        calculateParam(obj)
    end
end

