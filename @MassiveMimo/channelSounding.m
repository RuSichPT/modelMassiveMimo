function H_estim = channelSounding(obj, snr)
    % Переопределение переменных  
    numTx = obj.main.numTx;
    lenFFT = obj.ofdm.lengthFFT;
    cycPrefLen = obj.ofdm.cyclicPrefixLength;
    nullCarrInd = obj.ofdm.nullCarrierIndices;    
    downChann = obj.channel.downChannel;  
    %% Формируем преамбулу
    [preamble, ltfSC] = obj.generatePreamble(numTx);
    %% Модулятор OFDM  
    preambleOFDM = ofdmmod(preamble, lenFFT, cycPrefLen, nullCarrInd);  
    %% Прохождение канала
    channelPreamble = obj.passChannel(preambleOFDM, downChann);
    %% Собственный шум
    noisePreamble = awgn(channelPreamble, snr, 'measured');
    %% Демодулятор OFDM
    outPreamble = ofdmdemod(noisePreamble, lenFFT, cycPrefLen, cycPrefLen, nullCarrInd);
    %% Оценка канала  
    H_estim = obj.channelEstimate(outPreamble, ltfSC, numTx);
end

