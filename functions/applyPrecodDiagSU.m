function [outputData, precodWeights, combWeights] = applyPrecodDiagSU(inputData, estimateChannel)
    
    % For single user
    
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
    newInputData = zeros(numSC,numOFDM,numTx);
    
    [precodWeights, combWeights] = diagbfweights(estimateChannel);
    
    expFactorTx = numTx/numSTS;
    for i = 1:numSTS
        newInputData(:,:,(i-1)*expFactorTx+(1:expFactorTx)) = repmat(inputData(:,:,i),1,1,expFactorTx);
    end
    
    for ii = 1:numSC 
        sqPrecodW = squeeze(precodWeights(ii,:,:));
        outputData(ii,:,:) = squeeze(newInputData(ii,:,:))*sqPrecodW;       
    end   
end