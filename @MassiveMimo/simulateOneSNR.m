function [numErrors, numBits] = simulateOneSNR(obj, snr)
    % Переопределение переменных
    numSTS = obj.main.numSTS;
    numSTSVec = obj.main.numSTSVec;
    modulation = obj.main.modulation;
    numUsers = obj.main.numUsers;
    bps = obj.main.bps;
    lenFFT = obj.ofdm.lengthFFT;
    cycPrefLen = obj.ofdm.cyclicPrefixLength;
    nullCarrInd = obj.ofdm.nullCarrierIndices;
    numSymbOFDM = obj.ofdm.numSymbOFDM;
    numSubCarr = obj.ofdm.numSubCarriers;
    downChann = obj.downChannel;
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
    [precodData, ~, combWeights] = obj.applyPrecod(inpModData, H_estim_zond);
    %% Модулятор OFDM  
    dataOFDM = ofdmmod(precodData, lenFFT, cycPrefLen, nullCarrInd);
    %% Прохождение канала
    channelData = downChann.pass(dataOFDM);
    %%
    outData = cell(numUsers,1);
    for uIdx = 1:numUsers
        stsU = numSTSVec(uIdx);
        stsIdx = sum(numSTSVec(1:(uIdx-1)))+(1:stsU);
        %% Собственный шум
        noiseData = awgn(channelData{uIdx,:}, snr, 'measured');
        %% Демодулятор OFDM
        modDataOut = ofdmdemod(noiseData, lenFFT, cycPrefLen, cycPrefLen, nullCarrInd);
        %% Обьединитель
        modDataOut = obj.applyComb(modDataOut, combWeights{uIdx});
        %% Оценка канала
        outPreambula = modDataOut(:,1:numSTS,:);
        modDataOut = modDataOut(:,(1 + numSTS):end,:);
        H_estim = obj.channelEstimate(outPreambula, ltfSC, numSTS);
        %% Эквалайзер
        tmpEqualizeData = obj.equalizerZFnumSC(modDataOut, H_estim(:,stsIdx,:));
        equalizeData = reshape(tmpEqualizeData, numSubCarr * numSymbOFDM, numSTSVec(uIdx));
        %% Демодулятор
        outData{uIdx} = qamdemod(equalizeData, modulation, 'OutputType', 'bit');
    end
    %% Выходные данные
    outData = cat(2,outData{:});
    numErrors = obj.calculateErrors(inpData, outData); 
end