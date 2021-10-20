function [numErrors, numBits] = simulateOneSNRphased(obj, snr)
    % Переопределение переменных
    numSTS = obj.main.numSTS;
    numTx = obj.main.numTx;
    modulation = obj.main.modulation;
    bps = obj.main.bps;
    lenFFT = obj.ofdm.lengthFFT;
    cycPrefLen = obj.ofdm.cyclicPrefixLength;
    nullCarrInd = obj.ofdm.nullCarrierIndices;
    numSymbOFDM = obj.ofdm.numSymbOFDM;
    numSubCarr = obj.ofdm.numSubCarriers;
    downChann = obj.channel.downChannel;
    %% Зондирование канала
    H_estim_zond = obj.channelSoundingPhased(snr);
    %% Формируем данные
    numBits = bps * numSymbOFDM * numSubCarr;
    inpData = randi([0 1], numBits, numSTS);
    %% Модулятор 
    tmpModData = qammod(inpData, modulation, 'InputType', 'bit');
    inpModData = reshape(tmpModData, numSubCarr, numSymbOFDM, numSTS);
    %% Модулятор пилотов
    [preambula, ltfSC] = obj.generatePreamble(numSTS);
    inpModData = cat(2, preambula, inpModData);
    %% Прекодирование
    [precodData, ~] = obj.applyPrecod(inpModData, H_estim_zond);
    %% Модулятор OFDM  
    dataSTS_OFDM = ofdmmod(precodData, lenFFT, cycPrefLen, nullCarrInd);  
    %% Повторяем на каждую антенну Tx
    dataOFDM = zeros(size(dataSTS_OFDM,1),numTx);
    expFactorTx = numTx/numSTS;
    for i = 1:numSTS
        dataOFDM(:,(i-1)*expFactorTx+(1:expFactorTx)) = repmat(dataSTS_OFDM(:,i), 1, expFactorTx);
    end
    obj.dataOFDM = dataOFDM;
    %% Прохождение канала
    channelData = obj.passChannel(dataOFDM, downChann);
    %% Собственный шум
    noiseData = awgn(channelData, snr, 'measured');
    %% Демодулятор OFDM
    modDataOut = ofdmdemod(noiseData, lenFFT, cycPrefLen, cycPrefLen, nullCarrInd);
    %% Оценка канала
    outPreambula = modDataOut(:,1:numSTS,:);
    modDataOut = modDataOut(:,(1 + numSTS):end,:);
    H_estim = obj.channelEstimate(outPreambula, ltfSC, numSTS);
    %% Эквалайзер
    tmpEqualizeData = obj.equalizerZFnumSC(modDataOut, H_estim);
    equalizeData = reshape(tmpEqualizeData, numSubCarr * numSymbOFDM, numSTS);
    %% Демодулятор
    outData = qamdemod(equalizeData, modulation, 'OutputType', 'bit');
    %% Выходные данные  
    numErrors = obj.calculateErrors(inpData, outData);   
end