clc;clear;
%% Создание моделей 
modelZF = PhasedMassiveMimo();
modelZF.main.numTx = 16;
modelZF.main.numUsers = 4;
modelZF.main.numRx = 8;
modelZF.main.numSTSVec = ones(1, modelZF.main.numUsers);
modelZF.calculateParam();

modelMF = copy(modelZF);
modelEBM = copy(modelZF);
modelRZF = copy(modelZF);
modelBD = copy(modelZF);
modelMF.main.precoderType = 'MF';
modelEBM.main.precoderType = 'EBM';
modelRZF.main.precoderType = 'RZF';
modelBD.main.precoderType = 'BD';
%% Симуляция
SNR = 0:40;                             % Диапазон SNR 
minNumErrs = 100;                       % Порог ошибок для цикла 
maxNumSimulation = 5;                   % Максимальное число итераций в цикле while 50
maxNumZeroBER = 1;                      % Максимальное кол-во измерений с нулевым кол-вом 

modelMF.simulate(SNR, maxNumZeroBER, minNumErrs, maxNumSimulation);
modelZF.simulate(SNR, maxNumZeroBER, minNumErrs, maxNumSimulation);
modelEBM.simulate(SNR, maxNumZeroBER, minNumErrs, maxNumSimulation);
% modelRZF.simulate(SNR, maxNumZeroBER, minNumErrs, maxNumSimulation);
% modelBD.simulate(SNR, maxNumZeroBER, minNumErrs, maxNumSimulation);
%% Построение графиков
str0 = 'Mean ';
str1 = [str0 num2str(modelMF.main.precoderType) ' ' num2str(modelMF.main.numTx) 'x'  num2str(modelMF.main.numRx)];
fig = modelMF.plotMeanBER('k', 2, 'SNR', str1);

str2 = [str0 num2str(modelZF.main.precoderType) ' ' num2str(modelZF.main.numTx) 'x'  num2str(modelZF.main.numRx)];
modelZF.plotMeanBER('--k', 2, 'SNR', str2, fig);

str3 = [str0 num2str(modelEBM.main.precoderType) ' ' num2str(modelEBM.main.numTx) 'x'  num2str(modelEBM.main.numRx)];
modelEBM.plotMeanBER('-.k', 2, 'SNR', str3, fig);

% str4 = [str0 num2str(modelRZF.main.precoderType) ' ' num2str(modelRZF.main.numTx) 'x'  num2str(modelRZF.main.numRx)];
% modelRZF.plotMeanBER(':k', 2, 'SNR', str4, fig);
% 
% str5 = [str0 num2str(modelBD.main.precoderType) ' ' num2str(modelBD.main.numTx) 'x'  num2str(modelBD.main.numRx)];
% modelBD.plotMeanBER('*-k', 2, 'SNR', str5, fig);