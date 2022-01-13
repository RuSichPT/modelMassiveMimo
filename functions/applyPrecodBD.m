function [outputData, precodWeights, combWeights] = applyPrecodBD(inputData, estimateChannel, numSTSVec)
    
    % inputData - входные данные размерностью [numSC,numOFDM,numSTS]
    % numSC - кол-во поднессущих
    % numOFDM - кол-во символов OFDM от каждой антенны
    % numSTS - кол-во потоков данных;
    % numSTSVec - кол-во независимых потоков данных на одного пользователя
    % numUsers - кол-во пользователей
    
    % estimateChannel - оценка канала размерностью [numSC,numTx,numSTS]
    % numTx - кол-во излучающих антен
    
    % outputData - выходные данные размерностью [numSC,numOFDM,numTx]
    % precodWeights - веса прекодирования
    % combWeights - веса комбинирования
    
    numSC = size(inputData,1);
    numOFDM = size(inputData,2);
    numSTS = size(inputData,3);
    numTx = size(estimateChannel,2);
    numUsers = size(numSTSVec,2);
    
    outputData = zeros(numSC,numOFDM,numTx);
    precodWeights = zeros(numSC,numSTS,numTx);
    
    % 1 вариант
    estimateChannelCell = cell(1,numUsers);    
    for i = 1:numSC        
        for j = 1:numUsers
            estimateChannelCell{j} = estimateChannel(i,:,j).';
        end        
        [sqPrecodW, combWeights] = blkdiagbfweights(estimateChannelCell, numSTSVec);
        precodWeights(i,:,:) = sqPrecodW;
        outputData(i,:,:) = squeeze(inputData(i,:,:))*sqPrecodW;
    end 
    
%     % 2 вариант
%     Hmean = cell(numUsers,1);
%     for uIdx = 1:numUsers
%         Hmean{uIdx} = mean(permute(estimateChannel(:,:,uIdx),[2 3 1]),3);
%     end
%     [sqPrecodW, combWeights] = blkdiagbfweights(Hmean, numSTSVec);
%     for i = 1:numSC       
%         precodWeights(i,:,:) = sqPrecodW;
%         outputData(i,:,:) = squeeze(inputData(i,:,:))*sqPrecodW;
%     end 
end

