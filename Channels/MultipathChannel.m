classdef MultipathChannel < Channel
    properties (SetAccess = private)
        maxNumScatters = [50 100];      % Диапазон рассеивателей
        chconf ChannelConfig            % Канальная конфигурация
        arrayTx AntArrayURA             % Передающая решетка
        arrayRx cell                    % Приемная решетка
        channel;                        % Матрица канала
    end
    properties(SetAccess = protected)
        At;                             % Матрица отклика антенной решетки относительно углов
    end
    %% Constructor, get       
    methods
        % Support name-value pair arguments when constructing object
        function obj = MultipathChannel(args)
            arguments
                args.maxNumScatters = [50 100];
                args.chconf = ChannelConfig();
                args.sysconf = SystemConfig();
            end
            obj@Channel('sysconf',args.sysconf)
            
            obj.maxNumScatters = args.maxNumScatters; 
            obj.chconf = args.chconf;
            obj.arrayTx = obj.getArrayTx();
            obj.arrayRx = obj.getArrayRx();            
        end
    end
    %%
    methods
        function outputData = pass(obj,inputData)
            numUsers = obj.sysconf.numUsers;
            pathDelays = obj.chconf.pathDelays;
            numRxUsers = obj.sysconf.numRxUsers;
            
            numPath = length(pathDelays);            
         
            channelTmp = cat(2,obj.channel{:});
            channelTmp = permute(channelTmp, [2,1,3]); % obj.channel{i} = numTx, numRx, numPath
            g = reshape(channelTmp, [], obj.sysconf.numRx, obj.sysconf.numTx, numPath);
            filter = comm.internal.channel.ChannelFilter('SampleRate', obj.chconf.sampleRate, 'PathDelays', pathDelays);
            outputDataTmp = step(filter, inputData, g);
            
            outputData = cell(numUsers,1); 
            for uIdx = 1:numUsers
                rxU = numRxUsers(uIdx);
                rxIdx = sum(numRxUsers(1:(uIdx-1)))+(1:rxU);
                outputData{uIdx,:} = outputDataTmp(:,rxIdx);
            end
        end
        function create(obj)
            obj.channel = obj.createChannel();
        end
    end
    %%
    methods (Access = protected)
        function str = getStrForDisp(obj)
            str = '';
        end
        function channel = createChannel(obj)            
            numPath = length(obj.chconf.pathDelays);            
            power = (10.^(obj.chconf.avgPathGains_dB/10));
            
            numUsers = obj.sysconf.numUsers;      
            channel = cell(numUsers,1);
            Ar = cell(numUsers,numPath);
            G = cell(numUsers,numPath);
            AtTemp = cell(numUsers,numPath);

            for pIdx = 1:numPath
                % H = At*G*Ar.'
                for uIdx = 1:numUsers
                    numScatters = randi(obj.maxNumScatters);
                    % At
                    anglesTx = [360*rand(1,numScatters)-180;180*rand(1,numScatters)-90];
                    AtTemp{uIdx,pIdx} = obj.arrayTx.steervec(anglesTx);                   
                    % Ar
                    anglesRx = [360*rand(1,numScatters)-180;180*rand(1,numScatters)-90];
                    Ar{uIdx,pIdx} = obj.arrayRx{uIdx}.steervec(anglesRx);
                    % G
                    g = 1/sqrt(2)*complex(randn(1,numScatters),randn(1,numScatters));
                    G{uIdx,pIdx} = diag(g)*power(pIdx);

                    channel{uIdx}(:,:,pIdx) = AtTemp{uIdx,pIdx}*G{uIdx,pIdx}*Ar{uIdx,pIdx}.';
                end
            end
            obj.At = AtTemp;
        end
        function array = getArrayTx(obj)
            arraySize = obj.numTxToarraySize(obj.sysconf.numTx);
            array = AntArrayURA('arraySize',arraySize);
        end
        function array = getArrayRx(obj)
            numUsers = obj.sysconf.numUsers;
            
            arRx = cell(numUsers,1);
            for uIdx = 1:numUsers
                arraySize = obj.numTxToarraySize(obj.sysconf.numRxUsers(uIdx));
                array = AntArrayURA('arraySize',arraySize);
                arRx{uIdx} = array;
            end
            array = arRx;
        end
        function arraySize = numTxToarraySize(~,numTx)
            tmp = factor(numTx);
            mid = ceil(length(tmp)/2);
            rows = prod(tmp(1:mid));
            columns = prod(tmp(mid+1:end));            
            arraySize = [rows columns];           
        end
    end
end        

