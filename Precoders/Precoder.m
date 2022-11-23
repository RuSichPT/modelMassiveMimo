classdef Precoder < handle
    
    properties(SetAccess = private)
        type;               % Тип прекодера
        F;                  % Коэффициенты прекодирования 
        system;             % Системные параметры
    end
    
    %% Constructor, get
    methods
        % Hest - оценка канала размерностью [numSC,numTx,numRx]
        function obj = Precoder(type,Hest,system)
            obj.type = type;
            obj.system = system;
            obj.F = obj.calcPrecodWeights(Hest);
        end    
    end
    %%
    methods
        function outData = apply(obj,inData)            
            % inData - входные данные размерностью [numSC,numOFDM,numSTS]
            % outData - выходные данные размерностью [numSC,numOFDM,numTx]
            numSC = size(inData,1);     % кол-во поднессущих
            numOFDM = size(inData,2);   % кол-во символов OFDM от каждой антенны
            
            outData = zeros(numSC,numOFDM,size(obj.F,3));
            
            % Кодируем
            for i = 1:numSC
                sqF = reshape(obj.F(i,:,:),size(obj.F,2),size(obj.F,3));
                sqData = reshape(inData(i,:,:),size(inData,2),size(inData,3));
                outData(i,:,:) = sqData*sqF;       
            end             
        end
    end
    %%
    methods (Access = protected)
        function precodWeights = calcPrecodWeights(obj,Hest)
            numSC = size(Hest,1);     % кол-во поднессущих
            precodWeights = getSizePrecodWeights(obj.type,numSC,obj.system);
                        
            for i = 1:numSC 
                sqHest = reshape(Hest(i,:,:),size(Hest(i,:,:),2),size(Hest(i,:,:),3));
                switch obj.type
                    case {'MF'}
                        precodWeights(i,:,:) = getMF(sqHest);
                    case {'ZF'}
                        precodWeights(i,:,:) = getZF(sqHest);
                    case {'RZF'}
                        precodWeights(i,:,:) = getRZF(sqHest,0,0.01);
                    case {'EBM'}
                        precodWeights(i,:,:) = getEBM(sqHest);
                    case {'DIAG'}
                        if (obj.system.numUsers == 1)
                            precodWeights(i,:,:) = getDIAG_SU(sqHest);
                        else
                            numRxVec = obj.system.numSTSVec * obj.system.numRx/obj.system.numSTS;
                            precodWeights(i,:,:) = getDIAG_MU(sqHest,obj.system.numSTSVec,numRxVec);
                        end
                end
            end
        end
    end
end
% Hest - оценка канала размерностью [numTx,numRx]
function precodWeights = getMF(Hest)
    precodWeights = Hest(:,:)'; 
end
function precodWeights = getZF(Hest)
    precodWeights =  (Hest'*Hest) \ Hest';
end
function precodWeights = getRZF(Hest,ermitMat,lambda)
    numSTS = size(Hest,2);
    precodWeights = (Hest' * Hest + ermitMat + lambda * eye(numSTS,numSTS)) \ Hest';
end
function precodWeights = getEBM(Hest)
    numSTS = size(Hest,2);
    [precodWeights, ~] = diagbfweights(Hest);
    precodWeights = precodWeights(1:numSTS,:);
end
function precodWeights = getDIAG_SU(Hest)
    [precodWeights, ~] = diagbfweights(Hest);
end
function precodWeights = getDIAG_MU(Hest,numSTSVec,numRxVec)
    numUsers = size(numSTSVec,2);
    HestCell = converterToCell(numUsers,numRxVec,Hest);
    [precodWeights, ~] = blkdiagbfweights(HestCell,numSTSVec);
end
%%
function HestCell = converterToCell(numUsers,numRxVec,Hest)
    HestCell = cell(1,numUsers);
    for uIdx = 1:numUsers
        rxU = numRxVec(uIdx);
        rxIdx = sum(numRxVec(1:(uIdx-1)))+(1:rxU);

        HestCell{uIdx} = Hest(:,rxIdx);
    end
end
function precodWeights = getSizePrecodWeights(type,numSC,system)
    
    if type == "DIAG"
        if (system.numUsers == 1)
            precodWeights = zeros(numSC,system.numSTS,system.numSTS);
        else
            precodWeights = zeros(numSC,system.numSTS,system.numTx);
        end
    else                           
        precodWeights = zeros(numSC,system.numRx,system.numTx); 
    end
end