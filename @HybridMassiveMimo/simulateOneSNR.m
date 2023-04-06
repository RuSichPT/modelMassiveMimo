function [numErrors,numBits,SINR_dB] = simulateOneSNR(obj,snr)
    % Переопределение переменных
    numSTS = obj.main.numSTS;
    numSTSVec = obj.main.numSTSVec;
    hybridType = obj.hybridType; 
    numRF = obj.numRF;
    mod = obj.modulation;
    numUsers = obj.main.numUsers;
    precodType = obj.precoderType;
    bps = obj.bps;
    lenFFT = obj.ofdm.lengthFFT;
    cycPrefLen = obj.ofdm.cyclicPrefixLength;
    nullCarrInd = obj.ofdm.nullCarrierIndices;
    numSymbOFDM = obj.ofdm.numSymbOFDM;
    numSubCarr = obj.ofdm.numSubCarriers;
    downChann = obj.downChannel;
    downChann.create();
    %% Зондирование канала
    soundAllChannels = 1; % Зондирование всех каналов
    [~,HestimZondCell] = obj.channelSounding(snr,soundAllChannels);
    %% Формируем данные
    numBits = bps * numSymbOFDM * numSubCarr;
    inpData = randi([0 1], numBits, numSTS);
    %% Модулятор 
    tmpModData = qammod(inpData, mod, 'InputType', 'bit');
    inpModData = reshape(tmpModData, numSubCarr, numSymbOFDM, numSTS);
    %% Модулятор пилотов
    [preambula, ltfSC] = obj.generatePreamble(numSTS);
    inpModData = cat(2, preambula, inpModData);
    %% Цифровое прекодирование BB beamforming
    precoder = HybridPrecoder(precodType,obj.main,HestimZondCell,hybridType,numRF,getAt(downChann,obj.main,numSubCarr));
    precodData = precoder.applyFbb(inpModData);
    %% Модулятор OFDM  
    dataOFDMbb = ofdmmod(precodData, lenFFT, cycPrefLen, nullCarrInd);  
    %% Аналоговое прекодирование RF beamforming: Apply Frf to the digital signal
    dataOFDMrf = precoder.applyFrf(dataOFDMbb);
    %% Прохождение канала
    channelData = downChann.pass(dataOFDMrf);
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
        outData{uIdx} = qamdemod(equalizeData, mod, 'OutputType', 'bit');
    end
    %% Выходные данные
    outData = cat(2,outData{:});
    numErrors = obj.sim.calculateErrors(inpData, outData); 
end

function At = getAt(channel,system,numSC)
    if isfield(channel, 'At')
        At = channel.At;
    else
        maxNumScatters = [50 100];      % Диапазон рассеивателей
        fc = 30e9;                      % Несущая частота
        
        cLight = physconst('LightSpeed');
        lambda = cLight/fc;
        nRays = randi(maxNumScatters);
        expFactorTx = system.numTx / system.numSTS;   
        if expFactorTx == 1 || system.numSTS == 1  % ULA
            % Uniform Linear array
            txarray = phased.ULA(system.numTx, 'ElementSpacing',0.5*lambda, ...
                'Element',phased.IsotropicAntennaElement('BackBaffled',false));
        else % URA
            % Uniform Rectangular array
            txarray = phased.PartitionedArray(...
                'Array',phased.URA([expFactorTx system.numSTS],0.5*lambda),...
                'SubarraySelection',ones(system.numSTS,system.numTx),'SubarraySteering','Custom');

        end
        posTxElem = getElementPosition(txarray)/lambda;
        txang = [rand(1,nRays)*360-180;rand(1,nRays)*180-90]; % random
        AtSC = steervec(posTxElem,txang);
        At = AtSC;
%         At = complex(zeros(numSC,size(AtSC,1),size(AtSC,2)));
%         for carrIdx = 1:numSC
%             At(carrIdx,:,:) = AtSC; % same for all sub-carriers
%         end
    end    
end