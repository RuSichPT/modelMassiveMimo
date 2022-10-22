classdef StaticChannel < Channel & matlab.System     
    properties (Dependent, SetAccess = private)
        channel;     % Матрица канала
    end
    properties(Access = private)
        seed;
    end
    %% Constructor, get     
    methods
        % Support name-value pair arguments when constructing object
        function obj = StaticChannel(varargin)
            setProperties(obj,nargin,varargin{:})
            obj.seed = randi(1e6);
        end
        function v = get.channel(obj)                        
            rng(obj.seed);
            v = obj.createMuChannel();                      
            rng('shuffle');
        end
    end
    %%
    methods
        function outputData = pass(obj,inputData)
            numUsers = obj.numUsers;
            outputData = cell(numUsers,1);
            for i = 1:numUsers
                channelTmp = obj.channel{i,:};
                outputData{i,:} = inputData*channelTmp; 
            end
        end
    end
    %%
    methods (Access = protected)
        function str = getStrForDisp(obj)
            str = '';
        end      
        
        % Создание канала 
        function [channel] = createChannel(obj,numRx)
            channel = zeros(obj.numTx, numRx);
            for i = 1:obj.numTx
                for j = 1:numRx           
                    channel(i,j) = (randn(1)+1i*randn(1))/sqrt(2);
                end
            end
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
    end
    
end

