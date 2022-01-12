clc;clear;close all;
%% Создание моделей
modelMM = MassiveMimo();
modelMM.main.numTx = 8;
modelMM.main.numUsers = 4;
modelMM.calculateParam();

modelHybridFull = HybridMassiveMimo();
modelHybridFull.main.numTx = 8;
modelHybridFull.main.numUsers = 4;
modelHybridFull.calculateParam();

modelHybridSub = copy(modelHybridFull);
modelHybridSub.main.numSubArray = 4;
%% Симуляция
SNR = 0:40;                             % Диапазон SNR 
minNumErrs = 100;                       % Порог ошибок для цикла 
maxNumSimulation = 5;                   % Максимальное число итераций в цикле while 50
maxNumZeroBER = 1;                      % Максимальное кол-во измерений с нулевым кол-вом

modelHybridFull.simulate(SNR, maxNumZeroBER, minNumErrs, maxNumSimulation);
modelHybridSub.simulate(SNR, maxNumZeroBER, minNumErrs, maxNumSimulation);
modelMM.simulate(SNR, maxNumZeroBER, minNumErrs, maxNumSimulation);
%% Построение графиков
str0 = 'Mean ';
str1 = [str0 num2str(modelHybridFull.main.precoderType) ' ' num2str(modelHybridFull.main.numTx) 'x'  num2str(modelHybridFull.main.numRx)...
        ' subArr ' num2str(modelHybridFull.main.numSubArray)];
fig = modelHybridFull.plotMeanBER('k', 2, 'SNR', str1);

str2 = [str0 num2str(modelMM.main.precoderType) ' ' num2str(modelMM.main.numTx) 'x'  num2str(modelMM.main.numRx)];
modelMM.plotMeanBER('--k', 2, 'SNR', str2, fig);

str3 = [str0 num2str(modelHybridSub.main.precoderType) ' ' num2str(modelHybridSub.main.numTx) 'x'  num2str(modelHybridSub.main.numRx)...
        ' subArr ' num2str(modelHybridSub.main.numSubArray)];
modelHybridSub.plotMeanBER('-.k', 2, 'SNR', str3, fig);