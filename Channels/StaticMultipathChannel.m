classdef StaticMultipathChannel < StaticLOSChannel  
    properties
        maxNumScatters = [50 100];      % Диапазон рассеивателей
        sampleRate = 40e6;              % Частота дискретизации
        averagePathGains = [-3 -9 -12]; % Средние коэффициенты усиления пути в Дб
        tau = [2 5 7];                  % Точки задержек пути 
    end
    properties (Dependent, SetAccess = private)
        pathDelays;                     % Задержки пути
        dt;                             % Шаг во временной области
        filter;
    end
    %% Constructor, get       
    methods
        % Support name-value pair arguments when constructing object
        function obj = StaticMultipathChannel(varargin)
            setProperties(obj,nargin,varargin{:})
        end
        function v = get.dt(obj)
            v = 1 / obj.sampleRate;
        end
        function v = get.pathDelays(obj)
            v = obj.tau * obj.dt;
        end
        function v = get.filter(obj)
            v = comm.internal.channel.ChannelFilter('SampleRate', obj.sampleRate, 'PathDelays', obj.pathDelays);
        end
    end
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
        function channel = createChannel(obj)            
            s = RandStream('mt19937ar','Seed',obj.seed);
            
            numUsersLoc = obj.numUsers;
            
            channel = cell(numUsersLoc,1);

            obj.anglesTx = cell(numUsersLoc,1);
            obj.anglesRx = cell(numUsersLoc,1);
            numScatters = cell(numUsersLoc,1);
            
            power = (10.^(obj.averagePathGains/10));
            numPath = length(obj.pathDelays);
            

            for pIdx = 1:numPath
                Ar = cell(numUsersLoc,1); G = cell(numUsersLoc,1); At = cell(numUsersLoc,1);
                % H = At*G*Ar.'
                for uIdx = 1:numUsersLoc
                    numScatters{uIdx} = randi(s,obj.maxNumScatters);
                    % At        
                    if isscalar(obj.posArrayTx)
                        At{uIdx} = ones(1,numScatters{uIdx});
                    else
                        obj.anglesTx{uIdx} = [360*rand(s,1,numScatters{uIdx})-180;180*rand(s,1,numScatters{uIdx})-90];
                        At{uIdx} = steervec(obj.posArrayTx,obj.anglesTx{uIdx});
                    end
                    % Ar
                    if isscalar(obj.posArrayRx)
                        Ar{uIdx} = ones(1,numScatters{uIdx});
                    else
                        obj.anglesRx{uIdx} = [360*rand(s,1,numScatters{uIdx})-180;180*rand(s,1,numScatters{uIdx})-90];
                        Ar{uIdx} = steervec(obj.posArrayRx,obj.anglesRx{uIdx});  
                    end
                    % G
                    g = 1/sqrt(2)*complex(randn(s,1,numScatters{uIdx}),randn(s,1,numScatters{uIdx}));
                    G{uIdx} = diag(g)*power(pIdx);

                    channel{uIdx}(:,:,pIdx) = At{uIdx}*G{uIdx}*Ar{uIdx}.';
                end
            end            
        end
    end
end
