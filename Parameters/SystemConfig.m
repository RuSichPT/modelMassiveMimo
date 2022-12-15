classdef SystemConfig
    properties (SetAccess = private)
        numUsers = 4;                       % Кол-во пользователей
        numTx = 32;                         % Кол-во передающих антен
        numRxUsers(1,:) = [1 1 1 1];        % Кол-во принимающих антен у каждого пользователя
        numSTSVec(1,:) = [1 1 1 1];         % Кол-во независимых потоков данных на одного пользователя / [2 1 3 2] 
    end
    properties (Dependent, SetAccess = private)
        numRx;                  % Кол-во приемных антен всего
        numSTS;                 % Кол-во потоков данных; должно быть степени 2: /2/4/8/16/32/64
    end
    %% Constructor, get
    methods
        % Support name-value pair arguments when constructing object
        function obj = SystemConfig(args)
            arguments
                args.numUsers = 4;
                args.numTx = 32;
                args.numRxUsers = [1 1 1 1];
                args.numSTSVec = [1 1 1 1];
            end
            obj.check(args);
            obj.numUsers = args.numUsers;
            obj.numTx = args.numTx;
            obj.numRxUsers = args.numRxUsers;
            obj.numSTSVec = args.numSTSVec;
        end
        function v = get.numRx(obj)
            v = sum(obj.numRxUsers);
        end
        function v = get.numSTS(obj)
            v = sum(obj.numSTSVec);
        end    
    end
    %%
    methods (Access = private)
        function check(~,args)            
            if length(args.numRxUsers) ~= args.numUsers 
                error('Неправильный размер, должно быть length(numRxUsers) == numUsers.');
            end
            
            if length(args.numSTSVec) ~= args.numUsers
                error('Неправильный размер, должно быть length(numSTSVec) == numUsers.');
            end
            
            if sum(args.numSTSVec) > sum(args.numRxUsers)
                error('Должно быть sum(numRxUsers) > sum(numSTSVec).');                
            end
            
            for i = 1:length(args.numRxUsers)
                if args.numRxUsers(i) <= 0
                    error('Должно быть numRxUsers > 0.');   
                end
                if args.numSTSVec(i) <= 0
                    error('Должно быть numSTSVec > 0.');   
                end
            end           
        end
    end
end

