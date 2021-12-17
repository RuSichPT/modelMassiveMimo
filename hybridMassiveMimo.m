clc;clear;
%% Создание моделей 
modelHybrid = MassiveMimo();
modelHybrid.main.numTx = 32;
modelHybrid.main.numUsers = 4;
modelHybrid.calculateParam();
modelMM = copy(modelHybrid);
%% Симуляция
SNR = 0:40;                             % Диапазон SNR 
minNumErrs = 100;                       % Порог ошибок для цикла 
maxNumSimulation = 5;                   % Максимальное число итераций в цикле while 50
maxNumZeroBER = 1;                      % Максимальное кол-во измерений с нулевым кол-вом

modelHybrid.simulateHybrid(SNR, maxNumZeroBER, minNumErrs, maxNumSimulation);
modelMM.simulate(SNR, maxNumZeroBER, minNumErrs, maxNumSimulation);
%% Построение графиков
str0 = 'Mean ';
str1 = [str0 num2str(modelHybrid.main.precoderType) ' ' num2str(modelHybrid.main.numTx) 'x'  num2str(modelHybrid.main.numRx)];
fig = modelHybrid.plotMeanBER('k', 2, 'SNR', str1);

str2 = [str0 num2str(modelMM.main.precoderType) ' ' num2str(modelMM.main.numTx) 'x'  num2str(modelMM.main.numRx)];
modelMM.plotMeanBER('--k', 2, 'SNR', str2, fig);