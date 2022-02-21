clc;clear;
%% Создание моделей
modelMM = MassiveMimo();
modelMM.main.numTx = 8;
modelMM.main.numUsers = 4;
modelMM.main.numRx = 8;
modelMM.main.numSTSVec = [1 1 1 1];
modelMM.main.precoderType = 'ZF';
% modelMM.channel.type = 'SCATTERING_FLAT';
% modelMM.channel.txAng = {0,30,60,90};
% modelMM.channel.tau = 0; 
% modelMM.channel.pdB = 0;
modelMM.channel.tau = [0 2 5 ] * (1 / modelMM.channel.sampleRate);
modelMM.channel.pdB = [0 -3 -9];
modelMM.calculateParam();

modelMM1 = copy(modelMM);
modelMM1.main.precoderType = 'DIAG';
modelMM1.calculateParam();

modelHybridFull = HybridMassiveMimo();
modelHybridFull.main.numTx = modelMM.main.numTx;
modelHybridFull.main.numUsers = modelMM.main.numUsers;
modelHybridFull.main.numRx = modelMM.main.numRx;
modelHybridFull.main.numSTSVec = modelMM.main.numSTSVec;
modelHybridFull.channel = modelMM.channel;
modelHybridFull.calculateParam();

modelHybridSub = copy(modelHybridFull);
modelHybridSub.main.hybridType = 'sub';

modelHybridFull.dispChannel();
modelMM.dispChannel();
modelMM1.dispChannel();
%% Симуляция
SNR = 0:25;                             % Диапазон SNR 
minNumErrs = 100;                       % Порог ошибок для цикла 
maxNumSimulation = 5;                   % Максимальное число итераций в цикле while 50
maxNumZeroBER = 1;                      % Максимальное кол-во измерений с нулевым кол-вом

modelHybridFull.simulate(SNR, maxNumZeroBER, minNumErrs, maxNumSimulation);
% modelMM.simulate(SNR, maxNumZeroBER, minNumErrs, maxNumSimulation);
modelMM1.simulate(SNR, maxNumZeroBER, minNumErrs, maxNumSimulation);
modelHybridSub.simulate(SNR, maxNumZeroBER, minNumErrs, maxNumSimulation);
%% Построение графиков
str0 = 'Mean ';
str1 = [str0 num2str(modelHybridFull.main.precoderType) ' ' num2str(modelHybridFull.main.numTx) 'x'  num2str(modelHybridFull.main.numRx)...
        'x'  num2str(modelHybridFull.main.numSTS) ' type ' modelHybridFull.main.hybridType];
fig = modelHybridFull.plotMeanBER('--k', 2, 'SNR', str1);

% str2 = [str0 num2str(modelMM.main.precoderType) ' ' num2str(modelMM.main.numTx) 'x'  num2str(modelMM.main.numRx) 'x'  num2str(modelMM.main.numSTS)];
% modelMM.plotMeanBER('k', 2, 'SNR', str2, fig);

str3 = [str0 num2str(modelMM1.main.precoderType) ' ' num2str(modelMM1.main.numTx) 'x'  num2str(modelMM1.main.numRx) 'x'  num2str(modelMM1.main.numSTS)];
modelMM1.plotMeanBER('*-k', 2, 'SNR', str3, fig);

str4 = [str0 num2str(modelHybridSub.main.precoderType) ' ' num2str(modelHybridSub.main.numTx) 'x'  num2str(modelHybridSub.main.numRx)...
        'x'  num2str(modelHybridSub.main.numSTS) ' type ' modelHybridSub.main.hybridType];
modelHybridSub.plotMeanBER('-.k', 2, 'SNR', str4, fig);

% plotImpulseFrequencyResponses(1, 1, modelMM.channel.downChannel, modelMM.channel.sampleRate);

if (~isfield(modelMM.channel,'tau')) || (modelMM.channel.tau == 0) 
    channel = cat(2, modelMM.channel.type,'flat');
else
    channel = modelMM.channel.type;
end
str = ['DataBase/RLNC2022/'  channel ' numSim ' num2str(maxNumSimulation) ' ' num2str(modelMM.main.numTx) 'x'...
        num2str(modelMM.main.numRx) 'x'  num2str(modelMM.main.numSTS) 'x'   erase(num2str(modelMM.main.numSTSVec),' ') '.mat'];
% save(str,'modelHybridFull','modelMM1','modelHybridSub');