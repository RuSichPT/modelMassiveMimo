function [numErrors, numBits] = simulateOneSNRphased(obj, snr)
    % ��������������� ����������
    numSTS = obj.main.numSTS;
    numTx = obj.main.numTx;
    modulation = obj.main.modulation;
    bps = obj.main.bps;
    lenFFT = obj.ofdm.lengthFFT;
    cycPrefLen = obj.ofdm.cyclicPrefixLength;
    nullCarrInd = obj.ofdm.nullCarrierIndices;
    numSymbOFDM = obj.ofdm.numSymbOFDM;
    numSubCarr = obj.ofdm.numSubCarriers;
    downChann = obj.channel.downChannel;
    %% ������������ ������
    H_estim_zond = obj.channelSoundingPhased(snr);
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
    [precodData, ~] = obj.applyPrecod(inpModData, H_estim_zond);
    %% ��������� OFDM  
    dataSTS_OFDM = ofdmmod(precodData, lenFFT, cycPrefLen, nullCarrInd);  
    %% ��������� �� ������ ������� Tx
    dataOFDM = zeros(size(dataSTS_OFDM,1),numTx);
    expFactorTx = numTx/numSTS;
    for i = 1:numSTS
        dataOFDM(:,(i-1)*expFactorTx+(1:expFactorTx)) = repmat(dataSTS_OFDM(:,i), 1, expFactorTx);
    end
    obj.dataOFDM = dataOFDM;
    %% ����������� ������
    channelData = obj.passChannel(dataOFDM, downChann);
    %% ����������� ���
    noiseData = awgn(channelData, snr, 'measured');
    %% ����������� OFDM
    modDataOut = ofdmdemod(noiseData, lenFFT, cycPrefLen, cycPrefLen, nullCarrInd);
    %% ������ ������
    outPreambula = modDataOut(:,1:numSTS,:);
    modDataOut = modDataOut(:,(1 + numSTS):end,:);
    H_estim = obj.channelEstimate(outPreambula, ltfSC, numSTS);
    %% ����������
    tmpEqualizeData = obj.equalizerZFnumSC(modDataOut, H_estim);
    equalizeData = reshape(tmpEqualizeData, numSubCarr * numSymbOFDM, numSTS);
    %% �����������
    outData = qamdemod(equalizeData, modulation, 'OutputType', 'bit');
    %% �������� ������  
    numErrors = obj.calculateErrors(inpData, outData);   
end