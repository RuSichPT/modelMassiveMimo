classdef SystemParam < matlab.System
    
    properties
        numUsers = 4;           % Кол-во пользователей
        numTx = 8;              % Кол-во передающих антен
        numRx;                  % Кол-во приемных антен всего
        numSTSVec;              % Кол-во независимых потоков данных на одного пользователя / [2 1 3 2]        
        modulation = 4;         % Порядок модуляции        
        freqCarrier = 28e9;     % Частота несущей GHz 
        precoderType = 'ZF';    % Тип прекодера
        combainerType = 'NONE'; % Тип комбинера  
    end    
    properties (Dependent, SetAccess = private)
        numSTS;                 % Кол-во потоков данных; должно быть степени 2: /2/4/8/16/32/64
        numRxUsers;             % Кол-во приемных антен на каждого пользователя
        numPhasedElemTx;        % Кол-во антенных элементов в 1 решетке на передачу
        numPhasedElemRx;        % Кол-во антенных элементов в 1 решетке на прием        
        bps;                    % Кол-во бит на символ в секунду
    end
    %% Constructor, get
    methods
        % Support name-value pair arguments when constructing object
        function obj = SystemParam(varargin)
            obj.numRx = obj.numUsers;
            obj.numSTSVec = ones(1, obj.numUsers);
            setProperties(obj,nargin,varargin{:})
        end
        function v = get.numSTS(obj)
            v = sum(obj.numSTSVec);
        end        
        function v = get.numPhasedElemTx(obj)
            v = obj.numTx / obj.numSTS;
        end
        function v = get.numPhasedElemRx(obj)
            v = obj.numRx / obj.numSTS;
        end
        function v = get.bps(obj)
            v = log2(obj.modulation);
        end
        function v = get.numRxUsers(obj)
            v = obj.numSTSVec*obj.numPhasedElemRx;
        end
    end
end

