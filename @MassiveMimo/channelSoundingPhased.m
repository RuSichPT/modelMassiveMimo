function H_estim = channelSoundingPhased(obj, snr)
    % ��������������� ����������  
    numTx = obj.main.numTx;
    numSTS = obj.main.numSTS;
    lenFFT = obj.ofdm.lengthFFT;
    cycPrefLen = obj.ofdm.cyclicPrefixLength;
    nullCarrInd = obj.ofdm.nullCarrierIndices;    
    downChann = obj.channel.downChannel;  
    %% ��������� ���������
    [preambleSTS, ltfSC] = obj.generatePreamble(numSTS);
    %% ��������� OFDM  
    preambleSTS_OFDM = ofdmmod(preambleSTS, lenFFT, cycPrefLen, nullCarrInd);
    %% ��������� �� ������ ������� Tx
    preambleOFDM = zeros(size(preambleSTS_OFDM,1),numTx);
    expFactorTx = numTx/numSTS;
    for i = 1:numSTS
        preambleOFDM(:,(i-1)*expFactorTx+(1:expFactorTx)) = repmat(preambleSTS_OFDM(:,i), 1, expFactorTx);
    end
    %% ����������� ������
    channelPreamble = obj.passChannel(preambleOFDM, downChann);
    %% ����������� ���
    noisePreamble = awgn(channelPreamble, snr, 'measured');
    %% ����������� OFDM
    outPreamble = ofdmdemod(noisePreamble, lenFFT, cycPrefLen, cycPrefLen, nullCarrInd);
    %% ������ ������  
    H_estim = obj.channelEstimate(outPreamble, ltfSC, numSTS);
end