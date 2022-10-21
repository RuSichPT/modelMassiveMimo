% clc;clear;
%% Создание моделей
hmimo = HybridMassiveMimo();
hmimo.main.numTx = 64;
hmimo.main.numRx = 16;
hmimo.main.numSTSVec = [2 2 2 2];
% hmimo.channel.type = 'ChannelForNeuralNet';
hmimoNN = copy(hmimo);
hmimoNN.main.precoderType = 'DRL-NN';
hmimo.channel;
%% Симуляция
SNR = 0:30;                             % Диапазон SNR 
minNumErrs = 100;                       % Порог ошибок для цикла 
maxNumSimulation = 1;                   % Максимальное число итераций в цикле while 50
maxNumZeroBER = 1;                      % Максимальное кол-во измерений с нулевым кол-вом 

hmimo.simulate(SNR, maxNumZeroBER, minNumErrs, maxNumSimulation);
% hmimoNN.simulate(SNR, maxNumZeroBER, minNumErrs, maxNumSimulation);
%% Построение графиков
% hmimo.plotMeanCapacity('k', 2, str1);

str0 = 'Mean ';
str1 = [str0 num2str(hmimo.main.precoderType) ' ' num2str(hmimo.main.numTx) 'x'  num2str(hmimo.main.numRx) 'x'  num2str(hmimo.main.numSTS)];
fig = hmimo.plotMeanBER('k', 2, 'SNR', str1);
% 
% str2 = [str0 num2str(hmimoNN.main.precoderType) ' ' num2str(hmimoNN.main.numTx) 'x'  num2str(hmimoNN.main.numRx) 'x'  num2str(hmimoNN.main.numSTS)];
% hmimoNN.plotMeanBER('--k', 2, 'SNR', str2, fig);