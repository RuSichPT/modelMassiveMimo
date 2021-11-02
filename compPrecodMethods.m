clc;clear;
%% Параметры системы
main.numTx = 8;                                        % Кол-во передающих антен
main.numUsers = 4;                                      % Кол-во пользователей
main.numRx = main.numUsers;                             % Кол-во приемных антен
main.numSTSVec = ones(1, main.numUsers);                % Кол-во независимых потоков данных на одного пользователя / [2 1 3 2]
main.modulation = 4;                                    % Порядок модуляции
main.freqCarrier = 28e9;                                % Частота несущей 28 GHz system                               
main.precoderType = 'ZF';                               % Тип прекодера
%% Параметры OFDM
ofdm.numSubCarriers = 450;                           % Кол-во поднессущих
ofdm.lengthFFT = 512;                                % Длина FFT для OFDM
ofdm.numSymbOFDM = 10;                               % Кол-во символов OFDM от каждой антенны
ofdm.cyclicPrefixLength = 64;                        % Длина защитных интервалов = 2*Ngi
%% Параметры канала
channel.channelType = 'RAYL_SPECIAL';    % PHASED_ARRAY_STATIC, PHASED_ARRAY_DYNAMIC STATIC 
channel.numUsers = main.numUsers;
switch channel.channelType
    case {'PHASED_ARRAY_STATIC', 'PHASED_ARRAY_DYNAMIC'}
        channel.numTx = 8; %12
        channel.numDelayBeams = 3;       % Кол-во задержанных сигналов (размерность канального тензора)
        channel.txAng = {0,90,180,270};
    case {'RAYL','RAYL_SPECIAL'}
        channel.sampleRate = 40e6;
        channel.tau = [2 5 7] * (1 / channel.sampleRate);
        channel.pdB = [-3 -9 -12];
        channel.seed = 95;
end
%% Создание моделей 
modelZF = MassiveMimo(main, ofdm, channel);
modelMF = copy(modelZF);
modelEBM = copy(modelZF);
modelRZF = copy(modelZF);
modelPhased = copy(modelZF);
modelBDA = copy(modelZF);
modelTPE = copy(modelZF);
modelNSA = copy(modelZF);
modelNI = copy(modelZF);
modelNI_NSA = copy(modelZF);
modelMF.main.precoderType = 'MF';
modelEBM.main.precoderType = 'EBM';
modelRZF.main.precoderType = 'RZF';
modelPhased.main.precoderType = 'NOT';
modelBDA.main.precoderType = 'BDA';
modelTPE.main.precoderType = 'TPE';
modelNSA.main.precoderType = 'NSA';
modelNI.main.precoderType = 'NI';
modelNI_NSA.main.precoderType = 'NI-NSA';
%% Симуляция
SNR = 0:40;                             % Диапазон SNR 
minNumErrs = 100;                       % Порог ошибок для цикла 
maxNumSimulation = 5;                   % Максимальное число итераций в цикле while 50
maxNumZeroBER = 1;                      % Максимальное кол-во измерений с нулевым кол-вом 

% modelMF.simulate(SNR, maxNumZeroBER, minNumErrs, maxNumSimulation);
% modelZF.simulate(SNR, maxNumZeroBER, minNumErrs, maxNumSimulation);
% modelEBM.simulate(SNR, maxNumZeroBER, minNumErrs, maxNumSimulation);
% modelRZF.simulate(SNR, maxNumZeroBER, minNumErrs, maxNumSimulation);
% modelPhased.simulate(SNR, maxNumZeroBER, minNumErrs, maxNumSimulation);
% modelBDA.simulate(SNR, maxNumZeroBER, minNumErrs, maxNumSimulation);
% modelTPE.simulate(SNR, maxNumZeroBER, minNumErrs, maxNumSimulation);
modelNSA.simulate(SNR, maxNumZeroBER, minNumErrs, maxNumSimulation);
modelNI.simulate(SNR, maxNumZeroBER, minNumErrs, maxNumSimulation);
modelNI_NSA.simulate(SNR, maxNumZeroBER, minNumErrs, maxNumSimulation);
%% Построение графиков
str0 = 'Mean ';
% str1 = [str0 num2str(modelMF.main.precoderType) ' ' num2str(modelMF.main.numTx) 'x'  num2str(modelMF.main.numRx)];
% fig = modelMF.plotMeanBER('k', 2, 'SNR', str1);
% 
% str2 = [str0 num2str(modelZF.main.precoderType) ' ' num2str(modelZF.main.numTx) 'x'  num2str(modelZF.main.numRx)];
% modelZF.plotMeanBER('--k', 2, 'SNR', str2, fig);

% str3 = [str0 num2str(modelEBM.main.precoderType) ' ' num2str(modelEBM.main.numTx) 'x'  num2str(modelEBM.main.numRx)];
% modelEBM.plotMeanBER('-.k', 2, 'SNR', str3, fig);

% str4 = [str0 num2str(modelRZF.main.precoderType) ' ' num2str(modelRZF.main.numTx) 'x'  num2str(modelRZF.main.numRx)];
% modelRZF.plotMeanBER(':k', 2, 'SNR', str4, fig);
% 
% str5 = [str0 num2str(modelPhased.main.precoderType) ' ' num2str(modelPhased.main.numTx) 'x'  num2str(modelPhased.main.numRx)];
% modelPhased.plotMeanBER('r', 2, 'SNR', str5, fig);
% 
% str6 = [str0 num2str(modelBDA.main.precoderType) ' ' num2str(modelBDA.main.numTx) 'x'  num2str(modelBDA.main.numRx)];
% modelBDA.plotMeanBER('--r', 2, 'SNR', str6, fig);

% str7 = [str0 num2str(modelTPE.main.precoderType) ' ' num2str(modelTPE.main.numTx) 'x'  num2str(modelTPE.main.numRx)];
% modelTPE.plotMeanBER('-.r', 2, 'SNR', str7, fig);

str8 = [str0 num2str(modelNSA.main.precoderType) ' ' num2str(modelNSA.main.numTx) 'x'  num2str(modelNSA.main.numRx)];
fig = modelNSA.plotMeanBER(':r', 2, 'SNR', str8);

str9 = [str0 num2str(modelNI.main.precoderType) ' ' num2str(modelNI.main.numTx) 'x'  num2str(modelNI.main.numRx)];
modelNI.plotMeanBER('b', 2, 'SNR', str9, fig);

str10 = [str0 num2str(modelNI_NSA.main.precoderType) ' ' num2str(modelNI_NSA.main.numTx) 'x'  num2str(modelNI_NSA.main.numRx)];
modelNI_NSA.plotMeanBER('--b', 2, 'SNR', str10, fig);