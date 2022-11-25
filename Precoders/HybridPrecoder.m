classdef HybridPrecoder < Precoder

    properties(SetAccess = private)
        hybridType; % Тип аналогового прекодирования sub / full
        Fbb;        % Цифровые коэффициенты прекодирования 
        Frf;        % Аналоговые коэффициенты прекодирования 
    end
    %% Constructor, get
    methods
        % HestCell - оценка канала размерностью Cell{numUserx}[numSC,numTx,numRx]
        function obj = HybridPrecoder(type,system,HestCell,hybridType)
            obj@Precoder(type,system);
            obj.hybridType = hybridType;
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
                case {'JSDM'}
                    obj.Frf = getJSDM_Frf(HestCell,obj.system.numSTSVec); 
            end
            
            if (obj.hybridType == "sub")
                numRF = size(obj.Frf,1);
                subNumTx = obj.system.numTx/numRF;
                subNumSTS = obj.system.numSTS/numRF;

                tmpFrf = cell(1,numRF);
                for i = 1:numRF
                    tmpFrf{i} = obj.Frf(1+(i-1)*subNumSTS:i*subNumSTS, 1+(i-1)*subNumTx:i*subNumTx);
                end
                obj.Frf = blkdiag(tmpFrf{:});
            end
                       
            % Fbb
            FbbMU = zeros(numSC,obj.system.numSTS,obj.system.numSTS);
            for uIdx = 1:obj.system.numUsers
                stsIdx = sum(obj.system.numSTSVec(1:uIdx-1))+(1:obj.system.numSTSVec(uIdx));
                FbbMU(:,stsIdx,stsIdx) = getFbbSU(HestCell{uIdx},obj.Frf(stsIdx,:));
            end

            obj.Fbb = FbbMU;            
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
function Fbb = getFbbSU(Hest,Frf)
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