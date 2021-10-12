function [numErrors, numBits] = simulateOneSNR(obj, snr)
    % Переопределение переменных
    numSTS = obj.main.numSTS;
    modulation = obj.main.modulation;
    bps = obj.main.bps;
    lenFFT = obj.ofdm.lengthFFT;
    cycPrefLen = obj.ofdm.cyclicPrefixLength;
    nullCarrInd = obj.ofdm.nullCarrierIndices;
    numSymbOFDM = obj.ofdm.numSymbOFDM;
    numSubCarr = obj.ofdm.numSubCarriers;
    downChann = obj.channel.downChannel;
    %% Зондирование канала
    H_estim_zond = obj.channelSounding(snr);
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
    dataOFDM = ofdmmod(precodData, lenFFT, cycPrefLen, nullCarrInd);  
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