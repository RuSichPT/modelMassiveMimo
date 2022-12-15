classdef HybridMassiveMimo < MassiveMimo    
    properties (SetAccess = private)
        hybridType = 'full';            % Тип архитектуры Full-Fully-connected hybrid beamforming
        Frf;
    end
    properties (Dependent, SetAccess = private)
        numRF                           % Кол-во RF цепочек
    end
    %% Constructor, get     
    methods
        % Support name-value pair arguments when constructing object
        function obj = HybridMassiveMimo(args)
            arguments
                args.main = SystemConfig();
                args.modulation = 4;     
                args.precoderType = 'JSDM/OMP';   
                args.ofdm = OfdmParam();
                args.downChannel = RaylSpecialChannel();
                args.sim = SimulationConfig();
                args.hybridType = 'full';
            end
            obj@MassiveMimo('main',args.main,'modulation',args.modulation,...
                'precoderType',args.precoderType,'ofdm',args.ofdm,'downChannel',args.downChannel,'sim',args.sim);
            obj.hybridType = args.hybridType;
        end
        function v = get.numRF(obj)
            v = obj.main.numSTS;
        end
        function str = getLegend(obj)
            str = [obj.precoderType ' ' num2str(obj.main.numTx) 'x'  num2str(obj.main.numRx)...
                    'x'  num2str(obj.main.numSTS) ' u' num2str(obj.main.numUsers) ' type ' obj.hybridType];
        end
    end
    %% Методы
    methods
        [digitalData, Frf] = applyPrecod(obj, inputData, estimateChannel)
        [numErrors, numBits, SINR_dB] = simulateOneSNR(obj, snr) 
    end
end

