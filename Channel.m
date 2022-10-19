classdef (Abstract) Channel < handle
    properties
        numUsers = 4;                   % Кол-во пользователей
        numTx = 32;                     % Кол-во передающих антен
        numRxUsers = [2 2 2 2];         % Кол-во приемных антен на каждого пользователя
    end
    properties (Dependent, SetAccess = private)
        numRx;                          % Кол-во приемных антен
    end
    %%
    methods
        function v = get.numRx(obj)
            v = sum(obj.numRxUsers);
        end
    end    
    %%
    methods (Abstract = true)
        pass(obj);
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

