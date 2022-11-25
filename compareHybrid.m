clc;clear;%close all;
addpath('Parameters');
addpath('Channels');
rng(67)
% numRows = 4;
% numColumns = 4;
% anglesTx = {[2;1]; [91;-1]; [-85;0]; [179;3];};  %[azimuth;elevation]
% channel = StaticLOSChannel('anglesTx',anglesTx,'numRows',numRows,'numColumns',numColumns);
% channel = StaticMultipathChannel('numRows',numRows,'numColumns',numColumns);
% channel.averagePathGains = 0;
% channel.tau = 0;
%% Создание Параметров
param = SystemParam();
param.numTx = 16;
param.numUsers = 2;
param.numRxUsers = [4 4]; 
param.numSTSVec = [2 2];
param.modulation = 4;
%% Создание канала
channel = StaticChannel(); % StaticChannel % RaylSpecialChannel
channel.numTx = param.numTx;
channel.numUsers = param.numUsers;
channel.numRxUsers = param.numRxUsers;
%% Создание моделей
hmimo = HybridMassiveMimo('main',param,'downChannel',channel);
mimo = MassiveMimo('main',param,'downChannel',channel);
mimo.main.precoderType = 'DIAG';
hmimo.main.precoderType = 'JSDM';
hmimo.hybridType = 'full';
%% Симуляция
SNR = 0:35;                             % Диапазон SNR 
minNumErrs = 100;                       % Порог ошибок для цикла 
maxNumSimulation = 1;                   % Максимальное число итераций в цикле while 50
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

fig1 = hmimo.plotCapacity('mean','k',2,str1);
mimo.plotCapacity('mean','--k',2,str2,fig1);

str0 = 'All STS ';
str1 = [str0 hmimo.main.precoderType ' ' num2str(hmimo.main.numTx) 'x'  num2str(hmimo.main.numRx)...
        'x'  num2str(hmimo.main.numSTS) ' type ' hmimo.hybridType];
str2 = [str0 num2str(mimo.main.precoderType) ' ' num2str(mimo.main.numTx) 'x'  num2str(mimo.main.numRx) 'x'  num2str(mimo.main.numSTS)];
fig1 = hmimo.plotCapacity('all','k',2,str1);
mimo.plotCapacity('all','--k',2,str2,fig1);