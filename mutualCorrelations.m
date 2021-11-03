clc;clear;
%% ��������� �������
main.numUsers = 4;                                      % ���-�� �������������
main.numSTSVec = ones(1, main.numUsers);                % ���-�� ����������� ������� ������ �� ������ ������������ / [2 1 3 2]
main.numPhasedElemTx = 2;                               % ���-�� �������� ��������� � 1 ������� �� ��������
main.numPhasedElemRx = 1;                               % ���-�� �������� ��������� � 1 ������� �� �����
main.modulation = 4;                                    % ������� ���������
main.freqCarrier = 28e9;                                % ������� ������� 28 GHz system                               
main.precoderType = 'MF';                               % ��� ���������
corrMatrix = zeros(main.numPhasedElemTx*main.numUsers);
corrMatrix(:,:) = 0.2;
for i = 1:main.numPhasedElemTx*main.numUsers
    corrMatrix(i,i) = 1;
end
%% ��������� OFDM
ofdm.numSubCarriers = 450;                           % ���-�� �����������
ofdm.lengthFFT = 512;                                % ����� FFT ��� OFDM
ofdm.numSymbOFDM = 10;                               % ���-�� �������� OFDM �� ������ �������
ofdm.cyclicPrefixLength = 64;                        % ����� �������� ���������� = 2*Ngi
%% ��������� ������
channel.channelType = 'STATIC';    % PHASED_ARRAY_STATIC, PHASED_ARRAY_DYNAMIC STATIC 
switch channel.channelType
    case {'PHASED_ARRAY_STATIC', 'PHASED_ARRAY_DYNAMIC'}
        channel.numDelayBeams = 3;       % ���-�� ����������� �������� (����������� ���������� �������)
        channel.txAng = {0,90,180,270};
    case 'RAYL'
        channel.sampleRate = 40e6;
        channel.tau = [2 5 7] * (1 / channel.sampleRate);
        channel.pdB = [-3 -9 -12];
end
%% �������� ������� 
modelMF = MassiveMimo(main, ofdm, channel);
modelMFmutCorr = copy(modelMF);
modelZF = MassiveMimo(main, ofdm, channel);
modelZF.main.precoderType = 'ZF';
modelZFmutCorr = copy(modelZF);
%% ���������
SNR = 0:40;                             % �������� SNR 
minNumErrs = 100;                       % ����� ������ ��� ����� 
maxNumSimulation = 3;                   % ������������ ����� �������� � ����� while 50
maxNumZeroBER = 1;                      % ������������ ���-�� ��������� � ������� ���-��� 

modelMF.simulate(SNR, maxNumZeroBER, minNumErrs, maxNumSimulation);
modelMFmutCorr.simulateMutCorr(SNR, maxNumZeroBER, minNumErrs, maxNumSimulation, corrMatrix);
modelZF.simulate(SNR, maxNumZeroBER, minNumErrs, maxNumSimulation);
modelZFmutCorr.simulateMutCorr(SNR, maxNumZeroBER, minNumErrs, maxNumSimulation, corrMatrix);
%% ���������� ��������
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
