classdef MassiveMimo < matlab.mixin.Copyable
    properties
        %% Параметры системы
        main = struct(...
                "numTx",            0, ...  % Кол-во передающих антен
                "numRx",            0, ...  % Кол-во приемных антен
                "numPhasedElemTx",  0, ...  % Кол-во антенных элементов в 1 решетке на передачу
                "numPhasedElemRx",  0, ...  % Кол-во антенных элементов в 1 решетке на прием
                "numUsers",         0, ...  % Кол-во пользователей
                "modulation",       0, ...  % Порядок модуляции
                "freqCarrier",      0, ...  % Частота несущей GHz        
                "numSTSVec",        0, ...  % Кол-во независимых потоков данных на одного пользователя / [2 1 3 2]
                "numSTS",           0, ...  % Кол-во потоков данных; должно быть степени 2: /2/4/8/16/32/64
                "bps",              0, ...  % Кол-во бит на символ в секунду
                "precoderType",     'NOT' ) % Тип прекодера                   
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
                "type",             "", ... % Тип канала 
                "downChannel",      0, ...  % Нисходящий канал
                "upChannel",        0 )     % Восходящий канал            
        %% Параметры симуляции
        simulation = struct(...
                "ber",              0,      ...  % Вероятность битовой ошибки
                "snr",              0,      ...  % Диапазон ОСШ
                "confidenceLevel",  0.95,   ...  % Уровень достоверности
                "coefConfInterval", 1/15 )     % ???
        dataOFDM = 0;
    end    
    methods
        %% Конструктор
        function obj = MassiveMimo(varargin)            
            if (mod(length(varargin),2) ~= 0)
                error("Кол-во параметров констуктора дб четным")
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
            %% Параметры системы
            if (exist('main','var') == 1)
                obj.initMainParam(main)
            else
                obj.initMainParam()
            end
            %% Параметры OFDM
            if (exist('ofdm','var') == 1)
                obj.initOFDMParam(ofdm)
            else
                obj.initOFDMParam()
            end
            %% Параметры канала                
            if (exist('channel','var') == 1)
                obj.initChannelParam(channel)
            else
                obj.initChannelParam()
            end
            %% Параметры симуляции                 
            if (nargin > 6)
                obj.simulation.confidenceLevel = simulation.confidenceLevel;
                obj.simulation.coefConfInterval = simulation.coefConfInterval;
            end
            %% Расчет вычисляемых параметров
            obj.calculateParam();
        end
        %% Методы
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
        
        % Инициализация
        initMainParam(obj, varargin)
        initOFDMParam(obj, varargin)
        initChannelParam(obj, varargin)

        % Графики  
        [figObj] = plotMeanBER(obj, lineStyle, lineWidth, flagSNR, legendStr, varargin)
        [figObj] = plotSTSBER(obj, lineStyle, lineWidth, flagSNR, partLegendStr, varargin)
        [figObj] = plotSpectrOFDM(obj, sampleRate_Hz)
        
        % Симуляция     
        simulate(obj, rangeSNR, maxNumZeroBER, minNumErrs, maxNumSimulation)
        simulateMutCorr(obj, rangeSNR, maxNumZeroBER, minNumErrs, maxNumSimulation, corrMatrix)
        simulateHybrid(obj, rangeSNR, maxNumZeroBER, minNumErrs, maxNumSimulation)
        
        [numErrors, numBits] = simulateOneSNR(obj, snr)       
        [numErrors, numBits] = simulateOneSNRphased(obj, snr) 
        [numErrors, numBits] = simulateOneSNRmutCorr(obj, snr, corrMatrix)
        [numErrors, numBits] = simulateOneSNRhybrid(obj, snr)

    end
end

