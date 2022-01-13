function [numErrors, numBits] = simulateOneSNR(obj, snr)
    % Переопределение переменных
    numTx = obj.main.numTx;
    numSTS = obj.main.numSTS;
    numRF = obj.main.numRF;
    hybridType = obj.main.hybridType; 
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
    if (hybridType == "sub")
        subNumTx = numTx/numRF;
        subNumSTS = numSTS/numRF;
        tmpFrf = cell(1,numRF);
        for i = 1:numRF
            tmpFrf{i} = Frf(1+(i-1)*subNumSTS:i*subNumSTS, 1+(i-1)*subNumTx:i*subNumTx);
        end
        Frf = blkdiag(tmpFrf{:});
    end
    dataOFDMrf = dataOFDMbb*Frf;
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