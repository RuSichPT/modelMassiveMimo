clc;clear;
addpath('Parameters');
addpath('Channels')
rng(122);
%% Создание моделей
param = SystemParam();
param.numTx = 8;
param.numUsers = 1;
param.numRxUsers = 4; 
param.numSTSVec = 2;
param.modulation = 4;

channel = StaticChannel(); % StaticChannel % RaylSpecialChannel
channel.numTx = param.numTx;
channel.numUsers = param.numUsers;
channel.numRxUsers = param.numRxUsers;

modelZF = MassiveMimo('main',param,'downChannel',channel);
modelTPE = MassiveMimo('main',param,'downChannel',channel);
modelNSA = MassiveMimo('main',param,'downChannel',channel);
modelNI = MassiveMimo('main',param,'downChannel',channel);
modelNI_NSA = MassiveMimo('main',param,'downChannel',channel);

modelTPE.main.precoderType = 'TPE';
modelNSA.main.precoderType = 'NSA';
modelNI.main.precoderType = 'NI';
modelNI_NSA.main.precoderType = 'NI-NSA';
%% Симуляция
SNR = 0:40;                             % Диапазон SNR 
minNumErrs = 100;                       % Порог ошибок для цикла 
maxNumSimulation = 5;                   % Максимальное число итераций в цикле while 50
maxNumZeroBER = 1;                      % Максимальное кол-во измерений с нулевым кол-вом 

modelZF.simulate(SNR, maxNumZeroBER, minNumErrs, maxNumSimulation);
modelTPE.simulate(SNR, maxNumZeroBER, minNumErrs, maxNumSimulation);
modelNSA.simulate(SNR, maxNumZeroBER, minNumErrs, maxNumSimulation);
modelNI.simulate(SNR, maxNumZeroBER, minNumErrs, maxNumSimulation);
modelNI_NSA.simulate(SNR, maxNumZeroBER, minNumErrs, maxNumSimulation);
%% Построение графиков
str0 = 'Mean ';
fig = figure();
str1 = [str0 num2str(modelZF.main.precoderType) ' ' num2str(modelZF.main.numTx) 'x'  num2str(modelZF.main.numRx) 'x'...
    num2str(modelZF.main.numSTS) ' u' num2str(modelZF.main.numUsers)];
fig = modelZF.plotMeanBER('k', 2, 'SNR', str1, fig);

str2 = [str0 num2str(modelTPE.main.precoderType) ' ' num2str(modelTPE.main.numTx) 'x'  num2str(modelTPE.main.numRx) 'x'...
    num2str(modelTPE.main.numSTS) ' u' num2str(modelTPE.main.numUsers)];
modelTPE.plotMeanBER('--k', 2, 'SNR', str2, fig);

str3 = [str0 num2str(modelNSA.main.precoderType) ' ' num2str(modelNSA.main.numTx) 'x'  num2str(modelNSA.main.numRx) 'x'...
    num2str(modelNSA.main.numSTS) ' u' num2str(modelNSA.main.numUsers)];
modelNSA.plotMeanBER('-.k', 2, 'SNR', str3, fig);

str4 = [str0 num2str(modelNI.main.precoderType) ' ' num2str(modelNI.main.numTx) 'x'  num2str(modelNI.main.numRx) 'x'...
    num2str(modelNI.main.numSTS) ' u' num2str(modelNI.main.numUsers)];
modelNI.plotMeanBER(':k', 2, 'SNR', str4, fig);

str5 = [str0 num2str(modelNI_NSA.main.precoderType) ' ' num2str(modelNI_NSA.main.numTx) 'x'  num2str(modelNI_NSA.main.numRx) 'x'...
    num2str(modelNI_NSA.main.numSTS) ' u' num2str(modelNI_NSA.main.numUsers)];
modelNI_NSA.plotMeanBER('*-k', 2, 'SNR', str5, fig);

modelZF.downChannel.dispChannel();
modelTPE.downChannel.dispChannel();
modelNSA.downChannel.dispChannel();
modelNI.downChannel.dispChannel();
modelNI_NSA.downChannel.dispChannel();