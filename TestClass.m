clear; clc;
addpath('MyChannels');

channelParam = ChannelParam();
static = StaticChannel();

channelNN = ChannelForNeuralNet();

ofdm = OfdmParam();
ofdm2 = OfdmParam();
ofdm1 = OfdmParam('numSubCarriers',120);
ofdm.numSubCarriers = 256;

main = SystemParam();
main.numTx = 32;
main1 = SystemParam('modulation', 16);

channel = RaylChannel('numTx',16);
channel.sampleRate = 20e6;
mCh = channel.channel;
channel1 = RaylChannel('tau',[1 2 3]);
channel1.numRxUsers = [2 4 2 4];

channel2 = RaylSpecialChannel();
channel3 = RaylSpecialChannel('tau',[1 2 3]);
channel2.numTx = 32;
mCh1 = channel2.channel;

mimo = MassiveMimo();
mimo.main.numTx = 32;
mimo.channel.type = 'RaylChannel';
mimo.channel.sampleRate = 40;

mimo1 = MassiveMimo();
mimo1.main.numTx = 16;

hmimo = HybridMassiveMimo();
hmimo.channel.type = 'RaylSpecialChannel';

SNR = 0:40;                             % Диапазон SNR 
minNumErrs = 100;                       % Порог ошибок для цикла 
maxNumSimulation = 1;                   % Максимальное число итераций в цикле while 50
maxNumZeroBER = 1;                      % Максимальное кол-во измерений с нулевым кол-вом 

% mimo.simulate(SNR, maxNumZeroBER, minNumErrs, maxNumSimulation);
% hmimo.simulate(SNR, maxNumZeroBER, minNumErrs, maxNumSimulation);

% mimo.plotMeanBER('*-k', 2, 'SNR', '');
% hmimo.plotMeanBER('--k', 2, 'SNR', '');
