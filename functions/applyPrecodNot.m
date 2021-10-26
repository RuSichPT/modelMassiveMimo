function [outputData, precodWeights, combWeights] = applyPrecodNot(inputData, estimateChannel)
    
    % inputData - ������� ������ ������������ [numSC,numOFDM,numSTS]
    % numSC - ���-�� �����������
    % numOFDM - ���-�� �������� OFDM �� ������ �������
    % numSTS - ���-�� ������� ������;
    
    % estimateChannel - ������ ������ ������������ [numSC,numTx,numSTS]
    % numTx - ���-�� ���������� �����
    
    % outputData - �������� ������ ������������ [numSC,numOFDM,numTx]
    % precodWeights - ���� ��������������
    % combWeights - ���� ��������������
    
    numSC = size(inputData,1);
    numOFDM = size(inputData,2);
    numSTS = size(inputData,3);
    numTx = size(estimateChannel,2);
    
    outputData = zeros(numSC,numOFDM,numTx);
    
    [precodWeights, combWeights] = diagbfweights(estimateChannel);
    
    for ii = 1:numSC 
        sqPrecodW = squeeze(precodWeights(ii,1:numSTS,:));
        outputData(ii,:,:) = squeeze(inputData(ii,:,:))*sqPrecodW;
%         outputData(ii,:,:) = squeeze(inputData(ii,:,:)); 
    end 
    
end

