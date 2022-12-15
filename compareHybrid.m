clc;clear;%close all;
inlcudes()
rng(67)
%% Система
numUsers = 1;
numTx = 64;
numRxUsers = 4; 
numSTSVec = 2;
syconf = SystemConfig('numUsers',numUsers,'numTx',numTx,'numRxUsers',numRxUsers,'numSTSVec',numSTSVec);
%% Канал
anglesTx = {[91;-1];};%{[91;-1]; [2;1]; [-85;0]; [179;3];};  %[azimuth;elevation] {[91;-1];};%
% channel = LOSChannel('sysconf',syconf,'anglesTx',anglesTx); % StaticChannel RaylSpecialChannel MultipathChannel LOSChannel
channel = StaticChannel('sysconf',syconf);
%% Симуляция
snr = 0:40;                             % Диапазон SNR 
sim = SimulationConfig('snr',snr);
%% Создание моделей
hmimo = HybridMassiveMimo('main',syconf,'downChannel',channel,'precoderType','JSDM/OMP','hybridType','full');
mimo = MassiveMimo('main',syconf,'downChannel',channel,'precoderType','DIAG','sim',sim);

hmimo.simulate();
mimo.simulate();
%% Построение графиков
fig = figure();
leg1 = hmimo.getLegend();
leg1 = [leg1 ' type ' hmimo.hybridType];
hmimo.plotMeanBER('lineStyle','k','legendStr',leg1,'figObj',fig);
mimo.plotMeanBER('lineStyle','--k','figObj',fig);

fig1 = figure();
hmimo.plotCapacity('type','mean','lineStyle','k','legendStr',leg1,'figObj',fig1);
mimo.plotCapacity('type','mean','lineStyle','--k','figObj',fig1);

fig2 = figure();
hmimo.plotCapacity('type','all','lineStyle','k','legendStr',leg1,'figObj',fig2);
mimo.plotCapacity('type','all','lineStyle','--k','figObj',fig2);
%%
function inlcudes()
    addpath('Parameters');
    addpath('Channels');
    addpath('Precoders');
end