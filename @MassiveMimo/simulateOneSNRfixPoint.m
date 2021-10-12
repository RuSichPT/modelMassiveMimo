function [numErrors, numBits] = simulateOneSNRfixPoint(obj, snr, numFixPoint, roundingType)
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
    downChann = obj.channel.downChannel;
    %% Зондирование канала
    % Формируем преамбулу
    [preambulaOFDMZond, zondLtfSC] = obj.generatePreambleOFDM(numTx);
    preambulaOFDMZond = round(preambulaOFDMZond, numFixPoint, roundingType);
    % Прохождение канала
    channelPreambulaZond = obj.passChannel(preambulaOFDMZond, downChann);
    channelPreambulaZond = round(channelPreambulaZond, numFixPoint, roundingType);
    % Собственный  шум
    noisePreambulaZond = awgn(channelPreambulaZond, snr, 'measured');
    noisePreambulaZond = round(noisePreambulaZond, numFixPoint, roundingType);
    % Демодулятор OFDM
    outPreambulaZond = ofdmdemod(noisePreambulaZond, lenFFT, cycPrefLen, cycPrefLen, ...
                                    nullCarrInd);
    outPreambulaZond = round(outPreambulaZond, numFixPoint, roundingType);
    % Оценка канала  
    H_estim_zond = obj.channelEstimate(outPreambulaZond, zondLtfSC, numTx);
    H_estim_zond = round(H_estim_zond, numFixPoint, roundingType);
    %% Формируем данные
    numBits = bps * numSymbOFDM * numSubCarr;
    inpData = randi([0 1], numBits, numSTS);
    %% Модулятор 
    tmpModData = qammod(inpData, modulation, 'InputType', 'bit');
    inpModData = reshape(tmpModData, numSubCarr, numSymbOFDM, numSTS);
    %% Прекодирование
    [precodData, precodWeights] = obj.applyPrecod(inpModData, H_estim_zond);
    precodData = round(precodData, numFixPoint, roundingType);
    precodWeights = round(precodWeights, numFixPoint, roundingType);
    %% Модулятор пилотов  
    [inpPreambula, ltfSC] = obj.generatePreambleOFDM(numSTS, precodWeights);
    %% Модулятор OFDM
    tmpdataOFDM = ofdmmod(precodData, lenFFT, cycPrefLen, nullCarrInd);                            
    dataOFDM = [inpPreambula ; tmpdataOFDM];
    dataOFDM = round(dataOFDM, numFixPoint, roundingType);
    %% Прохождение канала
    channelData = obj.passChannel(dataOFDM, downChann);
    channelData = round(channelData, numFixPoint, roundingType);
    %% Собственный шум
    noiseData = awgn(channelData, snr, 'measured');
    noiseData = round(noiseData, numFixPoint, roundingType); 
    %% Демодулятор OFDM
    modDataOut = ofdmdemod(noiseData, lenFFT, cycPrefLen, cycPrefLen, nullCarrInd);
    modDataOut = round(modDataOut, numFixPoint, roundingType); 
    %% Оценка канала
    outPreambula = modDataOut(:,1:numSTS,:);
    modDataOut = modDataOut(:,(1 + numSTS):end,:);
    H_estim = obj.channelEstimate(outPreambula, ltfSC, numSTS);
    H_estim = round(H_estim, numFixPoint, roundingType);
    %% Эквалайзер
    tmpEqualizeData = obj.equalizerZFnumSC(modDataOut, H_estim);
    equalizeData = reshape(tmpEqualizeData, numSubCarr * numSymbOFDM, numSTS);
    equalizeData = round(equalizeData, numFixPoint, roundingType);
    %% Демодулятор
    outData = qamdemod(equalizeData, modulation, 'OutputType', 'bit');
    %% Выходные данные  
    numErrors = obj.calculateErrors(inpData, outData);   
end

