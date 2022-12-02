classdef HybridPrecoder < Precoder

    properties(SetAccess = private)
        hybridType; % Тип аналогового прекодирования sub / full
        Fbb;        % Цифровые коэффициенты прекодирования 
        Frf;        % Аналоговые коэффициенты прекодирования 
    end
    properties(Access = private)
        numRays;    % numRays - кол-во лучей
        numRF;
        At;
    end
    %% Constructor, get
    methods
        % HestCell - оценка канала размерностью Cell{numUserx}[numSC,numTx,numRx]
        % At - матрица отклика антенной решетки относительно углов прихода
        % сигнала на ант решетку. [numTx,numRays]
        function obj = HybridPrecoder(type,system,HestCell,hybridType,numRF,At)
            obj@Precoder(type,system);
            obj.hybridType = hybridType;
            obj.numRF = numRF;
            obj.At = At;
            obj.calcPrecodWeights(HestCell);
        end    
    end
    %%
    methods
        function outData = applyFbb(obj,inData)
            % inData - входные данные размерностью [numSC,numOFDM,numSTS]
            % outData - выходные данные размерностью [numSC,numOFDM,numTx]
            outData = obj.applyPrecod(inData,obj.Fbb);
        end
        function outData = applyFrf(obj,inData)
            % inData - входные данные размерностью [numData,numRF]
            % outData - выходные данные размерностью [numData,numTx]
            % numData - число данных           
            outData = inData*obj.Frf;            
        end
    end
    methods (Access = protected)
        function calcPrecodWeights(obj,HestCell)
            numSC = size(HestCell{1},1);     % кол-во поднессущих
            
            % Frf
            switch obj.type
                case {'JSDM/OMP'}
                    if obj.system.numUsers > 1                      
                        frf = getJSDM_Frf(HestCell,obj.system.numSTSVec);                                               
                    else
                        [frf,fbbMU] = getOMP_Frf_Fbb(HestCell,obj.At,obj.system.numSTS,obj.numRF);
                    end
                case {'ZF'}
                    frf = getZF_Frf(HestCell,obj.At,obj.numRF);
                otherwise
                    error('Нет такого типа прекодера!');
            end
            
            if (obj.hybridType == "sub")
                subNumTx = obj.system.numTx/obj.numRF;
                subNumSTS = obj.system.numSTS/obj.numRF;

                tmpFrf = cell(1,obj.numRF);
                for i = 1:obj.numRF
                    tmpFrf{i} = frf(1+(i-1)*subNumSTS:i*subNumSTS, 1+(i-1)*subNumTx:i*subNumTx);
                end
                frf = blkdiag(tmpFrf{:});
            end
                       
            % Fbb
            switch obj.type
                case {'JSDM/OMP'}
                    if obj.system.numUsers > 1
                        fbbMU = zeros(numSC,obj.system.numSTS,obj.system.numSTS);
                        for uIdx = 1:obj.system.numUsers
                            stsIdx = sum(obj.system.numSTSVec(1:uIdx-1))+(1:obj.system.numSTSVec(uIdx));
                            fbbMU(:,stsIdx,stsIdx) = getJSDM_FbbSU(HestCell{uIdx},frf(stsIdx,:));
                        end
                    end
                case {'ZF'}
                    Hest = cat(3,HestCell{:});
                    fbbMU = getZF_Fbb(Hest,frf);
            end

            obj.Frf = frf;
            obj.Fbb = fbbMU;
        end
    end
end
% HestCell - оценка канала размерностью Cell{numUserx}[numSC,numTx,numRx]
function Frf = getJSDM_Frf(HestCell,numSTSVec)
    numUsers = size(numSTSVec,2);
    HmeanCell = cell(numUsers,1);
    for uIdx = 1:numUsers
        Hmean = mean(HestCell{uIdx},1);
        HmeanCell{uIdx} = reshape(Hmean,size(Hmean,2),size(Hmean,3));
    end
    [mFrf, ~] = blkdiagbfweights(HmeanCell,numSTSVec);
    theta = angle(mFrf);
    Frf = exp(1i*theta);
end
% Hest - оценка канала размерностью [numSC,numTx,numRx]
function Fbb = getJSDM_FbbSU(Hest,Frf)
    numSC = size(Hest,1);     % кол-во поднессущих
    Fbb = [];
    
    for i = 1:numSC 
        sqHest = reshape(Hest(i,:,:),size(Hest(i,:,:),2),size(Hest(i,:,:),3));        
        Heff = Frf*sqHest; % так как у нас модель y = x*H + n, то Heff = Frf*H
        [U,~,~] = svd(Heff,'econ');
        fbb(1,:,:) = U';
        Fbb = cat(1,Fbb,fbb);
    end
end
% HestCell - оценка канала размерностью Cell{numUserx}[numSC,numTx,numRx]
function Frf = getZF_Frf(HestCell,At,numRF)
    warning('off');
    Frf = zeros(numRF,size(At,1));
    Hest = cat(3,HestCell{:});
    Hmean = reshape(mean(Hest,1),size(Hest,2),size(Hest,3));

    At = At';
    for m = 1:numRF   
        [~,k] = minNormFrob(At,Frf,Hmean);

        Frf(m,:) = At(k,:);
        At(k,:) = [];
    end
    warning('on');
end
function [Frf,Fbb] = getOMP_Frf_Fbb(HestCell,At,numSTS,numRF)
    numSC = size(HestCell{1},1);     % кол-во поднессущих
    AtExp = complex(zeros(numSC,size(At,1),size(At,2)));
    for carrIdx = 1:numSC
        AtExp(carrIdx,:,:) = At; % same for all sub-carriers
    end
    
    [Fbb,frf] = omphybweights(HestCell{1},numSTS,numRF,AtExp);

    Frf = permute(mean(frf,1),[2 3 1]); 
end
function Fbb = getZF_Fbb(Hest,Frf)
    warning('off');
    numSC = size(Hest,1);     % кол-во поднессущих
    Fbb = [];
    for i = 1:numSC
        sqHest = reshape(Hest(i,:,:),size(Hest(i,:,:),2),size(Hest(i,:,:),3));        
        Heff = Frf*sqHest; % так как у нас модель y = x*H + n, то Heff = Frf*H
        fbb(1,:,:) = (Heff'*Heff) \ Heff';
        Fbb = cat(1,Fbb,fbb);
    end
    warning('on');
end
function [minf,idx] = minNormFrob(At,Frf,H)
    
    f = zeros(1, size(At,1));
    for i = 1:size(At,1)
        frf = vertcat(Frf,At(i,:));
        Heff = frf*H; % так как у нас модель y = x*H + n, то Heff = Frf*H
        func = ((Heff'*Heff) \ Heff')*frf;
        f(i) = norm(func,'fro');
    end
    
    [minf,idx] = min(f);
end