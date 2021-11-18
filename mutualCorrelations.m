clc;clear;
%% Параметры системы
main.numTx = 8;                                        % Кол-во передающих антен
main.numUsers = 4;                                      % Кол-во пользователей
main.numRx = main.numUsers;                             % Кол-во приемных антен
main.numSTSVec = ones(1, main.numUsers);                % Кол-во независимых потоков данных на одного пользователя / [2 1 3 2]
main.modulation = 4;                                    % Порядок модуляции
main.freqCarrier = 28e9;                                % Частота несущей 28 GHz system                               
main.precoderType = 'ZF';                               % Тип прекодера
corrMatrix = zeros(main.numTx);
corrMatrix(:,:) = 0.2;
for i = 1:main.numTx
    corrMatrix(i,i) = 1;
end
%% Параметры канала
channel.channelType = 'STATIC';    % PHASED_ARRAY_STATIC, PHASED_ARRAY_DYNAMIC STATIC 
switch channel.channelType
    case {'PHASED_ARRAY_STATIC', 'PHASED_ARRAY_DYNAMIC'}
        channel.numDelayBeams = 3;       % Кол-во задержанных сигналов (размерность канального тензора)
        channel.txAng = {0,90,180,270};
    case 'RAYL'
        channel.sampleRate = 40e6;
        channel.tau = [2 5 7] * (1 / channel.sampleRate);
        channel.pdB = [-3 -9 -12];
end
%% Создание моделей 
modelMF = MassiveMimo('Main', main,'Channel', channel);
modelMFmutCorr = copy(modelMF);
modelZF = MassiveMimo('Main', main,'Channel', channel);
modelZF.main.precoderType = 'ZF';
modelZFmutCorr = copy(modelZF);
%% Симуляция
SNR = 0:40;                             % Диапазон SNR 
minNumErrs = 100;                       % Порог ошибок для цикла 
maxNumSimulation = 3;                   % Максимальное число итераций в цикле while 50
maxNumZeroBER = 1;                      % Максимальное кол-во измерений с нулевым кол-вом 

modelMF.simulate(SNR, maxNumZeroBER, minNumErrs, maxNumSimulation);
modelMFmutCorr.simulateMutCorr(SNR, maxNumZeroBER, minNumErrs, maxNumSimulation, corrMatrix);
modelZF.simulate(SNR, maxNumZeroBER, minNumErrs, maxNumSimulation);
modelZFmutCorr.simulateMutCorr(SNR, maxNumZeroBER, minNumErrs, maxNumSimulation, corrMatrix);
%% Построение графиков
str0 = 'Mean ';
str1 = [str0 num2str(modelMF.main.precoderType) ' ' num2str(modelMF.main.numTx) 'x'  num2str(modelMF.main.numRx)];
fig = modelMF.plotMeanBER('k', 2, 'SNR', str1);

str = 'CorrTx ';
str2 = [str0 str num2str(modelMFmutCorr.main.precoderType) ' ' num2str(modelMFmutCorr.main.numTx) 'x'  num2str(modelMFmutCorr.main.numRx)];
modelMFmutCorr.plotMeanBER('-.k', 2, 'SNR', str2, fig);

str3 = [str0 num2str(modelZF.main.precoderType) ' ' num2str(modelZF.main.numTx) 'x'  num2str(modelZF.main.numRx)];
modelZF.plotMeanBER('--k', 2, 'SNR', str3, fig);

str4 = [str0 str num2str(modelZFmutCorr.main.precoderType) ' ' num2str(modelZFmutCorr.main.numTx) 'x'  num2str(modelZFmutCorr.main.numRx)];
modelZFmutCorr.plotMeanBER(':k', 2, 'SNR', str4, fig);

lineStyle = {'r';'g';'b';'k';};
fig = modelMF.plotSTSBER(lineStyle, 2, 'SNR', '');

lineStyle = {'--r';'--g';'--b';'--k';};
modelMFmutCorr.plotSTSBER(lineStyle, 2, 'SNR', str, fig);
