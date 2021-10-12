function H_estim = estimateUplink (obj, snr)
    % ��������������� ���������� 
    numRx = obj.main.numRx;
    lenFFT = obj.ofdm.lengthFFT;
    cycPrefLen = obj.ofdm.cyclicPrefixLength;
    nullCarrInd = obj.ofdm.nullCarrierIndices;
    upChann = obj.channel.upChannel;  
    %% ��������� ���������
    [preambula, ltfSC] = obj.generatePreamble(numRx);
    %% ��������� OFDM
    preambulaOFDM = ofdmmod(preambula, lenFFT, cycPrefLen, nullCarrInd);
    %% ����������� ������
    channelPreambula = obj.passChannel(preambulaOFDM, upChann);
    %% ����������� ���
    noisePreambula = awgn(channelPreambula, snr, 'measured');
    %% ����������� OFDM
    outPreambula = ofdmdemod(noisePreambula, lenFFT, cycPrefLen, cycPrefLen, nullCarrInd);
    %% ������ ������  
    H_estim = obj.channelEstimate(outPreambula, ltfSC, numRx);
    H_estim = conj(permute(H_estim, [1,3,2]));
end

