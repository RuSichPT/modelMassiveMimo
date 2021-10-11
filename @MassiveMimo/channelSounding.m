function H_estim = channelSounding(obj, snr)
    % Переопределение переменных  
    numTx = obj.main.numTx;
    lenFFT = obj.ofdm.lengthFFT;
    cycPrefLen = obj.ofdm.cyclicPrefixLength;
    nullCarrInd = obj.ofdm.nullCarrierIndices;    
    downChann = obj.channel.downChannel;  
    %% Формируем преамбулу
    [preambulaOFDM, ltfSC] = obj.generatePreamble(numTx);
    %% Прохождение канала
    channelPreambula = obj.passChannel(preambulaOFDM, downChann);
    %% Собственный  шум
    noisePreambula = awgn(channelPreambula, snr, 'measured');
    %% Демодулятор OFDM
    outPreambula = ofdmdemod(noisePreambula, lenFFT, cycPrefLen, cycPrefLen, nullCarrInd);
    %% Оценка канала  
    H_estim = obj.channelEstimate(outPreambula, ltfSC, numTx);
end

