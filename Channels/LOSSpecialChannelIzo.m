classdef LOSSpecialChannelIzo < LOSChannel   
    %% Constructor, get         
    methods
        % Support name-value pair arguments when constructing object        
        function obj = LOSSpecialChannelIzo(args)
            arguments
                args.anglesTx = {[-65;-1]; [-25;2]; [37;3]; [70;-5];};
                args.chconf = ChannelConfig();
                args.sysconf = SystemConfig();
            end
            obj@LOSChannel('sysconf',args.sysconf,'chconf',args.chconf,'anglesTx',args.anglesTx);    
        end
    end
    %%
    methods(Access = protected)       
        function channel = createChannel(obj)
            numUsers = obj.sysconf.numUsers;
            anglesTxLoc = obj.anglesTx;

            channel = cell(numUsers,1);
            Ar = cell(numUsers,1);
            G = cell(numUsers,1);
            At = cell(numUsers,1);
            
            steerMat = obj.loadSteerinMatrix();

            min = 0.5;
            max = 1;
            % H = At*G*Ar.'
            for uIdx = 1:numUsers
                % At
                index = anglesTxLoc{uIdx}(1) + 91;
                At{uIdx} = steerMat(:,index);             
                % Ar
                Ar{uIdx} = 1;
                % G
%                 g = 1/sqrt(2)*complex(randRange(min,max),randRange(min,max));
                g = obj.getG(uIdx);
                G{uIdx} = diag(g);
                channel{uIdx} = At{uIdx}*G{uIdx}*Ar{uIdx}.';
            end
            obj.At = At;
        end
        function steerMatrix = loadSteerinMatrix(~)
            load('dn/G_is.mat','G_is');            
            steerMatrix = G_is;
        end
        function g = getG(~,uIdx)
            G = [1 1 1 1];
            g = G(uIdx);
        end
    end
end
%%
function x = randRange(min,max)
    x = min+(max-min)*rand;
end
