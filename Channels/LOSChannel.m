classdef LOSChannel < MultipathChannel   
    properties (SetAccess = private)
        anglesTx cell = {[-65;-1]; [-25;2]; [37;3]; [70;-5];};     %[azimuth;elevation]
        anglesRx cell; %[azimuth;elevation]
    end
    %% Constructor, get
    methods
        % Support name-value pair arguments when constructing object        
        function obj = LOSChannel(args)
            arguments
                args.anglesTx = {[-65;-1]; [-25;2]; [37;3]; [70;-5];};
                args.anglesRx = 0;
                args.chconf = ChannelConfig();
                args.sysconf = SystemConfig();
            end
            obj@MultipathChannel('sysconf',args.sysconf,'chconf',args.chconf); 
            if args.anglesRx == 0
                args.anglesRx = getAnglesRx(args.anglesTx);
            end
            obj.check(args);
            obj.anglesTx = args.anglesTx;
            obj.anglesRx = args.anglesRx;
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
    end
    %%
    methods(Access = protected)       
        function channel = createChannel(obj)
            numUsers = obj.sysconf.numUsers;
            anglesTxLoc = obj.anglesTx;
            anglesRxLoc = obj.anglesRx;

            channel = cell(numUsers,1);
            Ar = cell(numUsers,1);
            G = cell(numUsers,1);
            At = cell(numUsers,1);
                        
            % H = At*G*Ar.'
            for uIdx = 1:numUsers
                numScatters = size(anglesTxLoc{uIdx},2);
                % At   
                At{uIdx} = obj.arrayTx.steervec(anglesTxLoc{uIdx});
                % Ar
                Ar{uIdx} = obj.arrayRx{uIdx}.steervec(anglesRxLoc{uIdx});
                % G
                g = 1/sqrt(2)*complex(randn(1,numScatters),randn(1,numScatters));
                G{uIdx} = diag(g);
                channel{uIdx} = At{uIdx}*G{uIdx}*Ar{uIdx}.';
            end
            obj.At = At;
        end
        function check(obj,args)            
            if length(args.anglesTx) ~=  obj.sysconf.numUsers
                error('Неправильный размер, должно быть length(anglesTx) == numUsers.');
            end
            
            if length(args.anglesRx) ~= obj.sysconf.numUsers
                error('Неправильный размер, должно быть length(anglesRx) == numUsers.');
            end        
         
        end
    end
end
%%
function v = getAnglesRx(anglesTx)
    numUsers = length(anglesTx);
    angRx = cell(numUsers,1);
    
    for uIdx = 1:numUsers
        az = anglesTx{uIdx}(1,:);
        if az > 0
            angRx{uIdx}(1,:) = az - 180;     % azimuth
        else
            angRx{uIdx}(1,:) = az + 180;     % azimuth
        end
        if size(anglesTx{uIdx},1) > 1
            elev = anglesTx{uIdx}(2,:);

            if elev > 0
                angRx{uIdx}(2,:) = elev - 90;    % elevation                  
            else
                angRx{uIdx}(2,:) = elev + 90;    % elevation    
            end
        end
    end
    v = angRx;
end