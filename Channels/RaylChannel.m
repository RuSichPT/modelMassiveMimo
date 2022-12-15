classdef RaylChannel < Channel
    properties (SetAccess = private)
        chconf ChannelConfig            % Канальная конфигурация
        channel;                        % Объект канала
    end
    %% Constructor, get  
    methods
        % Support name-value pair arguments when constructing object
        function obj = RaylChannel(args)
            arguments
                args.chconf = ChannelConfig();
                args.sysconf = SystemConfig();
            end
            obj@Channel('sysconf',args.sysconf)            
            obj.chconf = args.chconf;
        end
    end
    %%
    methods        
        function outputData = pass(obj,inputData)
            numUsers = obj.sysconf.numUsers;

            outputData = cell(numUsers,1);
            H = cell(numUsers,1);
            for i = 1:numUsers
                channelTmp = obj.channel{i,:};
                [outputData{i,:}, H{i}] = channelTmp(inputData);
            end
        end
        function create(obj)
            obj.channel = obj.createMuChannel();
        end
    end
    %%
    methods (Access = protected)
        % Создание многопользовательского канала
        function muChannel = createMuChannel(obj)
            numUsers = obj.sysconf.numUsers;
            numRxUsers = obj.sysconf.numRxUsers;

            muChannel = cell(numUsers,1);
            for i = 1:numUsers
                muChannel{i} = obj.createChannel(numRxUsers(i));
            end
        end
        
        % Создание канала 
        function channel = createChannel(obj,numRx) 
            channel = comm.MIMOChannel(...
                    'SampleRate',                       obj.chconf.sampleRate,          ...
                    'PathDelays',                       obj.chconf.pathDelays,          ...
                    'AveragePathGains',                 obj.chconf.avgPathGains_dB,     ...
                    'MaximumDopplerShift',              0,                              ...
                    'SpatialCorrelationSpecification',  'None',                         ... 
                    'NumTransmitAntennas',              obj.sysconf.numTx,              ...
                    'NumReceiveAntennas',               numRx,                          ...
                    'PathGainsOutputPort',              true);
        end

        
        function str = getStrForDisp(obj)
            str = ['sampleRate: ' num2str(obj.chconf.sampleRate) '; '];
            str = [str 'tau: ' num2str(obj.chconf.tau) '; '];
            str = [str 'averagePathGains: ' num2str(obj.chconf.avgPathGains_dB) '; '];                
        end
    end
end

