classdef MassiveMimo < matlab.mixin.Copyable
    properties
        %% ��������� �������
        main = struct(...
                "numAntenns",       0, ...  % ���-�� ������ � �������� ������� / 12 or 8
                "numUsers",         0, ...  % ���-�� �������������
                "modulation",       0, ...  % ������� ���������
                "freqCarrier",      0, ...  % ������� ������� GHz        
                "numSTSVec",        0, ...  % ���-�� ����������� ������� ������ �� ������ ������������ / [2 1 3 2]
                "numSTS",           0, ...  % ���-�� ������� ������; ������ ���� ������� 2: /2/4/8/16/32/64
                "numAntennsSTS",    0, ...  % ���-�� ������ �� ���� ����� ������
                "numTx",            0, ...  % ���-�� ���������� ����� 
                "numRx",            0, ...  % ���-�� �������� �����
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
                    "ber",              0, ...  % ����������� ������� ������
                    "snr",              0, ...  % �������� ���
                    "confidenceLevel",  0, ...  % ������� �������������
                    "coefConfInterval", 0 )     % ??? 
    end
    
    methods
        % �����������
        function obj = MassiveMimo(main, ofdm, channel, simulation)
            % ��������� �������
            if (nargin > 0)
                obj.main.numAntenns = main.numAntenns;     
                obj.main.numUsers = main.numUsers;
                obj.main.modulation = main.modulation;
                obj.main.freqCarrier = main.freqCarrier;
                obj.main.precoderType = main.precoderType;           

                obj.main.numSTSVec = ones(1, obj.main.numUsers);                  
                obj.main.numSTS = sum(obj.main.numSTSVec);                        
                obj.main.numAntennsSTS = obj.main.numAntenns / obj.main.numSTS;            
                obj.main.numTx = obj.main.numSTS * obj.main.numAntennsSTS;                 
                obj.main.numRx = obj.main.numSTS;                                
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
                obj.channel.impResponse  = channel.impResponse;
            end
            % ��������� ���������                 
            if (nargin > 3)

            end
        end
        % ������
        [preamble, ltfSC] = generatePreamble(obj, numSTS, varargin)
        
        outputData = passChannel(obj, inputData)
        
        estimH = channelEstimate(obj, rxData, ltfSC, numSTS)
        
        [outputData, precodWeights, combWeights] = applyPrecod(obj, inputData, estimateChannel)
        
        outputData = equalizerZFnumSC(obj, inputData, H_estim)
        
        [berconf, lengthConfInterval] = simulateOneSNR(obj, snr)
        
        simulate(obj, rangeSNR, maxNumZeroBER, minNumErrs, maxNumSimulation)
        
        numErrors = calculateErrors(obj, inpData, outData)
        
        [berconf, lenConfInterval] = calculateBER(obj, allNumErrors, allNumBits);
        
        plotMeanBER(obj, lineStyle, lineWidth, flag, varargin)

    end
end

