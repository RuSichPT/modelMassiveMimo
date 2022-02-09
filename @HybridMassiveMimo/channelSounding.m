function [H_estim, H_estimUsers] = channelSounding(obj, snr)
    % Переопределение переменных  
    numTx = obj.main.numTx;
    numUsers = obj.main.numUsers;
    lenFFT = obj.ofdm.lengthFFT;
    cycPrefLen = obj.ofdm.cyclicPrefixLength;
    nullCarrInd = obj.ofdm.nullCarrierIndices;    
    downChann = obj.channel.downChannel;  
    %% Формируем преамбулу
    [preamble, ltfSC] = obj.generatePreamble(numTx);
    %% Модулятор OFDM  
    preambleOFDM = ofdmmod(preamble, lenFFT, cycPrefLen, nullCarrInd);
    
    H_estimUsers = cell(numUsers, 1);
    for uIdx = 1:numUsers
        %% Прохождение канала
        channelPreamble = obj.passChannel(preambleOFDM, downChann{uIdx});
        %% Собственный шум
        noisePreamble = awgn(channelPreamble, snr, 'measured');
        %% Демодулятор OFDM
        outPreamble = ofdmdemod(noisePreamble, lenFFT, cycPrefLen, cycPrefLen, nullCarrInd);
        %% Оценка канала  
        H_estimUsers{uIdx} = obj.channelEstimate(outPreamble, ltfSC, numTx);
    end
    H_estim = cat(3,H_estimUsers{:});
end

