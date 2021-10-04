clc;clear;
%% ��������� �������
main.numUsers = 4;                                      % ���-�� �������������
main.numSTSVec = ones(1, main.numUsers);                % ���-�� ����������� ������� ������ �� ������ ������������ / [2 1 3 2]
main.numPhasedElemTx = 2;                               % ���-�� �������� ��������� � 1 ������� �� ��������
main.numPhasedElemRx = 1;                               % ���-�� �������� ��������� � 1 ������� �� �����
main.modulation = 4;                                    % ������� ���������
main.freqCarrier = 28e9;                                % ������� ������� 28 GHz system                               
main.precoderType = "MF";                               % ��� ���������
%% ��������� OFDM
ofdm.numSubCarriers = 450;                           % ���-�� �����������
ofdm.lengthFFT = 512;                                % ����� FFT ��� OFDM
ofdm.numSymbOFDM = 10;                               % ���-�� �������� OFDM �� ������ �������
ofdm.cyclicPrefixLength = 64;                        % ����� �������� ���������� = 2*Ngi
%% ��������� ������
channel.channelType = "RAYL";    % PHASED_ARRAY_STATIC, PHASED_ARRAY_DYNAMIC
channel.numUsers = main.numUsers;
switch channel.channelType
    case {"PHASED_ARRAY_STATIC","PHASED_ARRAY_DYNAMIC"}
        channel.numTx = 8; %12
        channel.numDelayBeams = 3;       % ���-�� ����������� �������� (����������� ���������� �������)
        channel.txAng = {0,90,180,270};
    case "RAYL"
        channel.sampleRate = 40e6;
        channel.tau = [2 5 7] * (1 / channel.sampleRate);
        channel.pdB = [-3 -9 -12];
end
%% �������� ������� 
modelMF = MassiveMimo(main, ofdm, channel);
modelZF = copy(modelMF);
modelEBM = copy(modelMF);
modelRZF = copy(modelMF);
modelZF.main.precoderType = "ZF";
modelEBM.main.precoderType = "EBM";
modelRZF.main.precoderType = "RZF";
%% ���������
SNR = 0:30;                             % �������� SNR 
minNumErrs = 100;                       % ����� ������ ��� ����� 
maxNumSimulation = 1;                   % ������������ ����� �������� � ����� while 50
maxNumZeroBER = 1;                      % ������������ ���-�� ��������� � ������� ���-��� 

modelMF.simulate(SNR, maxNumZeroBER, minNumErrs, maxNumSimulation);
modelZF.simulate(SNR, maxNumZeroBER, minNumErrs, maxNumSimulation);
modelEBM.simulate(SNR, maxNumZeroBER, minNumErrs, maxNumSimulation);
modelRZF.simulate(SNR, maxNumZeroBER, minNumErrs, maxNumSimulation);
%% ���������� ��������
figure();
modelMF.plotMeanBER('k', 2, "notCreateFigure", "SNR");
str1 = ['Massive MIMO MF ' num2str(modelMF.main.numTx) 'x'  num2str(modelMF.main.numRx)];

modelZF.plotMeanBER('--k', 2, "notCreateFigure", "SNR");
str2 = ['Massive MIMO ZF ' num2str(modelZF.main.numTx) 'x'  num2str(modelZF.main.numRx)];

modelEBM.plotMeanBER('-.k', 2, "notCreateFigure", "SNR");
str3 = ['Massive MIMO EBM ' num2str(modelEBM.main.numTx) 'x'  num2str(modelEBM.main.numRx)];

modelRZF.plotMeanBER('*k', 2, "notCreateFigure", "SNR");
str4 = ['Massive MIMO RZF ' num2str(modelRZF.main.numTx) 'x'  num2str(modelRZF.main.numRx)];

title(" Mean ");
legend(str1, str2, str3, str4);