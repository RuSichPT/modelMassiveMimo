function [numErrors,numBits,SINR_dB] = simulateOneSNR(obj,snr)
    addpath('Precoders');
    % ��������������� ����������
    numTx = obj.main.numTx;
    numRx = obj.main.numRx;
    numSTS = obj.main.numSTS;
    numSTSVec = obj.main.numSTSVec;
    modulation = obj.main.modulation;
    numUsers = obj.main.numUsers;
    precoderType = obj.main.precoderType;
    bps = obj.main.bps;
    lenFFT = obj.ofdm.lengthFFT;
    cycPrefLen = obj.ofdm.cyclicPrefixLength;
    nullCarrInd = obj.ofdm.nullCarrierIndices;
    numSymbOFDM = obj.ofdm.numSymbOFDM;
    numSubCarr = obj.ofdm.numSubCarriers;
    downChann = obj.downChannel;
    %% ������������ ������
    H_estim_zond = obj.channelSounding(snr);
    %% ��������� ������
    numBits = bps * numSymbOFDM * numSubCarr;
    inpData = randi([0 1], numBits, numSTS);
    %% ��������� 
    tmpModData = qammod(inpData, modulation, 'InputType', 'bit');
    inpModData = reshape(tmpModData, numSubCarr, numSymbOFDM, numSTS);
    %% ��������� �������
    [preambula, ltfSC] = obj.generatePreamble(numSTS);
    inpModData = cat(2, preambula, inpModData);
    %% ��������� ������ �� ������ �������
    if (precoderType ~= "DIAG") && (numRx ~= numSTS)
        inpModData = repeatDataSC(inpModData,numRx,numSTS);
    end
    %% ��������������
%     [precodData, precodWeights, combWeights] = obj.applyPrecod(inpModData, H_estim_zond);
%     obj.F = precodWeights;
    precoder = Precoder(precoderType,H_estim_zond,obj.main);
    precodData = precoder.apply(inpModData);
    %% ��������� OFDM
    dataOFDM = ofdmmod(precodData, lenFFT, cycPrefLen, nullCarrInd);
    %% ��������� ������ �� ������ ������� (����� � �� OFDM - �� ������)
    if (precoderType == "DIAG") && (numUsers == 1)
        dataOFDM = repeatData(dataOFDM,numTx,numSTS);
    end
    %% ����������� ������
    channelData = downChann.pass(dataOFDM);
    %%
    outData = cell(numUsers,1);
    sigma = zeros(numUsers,1);
    SINR_dB = zeros(numUsers,1);
    for uIdx = 1:numUsers
        stsU = numSTSVec(uIdx);
        stsIdx = sum(numSTSVec(1:(uIdx-1)))+(1:stsU);
        %% ����������� ���
        noiseData = awgn(channelData{uIdx,:}, snr, 'measured');
        %% ����������� OFDM
        modDataOut = ofdmdemod(noiseData, lenFFT, cycPrefLen, cycPrefLen, nullCarrInd);
        %% ������������
%         modDataOut = obj.applyComb(modDataOut, combWeights{uIdx});
        %% ������ ������
        outPreambula = modDataOut(:,1:numSTS,:);
        modDataOut = modDataOut(:,(1 + numSTS):end,:);
        H_estim = obj.channelEstimate(outPreambula, ltfSC, numSTS);
        %% ����������
        tmpEqualizeData = obj.equalizerZFnumSC(modDataOut, H_estim(:,stsIdx,:));
        equalizeData = reshape(tmpEqualizeData, numSubCarr * numSymbOFDM, numSTSVec(uIdx));
        %% sigma (���) SNR
        inpModDataTmp = squeeze(inpModData(:,:,stsIdx));
        inpModDataTmp = inpModDataTmp(:,(1 + numSTS):end,:);
        A = rms(inpModDataTmp(:));
        sigma(uIdx) = rms(equalizeData(:) - inpModDataTmp(:));
        SINR_dB(uIdx) = 20*log10(A/sigma(uIdx));
        %% �����������
        outData{uIdx} = qamdemod(equalizeData, modulation, 'OutputType', 'bit');
    end
    %% �������� ������
    outData = cat(2,outData{:});
    numErrors = obj.calculateErrors(inpData, outData); 
end

function newInData = repeatDataSC(inData,numRx,numSTS)
    newInData = zeros(size(inData,1),size(inData,2),numRx);
    
    expFactorRx = numRx/numSTS;
    for i = 1:numSTS
        newInData(:,:,(i-1)*expFactorRx+(1:expFactorRx)) = repmat(inData(:,:,i),1,1,expFactorRx);
    end
end
function newInData = repeatData(inData,numTx,numSTS)
    newInData = zeros(size(inData,1),numTx);
    
    expFactorTx = numTx/numSTS;
    for i = 1:numSTS
        newInData(:,(i-1)*expFactorTx+(1:expFactorTx)) = repmat(inData(:,i),1,expFactorTx);
    end
end