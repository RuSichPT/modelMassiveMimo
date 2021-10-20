clc;clear;
%% ��������� �������
main.numTx = 8;                                        % ���-�� ���������� �����
main.numUsers = 4;                                      % ���-�� �������������
main.numRx = main.numUsers;                             % ���-�� �������� �����
main.numSTSVec = ones(1, main.numUsers);                % ���-�� ����������� ������� ������ �� ������ ������������ / [2 1 3 2]
main.modulation = 4;                                    % ������� ���������
main.freqCarrier = 28e9;                                % ������� ������� 28 GHz system                               
main.precoderType = 'ZF';                               % ��� ���������
%% ��������� OFDM
ofdm.numSubCarriers = 450;                           % ���-�� �����������
ofdm.lengthFFT = 512;                                % ����� FFT ��� OFDM
ofdm.numSymbOFDM = 10;                               % ���-�� �������� OFDM �� ������ �������
ofdm.cyclicPrefixLength = 64;                        % ����� �������� ���������� = 2*Ngi
%% ��������� ������
channel.channelType = 'RAYL_SPECIAL';    % PHASED_ARRAY_STATIC, PHASED_ARRAY_DYNAMIC STATIC 
channel.numUsers = main.numUsers;
switch channel.channelType
    case {'PHASED_ARRAY_STATIC', 'PHASED_ARRAY_DYNAMIC'}
        channel.numTx = 8; %12
        channel.numDelayBeams = 3;       % ���-�� ����������� �������� (����������� ���������� �������)
        channel.txAng = {0,90,180,270};
    case {'RAYL','RAYL_SPECIAL'}
        channel.sampleRate = 40e6;
        channel.tau = [2 5 7] * (1 / channel.sampleRate);
        channel.pdB = [-3 -9 -12];
        channel.seed = 95;
end
%% �������� ������� 
modelZF = MassiveMimo(main, ofdm, channel);
modelMF = copy(modelZF);
modelEBM = copy(modelZF);
modelRZF = copy(modelZF);
modelPhased = copy(modelZF);
modelBDA = copy(modelZF);
modelMF.main.precoderType = 'MF';
modelEBM.main.precoderType = 'EBM';
modelRZF.main.precoderType = 'RZF';
modelPhased.main.precoderType = 'NOT';
modelBDA.main.precoderType = 'BDA';
%% ���������
SNR = 0:40;                             % �������� SNR 
minNumErrs = 100;                       % ����� ������ ��� ����� 
maxNumSimulation = 5;                   % ������������ ����� �������� � ����� while 50
maxNumZeroBER = 1;                      % ������������ ���-�� ��������� � ������� ���-��� 

modelMF.simulate(SNR, maxNumZeroBER, minNumErrs, maxNumSimulation);
modelZF.simulate(SNR, maxNumZeroBER, minNumErrs, maxNumSimulation);
modelEBM.simulate(SNR, maxNumZeroBER, minNumErrs, maxNumSimulation);
modelRZF.simulate(SNR, maxNumZeroBER, minNumErrs, maxNumSimulation);
modelPhased.simulate(SNR, maxNumZeroBER, minNumErrs, maxNumSimulation);
modelBDA.simulate(SNR, maxNumZeroBER, minNumErrs, maxNumSimulation);
%% ���������� ��������
str0 = 'Mean ';
str1 = [str0 num2str(modelMF.main.precoderType) ' ' num2str(modelMF.main.numTx) 'x'  num2str(modelMF.main.numRx)];
fig = modelMF.plotMeanBER('k', 2, 'SNR', str1);

str2 = [str0 num2str(modelZF.main.precoderType) ' ' num2str(modelZF.main.numTx) 'x'  num2str(modelZF.main.numRx)];
modelZF.plotMeanBER('--k', 2, 'SNR', str2, fig);

str3 = [str0 num2str(modelEBM.main.precoderType) ' ' num2str(modelEBM.main.numTx) 'x'  num2str(modelEBM.main.numRx)];
modelEBM.plotMeanBER('-.k', 2, 'SNR', str3, fig);

str4 = [str0 num2str(modelRZF.main.precoderType) ' ' num2str(modelRZF.main.numTx) 'x'  num2str(modelRZF.main.numRx)];
modelRZF.plotMeanBER('*k', 2, 'SNR', str4, fig);

str5 = [str0 num2str(modelPhased.main.precoderType) ' ' num2str(modelPhased.main.numTx) 'x'  num2str(modelPhased.main.numRx)];
modelPhased.plotMeanBER('*k', 2, 'SNR', str5, fig);

str6 = [str0 num2str(modelBDA.main.precoderType) ' ' num2str(modelBDA.main.numTx) 'x'  num2str(modelBDA.main.numRx)];
modelBDA.plotMeanBER(':k', 2, 'SNR', str6, fig);