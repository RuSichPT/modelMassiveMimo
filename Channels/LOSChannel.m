classdef LOSChannel < MultipathChannel   
    properties
        anglesTx = {[-65;0]; [-25;0]; [37;0]; [70;0];};     %[azimuth;elevation]
    end
    properties(Dependent, SetAccess = private)
        anglesRx;       %[azimuth;elevation]
    end
    %% Constructor, get         
    methods
        % Support name-value pair arguments when constructing object        
        function obj = LOSChannel(varargin)
            obj@MultipathChannel('sampleRate',1,'averagePathGains',0,'tau',0);
            setProperties(obj,nargin,varargin{:})
%             obj.checkParam();
        end
        function v = get.anglesRx(obj)
            angRx = cell(obj.numUsers,1);
            for uIdx = 1:length(obj.anglesTx)
                angRx{uIdx} = obj.anglesTx{uIdx}+180;
            end
            v = angRx;
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
    methods(Access = protected)       
        function channel = createChannel(obj)
            s = RandStream('mt19937ar','Seed',obj.seed);
            
            numUsersLoc = obj.numUsers;
            anglesTxLoc = obj.anglesTx;
            anglesRxLoc = obj.anglesRx;

            channel = cell(numUsersLoc,1);
            Ar = cell(numUsersLoc,1); G = cell(numUsersLoc,1); At = cell(numUsersLoc,1);
                        
            % H = At*G*Ar.'
            for uIdx = 1:numUsersLoc
                numScatters = size(anglesTxLoc{uIdx},2);
                % At   
                At{uIdx} = obj.arrayTx.steervec(anglesTxLoc{uIdx});
                % Ar
                Ar{uIdx} = obj.arrayRx{uIdx}.steervec(anglesRxLoc{uIdx});
                % G
                g = 1/sqrt(2)*complex(randn(s,1,numScatters),randn(s,1,numScatters));
                G{uIdx} = diag(g);
                channel{uIdx} = At{uIdx}*G{uIdx}*Ar{uIdx}.';
            end
            obj.At = At;
        end
%         function checkParam(obj)
%             if obj.numUsers ~= length(obj.anglesTx)
%                 error('Количество numUsers не совпадает c length(anglesTx)');
%             end
%             if obj.arraySizeTx(1)*obj.arraySizeTx(2) ~= obj.numTx
%                 error('Количество numTx не совпадает c numColumnsTx*numRowsTx');
%             end
%         end
    end
end
