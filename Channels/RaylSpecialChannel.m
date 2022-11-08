classdef RaylSpecialChannel < RaylChannel
    properties
        seed = 95;  % Сид для ГПСЧ канала
    end
    %% Constructor, get  
    methods
        % Support name-value pair arguments when constructing object
        function obj = RaylSpecialChannel(varargin)
            setProperties(obj,nargin,varargin{:})
        end
    end
    %%
    methods (Access = protected)
        % Создание канала 
        function channel = createChannel(obj,numRx,seed)
            channel = comm.MIMOChannel(...
                    'SampleRate',                       obj.sampleRate,             ...
                    'PathDelays',                       obj.pathDelays,             ...
                    'AveragePathGains',                 obj.averagePathGains,       ...
                    'MaximumDopplerShift',              0,                          ...
                    'SpatialCorrelationSpecification',  'None',                     ... 
                    'NumTransmitAntennas',              obj.numTx,                  ...
                    'NumReceiveAntennas',               numRx,                      ...
                    'RandomStream',                     'mt19937ar with seed',      ...
                    'Seed',                             seed,                       ... 
                    'PathGainsOutputPort',              true);
        end
        
        % Создание многопользовательского канала 
        function muChannel = createMuChannel(obj)
            numUsers = obj.numUsers;
            numRxUsers = obj.numRxUsers;
            muChannel = cell(numUsers,1);
            seedTmp = obj.seed;
            for i = 1:numUsers
                muChannel{i} = obj.createChannel(numRxUsers(i), seedTmp);
                seedTmp = seedTmp + 1;
            end
        end
        
        function str = getStrForDisp(obj)
            str = getStrForDisp@RaylChannel(obj);
            str = [str 'seed: ' num2str(obj.seed) '; '];              
        end
    end    
end

