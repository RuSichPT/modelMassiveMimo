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
        [preamble, ltfSC]                        = generatePreamble(obj, numSTS)
        [Hestim, HestimCell]                     = channelSounding(obj, snr, soundAllChannels)
        [estimH]                                 = channelEstimate(obj, rxData, ltfSC, numSTS)
        [outputData]                             = equalizerZFnumSC(obj, inputData, H_estim)

        % �������  
        [figObj] = plotMeanBER(obj, lineStyle, lineWidth, flagSNR, legendStr, varargin)
        [figObj] = plotCapacity(obj,type,lineStyle,lineWidth,legendStr,varargin)
        [figObj] = plotSTSBER(obj, lineStyle, lineWidth, flagSNR, partLegendStr, varargin)
        
        % ���������     
        simulate(obj, rangeSNR, maxNumZeroBER, minNumErrs, maxNumSimulation)
        simulateMutCorr(obj, rangeSNR, maxNumZeroBER, minNumErrs, maxNumSimulation, corrMatrix)
        
        [numErrors,numBits,SINR_dB] = simulateOneSNR(obj,snr)       
        [numErrors,numBits] = simulateOneSNRmutCorr(obj,snr,corrMatrix)

    end
    %%
    methods
        function numErrors = calculateErrors(obj, inpData, outData)
            % inpData, outData - ������� � �������� ������ ������������ [numBits, numSTS]
            % numBits - ���-�� ���
            % numSTS - ���-�� ������� ������;

            % numErrors - ���-�� ������ � numBits

            numSTS = obj.main.numSTS;
            numErrors = zeros(1, numSTS);            
            for i = 1:numSTS
                numErrors(i) = sum(abs(outData(:,i) - inpData(:,i)));
            end
        end        
        function [berconf,lengthConfInterval] = calculateBER(obj, numErrors, numBits)
            % obj.main.numSTS - ���-�� ������� ������
            % numErrors - ���-�� ������;
            % numBits - ���-�� ���

            % berconf - BER
            % lengthConfInterval - ����� �������������� ���������
            % confidenceLevel - % ������� �������������

            numSTS = obj.main.numSTS;
            confLvl = obj.simulation.confidenceLevel;

            confidenceInterval = zeros(2, numSTS);
            lengthConfInterval = zeros(1, numSTS);
            berconf = zeros(1, numSTS);

            for i = 1:numSTS
                [berconf(i), confidenceInterval(:,i)] = berconfint(numErrors(i), numBits, confLvl);
                lengthConfInterval(i) = confidenceInterval(2,i) - confidenceInterval(1,i);
            end
        end
        function figObj = plotSpectrOFDM(obj, sampleRate_Hz)
            snr = 10;
            numTx = 1;
            obj.simulateOneSNR(snr);
            figObj = plotESD(obj.dataOFDM(:,numTx), sampleRate_Hz);
        end
    end
end