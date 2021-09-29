clc;clear;
main.numAntenns = 8;                                 % Кол-во антенн в антенной решетке / 12 or 8 
main.numUsers = 4;                                   % Кол-во пользователей
main.modulation = 4;                                 % Порядок модуляции
main.freqCarrier = 28e9;                             % Частота несущей 28 GHz system
main.precoderType = "MF";
ofdm.numSubCarriers = 450;                           % Кол-во поднессущих
ofdm.lengthFFT = 512;                                % Длина FFT для OFDM
ofdm.numSymbOFDM = 10;                               % Кол-во символов OFDM от каждой антенны
ofdm.cyclicPrefixLength = 64;                        % Длина защитных интервалов = 2*Ngi

confidenceLevel = 0.95;         % Уровень достоверности
coefConfInterval = 1/15;        % ???  

chanParam.channelType = "PHASED_ARRAY_STATIC";    % PHASED_ARRAY_STATIC, PHASED_ARRAY_DYNAMIC
chanParam.numUsers = main.numUsers;
if (chanParam.channelType == "PHASED_ARRAY_STATIC" || chanParam.channelType == "PHASED_ARRAY_DYNAMIC")
    [chanParam.da, chanParam.dp] = loadSteeringVector(main.numAntenns);  % Амплитуда и фаза SteeringVector
    chanParam.numDelayBeams = 3;                                    % Кол-во задержанных сигналов (размерность канального тензора)
    chanParam.txAng = {0,90,180,270};
end

[H] = createChannel(chanParam);
channel.channelType = chanParam.channelType;
channel.H = H;
modelMF = MassiveMimo(main, ofdm, channel);
modelZF = copy(modelMF);
modelEBM = copy(modelMF);
modelZF.precoderType = "ZF";
modelEBM.precoderType = "EBM";

SNR = 0:30;                             % Диапазон SNR 
minNumErrs = 100;                       % Порог ошибок для цикла 
maxNumSimulation = 1;                   % Максимальное число итераций в цикле while 50
maxNumZeroBER = 1;                       % Максимальное кол-во измерений с нулевым кол-вом 

modelMF.simulate(SNR, maxNumZeroBER, minNumErrs, maxNumSimulation);
modelZF.simulate(SNR, maxNumZeroBER, minNumErrs, maxNumSimulation);
modelEBM.simulate(SNR, maxNumZeroBER, minNumErrs, maxNumSimulation);

%% Построение графиков
figure();
modelMF.plotMeanBER('k', 2, "notCreateFigure", "Eb/N0");
str1 = ['Massive MIMO MF ' num2str(modelMF.numTx) 'x'  num2str(modelMF.numRx)];

modelZF.plotMeanBER('--k', 2, "notCreateFigure", "Eb/N0");
str2 = ['Massive MIMO ZF ' num2str(modelZF.numTx) 'x'  num2str(modelZF.numRx)];

modelEBM.plotMeanBER('-.k', 2, "notCreateFigure", "Eb/N0");
str3 = ['Massive MIMO EBM ' num2str(modelEBM.numTx) 'x'  num2str(modelEBM.numRx)];

title(" Mean ");
legend(str1, str2, str3);