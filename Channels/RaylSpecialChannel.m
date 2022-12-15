classdef RaylSpecialChannel < RaylChannel
    properties (SetAccess = private)
        seed = 95;  % Сид для ГПСЧ канала
    end
    %% Constructor, get  
    methods
        % Support name-value pair arguments when constructing object
        function obj = RaylSpecialChannel(args)
            arguments
                args.seed = 95;
                args.chconf = ChannelConfig();
                args.sysconf = SystemConfig();
            end
            obj@RaylChannel('sysconf',args.sysconf,'chconf',args.chconf)
            obj.seed = args.seed;
        end
    end
    %%
    methods (Access = protected)
        % Создание многопользовательского канала 
        function muChannel = createMuChannel(obj)
            numUsers = obj.sysconf.numUsers;
            numRxUsers = obj.sysconf.numRxUsers;

            muChannel = cell(numUsers,1);
            seedTmp = obj.seed;
            for i = 1:numUsers
                muChannel{i} = obj.createChannel(numRxUsers(i),seedTmp);
                seedTmp = seedTmp + 1;
            end
        end
        % Создание канала 
        function channel = createChannel(obj,numRx,seed)
            channel = comm.MIMOChannel(...
                    'SampleRate',                       obj.chconf.sampleRate,              ...
                    'PathDelays',                       obj.chconf.pathDelays,              ...
                    'AveragePathGains',                 obj.chconf.avgPathGains_dB,         ...
                    'MaximumDopplerShift',              0,                                  ...
                    'SpatialCorrelationSpecification',  'None',                             ... 
                    'NumTransmitAntennas',              obj.sysconf.numTx,                  ...
                    'NumReceiveAntennas',               numRx,                              ...
                    'RandomStream',                     'mt19937ar with seed',              ...
                    'Seed',                             seed,                               ... 
                    'PathGainsOutputPort',              true);
        end
                
        function str = getStrForDisp(obj)
            str = getStrForDisp@RaylChannel(obj);
            str = [str 'seed: ' num2str(obj.seed) '; '];              
        end
    end    
end

