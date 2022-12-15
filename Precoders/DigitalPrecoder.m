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
function invMat = invMatrixCayleyHamilton(mat, sizeMat)

    % mat - квадратная матрица
    % sizeMat - размер матрицы, (в формуле в литературе - длина в сумме)
    % Чтобы матрица обратилась необходимо sizeMat = size(mat)
       
    cpoly = poly(mat);

    invMat = 0;
    for i = 0:sizeMat-1
       invMat = invMat + cpoly(sizeMat - i)*mat^(i);
    end
    
    invMat =( (-1)^(sizeMat - 1)/det(mat) )*invMat;
    
end
function invMat = invMatrixNeumannSeries(mat, numIter)

    % mat - квадратная матрица
    % numIter - кол-во итераций 
    % необходимо numIter -> inf
    
    if (numIter <= 0)
        error("Кол-во итерация не может быть <=0")
    end
    
    invMat = 0;
    D = diag(diag(mat));    
    E = triu(mat,1) + tril(mat,-1);
    
    lambdaMax = max(eig((-inv(D)*E)));
    
    % Условие сходимости
    if (abs(lambdaMax) < 1)   
        for i = 0:numIter - 1
            invMat = invMat + ( (-inv(D)*E)^i )*inv(D);
        end
    else
        invMat = inv(D);
%         fprintf("Условие сходимости метода NSA %d > 1 нарушено\n", abs(lambdaMax))
    end 
end
function invMat = invMatrixNeumannSeries2(mat, numIter, X)

    % mat - квадратная матрица
    % numIter - кол-во итераций
    % X - первое приближение матрицы mat
    % необходимо numIter -> inf
    
    if (numIter <= 0)
        error("Кол-во итерация не может быть <=0")
    end
    
    invMat = 0;
        
    tmp = eye(size(mat,1)) - X*mat;   
    lambdaMax = max(eig(tmp));
    
    % Условие сходимости
    if (abs(lambdaMax) < 1)   
        for i = 0:numIter - 1
            tmp = eye(size(mat,1)) - X*mat; 
            invMat = invMat + (tmp^i)*X;
        end
    else
        invMat = X;
%         fprintf("Условие сходимости метода NSA %d > 1 нарушено\n", abs(lambdaMax))
    end 
end
function invMat = invMatrixNewton(mat, numIter)

    % mat - квадратная матрица
    % numIter - кол-во итераций 
    % необходимо numIter -> inf
    
    if (numIter <= 0)
        error("Кол-во итерация не может быть <=0")
    end
        
    numIter = numIter + 1;
    invMatIter = cell(1, numIter);
    invMatIter{1} = invMatrixNeumannSeries(mat, 1);

    % Условие сходимости
    if (norm(eye(size(mat,1)) - mat*invMatIter{1}) < 1)
        for i = 2:numIter
            invMatIter{i} = invMatIter{i - 1}*(2*eye(size(mat,1)) - mat*invMatIter{i - 1});
        end
        invMat = invMatIter{end};
    else
        invMat = invMatIter{1};
%         fprintf("Условие сходимости метода NI %d > 1 нарушено\n", norm(eye(size(mat,1)) - mat*invMatIter{1}))
    end  
end