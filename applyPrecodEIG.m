function [outputData, precodWeights, combWeights] = applyPrecodEIG(inputData, estimateChannel)
    
    % inputData - входные данные размерностью [numSC,numOFDM,numSTS]
    % numSC - кол-во поднессущих
    % numOFDM - кол-во символов OFDM от каждой антенны
    % numSTS - кол-во потоков данных;
    
    % estimateChannel - оценка канала размерностью [numSC,numTx,numSTS]
    % numTx - кол-во излучающих антен
    
    % outputData - выходные данные размерностью [numSC,numOFDM,numTx]
    % precodWeights - веса прекодирования
    % combWeights - веса комбинирования
    
    numSC = size(inputData,1);
    numOFDM = size(inputData,2);
    numSTS = size(inputData,3);
    numTx = size(estimateChannel,2);
    
    outputData = zeros(numSC,numOFDM,numTx);
    
    [precodWeights, combWeights] = diagbfweights(estimateChannel);
    
    for ii = 1:numSC 
        sqPrecodW = squeeze(precodWeights(ii,1:numSTS,:));
        outputData(ii,:,:) = squeeze(inputData(ii,:,:))*sqPrecodW;       
    end 
    
    precodWeights = precodWeights(:,1:numSTS,:);
    
end

