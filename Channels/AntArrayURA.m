classdef AntArrayURA    
    properties
        fc = 30e9;          % Несущая частота
        arraySize = [8 4];  % Размер решетки [строки столбцы]
    end
    properties(Dependent, SetAccess = private)
        lambda;             % Длина волны
        elemSpacing;        % Расстояние между элементами
        array;              % Решетка
    end
    %% Constructor, get         
    methods
        function obj = AntArrayURA(args)
            arguments
                args.fc = 30e9;
                args.arraySize = [8 4];
            end
            obj.fc = args.fc;
            if (args.arraySize(1) == 1) && (args.arraySize(2) == 1) 
                obj.arraySize = 1;
            else
                obj.arraySize = args.arraySize;  
            end
        end
        function v = get.lambda(obj)
            cLight = physconst('LightSpeed');
            v = cLight/obj.fc;
        end
        function v = get.elemSpacing(obj)
            if obj.arraySize == 1 
                v = 1;
            else
                v = [0.5 0.5]*obj.lambda;
            end
        end
        function v = get.array(obj)
            elem = phased.IsotropicAntennaElement;
            if obj.arraySize == 1 
                v = elem;
            else
                v = phased.URA('Size',obj.arraySize,'ElementSpacing',obj.elemSpacing,'Element',elem);
            end

        end
    end
    %%
    methods
        % 1-by-M vector or a 2-by-M matrix,
        % where M is the number of incoming signals.
        % If ang is a 2-by-M matrix, then [az;el].
        % If ang is a 1-by-M matrix, then [az;0].
        function w = steervec(obj,angles)
            numIncSign = size(angles,2);
            if obj.arraySize == 1  
                w = ones(1,numIncSign);
            else
               % Позиции элементов решетки
                posArray = getElementPosition(obj.array)/obj.lambda;
                w = steervec(posArray,angles); 
            end
        end
    end
end

