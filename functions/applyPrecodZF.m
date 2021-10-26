function [outputData, precodWeights] = applyPrecodZF(inputData, estimateChannel)
    
    % inputData - ������� ������ ������������ [numSC,numOFDM,numSTS]
    % numSC - ���-�� �����������
    % numOFDM - ���-�� �������� OFDM �� ������ �������
    % numSTS - ���-�� ������� ������;
    
    % estimateChannel - ������ ������ ������������ [numSC,numTx,numSTS]
    % numTx - ���-�� ���������� �����
    
    % outputData - �������� ������ ������������ [numSC,numOFDM,numTx]
    % precodWeights - ���� ��������������    
    
    numSC = size(inputData,1);
    numOFDM = size(inputData,2);
    numSTS = size(inputData,3);
    numTx = size(estimateChannel,2);
    
    precodWeights = zeros(numSC,numSTS,numTx);
    outputData = zeros(numSC,numOFDM,numTx);
    
%     Instead of multiplying by the inverse, use matrix right division (/) or matrix left division (\). That is:
%     Replace inv(A)*b with A\b - faster 
%     Replace b*inv(A) with b/A - faster 

    for ii = 1:numSC
        sqEstChan = squeeze(estimateChannel(ii,:,:));
        precodWeights(ii,:,:) = (sqEstChan'*sqEstChan) \ sqEstChan';
        sqPrecodW = squeeze(precodWeights(ii,:,:));
        outputData(ii,:,:) = squeeze(inputData(ii,:,:))*sqPrecodW;       
    end 
    
end

