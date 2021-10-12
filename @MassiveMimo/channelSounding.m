function H_estim = channelSounding(obj, snr)
    % ��������������� ����������  
    numTx = obj.main.numTx;
    lenFFT = obj.ofdm.lengthFFT;
    cycPrefLen = obj.ofdm.cyclicPrefixLength;
    nullCarrInd = obj.ofdm.nullCarrierIndices;    
    downChann = obj.channel.downChannel;  
    %% ��������� ���������
    [preamble, ltfSC] = obj.generatePreamble(numTx);
    %% ��������� OFDM  
    preambleOFDM = ofdmmod(preamble, lenFFT, cycPrefLen, nullCarrInd);  
    %% ����������� ������
    channelPreamble = obj.passChannel(preambleOFDM, downChann);
    %% ����������� ���
    noisePreamble = awgn(channelPreamble, snr, 'measured');
    %% ����������� OFDM
    outPreamble = ofdmdemod(noisePreamble, lenFFT, cycPrefLen, cycPrefLen, nullCarrInd);
    %% ������ ������  
    H_estim = obj.channelEstimate(outPreamble, ltfSC, numTx);
end

