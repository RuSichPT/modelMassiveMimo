function [numErrors, numBits] = simulateOneSNRCoder(obj, snr)
    % Переопределение переменных
    numTx = obj.main.numTx;
    numSTS = obj.main.numSTS;
    numRF = obj.main.numRF;
    numSTSVec = obj.main.numSTSVec;
    hybridType = obj.main.hybridType; 
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
    numBits = bps * numSymbOFDM * numSubCarr * 1/3 - 6;
    inpData = randi([0 1], numBits, numSTS);
    %% Кодер
    % Convolutional encoder
    encoder = comm.ConvolutionalEncoder( ...
        'TrellisStructure',poly2trellis(7,[133 171 165]), ...
        'TerminationMethod','Terminated');
    for stsIdx = 1:numSTS     
        encodedBits(:,stsIdx) = encoder(inpData(:,stsIdx));
    end
    %% Модулятор 
    tmpModData = qammod(encodedBits, modulation, 'InputType', 'bit', 'UnitAveragePower',true);
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
    %%
    decoder = comm.ViterbiDecoder('InputFormat','Unquantized', ...
    'TrellisStructure',poly2trellis(7, [133 171 165]), ...
    'TerminationMethod','Terminated','OutputDataType','double');
    outDataTmp = cell(numUsers,1);
    for uIdx = 1:numUsers
        stsU = numSTSVec(uIdx);
        stsIdx = sum(numSTSVec(1:(uIdx-1)))+(1:stsU);
        %% Прохождение канала
        channelData = obj.passChannel(dataOFDMrf, downChann{uIdx});
        %% Собственный шум
        noiseData = awgn(channelData, snr, 'measured');
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
        % Noise variance calculation for unity average signal power.
        noiseVar = 10.^(-snr/10);
        % Soft demodulation
        outLLR{uIdx} = qamdemod(equalizeData,modulation,'UnitAveragePower',true, ...
            'OutputType','approxllr','NoiseVariance',noiseVar);
%         outData{uIdx} = qamdemod(equalizeData, modulation, 'OutputType', 'bit');
        %% Декодер
        for stsIdx = 1:numSTSVec(uIdx)
            % Soft-input channel decoding
            outDataTmp{uIdx}(:,stsIdx) = decoder(outLLR{uIdx}(:,stsIdx));
        end
    end
    %% Выходные данные
    outDataTmp = cat(2,outDataTmp{:});
    outData = outDataTmp(1:end-6,:);
    numErrors = obj.calculateErrors(inpData, outData); 
end