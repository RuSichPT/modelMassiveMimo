function [outputData, precodWeights] = applyPrecodZF(inputData, estimateChannel)
    
    % inputData - входные данные размерностью [numSC,numOFDM,numSTS]
    % numSC - кол-во поднессущих
    % numOFDM - кол-во символов OFDM от каждой антенны
    % numSTS - кол-во потоков данных;
    
    % estimateChannel - оценка канала размерностью [numSC,numTx,numSTS]
    % numTx - кол-во излучающих антен
    
    % outputData - выходные данные размерностью [numSC,numOFDM,numTx]
    % precodWeights - веса прекодирования    
    
    numSC = size(inputData,1);
    numOFDM = size(inputData,2);
    numSTS = size(inputData,3);
    numTx = size(estimateChannel,2);
%     numRx = size(estimateChannel,3);
    
    precodWeights = zeros(numSC,numSTS,numTx);
    outputData = zeros(numSC,numOFDM,numTx);
%     inputDataNew = zeros(numSC,numOFDM,numTx);
    
%     Instead of multiplying by the inverse, use matrix right division (/) or matrix left division (\). That is:
%     Replace inv(A)*b with A\b - faster 
%     Replace b*inv(A) with b/A - faster 

    
% %   repeat over numTx
%     expFactorTx = numTx/numSTS;
%     for i = 1:numSTS
%         inputDataNew(:,:,(i-1)*expFactorTx+(1:expFactorTx)) = repmat(inputData(:,:,i),1,1,expFactorTx);
%     end
    
    for ii = 1:numSC
        sqEstChan = squeeze(estimateChannel(ii,:,:));
        precodWeights(ii,:,:) = (sqEstChan'*sqEstChan) \ sqEstChan';
        sqPrecodW = squeeze(precodWeights(ii,:,:));
        outputData(ii,:,:) = squeeze(inputData(ii,:,:))*sqPrecodW;       
    end 
    
end

