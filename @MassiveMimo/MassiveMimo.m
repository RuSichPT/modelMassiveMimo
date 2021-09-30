classdef MassiveMimo < matlab.mixin.Copyable
    properties
        %% Параметры системы
        main = struct(...
                "numAntenns",       0, ...  % Кол-во антенн в антенной решетке / 12 or 8
                "numUsers",         0, ...  % Кол-во пользователей
                "modulation",       0, ...  % Порядок модуляции
                "freqCarrier",      0, ...  % Частота несущей GHz        
                "numSTSVec",        0, ...  % Кол-во независимых потоков данных на одного пользователя / [2 1 3 2]
                "numSTS",           0, ...  % Кол-во потоков данных; должно быть степени 2: /2/4/8/16/32/64
                "numAntennsSTS",    0, ...  % Кол-во антенн на один поток данных
                "numTx",            0, ...  % Кол-во передающих антен 
                "numRx",            0, ...  % Кол-во приемных антен
                "bps",              0, ...  % Кол-во бит на символ в секунду
                "precoderType",     "" )    % Тип прекодера                   
        %% Параметры OFDM
        ofdm = struct(...
                "numSubCarriers",       0, ...  % Кол-во поднессущих
                "lengthFFT",            0, ...  % Длина FFT для OFDM
                "numSymbOFDM",          0, ...  % Кол-во символов OFDM от каждой антенны
                "cyclicPrefixLength",   0, ...  % Длина защитных интервалов               
                "nullCarrierIndices",   0 )     % Длина нулевых интервалов
        %% Параметры канала
        % PHASED_ARRAY_STATIC, PHASED_ARRAY_DYNAMIC
        channel = struct(...           
                "channelType",      "", ... % Тип канала 
                "impResponse",      0 )     % Импульсная характеристика канала
        %% Параметры симуляции
        simulation = struct(...
                    "ber",              0, ...  % Вероятность битовой ошибки
                    "snr",              0, ...  % Диапазон ОСШ
                    "confidenceLevel",  0, ...  % Уровень достоверности
                    "coefConfInterval", 0 )     % ??? 
    end
    
    methods
        % Конструктор
        function obj = MassiveMimo(main, ofdm, channel, simulation)
            % Параметры системы
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
            % Параметры OFDM
            if (nargin > 1)
                obj.ofdm.numSubCarriers = ofdm.numSubCarriers;                           
                obj.ofdm.lengthFFT = ofdm.lengthFFT;                                
                obj.ofdm.numSymbOFDM = ofdm.numSymbOFDM;                               
                obj.ofdm.cyclicPrefixLength = ofdm.cyclicPrefixLength;                        

                tmpNCI = obj.ofdm.lengthFFT - obj.ofdm.numSubCarriers;
                lengthFFT = obj.ofdm.lengthFFT;
                obj.ofdm.nullCarrierIndices = [1:(tmpNCI / 2) (1 + lengthFFT - tmpNCI / 2):lengthFFT]';
            end
            % Параметры канала                
            if (nargin > 2)
                obj.channel.channelType = channel.channelType;
                obj.channel.impResponse  = channel.impResponse;
            end
            % Параметры симуляции                 
            if (nargin > 3)

            end
        end
        % Методы
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

