function H_estim = channelSoundingPhased(obj, snr)
    % Переопределение переменных  
    numTx = obj.main.numTx;
    numSTS = obj.main.numSTS;
    lenFFT = obj.ofdm.lengthFFT;
    cycPrefLen = obj.ofdm.cyclicPrefixLength;
    nullCarrInd = obj.ofdm.nullCarrierIndices;    
    downChann = obj.channel.downChannel;  
    %% Формируем преамбулу
    [preambleSTS, ltfSC] = obj.generatePreamble(numSTS);
    %% Модулятор OFDM  
    preambleSTS_OFDM = ofdmmod(preambleSTS, lenFFT, cycPrefLen, nullCarrInd);
    %% Повторяем на каждую антенну Tx
    preambleOFDM = zeros(size(preambleSTS_OFDM,1),numTx);
    expFactorTx = numTx/numSTS;
    for i = 1:numSTS
        preambleOFDM(:,(i-1)*expFactorTx+(1:expFactorTx)) = repmat(preambleSTS_OFDM(:,i), 1, expFactorTx);
    end
    %% Прохождение канала
    channelPreamble = obj.passChannel(preambleOFDM, downChann);
    %% Собственный шум
    noisePreamble = awgn(channelPreamble, snr, 'measured');
    %% Демодулятор OFDM
    outPreamble = ofdmdemod(noisePreamble, lenFFT, cycPrefLen, cycPrefLen, nullCarrInd);
    %% Оценка канала  
    H_estim = obj.channelEstimate(outPreamble, ltfSC, numSTS);
end