classdef MassiveMimo < matlab.mixin.Copyable
    properties
        %% ��������� �������
        numAntenns           % ���-�� ������ � �������� ������� / 12 or 8
        numUsers             % ���-�� �������������
        modulation           % ������� ���������
        freqCarrier          % ������� ������� GHz
        
        numSTSVec            % ���-�� ����������� ������� ������ �� ������ ������������ / [2 1 3 2]
        numSTS               % ���-�� ������� ������; ������ ���� ������� 2: /2/4/8/16/32/64
        numAntennsSTS        % ���-�� ������ �� ���� ����� ������
        numTx                % ���-�� ���������� ����� 
        numRx                % ���-�� �������� �����
        bps                  % ���-�� ��� �� ������ � �������
        precoderType         % ��� ���������
        %% ��������� OFDM 
        numSubCarriers       % ���-�� �����������
        lengthFFT            % ����� FFT ��� OFDM
        numSymbOFDM          % ���-�� �������� OFDM �� ������ �������
        cyclicPrefixLength   % ����� �������� ����������
               
        nullCarrierIndices   % ����� ������� ����������
        %% ��������� ������
        % PHASED_ARRAY_STATIC, PHASED_ARRAY_DYNAMIC
        channelType          % ��� ������ 
        H                    % ���������� �������������� ������
        %% ��������� ���������
        ber;                            % ����������� ������� ������
        snr;                            % �������� ���
        confidenceLevel = 0.95;         % ������� �������������
        coefConfInterval = 1/15;        % ??? 
    end
    
    methods
        % �����������
        function obj = MassiveMimo(main, ofdm, channel)
            % ��������� �������
            obj.numAntenns = main.numAntenns;     
            obj.numUsers = main.numUsers;
            obj.modulation = main.modulation;
            obj.freqCarrier = main.freqCarrier;
            obj.precoderType = main.precoderType;
            
            % ��������� OFDM 
            obj.numSTSVec = ones(1, obj.numUsers);                  
            obj.numSTS = sum(obj.numSTSVec);                        
            obj.numAntennsSTS = obj.numAntenns / obj.numSTS;            
            obj.numTx = obj.numSTS * obj.numAntennsSTS;                 
            obj.numRx = obj.numSTS;                                
            obj.bps = log2(obj.modulation);
            
            obj.numSubCarriers = ofdm.numSubCarriers;                           
            obj.lengthFFT = ofdm.lengthFFT;                                
            obj.numSymbOFDM = ofdm.numSymbOFDM;                               
            obj.cyclicPrefixLength = ofdm.cyclicPrefixLength;                        

            tmpNCI = obj.lengthFFT - obj.numSubCarriers;
            obj.nullCarrierIndices = [1:(tmpNCI / 2) (1 + obj.lengthFFT - tmpNCI / 2):obj.lengthFFT]';  
                        
            obj.channelType = channel.channelType;
            obj.H  = channel.H;
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

