clc;clear;
%% Создание моделей
modelMM = MassiveMimo();
modelMM.main.numTx = 8;
modelMM.main.numUsers = 4;
modelMM.main.numRx = 8;
modelMM.main.numSTSVec = [1 1 1 1];
modelMM.main.precoderType = 'ZF';
modelMM.channel.type = 'STATIC';
modelMM.calculateParam();

modelMM1 = copy(modelMM);
modelMM1.main.precoderType = 'DIAG';
modelMM1.calculateParam();

modelHybridFull = HybridMassiveMimo();
modelHybridFull.main.numTx = modelMM.main.numTx;
modelHybridFull.main.numUsers = modelMM.main.numUsers;
modelHybridFull.main.numRx = modelMM.main.numRx;
modelHybridFull.main.numSTSVec = modelMM.main.numSTSVec;
modelHybridFull.channel.type = 'STATIC';
modelHybridFull.calculateParam();

modelHybridSub = copy(modelHybridFull);
modelHybridSub.main.hybridType = 'sub';
%% Симуляция
SNR = 0:40;                             % Диапазон SNR 
minNumErrs = 100;                       % Порог ошибок для цикла 
maxNumSimulation = 5;                   % Максимальное число итераций в цикле while 50
maxNumZeroBER = 1;                      % Максимальное кол-во измерений с нулевым кол-вом

modelHybridFull.simulate(SNR, maxNumZeroBER, minNumErrs, maxNumSimulation);
modelMM.simulate(SNR, maxNumZeroBER, minNumErrs, maxNumSimulation);
modelMM1.simulate(SNR, maxNumZeroBER, minNumErrs, maxNumSimulation);
% modelHybridSub.simulate(SNR, maxNumZeroBER, minNumErrs, maxNumSimulation);
%% Построение графиков
str0 = 'Mean ';
str1 = [str0 num2str(modelHybridFull.main.precoderType) ' ' num2str(modelHybridFull.main.numTx) 'x'  num2str(modelHybridFull.main.numRx)...
        'x'  num2str(modelHybridFull.main.numSTS) ' type ' modelHybridFull.main.hybridType];
fig = modelHybridFull.plotMeanBER('--k', 2, 'SNR', str1);

str2 = [str0 num2str(modelMM.main.precoderType) ' ' num2str(modelMM.main.numTx) 'x'  num2str(modelMM.main.numRx) 'x'  num2str(modelMM.main.numSTS)];
modelMM.plotMeanBER('k', 2, 'SNR', str2, fig);

str3 = [str0 num2str(modelMM1.main.precoderType) ' ' num2str(modelMM1.main.numTx) 'x'  num2str(modelMM1.main.numRx) 'x'  num2str(modelMM1.main.numSTS)];
modelMM1.plotMeanBER('*-k', 2, 'SNR', str3, fig);

% str3 = [str0 num2str(modelHybridSub.main.precoderType) ' ' num2str(modelHybridSub.main.numTx) 'x'  num2str(modelHybridSub.main.numRx)...
%         'x'  num2str(modelHybridSub.main.numSTS) ' type ' modelHybridSub.main.hybridType];
% modelHybridSub.plotMeanBER('-.k', 2, 'SNR', str3, fig);