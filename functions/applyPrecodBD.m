function [outputData, precodWeights, combWeights] = applyPrecodBD(inputData, estimateChannel, numSTSVec)
    
    % inputData - ������� ������ ������������ [numSC,numOFDM,numSTS]
    % numSC - ���-�� �����������
    % numOFDM - ���-�� �������� OFDM �� ������ �������
    % numSTS - ���-�� ������� ������;
    % numSTSVec - ���-�� ����������� ������� ������ �� ������ ������������
    % numUsers - ���-�� �������������
    
    % estimateChannel - ������ ������ ������������ [numSC,numTx,numSTS]
    % numTx - ���-�� ���������� �����
    
    % outputData - �������� ������ ������������ [numSC,numOFDM,numTx]
    % precodWeights - ���� ��������������
    % combWeights - ���� ��������������
    
    numSC = size(inputData,1);
    numOFDM = size(inputData,2);
    numSTS = size(inputData,3);
    numTx = size(estimateChannel,2);
    numUsers = size(numSTSVec,2);
    
    outputData = zeros(numSC,numOFDM,numTx);
    precodWeights = zeros(numSC,numSTS,numTx);
    
    % 1 �������
    estimateChannelCell = cell(1,numUsers);    
    for i = 1:numSC        
        for j = 1:numUsers
            estimateChannelCell{j} = estimateChannel(i,:,j).';
        end        
        [sqPrecodW, combWeights] = blkdiagbfweights(estimateChannelCell, numSTSVec);
        precodWeights(i,:,:) = sqPrecodW;
        outputData(i,:,:) = squeeze(inputData(i,:,:))*sqPrecodW;
    end 
    
%     % 2 �������
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

