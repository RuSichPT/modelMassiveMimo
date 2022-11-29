classdef StaticLOSChannel < matlab.System 
    properties
        fc = 30e9;          % Несущая частота
        anglesTx = {[-65;0]; [-25;0]; [37;0]; [70;0];};  %[azimuth;elevation]
        numRows = 8;        
        numColumns = 4;
        posArrayRx = 1;
        anglesRx = [];
    end
    properties(Dependent, SetAccess = private)
        numUsers;       % Кол-во пользователей
        numTx;          % Кол-во передающих антен
        numRx;          % Кол-во приемных антен всего
        numRxUsers;     % Кол-во приемных антен на каждого пользователя
        lambda;         % Длина волны
        elementSpacing; % Расстояние между элементами
        arraySize;      % Размер решетки
        arrayTx;        % Передающая решетка
        posArrayTx;     % Позиции элементов решетки
        channel;        % Матрица канала
    end
    properties(Access = protected)
        seed;
    end
    properties(SetAccess = protected)
        At;         % матрица отклика антенной решетки относительно углов
    end
    %% Constructor, get         
    methods
        % Support name-value pair arguments when constructing object        
        function obj = StaticLOSChannel(varargin)
            setProperties(obj,nargin,varargin{:})
            obj.seed = randi(1e6);
        end
        function v = get.numUsers(obj)
            v = size(obj.anglesTx,1);
        end        
        function v = get.numTx(obj)
            v = obj.numRows*obj.numColumns;
        end
        function v = get.numRx(obj)
            v = obj.numUsers;
        end
        function v = get.numRxUsers(obj)
            v = ones(1,obj.numUsers);
        end
        function v = get.lambda(obj)
            cLight = physconst('LightSpeed');
            v = cLight/obj.fc;
        end  
        function v = get.elementSpacing(obj)
            v = [0.5 0.5]*obj.lambda;
        end
        function v = get.arraySize(obj)
            v = [obj.numRows, obj.numColumns];
        end
        function v = get.arrayTx(obj)
            v = phased.URA('Size',obj.arraySize,...
                            'ElementSpacing',obj.elementSpacing,...
                            'Element',phased.IsotropicAntennaElement);
        end
        function v = get.posArrayTx(obj)
            v = getElementPosition(obj.arrayTx)/obj.lambda;
        end
        function v = get.channel(obj)                        
            v = obj.createChannel();                        
        end
    end
    %%
    methods
        function outputData = pass(obj,inputData)
            numUsersLoc = obj.numUsers;
            outputData = cell(numUsersLoc,1);
            for i = 1:numUsersLoc
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
        
        function channel = createChannel(obj)
            s = RandStream('mt19937ar','Seed',obj.seed);
            
            numUsersLoc = obj.numUsers;
            anglesTxLoc = obj.anglesTx;

            channel = cell(numUsersLoc,1);
            Ar = cell(numUsersLoc,1); G = cell(numUsersLoc,1); At_temp = cell(numUsersLoc,1);
            numScatters = cell(numUsersLoc,1);

            % H = At*G*Ar.'
            for uIdx = 1:numUsersLoc
                numScatters{uIdx} = size(anglesTxLoc{uIdx},2);
                % At   
                At_temp{uIdx} = steervec(obj.posArrayTx,anglesTxLoc{uIdx});
                % Ar
                Ar{uIdx} = ones(1,numScatters{uIdx});
                % G
                g = 1/sqrt(2)*complex(randn(s,1,numScatters{uIdx}),randn(s,1,numScatters{uIdx}));
                G{uIdx} = diag(g);

                channel{uIdx} = At_temp{uIdx}*G{uIdx}*Ar{uIdx}.';
                obj.At{uIdx} = At_temp{uIdx};
            end

        end
    end
end

