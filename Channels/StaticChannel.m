classdef StaticChannel < Channel & matlab.System     
    properties (SetAccess = private)
        channel;     % Матрица канала
    end
    %% Constructor, get     
    methods
        % Support name-value pair arguments when constructing object
        function obj = StaticChannel(varargin)
            setProperties(obj,nargin,varargin{:})
            channel = cell(obj.numUsers,1);
            for uIdx = 1:obj.numUsers
                channel{uIdx,:} = obj.createChannel(obj.numRxUsers(uIdx));
            end
            obj.channel = channel;
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
    end
    %%
    methods (Access = private)
        function [channel] = createChannel(obj,numRx)
            channel = zeros(obj.numTx, numRx);
            for i = 1:obj.numTx
                for j = 1:numRx           
                    channel(i,j) = (randn(1)+1i*randn(1))/sqrt(2);
                end
            end
        end
    end
    
end

