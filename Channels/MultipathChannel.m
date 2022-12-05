classdef MultipathChannel < FreqSelectChannel & matlab.System
    properties
        maxNumScatters = [50 100];      % Диапазон рассеивателей
        arrayTx;                        % Передающая решетка
        arrayRx;                        % Принимающая решетка
    end
    properties(Dependent, SetAccess = private)
        channel;                        % Матрица канала
    end
    properties(Dependent, Access = private)
        filter;
    end
    properties(SetAccess = protected)
        At;                             % Матрица отклика антенной решетки относительно углов
    end
    properties(Access = protected)
        seed;
    end    
    %% Constructor, get       
    methods
        % Support name-value pair arguments when constructing object
        function obj = MultipathChannel(varargin)
            obj.getArrays();
            setProperties(obj,nargin,varargin{:})
            obj.seed = randi(1e6);
        end
        function v = get.filter(obj)
            v = comm.internal.channel.ChannelFilter('SampleRate', obj.sampleRate, 'PathDelays', obj.pathDelays);
        end
        function v = get.channel(obj)                        
            v = obj.createChannel();                        
        end
    end
    %%
    methods
        function outputData = pass(obj,inputData)
            numUsers = obj.numUsers;
            outputData = cell(numUsers,1);
            numPath = length(obj.pathDelays);      
            
            channelTmp = cat(2,obj.channel{:});
            channelTmp = permute(channelTmp, [2,1,3]); % obj.channel{i} = numTx, numRx, numPath
            g = reshape(channelTmp, [], obj.numRx, obj.numTx, numPath);
            outputDataTmp = step(obj.filter, inputData, g);
            for i = 1:numUsers
                outputData{i,:} = outputDataTmp(:,i);
            end
        end
    end
    %%
    methods (Access = protected)
        function str = getStrForDisp(obj)
            str = '';
        end
        function channel = createChannel(obj)            
            s = RandStream('mt19937ar','Seed',obj.seed);
            
            numPath = length(obj.pathDelays);            
            power = (10.^(obj.averagePathGains/10));
            
            numUsersLoc = obj.numUsers;      
  
            channel = cell(numUsersLoc,1);
            Ar = cell(numUsersLoc,numPath);
            G = cell(numUsersLoc,numPath);
            At = cell(numUsersLoc,numPath);

            for pIdx = 1:numPath
                % H = At*G*Ar.'
                for uIdx = 1:numUsersLoc
                    numScatters = randi(s,obj.maxNumScatters);
                    % At
                    anglesTx = [360*rand(s,1,numScatters)-180;180*rand(s,1,numScatters)-90];
                    At{uIdx,pIdx} = obj.arrayTx.steervec(anglesTx);                   
                    % Ar
                    anglesRx = [360*rand(s,1,numScatters)-180;180*rand(s,1,numScatters)-90];
                    Ar{uIdx,pIdx} = obj.arrayRx{uIdx}.steervec(anglesRx);
                    % G
                    g = 1/sqrt(2)*complex(randn(s,1,numScatters),randn(s,1,numScatters));
                    G{uIdx,pIdx} = diag(g)*power(pIdx);

                    channel{uIdx}(:,:,pIdx) = At{uIdx,pIdx}*G{uIdx,pIdx}*Ar{uIdx,pIdx}.';
                end
            end
            obj.At = At;
        end
        function getArrays(obj)
            arraySize = numTxToarraySize(obj.numTx);
            obj.arrayTx = AntArrayURA('arraySize',arraySize);
            
            arRx = cell(obj.numUsers,1);
            for uIdx = 1:obj.numUsers
                arraySize = numTxToarraySize(obj.numRxUsers(uIdx));
                array = AntArrayURA('arraySize',arraySize);
                arRx{uIdx} = array;
            end
            obj.arrayRx = arRx;
        end
    end
end        
function arraySize = numTxToarraySize(numTx)
    tmp = factor(numTx);
    mid = ceil(length(tmp)/2);
    rows = prod(tmp(1:mid));
    columns = prod(tmp(mid+1:end));            
    arraySize = [rows columns];           
end