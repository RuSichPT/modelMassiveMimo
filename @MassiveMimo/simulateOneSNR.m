function [numErrors, numBits] = simulateOneSNR(obj, snr)
    %% Зондирование канала
    [preambulaOFDMZond,zondLtfSC] = obj.generatePreamble(obj.numTx);
    % Прохождение канала
    channelPreambulaZond = obj.passChannel(preambulaOFDMZond);
    % Собственный  шум
    noisePreambulaZond = awgn(channelPreambulaZond, snr, 'measured');
    % Демодулятор OFDM
    outPreambulaZond = ofdmdemod(noisePreambulaZond, obj.lengthFFT, obj.cyclicPrefixLength, obj.cyclicPrefixLength, ...
                                    obj.nullCarrierIndices);
    % Оценка канала  
    H_estim_zond = obj.channelEstimate(outPreambulaZond, zondLtfSC, obj.numTx); 
    %% Формируем данные
    numBits = obj.bps * obj.numSymbOFDM * obj.numSubCarriers;
    inpData = randi([0 1], numBits, obj.numSTS);
    %% Модулятор 
    tmpModData = qammod(inpData, obj.modulation, 'InputType', 'bit');
    inpModData = reshape(tmpModData, obj.numSubCarriers, obj.numSymbOFDM, obj.numSTS);
    %% Прекодирование
    [precodData, precodWeights] = obj.applyPrecod(inpModData, H_estim_zond);           
    %% Модулятор пилотов  
    [inpPreambula, ltfSC] = obj.generatePreamble(obj.numSTS, precodWeights);
    %% Модулятор OFDM
    tmpdataOFDM = ofdmmod(precodData, obj.lengthFFT, obj.cyclicPrefixLength, obj.nullCarrierIndices);                            
    dataOFDM = [inpPreambula ; tmpdataOFDM];
    %% Прохождение канала
    channelData = obj.passChannel(dataOFDM);
    %% Собственный шум
    noiseData = awgn(channelData, snr, 'measured');
    %% Демодулятор OFDM
    modDataOut = ofdmdemod(noiseData, obj.lengthFFT, obj.cyclicPrefixLength, obj.cyclicPrefixLength, obj.nullCarrierIndices);           
    %% Оценка канала
    outPreambula = modDataOut(:,1:obj.numSTS,:);
    modDataOut = modDataOut(:,(1 + obj.numSTS):end,:);
    H_estim = obj.channelEstimate(outPreambula, ltfSC, obj.numSTS);
    %% Эквалайзер
    tmpEqualizeData = obj.equalizerZFnumSC(modDataOut, H_estim);
    equalizeData = reshape(tmpEqualizeData, obj.numSubCarriers * obj.numSymbOFDM, obj.numSTS);
    %% Демодулятор
    outData = qamdemod(equalizeData, obj.modulation, 'OutputType', 'bit');
    %% Выходные данные  
    numErrors = obj.calculateErrors(inpData, outData);   
end

