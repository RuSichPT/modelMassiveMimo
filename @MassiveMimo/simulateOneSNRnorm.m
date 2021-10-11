function [numErrors, numBits] = simulateOneSNRnorm(obj, snr)
    %% Переопределение переменных
    numTx = obj.main.numTx;
    numSTS = obj.main.numSTS;
    modulation = obj.main.modulation;
    bps = obj.main.bps;
    lenFFT = obj.ofdm.lengthFFT;
    cycPrefLen = obj.ofdm.cyclicPrefixLength;
    nullCarrInd = obj.ofdm.nullCarrierIndices;
    numSymbOFDM = obj.ofdm.numSymbOFDM;
    numSubCarr = obj.ofdm.numSubCarriers;
    
    %% Зондирование канала
    % Формируем преамбулу
    [preambulaOFDMZond,zondLtfSC] = obj.generatePreamble(numTx);   
    % Прохождение канала
    channelPreambulaZond = obj.passChannel(preambulaOFDMZond);
    % Собственный  шум
    noisePreambulaZond = awgn(channelPreambulaZond, snr, 'measured');
    % Демодулятор OFDM
    outPreambulaZond = ofdmdemod(noisePreambulaZond, lenFFT, cycPrefLen, cycPrefLen, nullCarrInd);
    % Оценка канала  
    H_estim_zond = obj.channelEstimate(outPreambulaZond, zondLtfSC, numTx); 
    %% Формируем данные
    numBits = bps * numSymbOFDM * numSubCarr;
    inpData = randi([0 1], numBits, numSTS);
    %% Модулятор 
    tmpModData = qammod(inpData, modulation, 'InputType', 'bit');
    inpModData = reshape(tmpModData, numSubCarr, numSymbOFDM, numSTS);
    %% Прекодирование
    [precodData, precodWeights] = obj.applyPrecod(inpModData, H_estim_zond);           
    %% Модулятор пилотов  
    [inpPreambula, ltfSC] = obj.generatePreamble(numSTS, precodWeights);
    %% Модулятор OFDM
    tmpdataOFDM = ofdmmod(precodData, lenFFT, cycPrefLen, nullCarrInd);                            
    dataOFDM = [inpPreambula ; tmpdataOFDM];
    %% Прохождение канала
    channelData = obj.passChannel(dataOFDM);
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

