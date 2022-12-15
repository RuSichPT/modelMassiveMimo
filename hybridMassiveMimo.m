clc;clear;
addpath('Parameters');
addpath('Channels');
%% Система
numTx = 32;
numUsers = 4;
numRx = 4;
numRxUsers = [1 1 1 1];
numSTSVec = [1 1 1 1];
precoderType = 'DIAG';
sysconf = SystemConfig('numUsers',numUsers,'numTx',numTx,'numRxUsers',numRxUsers,'numSTSVec',numSTSVec);
%% Канал
tau = [0 2 5];
avgPathGains_dB = [0 -3 -9];
chconf = ChannelConfig('tau',tau,'avgPathGains_dB',avgPathGains_dB);
channel = RaylSpecialChannel('chconf',chconf,'sysconf',sysconf);
%% Симуляция
snr = 0:25;
maxNumSimulation = 1;
sim = SimulationConfig('snr',snr,'maxNumSimulation',maxNumSimulation);
%% Модели
modelMM = MassiveMimo('main',sysconf,'downChannel',channel,'sim',sim,'precoderType','ZF');
modelHybridFull = HybridMassiveMimo('main',sysconf,'downChannel',channel,'sim',sim,'precoderType','JSDM/OMP');
modelHybridSub = HybridMassiveMimo('main',sysconf,'downChannel',channel,'sim',sim,'precoderType','JSDM/OMP','hybridType','sub');

modelHybridFull.downChannel.dispChannel();
modelMM.downChannel.dispChannel();
modelHybridSub.downChannel.dispChannel();
%% Симуляция

modelHybridFull.simulate();
modelMM.simulate();
modelHybridSub.simulate();
%% Построение графиков
% Ber
fig = figure();
modelHybridFull.plotMeanBER('lineStyle','--k','figObj',fig);
modelMM.plotMeanBER('lineStyle','k','figObj',fig);
modelHybridSub.plotMeanBER('lineStyle','-.k','figObj',fig);

% Capacity
fig1 = figure();
modelHybridFull.plotCapacity('type','mean','lineStyle','--k','figObj',fig1);
modelMM.plotCapacity('type','mean','lineStyle','k','figObj',fig1);
modelHybridSub.plotCapacity('type','mean','lineStyle','-.k','figObj',fig1);
%% Save
if modelMM.downChannel.tau == 0 
    channel = cat(2, class(modelMM.downChannel),'flat');
else
    channel = class(modelMM.downChannel);
end
% str = ['DataBase/RLNC2022/'  channel ' numSim ' num2str(maxNumSimulation) ' ' num2str(modelMM.main.numTx) 'x'...
%         num2str(modelMM.main.numRx) 'x'  num2str(modelMM.main.numSTS) 'x'   erase(num2str(modelMM.main.numSTSVec),' ') '.mat'];
    
str = ['DataBase/Теория и техника радиосвязи 2022/'  channel ' numSim ' num2str(maxNumSimulation) ' ' num2str(modelMM.main.numTx) 'x'...
        num2str(modelMM.main.numRx) 'x'  num2str(modelMM.main.numSTS) 'x'   erase(num2str(modelMM.main.numSTSVec),' ') '.mat'];
    
% save(str,'modelHybridFull','modelMM','modelHybridSub');