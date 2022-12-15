clc;clear;close all;
addpath('Parameters');
addpath('Channels');
%% Система
numUsers = 4;
numTx = 16;
numRxUsers = [4 4 4 4]; 
numSTSVec = [2 2 2 2];
mod = 4;
precoderType = 'DIAG';
sysconf = SystemConfig('numUsers',numUsers,'numTx',numTx,'numRxUsers',numRxUsers,'numSTSVec',numSTSVec);
%% Создание канала
channel = RaylSpecialChannel('sysconf',sysconf);
%% Симуляция
snr = 0:30;                             % Диапазон SNR 
sim = SimulationConfig('snr',snr);
%% Создание модели
mimo = MassiveMimo('main',sysconf,'downChannel',channel,'sim',sim,'precoderType',precoderType,'modulation',mod);
mimo.simulate();
%% Построение графиков
mimo.plotMeanBER('lineStyle','--k');
mimo.plotCapacity('type','all','lineStyle','--k');