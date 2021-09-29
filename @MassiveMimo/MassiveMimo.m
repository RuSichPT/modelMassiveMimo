classdef MassiveMimo < matlab.mixin.Copyable
    properties
        %% Параметры системы
        numAntenns           % Кол-во антенн в антенной решетке / 12 or 8
        numUsers             % Кол-во пользователей
        modulation           % Порядок модуляции
        freqCarrier          % Частота несущей GHz
        
        numSTSVec            % Кол-во независимых потоков данных на одного пользователя / [2 1 3 2]
        numSTS               % Кол-во потоков данных; должно быть степени 2: /2/4/8/16/32/64
        numAntennsSTS        % Кол-во антенн на один поток данных
        numTx                % Кол-во передающих антен 
        numRx                % Кол-во приемных антен
        bps                  % Кол-во бит на символ в секунду
        precoderType         % Тип прекодера
        %% Параметры OFDM 
        numSubCarriers       % Кол-во поднессущих
        lengthFFT            % Длина FFT для OFDM
        numSymbOFDM          % Кол-во символов OFDM от каждой антенны
        cyclicPrefixLength   % Длина защитных интервалов
               
        nullCarrierIndices   % Длина нулевых интервалов
        %% Параметры канала
        % PHASED_ARRAY_STATIC, PHASED_ARRAY_DYNAMIC
        channelType          % Тип канала 
        H                    % Импульсная характеристика канала
        %% Параметры симуляции
        ber;                            % Вероятность битовой ошибки
        snr;                            % Диапазон ОСШ
        confidenceLevel = 0.95;         % Уровень достоверности
        coefConfInterval = 1/15;        % ??? 
    end
    
    methods
        % Конструктор
        function obj = MassiveMimo(main, ofdm, channel)
            % Параметры системы
            obj.numAntenns = main.numAntenns;     
            obj.numUsers = main.numUsers;
            obj.modulation = main.modulation;
            obj.freqCarrier = main.freqCarrier;
            obj.precoderType = main.precoderType;
            
            % Параметры OFDM 
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

