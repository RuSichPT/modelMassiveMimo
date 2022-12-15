classdef ChannelForNeuralNet < Channel
    properties (SetAccess = private)
        channel;     % Матрица канала
    end
    %% Constructor, get
    methods
        % Support name-value pair arguments when constructing object
        function obj = ChannelForNeuralNet(args)
            arguments
                args.sysconf = SystemConfig();
            end
            if args.sysconf.numTx ~= 16
                error('Должно быть numTx = 16');
            end
            obj@Channel('sysconf',args.sysconf);
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
%             load('DataBase/NeuralNetwork/H_I.txt'); %pwd
%             load('DataBase/NeuralNetwork/H_Q.txt');
            load('H_real.txt', 'H_real');
            load('H_imag.txt', 'H_imag');
            
            H_I = H_real;
            H_Q = H_imag;
            
            H = H_I+1i*H_Q;
            H = H';           
                        
            numUsers = obj.sysconf.numUsers;
            chan = cell(obj.sysconf.numUsers,1);
            
            if numUsers == 1
                chan{1,:} = H;
            else
                for uIdx = 1:numUsers
                    chan{uIdx,:} = H(:,uIdx);
                end
            end

            obj.channel = chan;
        end
    end
    %%
    methods (Access = protected)
        function str = getStrForDisp(obj)
            str = '';
        end
    end
end

