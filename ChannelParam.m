classdef ChannelParam   
    properties
        type;                   % Тип канала
        sampleRate;             % Частота дискретизации
        averagePathGains;       % Средние коэффициенты усиления пути в Дб
        tau;                    % Точки задержек пути 
    end
    properties (Dependent, SetAccess = private)
        pathDelays;         % Задержки пути
        dt;                 % Шаг во временной области
    end
    %% Constructor, get
    methods
        % Support name-value pair arguments when constructing object
        function obj = ChannelParam(args)
            arguments
                args.type = 'RaylSpecialChannel'         % Тип канала
                args.sampleRate = 40e6;                  % Частота дискретизации
                args.averagePathGains = [-3 -9 -12];     % Средние коэффициенты усиления пути в Дб
                args.tau = [2 5 7];                      % Точки задержек пути 
            end
            obj.type = args.type;                  
            obj.sampleRate = args.sampleRate;             
            obj.averagePathGains = args.averagePathGains;       
            obj.tau = args.tau;                     
        end
        function v = get.dt(obj)
            v = 1 / obj.sampleRate;
        end
        function v = get.pathDelays(obj)
            v = obj.tau * obj.dt;
        end
    end
end

