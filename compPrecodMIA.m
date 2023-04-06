clc;clear;
rng(122);
%% Система
numUsers = 1;
numTx = 8;
numRxUsers = 4; 
numSTSVec = 2;
mod = 4;
syconf = SystemConfig('numUsers',numUsers,'numTx',numTx,'numRxUsers',numRxUsers,'numSTSVec',numSTSVec);
%% Создание канала
channel = RaylSpecialChannel('sysconf',syconf); % StaticChannel % RaylSpecialChannel
%% Симуляция
snr = 0:40;
maxNumSimulation = 1;
sim = SimulationConfig('snr',snr,'maxNumSimulation',maxNumSimulation);
%% Создание моделей
modelZF = MassiveMimo('main',syconf,'downChannel',channel,'sim',sim,'modulation',mod,'precoderType','ZF');
modelTPE = MassiveMimo('main',syconf,'downChannel',channel,'sim',sim,'modulation',mod,'precoderType','TPE');
modelNSA = MassiveMimo('main',syconf,'downChannel',channel,'sim',sim,'modulation',mod,'precoderType','NSA');
modelNI = MassiveMimo('main',syconf,'downChannel',channel,'sim',sim,'modulation',mod,'precoderType','NI');
modelNI_NSA = MassiveMimo('main',syconf,'downChannel',channel,'sim',sim,'modulation',mod,'precoderType','NI-NSA');

modelZF.simulate();
modelTPE.simulate();
modelNSA.simulate();
modelNI.simulate();
modelNI_NSA.simulate();
%% Построение графиков
fig = figure();
modelZF.plotMeanBER('lineStyle','k','figObj',fig);
modelTPE.plotMeanBER('lineStyle','--k','figObj',fig);
modelNSA.plotMeanBER('lineStyle','-.k','figObj',fig);
modelNI.plotMeanBER('lineStyle',':k','figObj',fig);
modelNI_NSA.plotMeanBER('lineStyle','*-k','figObj',fig);

modelZF.downChannel.dispChannel();
modelTPE.downChannel.dispChannel();
modelNSA.downChannel.dispChannel();
modelNI.downChannel.dispChannel();
modelNI_NSA.downChannel.dispChannel();