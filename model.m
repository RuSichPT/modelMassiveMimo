clear;clc;%close all;
initParam                               % Параметры

SNR = 0:30;                             % Диапазон SNR 
numExperience = 1;                      % Кол-во опытов
minNumErrs = 100;                       % Порог ошибок для цикла 
maxIndLoop = 1;                         % Максимальное число итераций в цикле while 50
maxNumZero = 1;                         % Максимальное кол-во нулевых точек в цикле while 2

berZF = zeros(numExperience,length(SNR),numSTS);  % BER
berMF = zeros(numExperience,length(SNR),numSTS);  
berEIG = zeros(numExperience,length(SNR),numSTS); 

for indExp = 1:numExperience
    numZero = 0;                                    % Кол-во нулевых точек    
    %Создание канала  
    [H] = createChannel(chanParam);
    for indSNR = 1:length(SNR)   
        numErrorsMF = zeros(1, numSTS); % Кол-во ошибок 
        numErrorsZF = zeros(1, numSTS);
        numErrorsEIG = zeros(1, numSTS);

        indLoop = 1;  % индикатор итераций цикла while
        conditionMF = 1;    % меняется ниже
        conditionZF = 1;
        conditionEIG = 1;
        
        if (numZero >= maxNumZero)
            break;
        end
        while ( (conditionMF || conditionZF || conditionEIG) && (indLoop <= maxIndLoop) )
            %% Зондирование канала
            [preambulaOFDMZond,zondLtfSC] = My_helperGenPreamble(preambleParamZond);
            % Прохождение канала
            channelPreambulaZond = passChannel(preambulaOFDMZond, H, chanParam.channelType);
            % Собственный  шум
            noisePreambulaZond = awgn(channelPreambulaZond, SNR(indSNR),'measured');
            % Демодулятор OFDM
            outPreambulaZond = ofdmdemod(noisePreambulaZond, lengthFFT, cyclicPrefixLength, cyclicPrefixLength, ...
                                            nullCarrierIndices);
            % Оценка канала  
            H_estim_zond = channelEstimate(outPreambulaZond, zondLtfSC, numTx, numSubCarriers);             
            %% Формируем данные
            inpData = randi([0 1], numBits, numSTS);
            %% Модулятор 
            tmpModData = qammod(inpData, modulation, 'InputType', 'bit');
            inpModData = reshape(tmpModData, numSubCarriers, numSymbOFDM, numSTS);
            clear tmpModData;
            %% Прекодирование              
            [precodDataMF, precodWeightsMF] = applyPrecodMF(inpModData, H_estim_zond); % Matched Filter                
            [precodDataZF, precodWeightsZF] = applyPrecodZF(inpModData, H_estim_zond);  % Zero Forcing         
            [precodDataEIG, precodWeightsEIG, ~] = applyPrecodEIG(inpModData, H_estim_zond); % Eigenvector            
            %% Модулятор пилотов  
            [preambulaMF, ltfSC_MF] = My_helperGenPreamble(preambleParam, precodWeightsMF);
            [preambulaZF, ltfSC_ZF] = My_helperGenPreamble(preambleParam, precodWeightsZF);
            [preambulaEIG, ltfSC_EIG] = My_helperGenPreamble(preambleParam, precodWeightsEIG);
            %% Модулятор OFDM
            tmpdataOFDM_MF = ofdmmod(precodDataMF, lengthFFT, cyclicPrefixLength, nullCarrierIndices);                            
            dataOFDM_MF = [preambulaMF ; tmpdataOFDM_MF];

            tmpdataOFDM_ZF = ofdmmod(precodDataZF, lengthFFT, cyclicPrefixLength, nullCarrierIndices);                            
            dataOFDM_ZF = [preambulaZF ; tmpdataOFDM_ZF];

            tmpdataOFDM_EIG = ofdmmod(precodDataEIG, lengthFFT, cyclicPrefixLength, nullCarrierIndices);                            
            dataOFDM_EIG = [preambulaEIG ; tmpdataOFDM_EIG];            
            clear tmpdataOFDM_MF tmpdataOFDM_ZF tmpdataOFDM_EIG;
            %% Прохождение канала
            channelDataMF = passChannel(dataOFDM_MF, H, chanParam.channelType);
            channelDataZF = passChannel(dataOFDM_ZF, H, chanParam.channelType);
            channelDataEIG = passChannel(dataOFDM_EIG, H, chanParam.channelType);            
            %% Собственный шум
            noiseDataMF = awgn(channelDataMF, SNR(indSNR), 'measured');
            noiseDataZF = awgn(channelDataZF, SNR(indSNR), 'measured');
            noiseDataEIG = awgn(channelDataEIG, SNR(indSNR), 'measured');
            %% Демодулятор OFDM
            modDataOutMF = ofdmdemod(noiseDataMF, lengthFFT, cyclicPrefixLength, cyclicPrefixLength, nullCarrierIndices);
            modDataOutZF = ofdmdemod(noiseDataZF, lengthFFT, cyclicPrefixLength, cyclicPrefixLength, nullCarrierIndices);
            modDataOutEIG = ofdmdemod(noiseDataEIG, lengthFFT, cyclicPrefixLength, cyclicPrefixLength, nullCarrierIndices);            
            %% Оценка канала 
            H_estim_MF = channelEstimate(modDataOutMF(:,1:numSTS,:), ltfSC_MF, numSTS, numSubCarriers);
            H_estim_ZF = channelEstimate(modDataOutZF(:,1:numSTS,:), ltfSC_ZF, numSTS, numSubCarriers); 
            H_estim_EIG = channelEstimate(modDataOutEIG(:,1:numSTS,:), ltfSC_EIG, numSTS, numSubCarriers);
            %% Эквалайзер
            tmpEqualizeDataMF = equalizerZFnumSC(modDataOutMF(:, (1 + numSTS):end,:), H_estim_MF);
            equalizeDataMF = reshape(tmpEqualizeDataMF, numSubCarriers*numSymbOFDM, numSTS);
            tmpEqualizeDataZF = equalizerZFnumSC(modDataOutZF(:, (1 + numSTS):end,:), H_estim_ZF);
            equalizeDataZF = reshape(tmpEqualizeDataZF, numSubCarriers*numSymbOFDM, numSTS);
            tmpEqualizeDataEIG = equalizerZFnumSC(modDataOutEIG(:, (1 + numSTS):end,:),H_estim_EIG);
            equalizeDataEIG = reshape(tmpEqualizeDataEIG, numSubCarriers*numSymbOFDM, numSTS);                        
            clear tmpEqualizeDataMF tmpEqualizeDataZF tmpEqualizeDataEIG;
            %% Демодулятор
            outDataMF = qamdemod(equalizeDataMF, modulation, 'OutputType', 'bit');
            outDataZF = qamdemod(equalizeDataZF, modulation, 'OutputType', 'bit'); 
            outDataEIG  = qamdemod(equalizeDataEIG, modulation, 'OutputType', 'bit');            
            %% Выходные данные           
            numErrorsMF = numErrorsMF + calculateErrors(inpData, outDataMF);
            numErrorsZF = numErrorsZF + calculateErrors(inpData, outDataZF);
            numErrorsEIG = numErrorsEIG + calculateErrors(inpData, outDataEIG);          

            [berconfMF,lenConfIntervalMF] = calculateBER(numSTS, numErrorsMF, indLoop*numBits, confidenceLevel);
            maxConfidenceIntervalMF = berconfMF * coefConfInterval;
            conditionMF = max(((lenConfIntervalMF > maxConfidenceIntervalMF)|(numErrorsMF < minNumErrs)));
            
            [berconfZF,lenConfIntervalZF] = calculateBER(numSTS, numErrorsZF, indLoop*numBits, confidenceLevel);
            maxConfidenceIntervalZF = berconfZF * coefConfInterval;
            conditionZF = max(((lenConfIntervalZF > maxConfidenceIntervalZF)|(numErrorsZF < minNumErrs)));
            
            [berconfEIG,lenConfIntervalMF] = calculateBER(numSTS, numErrorsEIG, indLoop*numBits, confidenceLevel);
            maxConfidenceIntervalEIG = berconfEIG * coefConfInterval;
            conditionEIG = max((lenConfIntervalMF > maxConfidenceIntervalEIG)|(numErrorsEIG < minNumErrs));
                      
            maxNumErrorsMFmax = max(numErrorsMF);            
            indLoop = indLoop+1;
        end
        
        if (maxNumErrorsMFmax == 0)
            numZero = numZero+1;
        end
        
        for m = 1:numSTS
            berMF(indExp,indSNR,m) = berconfMF(m);
            berZF(indExp,indSNR,m) = berconfZF(m);
            berEIG(indExp,indSNR,m) = berconfEIG(m);
        end
        
        fprintf('Complete %d db, indLoop = %d \n',...
        SNR(indSNR), indLoop-1);
    end
    disp("Exp: " + indExp);
end
%% Построение графиков
meanBerMF = squeeze(mean(berMF,1));
meanBerZF = squeeze(mean(berZF,1));
meanBerEIG = squeeze(mean(berEIG,1));
figure();
plot_ber(mean(meanBerMF,2), SNR, bps, 'k', 2, 0);
str1 = ['Massive MIMO MF ' num2str(numTx) 'x'  num2str(numRx)];

plot_ber(mean(meanBerZF,2), SNR, bps,'--k', 2, 0);
str2 = ['Massive MIMO ZF ' num2str(numTx) 'x'  num2str(numRx)];

plot_ber(mean(meanBerEIG,2), SNR, bps, '-.k', 2, 0);
str3 = ['Massive MIMO EBM ' num2str(numTx) 'x'  num2str(numRx)];

title(" Mean ");
legend(str1, str2, str3);