classdef StaticMultipathChannel < StaticLOSChannel  
    properties
        maxNumScatters = [50 100];    % Диапазон рассеивателей
    end
    %% Constructor, get       
    methods
        % Support name-value pair arguments when constructing object
        function obj = StaticMultipathChannel(varargin)
            setProperties(obj,nargin,varargin{:})
        end
    end
    %%
    methods (Access = protected)
        function channel = createChannel(obj)            
            numUsersLoc = obj.numUsers;
            
            channel = cell(numUsersLoc,1);
            Ar = cell(numUsersLoc,1); G = cell(numUsersLoc,1); At = cell(numUsersLoc,1);
            obj.anglesTx = cell(numUsersLoc,1);
            obj.anglesRx = cell(numUsersLoc,1);
            numScatters = cell(numUsersLoc,1);

            % H = At*G*Ar.'
            for uIdx = 1:numUsersLoc
                numScatters{uIdx} = randi(obj.maxNumScatters);
                % At        
                if isscalar(obj.posArrayTx)
                    At{uIdx} = ones(1,numScatters{uIdx});
                else
                    obj.anglesTx{uIdx} = [360*rand(1,numScatters{uIdx})-180;180*rand(1,numScatters{uIdx})-90];
                    At{uIdx} = steervec(obj.posArrayTx,obj.anglesTx{uIdx});
                end
                % Ar
                if isscalar(obj.posArrayRx)
                    Ar{uIdx} = ones(1,numScatters{uIdx});
                else
                    obj.anglesRx{uIdx} = [360*rand(1,numScatters{uIdx})-180;180*rand(1,numScatters{uIdx})-90];
                    Ar{uIdx} = steervec(obj.posArrayRx,obj.anglesRx{uIdx});  
                end
                % G
                g = 1/sqrt(2)*complex(randn(1,numScatters{uIdx}),randn(1,numScatters{uIdx}));
                G{uIdx} = diag(g);

                channel{uIdx} = At{uIdx}*G{uIdx}*Ar{uIdx}.';
            end
            
        end
    end
end

