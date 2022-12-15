classdef ChannelConfig 
    properties (SetAccess = private)
        sampleRate = 40e6;              % Частота дискретизации
        avgPathGains_dB = [-3 -9 -12];  % Средние коэффициенты усиления пути в дБ
        tau = [2 5 7];                  % Точки задержек пути 
    end
    properties (Dependent, SetAccess = private)
        pathDelays;         % Задержки пути
        dt;                 % Шаг во временной области
    end
    %% Constructor, get
    methods
        % Support name-value pair arguments when constructing object
        function obj = ChannelConfig(args)
            arguments
                args.sampleRate = 40e6;                  
                args.avgPathGains_dB = [-3 -9 -12];       
                args.tau = [2 5 7];                     
            end
            obj.check(args);
            obj.sampleRate = args.sampleRate;             
            obj.avgPathGains_dB = args.avgPathGains_dB;       
            obj.tau = args.tau;                     
        end
        function v = get.dt(obj)
            v = 1 / obj.sampleRate;
        end
        function v = get.pathDelays(obj)
            v = obj.tau * obj.dt;
        end
    end
    %%
    methods (Access = private)
        function check(~,args)
            if length(args.avgPathGains_dB) ~= length(args.tau) 
                error('Неправильный размер, должно быть length(avgPathGains_dB) == length(tau).');
            end
        end
    end
end

