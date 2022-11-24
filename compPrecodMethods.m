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

channel = StaticChannel(); % StaticChannel % RaylSpecialChannel
channel.numTx = param.numTx;
channel.numUsers = param.numUsers;
channel.numRxUsers = param.numRxUsers;

modelZF = MassiveMimo('main',param,'downChannel',channel);
modelMF = MassiveMimo('main',param,'downChannel',channel);
modelEBM = MassiveMimo('main',param,'downChannel',channel);
modelRZF = MassiveMimo('main',param,'downChannel',channel);
modelDIAG = MassiveMimo('main',param,'downChannel',channel);

modelMF.main.precoderType = 'MF';
modelEBM.main.precoderType = 'EBM';
modelRZF.main.precoderType = 'RZF';
modelDIAG.main.precoderType = 'DIAG';
%% Симуляция
SNR = 0:40;                             % Диапазон SNR 
minNumErrs = 100;                       % Порог ошибок для цикла 
maxNumSimulation = 1;                   % Максимальное число итераций в цикле while 50
maxNumZeroBER = 1;                      % Максимальное кол-во измерений с нулевым кол-вом 

modelMF.simulate(SNR, maxNumZeroBER, minNumErrs, maxNumSimulation);
modelZF.simulate(SNR, maxNumZeroBER, minNumErrs, maxNumSimulation);
modelEBM.simulate(SNR, maxNumZeroBER, minNumErrs, maxNumSimulation);
modelRZF.simulate(SNR, maxNumZeroBER, minNumErrs, maxNumSimulation);
modelDIAG.simulate(SNR, maxNumZeroBER, minNumErrs, maxNumSimulation);
%% Построение графиков
str0 = 'Mean ';
fig = figure();
str1 = [str0 num2str(modelMF.main.precoderType) ' ' num2str(modelMF.main.numTx) 'x'  num2str(modelMF.main.numRx) 'x'...
    num2str(modelMF.main.numSTS) ' u' num2str(modelMF.main.numUsers)];
modelMF.plotMeanBER('k', 2, 'SNR', str1, fig);

str2 = [str0 num2str(modelZF.main.precoderType) ' ' num2str(modelZF.main.numTx) 'x'  num2str(modelZF.main.numRx) 'x'...
    num2str(modelZF.main.numSTS) ' u' num2str(modelZF.main.numUsers)];
modelZF.plotMeanBER('--k', 2, 'SNR', str2, fig);

str3 = [str0 num2str(modelEBM.main.precoderType) ' ' num2str(modelEBM.main.numTx) 'x'  num2str(modelEBM.main.numRx) 'x'...
    num2str(modelEBM.main.numSTS) ' u' num2str(modelEBM.main.numUsers)];
modelEBM.plotMeanBER('-.k', 2, 'SNR', str3, fig);

str4 = [str0 num2str(modelRZF.main.precoderType) ' ' num2str(modelRZF.main.numTx) 'x'  num2str(modelRZF.main.numRx) 'x'...
    num2str(modelRZF.main.numSTS) ' u' num2str(modelRZF.main.numUsers)];
modelRZF.plotMeanBER(':k', 2, 'SNR', str4, fig);

str5 = [str0 num2str(modelDIAG.main.precoderType) ' ' num2str(modelDIAG.main.numTx) 'x'  num2str(modelDIAG.main.numRx) 'x'...
    num2str(modelDIAG.main.numSTS) ' u' num2str(modelDIAG.main.numUsers)];
modelDIAG.plotMeanBER('*-k', 2, 'SNR', str5, fig);

modelMF.downChannel.dispChannel();
modelZF.downChannel.dispChannel();
modelEBM.downChannel.dispChannel();
modelRZF.downChannel.dispChannel();
modelDIAG.downChannel.dispChannel();