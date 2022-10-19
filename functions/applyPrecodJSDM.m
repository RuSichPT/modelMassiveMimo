function [digitalData, Fbb, Frf] = applyPrecodJSDM(inputData, estimateChannel, numSTSVec, numUsers)
    
    % inputData - входные данные размерностью [numSC,numOFDM,numSTS]
    % numSC - кол-во поднессущих
    % numOFDM - кол-во символов OFDM от каждой антенны
    % numSTS - кол-во потоков данных;
    
    % estimateChannel - оценка канала размерностью [numSC,numTx,numSTS]
    % numTx - кол-во излучающих антен
    
    % numSTSVec - кол-во независимых потоков данных на одного пользователя [1, numUsers]
    % numUsers - кол-во пользователей

    % digitalData - выходные цифровые данные размерностью [numSC,numOFDM,numSTS]
    % Fbb - веса прекодирования BB
    % Frf - веса прекодирования RF    
    
    numSC = size(inputData,1);
    numOFDM = size(inputData,2);
    numSTS = size(inputData,3);
    digitalData = zeros(numSC,numOFDM,numSTS);
    
    prm.numUsers = numUsers;
    prm.numSTSVec = numSTSVec;
    prm.numCarriers = numSC;
    
    % Multi-user Joint Spatial Division Multiplexing
    [FbbCell, Frf] = helperJSDMTransmitWeights(estimateChannel,prm);
    
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

