clc;clear;close all;
addpath('Parameters');
addpath('Channels');
%% Создание модели
mimo = MassiveMimo();
mimo.main.numUsers = 4;
mimo.main.numTx = 16;
mimo.main.numRxUsers = [1 1 1 1]; 
mimo.main.numSTSVec = [1 1 1 1];
mimo.main.modulation = 4;
mimo.main.precoderType = 'ZF';
%% Создание канала
channel = RaylSpecialChannel();
channel.numUsers = mimo.main.numUsers;
channel.numTx = mimo.main.numTx;
channel.numRxUsers = mimo.main.numRxUsers;
mimo.downChannel = channel;
%% Симуляция
SNR = 0:35;                             % Диапазон SNR 
minNumErrs = 100;                       % Порог ошибок для цикла 
maxNumSimulation = 1;                   % Максимальное число итераций в цикле while 50
maxNumZeroBER = 1;                      % Максимальное кол-во измерений с нулевым кол-вом

mimo.simulate(SNR, maxNumZeroBER, minNumErrs, maxNumSimulation);
%% Построение графиков
str0 = 'Mean ';

str1 = [str0 num2str(mimo.main.precoderType) ' ' num2str(mimo.main.numTx) 'x'  num2str(mimo.main.numRx) 'x'  num2str(mimo.main.numSTS)];
fig = mimo.plotMeanBER('--k', 2, 'SNR', str1);
