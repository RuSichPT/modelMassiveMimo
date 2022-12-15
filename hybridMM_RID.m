clc;clear;close all;
addpath('Parameters');
addpath('Channels');
%% Создание модели
numUsers = 2;
numTx = 32;
numRxUsers = [2 2]; 
numSTSVec = [2 2];
mod = 4;
hybridType = 'full';
sysconf = SystemConfig('numUsers',numUsers,'numTx',numTx,'numRxUsers',numRxUsers,'numSTSVec',numSTSVec);
%% Создание канала
channel = RaylSpecialChannel('sysconf',sysconf);
%% Симуляция
snr = 0:30;                             % Диапазон SNR 
sim = SimulationConfig('snr',snr);
%% Создание модели
hmimo = HybridMassiveMimo('main',sysconf,'downChannel',channel,'sim',sim,'hybridType',hybridType,'modulation',mod);
hmimo.simulate();
%% Построение графиков
hmimo.plotMeanBER('lineStyle','--k');
hmimo.plotCapacity('type','all','lineStyle','--k');