classdef (Abstract) Channel < handle
    properties (SetAccess = private)
        sysconf SystemConfig;  % Системная конфигурация
    end
    %%
    methods
        % Support name-value pair arguments when constructing object 
        function obj = Channel(args)
            arguments
                args.sysconf = SystemConfig();
            end
            obj.sysconf = args.sysconf ;
        end
    end    
    %%
    methods (Abstract = true)
        pass(obj,inputData);
    end    
    methods (Abstract = true)
        create(obj);
    end
    methods (Abstract = true, Access = protected)
        getStrForDisp(obj);
    end
    methods
        function dispChannel(obj)
            str = ['\n' class(obj) ': \n'];
            str = [str obj.getStrForDisp()];
            str = [str '\n'];
            fprintf(str);
        end 
    end
end

