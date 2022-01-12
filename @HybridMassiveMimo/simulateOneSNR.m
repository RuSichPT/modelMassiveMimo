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
    %% Цифровое прекодирование BB beamforming
    [precodData,Frf] = obj.applyPrecod(inpModData, H_estim_zond);
    %% Модулятор OFDM  
    dataOFDMbb = ofdmmod(precodData, lenFFT, cycPrefLen, nullCarrInd);  
    obj.dataOFDM = dataOFDMbb;
    %% Аналоговое прекодирование RF beamforming: Apply Frf to the digital signal
    %   Each antenna element is connected to each data stream
    dataOFDMrf = [];
    subsetNumTx = obj.main.numTx/obj.main.numSubArray;
    subsetNumSTS = obj.main.numSTS/obj.main.numSubArray;
    for i = 1:obj.main.numSubArray
        tmpDataOFDMbb = dataOFDMbb(:,1+(i-1)*subsetNumSTS:i*subsetNumSTS);
        tmpFrf = Frf(1+(i-1)*subsetNumSTS:i*subsetNumSTS,1+(i-1)*subsetNumTx:i*subsetNumTx);
        tmpDataOFDMrf = tmpDataOFDMbb*tmpFrf;
        dataOFDMrf = cat(2,dataOFDMrf,tmpDataOFDMrf);
    end
    %% Прохождение канала
    channelData = obj.passChannel(dataOFDMrf, downChann);
    %% Собственный шум
    noiseData = awgn(channelData, snr, 'measured');
    %% Демодулятор OFDM
    modDataOut = ofdmdemod(noiseData, lenFFT, cycPrefLen, cycPrefLen, nullCarrInd);           
    %% Оценка канала
    outPreambula = modDataOut(:,1:numSTS,:);
    modDataOut = modDataOut(:,(1 + numSTS):end,:);
    H_estim = obj.channelEstimate(outPreambula, ltfSC, numSTS);
%     equalizeData1 = reshape(modDataOut, numSubCarr * numSymbOFDM, numSTS);
    %% Эквалайзер
    tmpEqualizeData = obj.equalizerZFnumSC(modDataOut, H_estim);
    equalizeData = reshape(tmpEqualizeData, numSubCarr * numSymbOFDM, numSTS);
    %% Демодулятор
    outData = qamdemod(equalizeData, modulation, 'OutputType', 'bit');
    %% Выходные данные  
    numErrors = obj.calculateErrors(inpData, outData);   
end