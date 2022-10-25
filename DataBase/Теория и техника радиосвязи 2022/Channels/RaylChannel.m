classdef RaylChannel < Channel & matlab.System    
    properties
        sampleRate = 40e6;              % Частота дискретизации
        averagePathGains = [-3 -9 -12]; % Средние коэффициенты усиления пути в Дб
        tau = [2 5 7];                  % Точки задержек пути 
    end  

    properties (Dependent, SetAccess = private)
        pathDelays;                     % Задержки пути
        dt;                             % Шаг во временной области
        channel;                        % Объект канала
    end
    properties(Access = private)
        seed;
    end
    %% Constructor, get  
    methods
        % Support name-value pair arguments when constructing object
        function obj = RaylChannel(varargin)
            setProperties(obj,nargin,varargin{:})
            obj.seed = randi(1e6);
        end
        function v = get.dt(obj)
            v = 1 / obj.sampleRate;
        end
        function v = get.channel(obj)
            rng(obj.seed);
            v = obj.createMuChannel();                               
            rng('shuffle');
        end
        function v = get.pathDelays(obj)
            v = obj.tau * obj.dt;
        end
    end
    %%
    methods        
        function outputData = pass(obj,inputData)
            numUsers = obj.numUsers;
            outputData = cell(numUsers,1);
            H = cell(numUsers,1);
            for i = 1:numUsers
                channelTmp = obj.channel{i,:};
                [outputData{i,:}, H{i}] = channelTmp(inputData);
            end
        end       
    end
    %%
    methods (Access = protected)
        % Создание канала 
        function channel = createChannel(obj, numRx) 
            channel = comm.MIMOChannel(...
                    'SampleRate',                       obj.sampleRate,         ...
                    'PathDelays',                       obj.pathDelays,         ...
                    'AveragePathGains',                 obj.averagePathGains,   ...
                    'MaximumDopplerShift',              0,                      ...
                    'SpatialCorrelationSpecification',  'None',                 ... 
                    'NumTransmitAntennas',              obj.numTx,              ...
                    'NumReceiveAntennas',               numRx,                  ...
                    'PathGainsOutputPort',              true);
        end
        
        % Создание многопользовательского канала 
        function muChannel = createMuChannel(obj)
            numUsers = obj.numUsers;
            numRxUsers = obj.numRxUsers;
            muChannel = cell(numUsers,1);
            for i = 1:numUsers
                muChannel{i} = obj.createChannel(numRxUsers(i));
            end
        end
        
        function str = getStrForDisp(obj)
            str = ['sampleRate: ' num2str(obj.sampleRate) '; '];
            str = [str 'tau: ' num2str(obj.tau) '; '];
            str = [str 'averagePathGains: ' num2str(obj.averagePathGains) '; '];                
        end
    end
end

