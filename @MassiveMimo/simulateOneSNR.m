function [numErrors, numBits] = simulateOneSNR(obj, snr)
    % Переопределение переменных
    numUsers = obj.main.numUsers; 
    numSTS = obj.main.numSTS;
    numPhasedElemRx = obj.main.numPhasedElemRx;
    numSTSVec = obj.main.numSTSVec;
    numRxVec = numSTSVec*numPhasedElemRx;
    modulation = obj.main.modulation;
    numUsers = obj.main.numUsers;
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
    [precodData, ~, ~] = obj.applyPrecod(inpModData, H_estim_zond);
    %% Модулятор OFDM  
    dataOFDM = ofdmmod(precodData, lenFFT, cycPrefLen, nullCarrInd);  
    obj.dataOFDM = dataOFDM;
    
    outData = cell(numUsers,1);
    for uIdx = 1:numUsers
        stsU = numSTSVec(uIdx);
        stsIdx = sum(numSTSVec(1:(uIdx-1)))+(1:stsU);
        %% Прохождение канала
        channelData = obj.passChannel(dataOFDM, downChann{uIdx});
        %% Собственный шум
        noiseData = awgn(channelData, snr, 'measured');
%         %% Сумматор на приеме
%         adder = cell(numSTSVec(uIdx), 1);
%         for i = 1:numSTSVec(uIdx)
%             adder{i} = ones(numPhasedElemRx,1);
%         end
%         adder = blkdiag(adder{:});
%         sumData = noiseData*adder;
        %% Демодулятор OFDM
        modDataOut = ofdmdemod(noiseData, lenFFT, cycPrefLen, cycPrefLen, nullCarrInd);           
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