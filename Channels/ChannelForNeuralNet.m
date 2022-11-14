classdef ChannelForNeuralNet < Channel & matlab.System 
    properties (SetAccess = private)
        channel;     % Матрица канала
    end
    %% Constructor, get     
    methods
        % Support name-value pair arguments when constructing object
        function obj = ChannelForNeuralNet(varargin)
            setProperties(obj,nargin,varargin{:})
%             load('DataBase/NeuralNetwork/H_I.txt'); %pwd
%             load('DataBase/NeuralNetwork/H_Q.txt');
            load('Verification/H_real.txt', 'H_real');
            load('Verification/H_imag.txt', 'H_imag');
            H_I = H_real;
            H_Q = H_imag;
            
            H = H_I+1i*H_Q;
            H = H';           
                        
            obj.numUsers = 1;
            channel = cell(obj.numUsers,1);
            
            if obj.numUsers == 1
                channel{1,:} = H;
            else
                for uIdx = 1:obj.numUsers
                    channel{uIdx,:} = H(:,uIdx);
                end
            end

            obj.channel = channel;
            obj.numTx = 16;
            obj.numRxUsers = [1 1 1 1];
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
end

