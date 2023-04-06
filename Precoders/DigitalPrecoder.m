classdef DigitalPrecoder < Precoder    
    properties(SetAccess = private)
        F;                  % Коэффициенты прекодирования 
    end
    
    %% Constructor, get
    methods
        % HestCell - оценка канала размерностью Cell{numUserx}[numSC,numTx,numRx]
        function obj = DigitalPrecoder(type,system,HestCell)
            obj@Precoder(type,system);
            obj.calcPrecodWeights(HestCell);
        end    
    end
    %%
    methods
        function outData = apply(obj,inData)
            % inData - входные данные размерностью [numSC,numOFDM,numSTS]
            % outData - выходные данные размерностью [numSC,numOFDM,numTx]
            outData = obj.applyPrecod(inData,obj.F);
        end
    end
    %%
    methods (Access = protected)
        function calcPrecodWeights(obj,HestCell)
            Hest = cat(3,HestCell{:});
            numSC = size(Hest,1);     % кол-во поднессущих
                        
            for i = 1:numSC 
                sqHest = reshape(Hest(i,:,:),size(Hest(i,:,:),2),size(Hest(i,:,:),3));
                switch obj.type
                    case {'MF'}
                        f = getMF(sqHest);
                    case {'ZF'}
                        f = getZF(sqHest);
                    case {'RZF'}
                        f = getRZF(sqHest,0,0.01);
                    case {'EBM'}
                        f = getEBM(sqHest);
                    case {'DIAG'}
                        if (obj.system.numUsers == 1)
                            f = getDIAG_SU(sqHest);
                        else
                            numRxVec = obj.system.numSTSVec * obj.system.numRx/obj.system.numSTS;
                            f = getDIAG_MU(sqHest,obj.system.numSTSVec,numRxVec);
                        end
                    case {'TPE'}
                        f = getTPE(sqHest,3);
                    case {'NSA'}
                        % K = 1:3; K = 3 max в таком случае выч сложность == ZF => K = 2 
                        f = getNSA(sqHest,2);
                    case {'NI'}
                        % K = 1:2; K = 2 max в таком случае выч сложность == ZF => K = 1 (тк использует 1 итерацию NSA)
                        f = getNI(sqHest,1);
                    case {'NI-NSA'}
                        f = getNI_NSA(sqHest,2);
                    otherwise
                        error('Нет такого типа прекодера!');
                end
                Ftmp(1,:,:) = f;
                obj.F = cat(1,obj.F,Ftmp);
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
function precodWeights = getTPE(Hest,J)
    % J - индекс коэффициента характеристического полинома матрицы (порядок разложения)
    matGram = (Hest'*Hest);
    precodWeights = invMatrixCayleyHamilton(matGram,J) * Hest';
end
function precodWeights = getNSA(Hest,K)
    % K - количество итераций разложения
    matGram = (Hest'*Hest);
    precodWeights = invMatrixNeumannSeries(matGram,K) * Hest';
end
function precodWeights = getNI(Hest,K)
    % K - количество итераций разложения
    matGram = (Hest'*Hest);
    precodWeights = invMatrixNewton(matGram,K) * Hest';
end
function precodWeights = getNI_NSA(Hest,K)
    % K - количество итераций разложения
    matGram = (Hest'*Hest);
    X = invMatrixNewton(matGram,1);
    precodWeights = invMatrixNeumannSeries2(matGram,K,X) * Hest';
end
%%
% Hest - оценка канала размерностью [numTx,numRx]
function HestCell = converterToCell(numUsers,numRxVec,Hest)
    HestCell = cell(1,numUsers);
    for uIdx = 1:numUsers
        rxU = numRxVec(uIdx);
        rxIdx = sum(numRxVec(1:(uIdx-1)))+(1:rxU);

        HestCell{uIdx} = Hest(:,rxIdx);
    end
end
