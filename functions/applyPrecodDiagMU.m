function [outputData, precodWeights, combWeights] = applyPrecodDiagMU(inputData, estimateChannel, numSTSVec)
    
    % For multi users
    % inputData - ������� ������ ������������ [numSC,numOFDM,numSTS]
    % numSC - ���-�� �����������
    % numOFDM - ���-�� �������� OFDM �� ������ �������
    % numSTS - ���-�� ������� ������;
    % numSTSVec - ���-�� ����������� ������� ������ �� ������ ������������
    % numUsers - ���-�� �������������    
    % estimateChannel - ������ ������ ������������ [numSC,numTx,numRx]
    % numTx - ���-�� ���������� �����    
    % outputData - �������� ������ ������������ [numSC,numOFDM,numTx]
    % precodWeights - ���� ��������������
    % combWeights - ���� ��������������
    
    numSC = size(inputData,1);
    numOFDM = size(inputData,2);
    numSTS = size(inputData,3);
    numTx = size(estimateChannel,2);
    numRx = size(estimateChannel,3);
    numUsers = size(numSTSVec,2);
    
    if (numUsers <= 1)
        error('������������� ��� ����� ������ �� > 1');
    end
    
    numRxVec = numSTSVec * numRx/numSTS;
    
    outputData = zeros(numSC,numOFDM,numTx);
    precodWeights = zeros(numSC,numSTS,numTx);
    combWeights = cell(numUsers,1);
    
    % 1 �������
    estimateChannelCell = cell(1,numUsers);

    for iSC = 1:numSC        
        for uIdx = 1:numUsers
            rxU = numRxVec(uIdx);
            rxIdx = sum(numRxVec(1:(uIdx-1)))+(1:rxU);
            
            if (ismatrix(estimateChannel(iSC,:,rxIdx)))
                estimateChannelCell{uIdx} = estimateChannel(iSC,:,rxIdx).'; 
            else
                estimateChannelCell{uIdx} = squeeze(estimateChannel(iSC,:,rxIdx)); 
            end
        end
        [sqPrecodW, combWeightsCarr] = blkdiagbfweights(estimateChannelCell, numSTSVec);
        for uIdx = 1:numUsers
            combWeights{uIdx}(:,:,iSC) = combWeightsCarr{uIdx}(:,:);
        end
        precodWeights(iSC,:,:) = sqPrecodW;
        outputData(iSC,:,:) = squeeze(inputData(iSC,:,:))*sqPrecodW;
    end 
    
%     % 2 �������
%     Hmean = cell(numUsers,1);
%     for uIdx = 1:numUsers
%         rxU = numSTSVec(uIdx);
%         rxIdx = sum(numSTSVec(1:(uIdx-1)))+(1:rxU);
%         Hmean{uIdx} = mean(permute(estimateChannel(:,:,rxIdx),[2 3 1]),3);
%     end
%     [sqPrecodW, combWeights] = blkdiagbfweights(Hmean, numSTSVec);
%     for i = 1:numSC       
%         precodWeights(i,:,:) = sqPrecodW;
%         outputData(i,:,:) = squeeze(inputData(i,:,:))*sqPrecodW;
%     end 
end

