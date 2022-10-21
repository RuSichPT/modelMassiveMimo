clc;clear;close all;
addpath('Parameters');
addpath('Channels');
%% Создание канала
anglesTx = {[2;1]; [91;-1]; [-85;0]; [179;3];};  %[azimuth;elevation]
numRows = 4;
numColumns = 2;
channel = StaticLOSChannel('anglesTx',anglesTx,'numRows',numRows,'numColumns',numColumns);
% channel = StaticChannel();
%% Создание модели
hmimo = HybridMassiveMimo();
hmimo.main.numTx = channel.numTx;
hmimo.downChannel = channel;
mimo = MassiveMimo();
mimo.main.numTx = channel.numTx;
mimo.downChannel = channel;
% mimo.main.precoderType = 'DIAG';
%% Симуляция
SNR = 0:25;                             % Диапазон SNR 
minNumErrs = 100;                       % Порог ошибок для цикла 
maxNumSimulation = 10;                   % Максимальное число итераций в цикле while 50
maxNumZeroBER = 1000;                      % Максимальное кол-во измерений с нулевым кол-вом

hmimo.simulate(SNR, maxNumZeroBER, minNumErrs, maxNumSimulation);
mimo.simulate(SNR, maxNumZeroBER, minNumErrs, maxNumSimulation);
%% Построение графиков
str0 = 'Mean ';
str1 = [str0 hmimo.main.precoderType ' ' num2str(hmimo.main.numTx) 'x'  num2str(hmimo.main.numRx)...
        'x'  num2str(hmimo.main.numSTS) ' type ' hmimo.hybridType];
fig = hmimo.plotMeanBER('k', 2, 'SNR', str1);

str2 = [str0 num2str(mimo.main.precoderType) ' ' num2str(mimo.main.numTx) 'x'  num2str(mimo.main.numRx) 'x'  num2str(mimo.main.numSTS)];
mimo.plotMeanBER('--k', 2, 'SNR', str2, fig);

fig1 = hmimo.plotCapacity('all','k',2,str1);
mimo.plotCapacity('all','--k',2,str2,fig1);