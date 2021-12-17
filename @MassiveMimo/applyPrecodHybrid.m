function [digitalData, Frf] = applyPrecodHybrid(obj, inputData, estimateChannel)

    % inputData - входные данные размерностью [numSC,numOFDM,numSTS]
    % numSC - кол-во поднессущих
    % numOFDM - кол-во символов OFDM от каждой антенны
    % numSTS - кол-во потоков данных;
    
    % estimateChannel - оценка канала размерностью [numSC,numTx,numSTS]
    % numTx - кол-во излучающих антен
    
    % digitalData - выходные цифровые данные размерностью [numSC,numOFDM,numSTS]
    % Frf - веса прекодирования RF
    
    obj.main.precoderType = 'HybridJSDM';
    
    numSC = size(inputData,1);
    numOFDM = size(inputData,2);
    numSTS = size(inputData,3);
    numSTSVec = obj.main.numSTSVec;
    numUsers = obj.main.numUsers;
    digitalData = zeros(numSC,numOFDM,numSTS);
    
    prm.numUsers = numUsers;
    prm.numSTSVec = numSTSVec;
    prm.numCarriers = numSC;
    
    estimateChannelSTS = cell(numSTS,1);          
    for i = 1:numSTS
        estimateChannelSTS{i} = estimateChannel(:,:,i);
    end 
    
    % Multi-user Joint Spatial Division Multiplexing
    [FbbCell, Frf] = helperJSDMTransmitWeights(estimateChannelSTS,prm);
    
    % Multi-user baseband precoding
    %   Pack the per user CSI into a matrix (block diagonal)
    steeringMatrix = zeros(numSC,sum(numSTSVec),sum(numSTSVec));
    for uIdx = 1:numUsers
        stsIdx = sum(numSTSVec(1:uIdx-1))+(1:numSTSVec(uIdx));
        steeringMatrix(:,stsIdx,stsIdx) = FbbCell{uIdx};  % Nst-by-Nsts-by-Nsts
    end
    Fbb = permute(steeringMatrix,[1 3 2]);
    
    % Apply precoding weights to the subcarriers, assuming perfect feedback       
    for ii = 1:numSC 
        sqPrecodW = squeeze(Fbb(ii,:,:));
        digitalData(ii,:,:) = squeeze(inputData(ii,:,:))*sqPrecodW;       
    end    

end

