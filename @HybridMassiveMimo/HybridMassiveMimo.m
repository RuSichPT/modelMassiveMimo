classdef HybridMassiveMimo < MassiveMimo    
    properties
        hybridType = 'full';            % Тип архитектуры Full-Fully-connected hybrid beamforming
    end
    properties (Dependent, SetAccess = private)
        numRF                           % Кол-во RF цепочек
    end
    %% Constructor, get     
    methods
        % Support name-value pair arguments when constructing object
        function obj = HybridMassiveMimo(varargin)
            obj.main.precoderType = 'JSDM';
            setProperties(obj,nargin,varargin{:})
        end
        function v = get.numRF(obj)
            v = obj.main.numSTS;
        end
    end
    %% Методы
    methods
        [H_estim, H_estimUsers] = channelSounding(obj, snr)
        [digitalData, Frf] = applyPrecod(obj, inputData, estimateChannel)
        [numErrors, numBits, SINR_dB] = simulateOneSNR(obj, snr) 
    end
end

