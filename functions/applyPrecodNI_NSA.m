function [outputData, precodWeights] = applyPrecodNI_NSA(inputData, estimateChannel, K)
    
    % inputData - ������� ������ ������������ [numSC,numOFDM,numSTS]
    % numSC - ���-�� �����������
    % numOFDM - ���-�� �������� OFDM �� ������ �������
    % numSTS - ���-�� ������� ������;
    % K - ���������� �������� ����������
    
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
        sqEstChan = squeeze(estimateChannel(ii,:,:));
        matGram = (sqEstChan'*sqEstChan);
        X = invMatrixNewton(matGram, 1);
        precodWeights(ii,:,:) = invMatrixNeumannSeries2(matGram, K, X) * sqEstChan';
        sqPrecodW = squeeze(precodWeights(ii,:,:));
        outputData(ii,:,:) = squeeze(inputData(ii,:,:))*sqPrecodW;       
    end 
    
end