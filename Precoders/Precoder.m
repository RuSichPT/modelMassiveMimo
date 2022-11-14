classdef Precoder < handle
    
    properties
        type;               % Тип прекодера
        F;                  % Коэффициенты прекодирования 
    end
    
    properties(Access = private)
        numSC;              % Кол-во поднессущих
        numTx;              % Кол-во передающих антен
        numSTS;             % Кол-во потоков данных
        numOFDM;            % Кол-во символов OFDM от каждой антенны
    end
    
    %% Constructor, get
    methods
        % Hest - оценка канала размерностью [numSC,numTx,numSTS]
        function obj = Precoder(Hest)
            obj.numSC = size(Hest,1);
            obj.numTx = size(Hest,2);
            obj.numSTS = size(Hest,3);
            obj.calcPrecodWeights(Hest);
        end    
    end
    %%
    methods
        function outData = apply(obj,inData)            
            % inData - входные данные размерностью [numSC,numOFDM,numSTS]
            % outData - выходные данные размерностью [numSC,numOFDM,numTx]              
            obj.numOFDM = size(inData, 2);
            outData = zeros(obj.numSC, obj.numOFDM, obj.numTx);

            for i = 1:obj.numSC 
                outData(i,:,:) = squeeze(inData(i,:,:))*squeeze(obj.F(i,:,:));       
            end             
        end
    end
    %%
    methods (Access = private)
        function calcPrecodWeights(obj,Hest)
            precodWeights = zeros(obj.numSC, obj.numSTS, obj.numTx);
            for i = 1:obj.numSC 
                precodWeights(i,:,:) = squeeze(Hest(i,:,:))';     
            end
            obj.F = precodWeights;
        end
    end
end


