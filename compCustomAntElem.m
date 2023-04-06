clc;clear;
rng(67)
%% Создание канала
numRows = 8;
numColumns = 8;
anglesTx = {[-60;1]; [-30;-1]; [30;0]; [60;3];};  %[azimuth;elevation]
channel = LOScustomAntElem('anglesTx',anglesTx,'numRows',numRows,'numColumns',numColumns);
% channel = StaticMultipathChannel('numRows',numRows,'numColumns',numColumns);
% channel.averagePathGains = 0;
% channel.tau = 0;
%% Создание модели
mimo = MassiveMimo();
mimo.main.numRxUsers = [1 1 1 1];
mimo.main.numSTSVec = [1 1 1 1];
mimo.main.numUsers = channel.numUsers;
mimo.main.numTx = channel.numTx; 
mimo.main.precoderType = 'DIAG';
mimo.downChannel = channel;
%% Симуляция
SNR = 0:35;                             % Диапазон SNR 
minNumErrs = 100;                       % Порог ошибок для цикла 
maxNumSimulation = 1;                   % Максимальное число итераций в цикле while 50
maxNumZeroBER = 1;                      % Максимальное кол-во измерений с нулевым кол-вом

mimo.simulate(SNR, maxNumZeroBER, minNumErrs, maxNumSimulation);
%% Построение графиков
fig = figure();
str0 = 'Mean ';
str1 = [str0 mimo.main.precoderType ' ' num2str(mimo.main.numTx) 'x'  num2str(mimo.main.numRx)...
        'x'  num2str(mimo.main.numSTS)];
mimo.plotMeanBER('k', 2, 'SNR', str1,fig);