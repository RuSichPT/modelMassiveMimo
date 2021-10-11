function H_estim = channelSounding(obj, snr)
    % ��������������� ����������  
    numTx = obj.main.numTx;
    lenFFT = obj.ofdm.lengthFFT;
    cycPrefLen = obj.ofdm.cyclicPrefixLength;
    nullCarrInd = obj.ofdm.nullCarrierIndices;    
    downChann = obj.channel.downChannel;  
    %% ��������� ���������
    [preambulaOFDM, ltfSC] = obj.generatePreamble(numTx);
    %% ����������� ������
    channelPreambula = obj.passChannel(preambulaOFDM, downChann);
    %% �����������  ���
    noisePreambula = awgn(channelPreambula, snr, 'measured');
    %% ����������� OFDM
    outPreambula = ofdmdemod(noisePreambula, lenFFT, cycPrefLen, cycPrefLen, nullCarrInd);
    %% ������ ������  
    H_estim = obj.channelEstimate(outPreambula, ltfSC, numTx);
end

