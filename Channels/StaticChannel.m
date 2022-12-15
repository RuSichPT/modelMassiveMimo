classdef StaticChannel < Channel
    properties (SetAccess = private)
        channel;     % Матрица канала
    end
    %% Constructor, get     
    methods
        % Support name-value pair arguments when constructing object
        function obj = StaticChannel(args)
            arguments
                args.sysconf = SystemConfig();
            end
            obj@Channel('sysconf',args.sysconf)
        end
    end
    %%
    methods
        function outputData = pass(obj,inputData)
            numUsers = obj.sysconf.numUsers;
            outputData = cell(numUsers,1);
            for i = 1:numUsers
                channelTmp = obj.channel{i,:};
                outputData{i,:} = inputData*channelTmp; 
            end
        end
        function create(obj)
            obj.channel = obj.createMuChannel();
        end
    end
    %%
    methods (Access = protected)
        function str = getStrForDisp(obj)
            str = '';
        end
        
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
        function [channel] = createChannel(obj,numRx)
            numTx = obj.sysconf.numTx;
            
            channel = zeros(numTx, numRx);
            for i = 1:numTx
                for j = 1:numRx           
                    channel(i,j) = (randn(1)+1i*randn(1))/sqrt(2);
                end
            end
        end

    end
    
end

