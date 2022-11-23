clc;clear;
addpath('Parameters');
addpath('Channels');
addpath('DataBase/Verification');
%% Создание моделей
hmimo = HybridMassiveMimo();
hmimo.main.numUsers = 1;
hmimo.main.modulation = 16;
hmimo.main.numTx = 16;
hmimo.main.numRxUsers = [4]; 
hmimo.main.numSTSVec = [4];

mimo = MassiveMimo();
mimo.main.numUsers = hmimo.main.numUsers;
mimo.main.numTx = hmimo.main.numTx;
mimo.main.modulation = hmimo.main.modulation;
mimo.main.numRxUsers = hmimo.main.numRxUsers; 
mimo.main.numSTSVec = hmimo.main.numSTSVec;

channel = ChannelForNeuralNet();% StaticChannel, ChannelForNeuralNet
channel.numUsers = hmimo.main.numUsers;
channel.numTx = hmimo.main.numTx;
channel.numRxUsers = hmimo.main.numRxUsers;

hmimo.downChannel = channel;
mimo.downChannel = channel;

hmimoNN = copy(hmimo);
hmimoNN.main.precoderType = 'DRL-NN';
%% Симуляция
SNR = 0:70;                             % Диапазон SNR 
minNumErrs = 100;                       % Порог ошибок для цикла 
maxNumSimulation = 1;                   % Максимальное число итераций в цикле while 50
maxNumZeroBER = 1;                      % Максимальное кол-во измерений с нулевым кол-вом 

hmimo.simulate(SNR, maxNumZeroBER, minNumErrs, maxNumSimulation);
mimo.simulate(SNR, maxNumZeroBER, minNumErrs, maxNumSimulation);
hmimoNN.simulate(SNR, maxNumZeroBER, minNumErrs, maxNumSimulation);
%% Построение графиков
% hmimo.plotMeanCapacity('k', 2, str1);

str0 = 'Mean ';
str1 = [str0 num2str(hmimo.main.precoderType) ' ' num2str(hmimo.main.numTx) 'x'  num2str(hmimo.main.numRx) 'x'  num2str(hmimo.main.numSTS)];
fig = hmimo.plotMeanBER('k', 2, 'SNR', str1);

str2 = [str0 num2str(mimo.main.precoderType) ' ' num2str(mimo.main.numTx) 'x'  num2str(mimo.main.numRx) 'x'  num2str(mimo.main.numSTS)];
mimo.plotMeanBER('--k', 2, 'SNR', str2, fig);

str3 = [str0 num2str(hmimoNN.main.precoderType) ' ' num2str(hmimoNN.main.numTx) 'x'  num2str(hmimoNN.main.numRx) 'x'  num2str(hmimoNN.main.numSTS)];
hmimoNN.plotMeanBER('-.k', 2, 'SNR', str3, fig);
