classdef ChannelParam < matlab.System    
    properties
        channelType = 'RaylSpecialChannel'  % Тип канала
        sampleRate = 40e6;                  % Частота дискретизации
        averagePathGains = [-3 -9 -12];     % Средние коэффициенты усиления пути в Дб
        tau = [2 5 7];                      % Точки задержек пути 
    end
    properties (Dependent, SetAccess = private)
        pathDelays;         % Задержки пути
        dt;                 % Шаг во временной области
    end
    %% Constructor, get
    methods
        % Support name-value pair arguments when constructing object
        function obj = ChannelParam(varargin)
            setProperties(obj,nargin,varargin{:})
        end
        function v = get.dt(obj)
            v = 1 / obj.sampleRate;
        end
        function v = get.pathDelays(obj)
            v = obj.tau * obj.dt;
        end
    end
end

