function H_estim = estimateUplink1(obj, snr)
    % Переопределение переменных 
    numRx = obj.main.numRx;
    lenFFT = obj.ofdm.lengthFFT;
    cycPrefLen = obj.ofdm.cyclicPrefixLength;
    nullCarrInd = obj.ofdm.nullCarrierIndices;
    upChann = obj.channel.upChannel;  
    %% Формируем преамбулу
    [preambula, ltfSC] = obj.generatePreamble2(numRx);
    %% Модулятор OFDM
    preambulaOFDM = ofdmmod(preambula, lenFFT, cycPrefLen, nullCarrInd);
    %% Прохождение канала
    channelPreambula = obj.passChannel(preambulaOFDM, upChann);
    %% Собственный шум
    noisePreambula = awgn(channelPreambula, snr, 'measured');
    %% Демодулятор OFDM
    outPreambula = ofdmdemod(noisePreambula, lenFFT, cycPrefLen, cycPrefLen, nullCarrInd);
    %% Оценка канала  
    H_estim = obj.channelEstimate1(outPreambula, ltfSC, numRx);
    H_estim = conj(permute(H_estim, [1,3,2]));
end

