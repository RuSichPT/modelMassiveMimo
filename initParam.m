%% Параметры системы 
numAntenns = 8;                                 % Кол-во антенн в антенной решетке / 12 or 8 
numUsers = 4;                                   % Кол-во пользователей
modulation = 4;                                 % Порядок модуляции
freqCarrier = 28e9;                             % Частота несущей 28 GHz system 

numSTSVec = ones(1, numUsers);                  % Кол-во независимых потоков данных на одного пользователя / [2 1 3 2]; 
numSTS = sum(numSTSVec);                        % Кол-во потоков данных; должно быть степени 2: /2/4/8/16/32/64
numAntennsSTS = numAntenns / numSTS;            % Кол-во антенн на один поток данных
numTx = numSTS * numAntennsSTS;                 % Кол-во передающих антен 
numRx = numSTS;                                 % Кол-во приемных антен
bps = log2(modulation);                         % Кол-во бит на символ в секунду
%% Параметры OFDM 
numSubCarriers = 450;                           % Кол-во поднессущих
lengthFFT = 512;                                % Длина FFT для OFDM
numSymbOFDM = 10;                               % Кол-во символов OFDM от каждой антенны
cyclicPrefixLength = 64;                        % Длина защитных интервалов = 2*Ngi

tmpNCI = lengthFFT - numSubCarriers;
nullCarrierIndices = [1:tmpNCI/2 (1 + lengthFFT - tmpNCI / 2):lengthFFT]'; % Guards and DC
clear tmpNCI;

numBits = bps * numSymbOFDM * numSubCarriers;   % Длина бинарного потока
%% Параметры канала
chanParam.channelType = "PHASED_ARRAY_STATIC";    % PHASED_ARRAY_STATIC, PHASED_ARRAY_DYNAMIC
chanParam.numUsers = numUsers;
if (chanParam.channelType == "PHASED_ARRAY_STATIC" || chanParam.typeChannel == "PHASED_ARRAY_DYNAMIC")
    [chanParam.da, chanParam.dp] = loadSteeringVector(numAntenns);  % Амплитуда и фаза SteeringVector
    chanParam.numDelayBeams = 3;                                    % Кол-во задержанных сигналов (размерность канального тензора)
    chanParam.txAng = {0,90,180,270};
end
%% Параметры преамбулы зондирования
preambleParamZond.numSC = numSubCarriers;
preambleParamZond.numSTS = numTx;
preambleParamZond.N_FFT = lengthFFT;
preambleParamZond.CyclicPrefixLength = cyclicPrefixLength;
preambleParamZond.NullCarrierIndices = nullCarrierIndices;
%% Параметры преамбулы 
preambleParam.numSC = numSubCarriers;
preambleParam.numSTS = numSTS;
preambleParam.N_FFT = lengthFFT;
preambleParam.CyclicPrefixLength = cyclicPrefixLength;
preambleParam.NullCarrierIndices = nullCarrierIndices;
%% Параметры расчета доверительного интервала Монте-Карло
confidenceLevel = 0.95;         % Уровень достоверности
coefConfInterval = 1/15;        % ???  