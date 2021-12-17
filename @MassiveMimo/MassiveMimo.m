classdef MassiveMimo < matlab.mixin.Copyable
    properties
        %% ��������� �������
        main = struct(...
                "numTx",            0, ...  % ���-�� ���������� �����
                "numRx",            0, ...  % ���-�� �������� �����
                "numPhasedElemTx",  0, ...  % ���-�� �������� ��������� � 1 ������� �� ��������
                "numPhasedElemRx",  0, ...  % ���-�� �������� ��������� � 1 ������� �� �����
                "numUsers",         0, ...  % ���-�� �������������
                "modulation",       0, ...  % ������� ���������
                "freqCarrier",      0, ...  % ������� ������� GHz        
                "numSTSVec",        0, ...  % ���-�� ����������� ������� ������ �� ������ ������������ / [2 1 3 2]
                "numSTS",           0, ...  % ���-�� ������� ������; ������ ���� ������� 2: /2/4/8/16/32/64
                "bps",              0, ...  % ���-�� ��� �� ������ � �������
                "precoderType",     'NOT' ) % ��� ���������                   
        %% ��������� OFDM
        ofdm = struct(...
                "numSubCarriers",       0, ...  % ���-�� �����������
                "lengthFFT",            0, ...  % ����� FFT ��� OFDM
                "numSymbOFDM",          0, ...  % ���-�� �������� OFDM �� ������ �������
                "cyclicPrefixLength",   0, ...  % ����� �������� ����������               
                "nullCarrierIndices",   0 )     % ����� ������� ����������
        %% ��������� ������
        % PHASED_ARRAY_STATIC, PHASED_ARRAY_DYNAMIC
        channel = struct(...           
                "type",             "", ... % ��� ������ 
                "downChannel",      0, ...  % ���������� �����
                "upChannel",        0 )     % ���������� �����            
        %% ��������� ���������
        simulation = struct(...
                "ber",              0,      ...  % ����������� ������� ������
                "snr",              0,      ...  % �������� ���
                "confidenceLevel",  0.95,   ...  % ������� �������������
                "coefConfInterval", 1/15 )     % ???
        dataOFDM = 0;
    end    
    methods
        %% �����������
        function obj = MassiveMimo(varargin)            
            if (mod(length(varargin),2) ~= 0)
                error("���-�� ���������� ����������� �� ������")
            end            
            for i = 1:length(varargin)/2 
                switch varargin{2*i-1}
                    case 'Main'
                        main = varargin{2*i};
                    case 'Ofdm'
                        ofdm = varargin{2*i};
                    case 'Channel'
                        channel = varargin{2*i};
                end
            end            
            %% ��������� �������
            if (exist('main','var') == 1)
                obj.initMainParam(main)
            else
                obj.initMainParam()
            end
            %% ��������� OFDM
            if (exist('ofdm','var') == 1)
                obj.initOFDMParam(ofdm)
            else
                obj.initOFDMParam()
            end
            %% ��������� ������                
            if (exist('channel','var') == 1)
                obj.initChannelParam(channel)
            else
                obj.initChannelParam()
            end
            %% ��������� ���������                 
            if (nargin > 6)
                obj.simulation.confidenceLevel = simulation.confidenceLevel;
                obj.simulation.coefConfInterval = simulation.coefConfInterval;
            end
            %% ������ ����������� ����������
            obj.calculateParam();
        end
        %% ������
        [preambleOFDM, ltfSC]                    = generatePreambleOFDM(obj, numSTS, varargin)
        [ltfTx, ltfSC]                           = generatePreamble(obj, numSTS)
        [H_estim]                                = channelSounding(obj, snr)
        [H_estim]                                = channelSoundingPhased(obj, snr)
        [H_estim]                                = estimateUplink(obj, snr)
        [outputData]                             = passChannel(obj, inputData, channel)        
        [estimH]                                 = channelEstimate(obj, rxData, ltfSC, numSTS)  
        [outputData, precodWeights, combWeights] = applyPrecod(obj, inputData, estimateChannel)
        [outputData, Frf]                        = applyPrecodHybrid(obj, inputData, estimateChannel) 
        [outputData]                             = equalizerZFnumSC(obj, inputData, H_estim)         
        [numErrors]                              = calculateErrors(obj, inpData, outData)     
        [berconf, lenConfInterval]               = calculateBER(obj, allNumErrors, allNumBits)
        [channel]                                = createChannel(obj)
                                                   calculateParam(obj)
        
        % �������������
        initMainParam(obj, varargin)
        initOFDMParam(obj, varargin)
        initChannelParam(obj, varargin)

        % �������  
        [figObj] = plotMeanBER(obj, lineStyle, lineWidth, flagSNR, legendStr, varargin)
        [figObj] = plotSTSBER(obj, lineStyle, lineWidth, flagSNR, partLegendStr, varargin)
        [figObj] = plotSpectrOFDM(obj, sampleRate_Hz)
        
        % ���������     
        simulate(obj, rangeSNR, maxNumZeroBER, minNumErrs, maxNumSimulation)
        simulateMutCorr(obj, rangeSNR, maxNumZeroBER, minNumErrs, maxNumSimulation, corrMatrix)
        simulateHybrid(obj, rangeSNR, maxNumZeroBER, minNumErrs, maxNumSimulation)
        
        [numErrors, numBits] = simulateOneSNR(obj, snr)       
        [numErrors, numBits] = simulateOneSNRphased(obj, snr) 
        [numErrors, numBits] = simulateOneSNRmutCorr(obj, snr, corrMatrix)
        [numErrors, numBits] = simulateOneSNRhybrid(obj, snr)

    end
end

