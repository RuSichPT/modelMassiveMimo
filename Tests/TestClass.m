clear; clc;
addpath('..\Parameters');
addpath('..\Channels');
addpath('..\Precoders');
addpath('..\DataBase\Verification');
addpath('..\..\modelMassiveMimo');

array = AntArrayURA('fc', 40e9);
ang = [30;20];
w = array.steervec(ang);

channelParam = ChannelParam();
static = StaticChannel();
if static.channel{1}() == static.channel{1}()
    disp('ok')
end
if static.channel{2}() == static.channel{2}()
    disp('ok')
end

channelNN = ChannelForNeuralNet();

multiChan = MultipathChannel();
if multiChan.channel{1}(:,:,1) == multiChan.channel{1}(:,:,1)
    disp('ok')
end
if multiChan.channel{2}(:,:,1) == multiChan.channel{2}(:,:,1)
    disp('ok')
end

LOS = LOSChannel();
if LOS.channel{1}() == LOS.channel{1}()
    disp('ok')
end
if LOS.channel{2}() == LOS.channel{2}()
    disp('ok')
end

custom = LOScustomAntElem();

ofdm = OfdmParam();
ofdm2 = OfdmParam();

ofdm1 = OfdmParam('numSubCarriers',120);
ofdm.numSubCarriers = 256;

main = SystemParam();
main.numTx = 32;
main1 = SystemParam('modulation', 16);

HestCell = cell(main.numUsers,1);
for i = 1:main.numUsers
    HestCell{i} = randn(ofdm.numSubCarriers,main.numTx,main.numRxUsers(i));
end
At = zeros(main.numTx,75);
digPrecoder = DigitalPrecoder('DIAG',main,HestCell);
hybPrecoder = HybridPrecoder('JSDM/OMP',main,HestCell,'full',4,At);

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

mimo1 = MassiveMimo();
mimo1.main.numTx = 16;

hmimo = HybridMassiveMimo();

SNR = 0:40;                             % Диапазон SNR 
minNumErrs = 100;                       % Порог ошибок для цикла 
maxNumSimulation = 1;                   % Максимальное число итераций в цикле while 50
maxNumZeroBER = 1;                      % Максимальное кол-во измерений с нулевым кол-вом 

% mimo.simulate(SNR, maxNumZeroBER, minNumErrs, maxNumSimulation);
% hmimo.simulate(SNR, maxNumZeroBER, minNumErrs, maxNumSimulation);

% mimo.plotMeanBER('*-k', 2, 'SNR', '');
% hmimo.plotMeanBER('--k', 2, 'SNR', '');
