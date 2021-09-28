function [outputData, precodWeights] = applyPrecodMF(inputData, estimateChannel)

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
    
    for ii = 1:numSC 
        precodWeights(ii,:,:) = squeeze(estimateChannel(ii,:,:))';
        sqPrecodW = squeeze(precodWeights(ii,:,:));
        outputData(ii,:,:) = squeeze(inputData(ii,:,:))*sqPrecodW;       
    end 
    
end

