classdef MassiveMimo < matlab.System & matlab.mixin.Copyable
    % ��������� ������:
    % RaylSpecialChannel(), RaylChannel(), ChannelForNeuralNet(), StaticChannel()
    
    properties        
        main;                           % ��������� �������                
        ofdm;                           % ��������� OFDM
        downChannel;                    % ���������� �����
        simulation = struct(...         % ��������� ���������
                "ber",              0,      ...  % ����������� ������� ������
                "snr",              0,      ...  % �������� ���
                "confidenceLevel",  0.95,   ...  % ������� �������������
                "coefConfInterval", 1/15 )     % ???
    end
    properties (SetAccess = private)
        F;
    end
    %% Constructor, get
    methods
        function obj = MassiveMimo(varargin)
            obj.main = SystemParam();
            obj.ofdm = OfdmParam();
            setProperties(obj,nargin,varargin{:})
        end
    end
    %% ������
    methods
        [preambleOFDM, ltfSC]                    = generatePreambleOFDM(obj, numSTS, varargin)
        [ltfTx, ltfSC]                           = generatePreamble(obj, numSTS)
        [H_estim]                                = estimateUplink(obj, snr)
        [outputData]                             = passChannel(obj, inputData, channel)        
        [estimH]                                 = channelEstimate(obj, rxData, ltfSC, numSTS)  
        [outputData]                             = applyComb(obj, inputData, combWeights)
        [outputData]                             = equalizerZFnumSC(obj, inputData, H_estim)         
        [numErrors]                              = calculateErrors(obj, inpData, outData)     
        [berconf, lenConfInterval]               = calculateBER(obj, allNumErrors, allNumBits)

        % �������  
        [figObj] = plotMeanBER(obj, lineStyle, lineWidth, flagSNR, legendStr, varargin)
        [figObj] = plotCapacity(obj,type,lineStyle,lineWidth,legendStr,varargin)
        [figObj] = plotSTSBER(obj, lineStyle, lineWidth, flagSNR, partLegendStr, varargin)
        [figObj] = plotSpectrOFDM(obj, sampleRate_Hz)
        
        % ���������     
        simulate(obj, rangeSNR, maxNumZeroBER, minNumErrs, maxNumSimulation)
        simulateMutCorr(obj, rangeSNR, maxNumZeroBER, minNumErrs, maxNumSimulation, corrMatrix)
        
        [numErrors,numBits,SINR_dB] = simulateOneSNR(obj,snr)       
        [numErrors,numBits] = simulateOneSNRmutCorr(obj,snr,corrMatrix)

    end
end