clc;clear;close all;
addpath('Parameters');
addpath('Channels');
%% Создание модели
hmimo = HybridMassiveMimo();
hmimo.main.numUsers = 2;
hmimo.main.numTx = 32;
hmimo.main.numRxUsers = [2 2]; 
hmimo.main.numSTSVec = [2 2];
hmimo.main.modulation = 4;
hmimo.hybridType = 'full';
%% Создание канала
channel = RaylSpecialChannel(); % RaylSpecialChannel, StaticChannel, RaylChannel
channel.numUsers = hmimo.main.numUsers;
channel.numTx = hmimo.main.numTx;
channel.numRxUsers = hmimo.main.numRxUsers;
hmimo.downChannel = channel;
%% Симуляция
SNR = 0:30;                             % Диапазон SNR 
minNumErrs = 100;                       % Порог ошибок для цикла 
maxNumSimulation = 1;                   % Максимальное число итераций в цикле while 50
maxNumZeroBER = 100;                    % Максимальное кол-во измерений с нулевым кол-вом

hmimo.simulate(SNR, maxNumZeroBER, minNumErrs, maxNumSimulation);
%% Построение графиков
str0 = 'Mean ';

str1 = [str0 hmimo.main.precoderType ' ' num2str(hmimo.main.numTx) 'x'  num2str(hmimo.main.numRx)...
        'x'  num2str(hmimo.main.numSTS) ' type ' hmimo.hybridType];
fig1 = hmimo.plotMeanBER('--k',2,'SNR',str1);

str2 = 'All STS ';
str3 = [str2 hmimo.main.precoderType ' ' num2str(hmimo.main.numTx) 'x'  num2str(hmimo.main.numRx)...
        'x'  num2str(hmimo.main.numSTS) ' type ' hmimo.hybridType];
fig2 = hmimo.plotCapacity('all','--k',2,str3);
