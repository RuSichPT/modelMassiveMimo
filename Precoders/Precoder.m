classdef (Abstract)Precoder < handle 
    
    properties(SetAccess = private)
        type;               % Тип прекодера
        system;             % Системные параметры
    end
    %% Constructor, get
    methods
        function obj = Precoder(type,system)
            obj.type = type;
            obj.system = system;
        end    
    end
    %%
    methods (Access = protected)
        function outData = applyPrecod(~,inData,F)            
            % inData - входные данные размерностью [numSC,numOFDM,numSTS]
            % outData - выходные данные размерностью [numSC,numOFDM,numTx]
            % F - коэффициенты прекодирования [numSC,numOFDM,numTx]
            numSC = size(inData,1);     % кол-во поднессущих
            numOFDM = size(inData,2);   % кол-во символов OFDM от каждой антенны
            
            outData = zeros(numSC,numOFDM,size(F,3));
            
            if size(F,2) ~= size(inData,3)
                str = ['Не совпадают размерности данных и прекодирующих коэффициентов '...
                    num2str(size(F,2)) '!=' num2str(size(inData,3))];
                error(str);
            end
            
            % Кодируем
            for i = 1:numSC
                sqF = reshape(F(i,:,:),size(F,2),size(F,3));
                sqData = reshape(inData(i,:,:),size(inData,2),size(inData,3));
                outData(i,:,:) = sqData*sqF;       
            end             
        end       
    end
end

