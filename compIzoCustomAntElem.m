clear;clc;
inlcudes()
%% Система
numUsers = 4;
numTx = 8;
numRxUsers = ones(1,numUsers); 
numSTSVec = numRxUsers;
config = SystemConfig('numUsers',numUsers,'numTx',numTx,'numRxUsers',numRxUsers,'numSTSVec',numSTSVec);
%% Канал
if numUsers == 8
    anglesTx = {[-65;0]; [-25;0]; [37;0]; [70;0]; [-11;0]; [11;0]; [-83;0]; [83;0];};
elseif numUsers == 4
    anglesTx = {[-45;0]; [-25;0]; [37;0]; [55;0];};
%     anglesTx = {[-5;0]; [0;0]; [5;0]; [10;0];};
elseif numUsers == 2  
%     anglesTx = {[-5;0]; [0;0];}; 
    anglesTx = {[-5;0]; [0;0];}; 
end
los = LOSSpecialChannelIzo('sysconf',config,'anglesTx',anglesTx);
losCust = LOSSpecialChannelCust('sysconf',config,'anglesTx',anglesTx);
% static = StaticChannel('sysconf',config);
%% Симуляция
snr = 0:40;                             % Диапазон SNR 
sim = SimulationConfig('snr',snr);
%% Модель
modelIzo = MassiveMimo('main',config,'downChannel',los,'sim',sim);
modelCust = MassiveMimo('main',config,'downChannel',losCust,'sim',sim);

numChannels = 10;
% rng(67);
% modelIzo.simulate();
modelIzo.simulate1(numChannels);
% rng(67);
% modelCust.simulate();
modelCust.simulate1(numChannels);
%% Построение графиков
fig = figure();
leg1 = modelIzo.getLegend();
leg1 = [leg1 ' izo'];
modelIzo.plotMeanBER('lineStyle','k','legendStr',leg1,'figObj',fig);

leg2 = modelCust.getLegend();
leg2 = [leg2 ' cust'];
modelCust.plotMeanBER('lineStyle','--k','legendStr',leg2,'figObj',fig);

fig1 = figure();
modelIzo.plotCapacity('type','mean','lineStyle','k','legendStr',leg1,'figObj',fig);
modelCust.plotCapacity('type','mean','lineStyle','--k','legendStr',leg2,'figObj',fig1);

Hizo = cat(2,modelIzo.downChannel.channel{:});
Hcust = cat(2,modelCust.downChannel.channel{:});
svd(Hizo)
svd(Hcust)
cond(Hizo)
cond(Hcust)
%%
function inlcudes()
    addpath('Parameters');
    addpath('Channels');
    addpath('Precoders');
end