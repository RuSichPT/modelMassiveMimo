classdef HybridMassiveMimo < MassiveMimo
    
    properties
    end
    
    methods
        %% Конструктор
        function obj = HybridMassiveMimo()
            %% Параметры системы
            obj.main.numSubArray = 1;           % Кол-во подрешеток 1-Fully-connected hybrid beamforming
            obj.main.numRF = obj.main.numSTS;   % Кол-во RF цепочек
        end
        %% Методы
        [digitalData, Frf] = applyPrecod(obj, inputData, estimateChannel)
        [numErrors, numBits] = simulateOneSNR(obj, snr)  

    end
end

