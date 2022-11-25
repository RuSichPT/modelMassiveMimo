function [numErrors,numBits,SINR_dB] = simulateOneSNR(obj,snr)
    addpath('Precoders');
    % Переопределение переменных
    numTx = obj.main.numTx;
    numRx = obj.main.numRx;
    numSTS = obj.main.numSTS;
    numSTSVec = obj.main.numSTSVec;
    modulation = obj.main.modulation;
    numUsers = obj.main.numUsers;
    precoderType = obj.main.precoderType;
    bps = obj.main.bps;
    lenFFT = obj.ofdm.lengthFFT;
    cycPrefLen = obj.ofdm.cyclicPrefixLength;
    nullCarrInd = obj.ofdm.nullCarrierIndices;
    numSymbOFDM = obj.ofdm.numSymbOFDM;
    numSubCarr = obj.ofdm.numSubCarriers;
    downChann = obj.downChannel;
    %% Зондирование канала
    if (obj.main.precoderType == "DIAG") && (numUsers == 1)
        soundAllChannels = 0; 
    else
        soundAllChannels = 1; % Зондированеи всех каналов 
    end
    [~,HestimZondCell] = obj.channelSounding(snr,soundAllChannels);
    %% Формируем данные
    numBits = bps * numSymbOFDM * numSubCarr;
    inpData = randi([0 1], numBits, numSTS);
    %% Модулятор 
    tmpModData = qammod(inpData, modulation, 'InputType', 'bit');
    inpModData = reshape(tmpModData, numSubCarr, numSymbOFDM, numSTS);
    %% Модулятор пилотов
    [preambula, ltfSC] = obj.generatePreamble(numSTS);
    inpModData = cat(2, preambula, inpModData);
    %% Повторяем данные на каждую антенну
    if (precoderType ~= "DIAG") && (numRx ~= numSTS)
        expFactorRx = numRx/numSTS;
        inpModData = repeatDataSC(inpModData,numSTS,expFactorRx);
    end
    %% Прекодирование
    precoder = DigitalPrecoder(precoderType,obj.main,HestimZondCell);
    precodData = precoder.apply(inpModData);
    %% Модулятор OFDM
    dataOFDM = ofdmmod(precodData, lenFFT, cycPrefLen, nullCarrInd);
    %% Повторяем данные на каждую антенну (можно и до OFDM - не влияет)
    if (precoderType == "DIAG") && (numUsers == 1)
        expFactorTx = numTx/numSTS;
        dataOFDM = repeatData(dataOFDM,numSTS,expFactorTx);
    end
    %% Прохождение канала
    channelData = downChann.pass(dataOFDM);
    %%
    outData = cell(numUsers,1);
    sigma = zeros(numUsers,1);
    SINR_dB = zeros(numUsers,1);
    for uIdx = 1:numUsers
        stsU = numSTSVec(uIdx);
        stsIdx = sum(numSTSVec(1:(uIdx-1)))+(1:stsU);
        %% Собственный шум
        noiseData = awgn(channelData{uIdx,:}, snr, 'measured');
        %% Демодулятор OFDM
        modDataOut = ofdmdemod(noiseData, lenFFT, cycPrefLen, cycPrefLen, nullCarrInd);
        %% Обьединитель
%         modDataOut = obj.applyComb(modDataOut, combWeights{uIdx});
        %% Оценка канала
        outPreambula = modDataOut(:,1:numSTS,:);
        modDataOut = modDataOut(:,(1 + numSTS):end,:);
        H_estim = obj.channelEstimate(outPreambula, ltfSC, numSTS);
        %% Эквалайзер
        tmpEqualizeData = obj.equalizerZFnumSC(modDataOut, H_estim(:,stsIdx,:));
        equalizeData = reshape(tmpEqualizeData, numSubCarr * numSymbOFDM, numSTSVec(uIdx));
        %% sigma (СКО) SNR
        inpModDataTmp = squeeze(inpModData(:,:,stsIdx));
        inpModDataTmp = inpModDataTmp(:,(1 + numSTS):end,:);
        A = rms(inpModDataTmp(:));
        sigma(uIdx) = rms(equalizeData(:) - inpModDataTmp(:));
        SINR_dB(uIdx) = 20*log10(A/sigma(uIdx));
        %% Демодулятор
        outData{uIdx} = qamdemod(equalizeData, modulation, 'OutputType', 'bit');
    end
    %% Выходные данные
    outData = cat(2,outData{:});
    numErrors = obj.calculateErrors(inpData, outData); 
end
%%
function newInData = repeatDataSC(inData,numSTS,expFactor)
    newInData = zeros(size(inData,1),size(inData,2),numSTS*expFactor);
    
    for i = 1:numSTS
        newInData(:,:,(i-1)*expFactor+(1:expFactor)) = repmat(inData(:,:,i),1,1,expFactor);
    end
end
function newInData = repeatData(inData,numSTS,expFactor)
    newInData = zeros(size(inData,1),numSTS*expFactor);
    
    for i = 1:numSTS
        newInData(:,(i-1)*expFactor+(1:expFactor)) = repmat(inData(:,i),1,expFactor);
    end
end