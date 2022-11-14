classdef Precoder < handle
    
    properties
        type;               % Тип прекодера
        F;                  % Коэффициенты прекодирования 
    end
    
    properties(Access = private)
        numSTSVec;          % Кол-во независимых потоков данных на одного пользователя / [2 1 3 2] 
        numUsers;           % Кол-во пользователей
        numSC;              % Кол-во поднессущих
        numTx;              % Кол-во передающих антен
        numSTS;             % Кол-во потоков данных
        numOFDM;            % Кол-во символов OFDM от каждой антенны
    end
    
    %% Constructor, get
    methods
        % Hest - оценка канала размерностью [numSC,numTx,numSTS]
        function obj = Precoder(type,numSTSVec,Hest)
            obj.numSTSVec = numSTSVec;
            obj.numUsers = length(numSTSVec);
            obj.type = type;
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
                sqHest = squeeze(Hest(i,:,:));
                switch obj.type
                    case {'MF'}
                        precodWeights(i,:,:) = getMF(sqHest);
                    case {'ZF'}
                        precodWeights(i,:,:) = getZF(sqHest);
                    case {'RZF'}
                        precodWeights(i,:,:) = getRZF(sqHest,0,0.01);
                    case {'EBM'}
                        precodWeights(i,:,:) = getEBM(sqHest);
%                     case {'DIAG'}
%                         if (obj.numUsers > 1)
%                             precodWeights(i,:,:) = getDIAG_MU(Hest);
%                         else
%                             precodWeights(i,:,:) = getDIAG_SU(Hest);
%                         end
                end
            end
            obj.F = precodWeights;
        end
    end
end
% Hest - оценка канала размерностью [numTx,numSTS]
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
    precodWeights = precodWeights(:,1:numSTS,:);
end
% % Hest - оценка канала размерностью Cell{1:numUsers}[numTx,numSTS]
% function precodWeights = getDIAG_MU(HestCell)
%     [precodWeights, ~] = blkdiagbfweights(HestCell, numSTSVec);
% end
% function converter
%     for uIdx = 1:numUsers
%         rxU = numRxVec(uIdx);
%         rxIdx = sum(numRxVec(1:(uIdx-1)))+(1:rxU);
% 
%         if (ismatrix(estimateChannel(iSC,:,rxIdx)))
%             estimateChannelCell{uIdx} = estimateChannel(iSC,:,rxIdx).'; 
%         else
%             estimateChannelCell{uIdx} = squeeze(estimateChannel(iSC,:,rxIdx)); 
%         end
%     end
% end