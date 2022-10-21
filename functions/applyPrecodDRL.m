function [digitalData, Fbb, Frf] = applyPrecodDRL(inputData,estimateChannel,numSTSVec,numUsers)

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
    
    load('DataBase/NeuralNetwork/F_rf_I.txt')
    load('DataBase/NeuralNetwork/F_rf_Q.txt')
    Frf = F_rf_I+1i*F_rf_Q;
    Frf = Frf';
    
    FbbCell = getFbb_forDRL_NN(estimateChannel,Frf,numSTSVec,numUsers,numSC);
    
%     prm.numUsers = numUsers;
%     prm.numSTSVec = numSTSVec;
%     prm.numCarriers = numSC;
%     % Multi-user Joint Spatial Division Multiplexing
%     [FbbCell1, Frf1] = helperJSDMTransmitWeights(estimateChannel,prm);
    
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

function [Fbb] = getFbb_forDRL_NN(H,mFrf,numSTSVec,numUsers,numCarriers)
    % Initialization
    Fbb = cell(numUsers,1);              % Baseband precoder per user, Vg
    
    % Get Vg: from the svd of hk (did svd within blkdiagbfweights also)
    for uIdx = 1:numUsers
        hk = permute(H{uIdx},[3 2 1]);     % numRx-by-numTx-by-numCarriers
        stsIdx = sum(numSTSVec(1:uIdx-1))+(1:numSTSVec(uIdx));

        Vg = complex(zeros(numCarriers,numSTSVec(uIdx),numSTSVec(uIdx))); 
        for i = 1:numCarriers
            % Need Wgi as well, if Rx end adopts hybrid arch
            %   Here use the analog precoder (mFrf) only
            [~,~,Vg(i,:,:)] = svd(hk(:,:,i)*mFrf(stsIdx,:).','econ');
        end
        Fbb{uIdx} = Vg;
    end
    
%     Htmp = cat(3,H{:});     % numRx-by-numTx-by-numCarriers
%     h = permute(Htmp,[1 3 2]);     % numRx-by-numTx-by-numCarriers
% 
%     Vg = []; 
%     for i = 1:numCarriers
%         % Need Wgi as well, if Rx end adopts hybrid arch
%         %   Here use the analog precoder (mFrf) only
%         [~,~,Vg(i,:,:)] = svd(squeeze(h(i,:,:))*mFrf.','econ');
%     end
%     Fbb = Vg;

end
