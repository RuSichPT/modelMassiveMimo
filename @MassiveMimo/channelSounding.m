function H_estim = channelSounding(obj, snr)
    % Переопределение переменных  
    numTx = obj.main.numTx;
    numPhasedElemRx = obj.main.numPhasedElemRx;
    numSTSVec = obj.main.numSTSVec;
    numRxVec = numSTSVec*numPhasedElemRx;
    numUsers = obj.main.numUsers;
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
    
%     %1 вариант
%     %% Демодулятор OFDM
%     outPreamble = ofdmdemod(noisePreamble, lenFFT, cycPrefLen, cycPrefLen, nullCarrInd);
%     %% Оценка канала  
%     H_estim = obj.channelEstimate(outPreamble, ltfSC, numTx);

    %2 вариант
    H_estim = cell(numUsers, 1);
    for uIdx = 1:numUsers
        %% Сумматор на приеме
        rxU = numRxVec(uIdx);
        rxIdx = sum(numRxVec(1:(uIdx-1)))+(1:rxU);
        adder = cell(numSTSVec(uIdx), 1);
        for i = 1:numSTSVec(uIdx)
            adder{i} = ones(numPhasedElemRx,1);
        end
        adder = blkdiag(adder{:});
        sumPreamble = noisePreamble(:,rxIdx)*adder;
        %% Демодулятор OFDM
        outPreamble = ofdmdemod(sumPreamble, lenFFT, cycPrefLen, cycPrefLen, nullCarrInd);
        %% Оценка канала  
        H_estim{uIdx} = obj.channelEstimate(outPreamble, ltfSC, numTx);
    end
    H_estim = cat(3,H_estim{:});
end

