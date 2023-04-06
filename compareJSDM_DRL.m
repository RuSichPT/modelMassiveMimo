clc;clear;
%% Система
numUsers = 1;
mod = 16;
numTx = 16;
numRxUsers = 4; 
numSTSVec = 4;
config = SystemConfig('numUsers',numUsers,'numTx',numTx,'numRxUsers',numRxUsers,'numSTSVec',numSTSVec);
%% Канал
channel = ChannelForNeuralNet('sysconf',config);% StaticChannel, ChannelForNeuralNet
%% Симуляция
snr = 0:70;                             % Диапазон SNR 
sim = SimulationConfig('snr',snr);
%% Создание моделей
hmimo = HybridMassiveMimo('main',config,'downChannel',channel,'sim',sim,'modulation',mod);
mimo = MassiveMimo('main',config,'downChannel',channel,'sim',sim,'modulation',mod);
hmimoNN = HybridMassiveMimo('main',config,'downChannel',channel,'precoderType','DRL-NN','sim',sim,'modulation',mod);

hmimo.simulate();
mimo.simulate();
hmimoNN.simulate();
%% Построение графиков
fig = figure();
fig = hmimo.plotMeanBER('k', 2, 'SNR', str1,fig);
mimo.plotMeanBER('--k', 2, 'SNR', str2,fig);
hmimoNN.plotMeanBER('-.k', 2, 'SNR', str3, fig);