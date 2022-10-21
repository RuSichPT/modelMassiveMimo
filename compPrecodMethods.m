clc;clear;
%% Создание моделей
param = SystemParam();
param.numTx = 32;
param.numUsers = 4;
param.numRx = 4;
param.numSTSVec = [1 1 1 1];

channel = RaylSpecialChannel();
channel.numTx = param.numTx;
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
% modelEBM.simulate(SNR, maxNumZeroBER, minNumErrs, maxNumSimulation);
% modelRZF.simulate(SNR, maxNumZeroBER, minNumErrs, maxNumSimulation);
modelDIAG.simulate(SNR, maxNumZeroBER, minNumErrs, maxNumSimulation);
%% Построение графиков
str0 = 'Mean ';
str1 = [str0 num2str(modelMF.main.precoderType) ' ' num2str(modelMF.main.numTx) 'x'  num2str(modelMF.main.numRx) 'x'  num2str(modelMF.main.numSTS)];
fig = modelMF.plotMeanBER('k', 2, 'SNR', str1);

str2 = [str0 num2str(modelZF.main.precoderType) ' ' num2str(modelZF.main.numTx) 'x'  num2str(modelZF.main.numRx) 'x'  num2str(modelZF.main.numSTS)];
modelZF.plotMeanBER('--k', 2, 'SNR', str2, fig);

% str3 = [str0 num2str(modelEBM.main.precoderType) ' ' num2str(modelEBM.main.numTx) 'x'  num2str(modelEBM.main.numRx) 'x'  num2str(modelEBM.main.numSTS)];
% modelEBM.plotMeanBER('-.k', 2, 'SNR', str3, fig);

% str4 = [str0 num2str(modelRZF.main.precoderType) ' ' num2str(modelRZF.main.numTx) 'x'  num2str(modelRZF.main.numRx) 'x'  num2str(modelRZF.main.numSTS)];
% modelRZF.plotMeanBER(':k', 2, 'SNR', str4, fig);

str5 = [str0 num2str(modelDIAG.main.precoderType) ' ' num2str(modelDIAG.main.numTx) 'x'  num2str(modelDIAG.main.numRx) 'x'  num2str(modelDIAG.main.numSTS)];
modelDIAG.plotMeanBER('*-k', 2, 'SNR', str5, fig);

modelMF.downChannel.dispChannel();
modelZF.downChannel.dispChannel();
modelEBM.downChannel.dispChannel();
modelRZF.downChannel.dispChannel();
modelDIAG.downChannel.dispChannel();