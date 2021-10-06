clc;clear;
%% ��������� �������
main.numUsers = 4;                                      % ���-�� �������������
main.numSTSVec = ones(1, main.numUsers);                % ���-�� ����������� ������� ������ �� ������ ������������ / [2 1 3 2]
main.numPhasedElemTx = 2;                               % ���-�� �������� ��������� � 1 ������� �� ��������
main.numPhasedElemRx = 1;                               % ���-�� �������� ��������� � 1 ������� �� �����
main.modulation = 4;                                    % ������� ���������
main.freqCarrier = 28e9;                                % ������� ������� 28 GHz system                               
main.precoderType = "EBM";                               % ��� ���������
roundingType = 'significant';                           % �� ������� round  
numFixPoint = 2;                                        % �� ������� round 
%% ��������� OFDM
ofdm.numSubCarriers = 450;                           % ���-�� �����������
ofdm.lengthFFT = 512;                                % ����� FFT ��� OFDM
ofdm.numSymbOFDM = 10;                               % ���-�� �������� OFDM �� ������ �������
ofdm.cyclicPrefixLength = 64;                        % ����� �������� ���������� = 2*Ngi
%% ��������� ������
channel.channelType = "PHASED_ARRAY_STATIC";    % PHASED_ARRAY_STATIC, PHASED_ARRAY_DYNAMIC
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
model = MassiveMimo(main, ofdm, channel);
modelFixPoint = MassiveMimo(main, ofdm, channel);
%% ���������
SNR = 0:30;                             % �������� SNR 
minNumErrs = 100;                       % ����� ������ ��� ����� 
maxNumSimulation = 5;                   % ������������ ����� �������� � ����� while 50
maxNumZeroBER = 1;                      % ������������ ���-�� ��������� � ������� ���-��� 

model.simulate(SNR, maxNumZeroBER, minNumErrs, maxNumSimulation);
modelFixPoint.simulateFixPoint(SNR, maxNumZeroBER, minNumErrs, maxNumSimulation, numFixPoint, roundingType);
%% ���������� ��������
figure();
model.plotMeanBER('k', 2, "notCreateFigure", "SNR");
str = 'Massive MIMO ';
str1 = [str num2str(model.main.precoderType) ' '  num2str(model.main.numTx) 'x'  num2str(model.main.numRx)];

modelFixPoint.plotMeanBER('-.k', 2, "notCreateFigure", "SNR");
str2 = [str num2str(modelFixPoint.main.precoderType) ' fixPoint ' num2str(modelFixPoint.main.numTx) 'x'  num2str(modelFixPoint.main.numRx)];

title(" Mean ");
legend(str1, str2);