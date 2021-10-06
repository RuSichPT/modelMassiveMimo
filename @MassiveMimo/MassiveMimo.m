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
                "precoderType",     "" )    % ��� ���������                   
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
                "channelType",      "", ... % ��� ������ 
                "impResponse",      0 )     % ���������� �������������� ������
        %% ��������� ���������
        simulation = struct(...
                    "ber",              0,      ...  % ����������� ������� ������
                    "snr",              0,      ...  % �������� ���
                    "confidenceLevel",  0.95,   ...  % ������� �������������
                    "coefConfInterval", 1/15 )     % ??? 
    end
    
    methods
        % �����������
        function obj = MassiveMimo(main, ofdm, channel, simulation)
            % ��������� �������
            if (nargin > 0)
                obj.main.numPhasedElemTx = main.numPhasedElemTx;
                obj.main.numPhasedElemRx = main.numPhasedElemRx;
                obj.main.numUsers = main.numUsers;
                obj.main.modulation = main.modulation;
                obj.main.freqCarrier = main.freqCarrier;
                obj.main.precoderType = main.precoderType;           

                obj.main.numSTSVec = main.numSTSVec;                  
                obj.main.numSTS = sum(obj.main.numSTSVec);
                obj.main.numTx = obj.main.numPhasedElemTx * obj.main.numSTS;
                obj.main.numRx = obj.main.numPhasedElemRx * obj.main.numSTS; 
                obj.main.bps = log2(obj.main.modulation);
            end
            % ��������� OFDM
            if (nargin > 1)
                obj.ofdm.numSubCarriers = ofdm.numSubCarriers;                           
                obj.ofdm.lengthFFT = ofdm.lengthFFT;                                
                obj.ofdm.numSymbOFDM = ofdm.numSymbOFDM;                               
                obj.ofdm.cyclicPrefixLength = ofdm.cyclicPrefixLength;                        

                tmpNCI = obj.ofdm.lengthFFT - obj.ofdm.numSubCarriers;
                lengthFFT = obj.ofdm.lengthFFT;
                obj.ofdm.nullCarrierIndices = [1:(tmpNCI / 2) (1 + lengthFFT - tmpNCI / 2):lengthFFT]';
            end
            % ��������� ������                
            if (nargin > 2)
                obj.channel.channelType = channel.channelType;
                obj.channel.impResponse = obj.createChannel(channel);
            end
            % ��������� ���������                 
            if (nargin > 3)
                obj.simulation.confidenceLevel = simulation.confidenceLevel;
                obj.simulation.coefConfInterval = simulation.coefConfInterval;
            end
            
        end
        % ������
        [preamble, ltfSC] = generatePreamble(obj, numSTS, varargin)
        
        outputData = passChannel(obj, inputData)
        
        estimH = channelEstimate(obj, rxData, ltfSC, numSTS)
        
        [outputData, precodWeights, combWeights] = applyPrecod(obj, inputData, estimateChannel)
        
        outputData = equalizerZFnumSC(obj, inputData, H_estim)
        
        [numErrors, numBits] = simulateOneSNR(obj, snr)
        
        simulate(obj, rangeSNR, maxNumZeroBER, minNumErrs, maxNumSimulation)
        
        [numErrors, numBits] = simulateOneSNRfixPoint(obj, snr, numFixPoint, roundingType)
        
        simulateFixPoint(obj, rangeSNR, maxNumZeroBER, minNumErrs, maxNumSimulation, numFixPoint, roundingType)
        
        numErrors = calculateErrors(obj, inpData, outData)
        
        [berconf, lenConfInterval] = calculateBER(obj, allNumErrors, allNumBits);
        
        plotMeanBER(obj, lineStyle, lineWidth, flag, varargin)
        
        [channel] = createChannel(obj, prm)

    end
end

