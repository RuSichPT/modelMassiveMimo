clc;clear;
addpath('Parameters');
addpath('Channels');
%% Создание моделей
modelMM = MassiveMimo();
numTx = 512;
numUsers = 4;
numRx = 4;
numSTSVec = [1 1 1 1];
%%
modelMM.main.numTx = numTx;
modelMM.main.numUsers = numUsers;
modelMM.main.numRx = numRx;
modelMM.main.numSTSVec = numSTSVec;
modelMM.main.precoderType = 'DIAG';
% modelMM.downChannel.type = 'STATIC';
% modelMM.downChannel.txAng = {0,30,60,90};
modelMM.downChannel = RaylSpecialChannel('numTx',numTx,'numUsers',numUsers,'numRxUsers',modelMM.main.numRxUsers);
modelMM.downChannel.tau = [0 2 5];
modelMM.downChannel.averagePathGains = [0 -3 -9];
% modelMM.downChannel.tau = 0; 
% modelMM.downChannel.averagePathGains = 0;

% modelMM1 = copy(modelMM);
% modelMM1.main.precoderType = 'DIAG';
% modelMM1.main.combainerType = 'DIAG';

modelHybridFull = HybridMassiveMimo();
modelHybridFull.main.numTx = modelMM.main.numTx;
modelHybridFull.main.numUsers = modelMM.main.numUsers;
modelHybridFull.main.numRx = modelMM.main.numRx;
modelHybridFull.main.numSTSVec = modelMM.main.numSTSVec;
modelHybridFull.downChannel = modelMM.downChannel;
modelHybridFull.main.precoderType = 'JSDM';

modelHybridSub = copy(modelHybridFull);
modelHybridSub.hybridType = 'sub';

modelHybridFull.downChannel.dispChannel();
modelMM.downChannel.dispChannel();
% modelMM1.downChannel.dispChannel();
modelHybridSub.downChannel.dispChannel();
%% Симуляция
SNR = 0:25;                             % Диапазон SNR 
minNumErrs = 100;                       % Порог ошибок для цикла 
maxNumSimulation = 1;                   % Максимальное число итераций в цикле while 50
maxNumZeroBER = 100;                      % Максимальное кол-во измерений с нулевым кол-вом

modelHybridFull.simulate(SNR, maxNumZeroBER, minNumErrs, maxNumSimulation);
modelMM.simulate(SNR, maxNumZeroBER, minNumErrs, maxNumSimulation);
% modelMM1.simulate(SNR, maxNumZeroBER, minNumErrs, maxNumSimulation);
modelHybridSub.simulate(SNR, maxNumZeroBER, minNumErrs, maxNumSimulation);
%% Построение графиков
% Ber
str0 = 'Mean ';
str1 = [str0 modelHybridFull.main.precoderType ' ' num2str(modelHybridFull.main.numTx) 'x'  num2str(modelHybridFull.main.numRx)...
        'x'  num2str(modelHybridFull.main.numSTS) ' type ' modelHybridFull.hybridType];
fig = modelHybridFull.plotMeanBER('--k', 2, 'SNR', str1);

str2 = [str0 modelMM.main.precoderType ' ' num2str(modelMM.main.numTx) 'x'  num2str(modelMM.main.numRx)...
    'x'  num2str(modelMM.main.numSTS) ' ' modelMM.main.combainerType];
modelMM.plotMeanBER('k', 2, 'SNR', str2, fig);

% str3 = [str0 modelMM1.main.precoderType ' ' num2str(modelMM1.main.numTx) 'x'  num2str(modelMM1.main.numRx)...
%     'x'  num2str(modelMM1.main.numSTS) ' ' modelMM1.main.combainerType];
% modelMM1.plotMeanBER('*-k', 2, 'SNR', str3, fig);

str4 = [str0 modelHybridSub.main.precoderType ' ' num2str(modelHybridSub.main.numTx) 'x'  num2str(modelHybridSub.main.numRx)...
        'x'  num2str(modelHybridSub.main.numSTS) ' type ' modelHybridSub.hybridType];
modelHybridSub.plotMeanBER('-.k', 2, 'SNR', str4, fig);

% Capacity
fig1 = modelHybridFull.plotCapacity('mean','--k',2,str1);
modelMM.plotCapacity('mean','k',2,str2,fig1);
modelHybridSub.plotCapacity('mean','-.k',2,str2,fig1);

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
    
save(str,'modelHybridFull','modelMM','modelHybridSub');