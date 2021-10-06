clc;clear;
%% Параметры системы
main.numUsers = 4;                                      % Кол-во пользователей
main.numSTSVec = ones(1, main.numUsers);                % Кол-во независимых потоков данных на одного пользователя / [2 1 3 2]
main.numPhasedElemTx = 2;                               % Кол-во антенных элементов в 1 решетке на передачу
main.numPhasedElemRx = 1;                               % Кол-во антенных элементов в 1 решетке на прием
main.modulation = 4;                                    % Порядок модуляции
main.freqCarrier = 28e9;                                % Частота несущей 28 GHz system                               
main.precoderType = 'EBM';                               % Тип прекодера
roundingType = 'significant';                           % См функцию round  
numFixPoint = 2;                                        % См функцию round 
%% Параметры OFDM
ofdm.numSubCarriers = 450;                           % Кол-во поднессущих
ofdm.lengthFFT = 512;                                % Длина FFT для OFDM
ofdm.numSymbOFDM = 10;                               % Кол-во символов OFDM от каждой антенны
ofdm.cyclicPrefixLength = 64;                        % Длина защитных интервалов = 2*Ngi
%% Параметры канала
channel.channelType = 'STATIC';    % PHASED_ARRAY_STATIC, PHASED_ARRAY_DYNAMIC STATIC 
channel.numUsers = main.numUsers;
switch channel.channelType
    case {'PHASED_ARRAY_STATIC', 'PHASED_ARRAY_DYNAMIC'}
        channel.numTx = 8; %12
        channel.numDelayBeams = 3;       % Кол-во задержанных сигналов (размерность канального тензора)
        channel.txAng = {0,90,180,270};
    case 'RAYL'
        channel.sampleRate = 40e6;
        channel.tau = [2 5 7] * (1 / channel.sampleRate);
        channel.pdB = [-3 -9 -12];
end
%% Создание моделей 
model = MassiveMimo(main, ofdm, channel);
modelFixPoint = MassiveMimo(main, ofdm, channel);
%% Симуляция
SNR = 0:30;                             % Диапазон SNR 
minNumErrs = 100;                       % Порог ошибок для цикла 
maxNumSimulation = 5;                   % Максимальное число итераций в цикле while 50
maxNumZeroBER = 1;                      % Максимальное кол-во измерений с нулевым кол-вом 

model.simulate(SNR, maxNumZeroBER, minNumErrs, maxNumSimulation);
modelFixPoint.simulateFixPoint(SNR, maxNumZeroBER, minNumErrs, maxNumSimulation, numFixPoint, roundingType);
%% Построение графиков
str0 = 'Mean ';
str1 = [str0 num2str(model.main.precoderType) ' '  num2str(model.main.numTx) 'x'  num2str(model.main.numRx)];
fig = model.plotMeanBER('k', 2, 'SNR', str1);

str2 = [str0 num2str(modelFixPoint.main.precoderType) ' fixPoint ' num2str(modelFixPoint.main.numTx) 'x'  num2str(modelFixPoint.main.numRx)];
modelFixPoint.plotMeanBER('-.k', 2, 'SNR', str2, fig);