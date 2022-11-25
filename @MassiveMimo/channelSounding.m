function [Hestim, HestimCell] = channelSounding(obj,snr,soundAllChannels)
    % Переопределение переменных
    numTx = obj.main.numTx;
    numSTS = obj.main.numSTS;
    numUsers = obj.main.numUsers;
    lenFFT = obj.ofdm.lengthFFT;
    cycPrefLen = obj.ofdm.cyclicPrefixLength;
    nullCarrInd = obj.ofdm.nullCarrierIndices;
    downChan = obj.downChannel; 
    %% Формируем преамбулу
    if soundAllChannels
        numSTS = numTx; % Гнерируем преамбулу по всем каналам
        [preamble, ltfSC] = obj.generatePreamble(numSTS);
    else
        [preambleSTS, ltfSC] = obj.generatePreamble(numSTS);

        % Повторяем данные на каждую антенну
        expFactorTx = numTx/numSTS;  
        preamble = repeatDataSC(preambleSTS,numSTS,expFactorTx);
    end
    %% Модулятор OFDM  
    preambleOFDM = ofdmmod(preamble,lenFFT,cycPrefLen,nullCarrInd);
    %% Прохождение канала
    channelPreamble = downChan.pass(preambleOFDM);
    HestimCell = cell(numUsers,1);
    for uIdx = 1:numUsers
        %% Собственный шум
        noisePreamble = awgn(channelPreamble{uIdx,:},snr,'measured');
        %% Демодулятор OFDM
        outPreamble = ofdmdemod(noisePreamble,lenFFT,cycPrefLen,cycPrefLen,nullCarrInd);
        %% Оценка канала  
        HestimCell{uIdx} = obj.channelEstimate(outPreamble,ltfSC,numSTS);
    end
    Hestim = cat(3,HestimCell{:});
end
function newInData = repeatDataSC(inData,numSTS,expFactor)
    newInData = zeros(size(inData,1),size(inData,2),numSTS*expFactor);
    
    for i = 1:numSTS
        newInData(:,:,(i-1)*expFactor+(1:expFactor)) = repmat(inData(:,:,i),1,1,expFactor);
    end
end