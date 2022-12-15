clc;clear;
addpath('Parameters');
addpath('Channels')
rng(122);
%% Система
numTx = 32;
numUsers = 4;
numRxUsers = [1 1 1 1]; 
numSTSVec = [1 1 1 1];
mod = 4;
config = SystemConfig('numUsers',numUsers,'numTx',numTx,'numRxUsers',numRxUsers,'numSTSVec',numSTSVec);
%% Создание канала
channel = StaticChannel('sysconf',config); % StaticChannel % RaylSpecialChannel
%% Симуляция
snr = 0:40;
maxNumSimulation = 1;
sim = SimulationConfig('snr',snr,'maxNumSimulation',maxNumSimulation);
%% Создание моделей
modelZF = MassiveMimo('main',config,'downChannel',channel,'sim',sim,'precoderType','ZF');
modelMF = MassiveMimo('main',config,'downChannel',channel,'sim',sim,'precoderType','MF');
modelEBM = MassiveMimo('main',config,'downChannel',channel,'sim',sim,'precoderType','EBM');
modelRZF = MassiveMimo('main',config,'downChannel',channel,'sim',sim,'precoderType','RZF');
modelDIAG = MassiveMimo('main',config,'downChannel',channel,'sim',sim,'precoderType','DIAG');

modelMF.simulate();
modelZF.simulate();
modelEBM.simulate();
modelRZF.simulate();
modelDIAG.simulate();
%% Построение графиков
fig = figure();
modelMF.plotMeanBER('lineStyle','k','figObj',fig);
modelZF.plotMeanBER('lineStyle','--k','figObj',fig);
modelEBM.plotMeanBER('lineStyle','-.k','figObj',fig);
modelRZF.plotMeanBER('lineStyle',':k','figObj',fig);
modelDIAG.plotMeanBER('lineStyle','*-k','figObj',fig);

modelMF.downChannel.dispChannel();
modelZF.downChannel.dispChannel();
modelEBM.downChannel.dispChannel();
modelRZF.downChannel.dispChannel();
modelDIAG.downChannel.dispChannel();