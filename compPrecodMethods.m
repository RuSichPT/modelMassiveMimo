clc;clear;
%% Параметры системы
main.numUsers = 4;                                      % Кол-во пользователей
main.numSTSVec = ones(1, main.numUsers);                % Кол-во независимых потоков данных на одного пользователя / [2 1 3 2]
main.numPhasedElemTx = 2;                               % Кол-во антенных элементов в 1 решетке на передачу
main.numPhasedElemRx = 1;                               % Кол-во антенных элементов в 1 решетке на прием
main.modulation = 4;                                    % Порядок модуляции
main.freqCarrier = 28e9;                                % Частота несущей 28 GHz system                               
main.precoderType = "MF";                               % Тип прекодера
%% Параметры OFDM
ofdm.numSubCarriers = 450;                           % Кол-во поднессущих
ofdm.lengthFFT = 512;                                % Длина FFT для OFDM
ofdm.numSymbOFDM = 10;                               % Кол-во символов OFDM от каждой антенны
ofdm.cyclicPrefixLength = 64;                        % Длина защитных интервалов = 2*Ngi
%% Параметры канала
channel.channelType = "RAYL";    % PHASED_ARRAY_STATIC, PHASED_ARRAY_DYNAMIC
channel.numUsers = main.numUsers;
switch channel.channelType
    case {"PHASED_ARRAY_STATIC","PHASED_ARRAY_DYNAMIC"}
        channel.numTx = 8; %12
        channel.numDelayBeams = 3;       % Кол-во задержанных сигналов (размерность канального тензора)
        channel.txAng = {0,90,180,270};
    case "RAYL"
        channel.sampleRate = 40e6;
        channel.tau = [2 5 7] * (1 / channel.sampleRate);
        channel.pdB = [-3 -9 -12];
end
%% Создание моделей 
modelMF = MassiveMimo(main, ofdm, channel);
modelZF = copy(modelMF);
modelEBM = copy(modelMF);
modelRZF = copy(modelMF);
modelZF.main.precoderType = "ZF";
modelEBM.main.precoderType = "EBM";
modelRZF.main.precoderType = "RZF";
%% Симуляция
SNR = 0:30;                             % Диапазон SNR 
minNumErrs = 100;                       % Порог ошибок для цикла 
maxNumSimulation = 1;                   % Максимальное число итераций в цикле while 50
maxNumZeroBER = 1;                      % Максимальное кол-во измерений с нулевым кол-вом 

modelMF.simulate(SNR, maxNumZeroBER, minNumErrs, maxNumSimulation);
modelZF.simulate(SNR, maxNumZeroBER, minNumErrs, maxNumSimulation);
modelEBM.simulate(SNR, maxNumZeroBER, minNumErrs, maxNumSimulation);
modelRZF.simulate(SNR, maxNumZeroBER, minNumErrs, maxNumSimulation);
%% Построение графиков
figure();
modelMF.plotMeanBER('k', 2, "notCreateFigure", "SNR");
str1 = ['Massive MIMO MF ' num2str(modelMF.main.numTx) 'x'  num2str(modelMF.main.numRx)];

modelZF.plotMeanBER('--k', 2, "notCreateFigure", "SNR");
str2 = ['Massive MIMO ZF ' num2str(modelZF.main.numTx) 'x'  num2str(modelZF.main.numRx)];

modelEBM.plotMeanBER('-.k', 2, "notCreateFigure", "SNR");
str3 = ['Massive MIMO EBM ' num2str(modelEBM.main.numTx) 'x'  num2str(modelEBM.main.numRx)];

modelRZF.plotMeanBER('*k', 2, "notCreateFigure", "SNR");
str4 = ['Massive MIMO RZF ' num2str(modelRZF.main.numTx) 'x'  num2str(modelRZF.main.numRx)];

title(" Mean ");
legend(str1, str2, str3, str4);