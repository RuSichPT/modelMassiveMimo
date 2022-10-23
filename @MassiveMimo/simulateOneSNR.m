function [numErrors,numBits,SINR_dB] = simulateOneSNR(obj,snr)
    % ��������������� ����������
    numSTS = obj.main.numSTS;
    numSTSVec = obj.main.numSTSVec;
    modulation = obj.main.modulation;
    numUsers = obj.main.numUsers;
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
    %% ��������������
    [precodData, precodWeights, combWeights] = obj.applyPrecod(inpModData, H_estim_zond);
    obj.F = precodWeights;
    %% ��������� OFDM  
    dataOFDM = ofdmmod(precodData, lenFFT, cycPrefLen, nullCarrInd);
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
        modDataOut = obj.applyComb(modDataOut, combWeights{uIdx});
        %% ������ ������
        outPreambula = modDataOut(:,1:numSTS,:);
        modDataOut = modDataOut(:,(1 + numSTS):end,:);
        H_estim = obj.channelEstimate(outPreambula, ltfSC, numSTS);
        %% ����������
        tmpEqualizeData = obj.equalizerZFnumSC(modDataOut, H_estim(:,stsIdx,:));
        equalizeData = reshape(tmpEqualizeData, numSubCarr * numSymbOFDM, numSTSVec(uIdx));
        %% sigma (���) SNR
        inpModDataTmp = squeeze(inpModData(:,:,uIdx));
        inpModDataTmp = inpModDataTmp(:,(1 + numSTS):end,:);
        A = rms(inpModDataTmp(:));
        sigma(uIdx) = rms(equalizeData - inpModDataTmp(:));
        SINR_dB(uIdx) = 20*log10(A/sigma(uIdx));
        %% �����������
        outData{uIdx} = qamdemod(equalizeData, modulation, 'OutputType', 'bit');
    end
    %% �������� ������
    outData = cat(2,outData{:});
    numErrors = obj.calculateErrors(inpData, outData); 
end