clc;clear;
%% �������� ������� 
modelZF = MassiveMimo();
modelTPE = copy(modelZF);
modelNSA = copy(modelZF);
modelNI = copy(modelZF);
modelNI_NSA = copy(modelZF);
modelTPE.main.precoderType = 'TPE';
modelNSA.main.precoderType = 'NSA';
modelNI.main.precoderType = 'NI';
modelNI_NSA.main.precoderType = 'NI-NSA';
%% ���������
SNR = 0:40;                             % �������� SNR 
minNumErrs = 100;                       % ����� ������ ��� ����� 
maxNumSimulation = 5;                   % ������������ ����� �������� � ����� while 50
maxNumZeroBER = 1;                      % ������������ ���-�� ��������� � ������� ���-��� 

modelZF.simulate(SNR, maxNumZeroBER, minNumErrs, maxNumSimulation);
modelTPE.simulate(SNR, maxNumZeroBER, minNumErrs, maxNumSimulation);
modelNSA.simulate(SNR, maxNumZeroBER, minNumErrs, maxNumSimulation);
modelNI.simulate(SNR, maxNumZeroBER, minNumErrs, maxNumSimulation);
modelNI_NSA.simulate(SNR, maxNumZeroBER, minNumErrs, maxNumSimulation);
%% ���������� ��������
str0 = 'Mean ';
str1 = [str0 num2str(modelZF.main.precoderType) ' ' num2str(modelZF.main.numTx) 'x'  num2str(modelZF.main.numRx)];
fig = modelZF.plotMeanBER('k', 2, 'SNR', str1);

str2 = [str0 num2str(modelTPE.main.precoderType) ' ' num2str(modelTPE.main.numTx) 'x'  num2str(modelTPE.main.numRx)];
modelTPE.plotMeanBER('r', 2, 'SNR', str2, fig);

str3 = [str0 num2str(modelNSA.main.precoderType) ' ' num2str(modelNSA.main.numTx) 'x'  num2str(modelNSA.main.numRx)];
modelNSA.plotMeanBER('--r', 2, 'SNR', str3, fig);

str4 = [str0 num2str(modelNI.main.precoderType) ' ' num2str(modelNI.main.numTx) 'x'  num2str(modelNI.main.numRx)];
modelNI.plotMeanBER('b', 2, 'SNR', str4, fig);

str5 = [str0 num2str(modelNI_NSA.main.precoderType) ' ' num2str(modelNI_NSA.main.numTx) 'x'  num2str(modelNI_NSA.main.numRx)];
modelNI_NSA.plotMeanBER('--b', 2, 'SNR', str5, fig);