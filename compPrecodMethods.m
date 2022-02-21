clc;clear;
%% Создание моделей 
modelZF = MassiveMimo();
modelZF.main.numTx = 8;
modelZF.main.numUsers = 4;
modelZF.main.numRx = 4;
modelZF.main.numSTSVec = [1 1 1 1];% 1 1];% 1 2];%ones(1, modelZF.main.numUsers);
% modelZF.channel.type = 'STATIC';
modelZF.calculateParam();

modelMF = copy(modelZF);
modelEBM = copy(modelZF);
modelRZF = copy(modelZF);
modelDIAG = copy(modelZF);
modelMF.main.precoderType = 'MF';
modelEBM.main.precoderType = 'EBM';
modelRZF.main.precoderType = 'RZF';
modelDIAG.main.precoderType = 'DIAG';
%% Симуляция
SNR = 0:40;                             % Диапазон SNR 
minNumErrs = 100;                       % Порог ошибок для цикла 
maxNumSimulation = 5;                   % Максимальное число итераций в цикле while 50
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

modelMF.dispChannel();
modelZF.dispChannel();
modelEBM.dispChannel();
modelRZF.dispChannel();
modelDIAG.dispChannel();