classdef SimulationConfig
    properties
        snr = 0:35;                         % Диапазон ОСШ
        minNumErrs = 10;                    % Минимальное кол-во ошибок
        maxNumSimulation = 1;               % Максимальное кол-во симуляций
        maxNumZeroBER = 1000;               % Максимально кол-во точек, где BER = 0
        confidenceLevel = 0.95;             % Уровень достоверности
        coefConfInterval = 1/15;            %
    end
    properties (SetAccess = private)
        ber;                                % Вероятность битовой ошибки
        capacity;                           % Пропускная способность
    end
    %% Constructor, set get         
    methods
        % Support name-value pair arguments when constructing object    
        function obj = SimulationConfig(args)
            arguments
                args.snr = 0:35;                         % Диапазон ОСШ
                args.minNumErrs = 10;                    % Порог ошибок для цикла
                args.maxNumSimulation = 1;               % Максимальное число итераций в цикле while 50
                args.maxNumZeroBER = 1000;               % Максимальное кол-во измерений с нулевым кол-вом
                args.confidenceLevel = 0.95;             % Уровень достоверности
                args.coefConfInterval = 1/15;            %  
            end
            obj.snr = args.snr;
            obj.minNumErrs = args.minNumErrs;
            obj.maxNumSimulation = args.maxNumSimulation;
            obj.maxNumZeroBER = args.maxNumZeroBER;
            obj.confidenceLevel = args.confidenceLevel;
            obj.coefConfInterval = args.coefConfInterval;
        end
        function obj = setBer(obj,ber)
            obj.ber = ber;
        end
        function obj = setCapacity(obj,capacity)
            obj.capacity = capacity;
        end
        function numErrors = calculateErrors(~,inpData,outData)
            % inpData, outData - входные и выходные данные размерностью [numBits, numSTS]
            % numBits - кол-во бит
            % numSTS - кол-во потоков данных;

            % numErrors - кол-во ошибок в numBits
            numSTS = size(inpData,2);
            numErrors = zeros(1,numSTS);            
            for i = 1:numSTS
                numErrors(i) = sum(abs(outData(:,i) - inpData(:,i)));
            end            
        end
        function [berconf,lengthConfInterval] = calculateBER(obj,numErrors,numBits,numSTS)
            % obj.main.numSTS - кол-во потоков данных
            % numErrors - кол-во ошибок;
            % numBits - кол-во бит

            % berconf - BER
            % lengthConfInterval - длина доверительного интервала
            % confidenceLevel - % уровень достоверности

            confLvl = obj.confidenceLevel;

            confidenceInterval = zeros(2, numSTS);
            lengthConfInterval = zeros(1, numSTS);
            berconf = zeros(1, numSTS);

            for i = 1:numSTS
                [berconf(i), confidenceInterval(:,i)] = berconfint(numErrors(i), numBits, confLvl);
                lengthConfInterval(i) = confidenceInterval(2,i) - confidenceInterval(1,i);
            end
        end
    end
end

