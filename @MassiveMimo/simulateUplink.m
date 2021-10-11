function H_estim = simulateUplink(obj, snr)
    % Переопределение переменных 
    numRx = obj.main.numRx;
    numSubCarr = obj.ofdm.numSubCarriers;
    lenFFT = obj.ofdm.lengthFFT;
    cycPrefLen = obj.ofdm.cyclicPrefixLength;
    nullCarrInd = obj.ofdm.nullCarrierIndices;
    upChann = obj.channel.upChannel;  
    %% Формируем данные 
    x = randi([0 1], numSubCarr, 1);
    %% Модулятор 
    ltfSC = pskmod(x,2);

    P = helperGetP(numRx);    
    Pred = P;
    
    Nltf = numRx;
    ltfTx = zeros(numSubCarr, Nltf, numRx);
    for i = 1:Nltf   
        ltf = ltfSC*Pred(:, i).';                
        ltfTx(:,i,:) = ltf;
    end
    %% Модулятор OFDM
    preambula = ofdmmod(ltfTx, lenFFT, cycPrefLen, nullCarrInd);
    %% Прохождение канала
    channelPreambula = obj.passChannel(preambula, upChann);
    %% Собственный шум
    noisePreambula = awgn(channelPreambula, snr, 'measured');
    %% Демодулятор OFDM
    outPreambula = ofdmdemod(noisePreambula, lenFFT, cycPrefLen, cycPrefLen, nullCarrInd);
    %% Оценка канала  
    H_estim = obj.channelEstimate(outPreambula, ltfSC, numRx);
    H_estim = conj(permute(H_estim, [1,3,2]));
end

