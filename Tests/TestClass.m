clear; clc;

ch = ChannelConfig();
sys = SystemConfig();
chConf = ChannelConfig('tau',[2 3],'avgPathGains',[0 3]);
sysConf = SystemConfig('numUsers',6,'numRxUsers',[1 2 1 1 1 1],'numSTSVec',[1 1 1 1 1 1]);

array = AntArrayURA('fc', 40e9);
ang = [30;20];
w = array.steervec(ang);

static = StaticChannel();
static.create();
if static.channel{1}() == static.channel{1}()
    disp('ok')
end
if static.channel{2}() == static.channel{2}()
    disp('ok')
end

% channelNN = ChannelForNeuralNet();

multiChan = MultipathChannel();
multiChan.create();
if multiChan.channel{1}(:,:,1) == multiChan.channel{1}(:,:,1)
    disp('ok')
end
if multiChan.channel{2}(:,:,1) == multiChan.channel{2}(:,:,1)
    disp('ok')
end

LOS = LOSChannel();
LOS.create();
if LOS.channel{1}() == LOS.channel{1}()
    disp('ok')
end
if LOS.channel{2}() == LOS.channel{2}()
    disp('ok')
end

% custom = LOScustomAntElem();

ofdm = OfdmParam();
ofdm2 = OfdmParam();

ofdm1 = OfdmParam('numSubCarriers',120);
ofdm.numSubCarriers = 256;

main = SystemConfig();
main1 = SystemConfig('numTx', 16);

chconf = ChannelConfig('tau',[1 2 3]);

HestCell = cell(main.numUsers,1);
for i = 1:main.numUsers
    HestCell{i} = randn(ofdm.numSubCarriers,main.numTx,main.numRxUsers(i));
end
At = zeros(main.numTx,75);
digPrecoder = DigitalPrecoder('DIAG',main,HestCell);
hybPrecoder = HybridPrecoder('JSDM/OMP',main,HestCell,'full',4,At);

rayl = RaylChannel();
rayl.create();
mCh = rayl.channel;
rayl1 = RaylChannel('chconf',chconf);
rayl1.create();

raylspec = RaylSpecialChannel();
raylspec.create();
raylspec1 = RaylSpecialChannel('chconf',chconf);
raylspec1.create();
mCh1 = raylspec.channel;

mimo = MassiveMimo('main',main,'downChannel',raylspec);

mimo1 = MassiveMimo();

hmimo = HybridMassiveMimo();

SNR = 0:40;                             % Диапазон SNR 
minNumErrs = 100;                       % Порог ошибок для цикла 
maxNumSimulation = 1;                   % Максимальное число итераций в цикле while 50
maxNumZeroBER = 1;                      % Максимальное кол-во измерений с нулевым кол-вом 

% mimo.simulate(SNR, maxNumZeroBER, minNumErrs, maxNumSimulation);
% hmimo.simulate(SNR, maxNumZeroBER, minNumErrs, maxNumSimulation);

% mimo.plotMeanBER('*-k', 2, 'SNR', '');
% hmimo.plotMeanBER('--k', 2, 'SNR', '');
