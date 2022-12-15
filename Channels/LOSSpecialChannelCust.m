classdef LOSSpecialChannelCust < LOSSpecialChannelIzo
    %% Constructor, get         
    methods
        % Support name-value pair arguments when constructing object        
        function obj = LOSSpecialChannelCust(args)
            arguments
                args.anglesTx = {[-65;-1]; [-25;2]; [37;3]; [70;-5];};
                args.chconf = ChannelConfig();
                args.sysconf = SystemConfig();
            end
            obj@LOSSpecialChannelIzo('sysconf',args.sysconf,'chconf',args.chconf,'anglesTx',args.anglesTx);    
        end
    end
    methods(Access = protected)  
        function steerMatrix = loadSteerinMatrix(~)
            load('dn/G_nis.mat','G_nis');            
            steerMatrix = G_nis;
        end
        function g = getG(~,uIdx)
            G = [1 1 1 1];
            g = G(uIdx);
        end
    end
end

