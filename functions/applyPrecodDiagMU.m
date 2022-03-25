function [outputData, precodWeights, combWeights] = applyPrecodDiagMU(inputData, estimateChannel, numSTSVec)
    
    % For multi users
    % inputData - входные данные размерностью [numSC,numOFDM,numSTS]
    % numSC - кол-во поднессущих
    % numOFDM - кол-во символов OFDM от каждой антенны
    % numSTS - кол-во потоков данных;
    % numSTSVec - кол-во независимых потоков данных на одного пользователя
    % numUsers - кол-во пользователей    
    % estimateChannel - оценка канала размерностью [numSC,numTx,numRx]
    % numTx - кол-во излучающих антен    
    % outputData - выходные данные размерностью [numSC,numOFDM,numTx]
    % precodWeights - веса прекодирования
    % combWeights - веса комбинирования
    
    numSC = size(inputData,1);
    numOFDM = size(inputData,2);
    numSTS = size(inputData,3);
    numTx = size(estimateChannel,2);
    numRx = size(estimateChannel,3);
    numUsers = size(numSTSVec,2);
    
    if (numUsers <= 1)
        error('Пользователей для этого метода дб > 1');
    end
    
    numRxVec = numSTSVec * numRx/numSTS;
    
    outputData = zeros(numSC,numOFDM,numTx);
    precodWeights = zeros(numSC,numSTS,numTx);
    combWeights = cell(numUsers,1);
    
    % 1 вариант
    estimateChannelCell = cell(1,numUsers);

    for iSC = 1:numSC        
        for uIdx = 1:numUsers
            rxU = numRxVec(uIdx);
            rxIdx = sum(numRxVec(1:(uIdx-1)))+(1:rxU);
            
            if (ismatrix(estimateChannel(iSC,:,rxIdx)))
                estimateChannelCell{uIdx} = estimateChannel(iSC,:,rxIdx).'; 
            else
                estimateChannelCell{uIdx} = squeeze(estimateChannel(iSC,:,rxIdx)); 
            end
        end
        [sqPrecodW, combWeightsCarr] = blkdiagbfweights(estimateChannelCell, numSTSVec);
        for uIdx = 1:numUsers
            combWeights{uIdx}(:,:,iSC) = combWeightsCarr{uIdx}(:,:);
        end
        precodWeights(iSC,:,:) = sqPrecodW;
        outputData(iSC,:,:) = squeeze(inputData(iSC,:,:))*sqPrecodW;
    end 
    
%     % 2 вариант
%     Hmean = cell(numUsers,1);
%     for uIdx = 1:numUsers
%         rxU = numSTSVec(uIdx);
%         rxIdx = sum(numSTSVec(1:(uIdx-1)))+(1:rxU);
%         Hmean{uIdx} = mean(permute(estimateChannel(:,:,rxIdx),[2 3 1]),3);
%     end
%     [sqPrecodW, combWeights] = blkdiagbfweights(Hmean, numSTSVec);
%     for i = 1:numSC       
%         precodWeights(i,:,:) = sqPrecodW;
%         outputData(i,:,:) = squeeze(inputData(i,:,:))*sqPrecodW;
%     end 
end

