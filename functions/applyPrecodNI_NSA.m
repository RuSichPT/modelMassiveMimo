function [outputData, precodWeights] = applyPrecodNI_NSA(inputData, estimateChannel, K)
    
    % inputData - входные данные размерностью [numSC,numOFDM,numSTS]
    % numSC - кол-во поднессущих
    % numOFDM - кол-во символов OFDM от каждой антенны
    % numSTS - кол-во потоков данных;
    % K - количество итераций разложения
    
    % estimateChannel - оценка канала размерностью [numSC,numTx,numSTS]
    % numTx - кол-во излучающих антен
    
    % outputData - выходные данные размерностью [numSC,numOFDM,numTx]
    % precodWeights - веса прекодирования    
    
    numSC = size(inputData,1);
    numOFDM = size(inputData,2);
    numSTS = size(inputData,3);
    numTx = size(estimateChannel,2);
    
    precodWeights = zeros(numSC,numSTS,numTx);
    outputData = zeros(numSC,numOFDM,numTx);    

    for ii = 1:numSC
        sqEstChan = squeeze(estimateChannel(ii,:,:));
        matGram = (sqEstChan'*sqEstChan);
        X = invMatrixNewton(matGram, 1);
        precodWeights(ii,:,:) = invMatrixNeumannSeries2(matGram, K, X) * sqEstChan';
        sqPrecodW = squeeze(precodWeights(ii,:,:));
        outputData(ii,:,:) = squeeze(inputData(ii,:,:))*sqPrecodW;       
    end 
    
end