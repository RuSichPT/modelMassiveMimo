%% ��������� ������� 
numAntenns = 8;                                 % ���-�� ������ � �������� ������� / 12 or 8 
numUsers = 4;                                   % ���-�� �������������
modulation = 4;                                 % ������� ���������
freqCarrier = 28e9;                             % ������� ������� 28 GHz system 

numSTSVec = ones(1, numUsers);                  % ���-�� ����������� ������� ������ �� ������ ������������ / [2 1 3 2]; 
numSTS = sum(numSTSVec);                        % ���-�� ������� ������; ������ ���� ������� 2: /2/4/8/16/32/64
numAntennsSTS = numAntenns / numSTS;            % ���-�� ������ �� ���� ����� ������
numTx = numSTS * numAntennsSTS;                 % ���-�� ���������� ����� 
numRx = numSTS;                                 % ���-�� �������� �����
bps = log2(modulation);                         % ���-�� ��� �� ������ � �������
%% ��������� OFDM 
numSubCarriers = 450;                           % ���-�� �����������
lengthFFT = 512;                                % ����� FFT ��� OFDM
numSymbOFDM = 10;                               % ���-�� �������� OFDM �� ������ �������
cyclicPrefixLength = 64;                        % ����� �������� ���������� = 2*Ngi

tmpNCI = lengthFFT - numSubCarriers;
nullCarrierIndices = [1:tmpNCI/2 (1 + lengthFFT - tmpNCI / 2):lengthFFT]'; % Guards and DC
clear tmpNCI;

numBits = bps * numSymbOFDM * numSubCarriers;   % ����� ��������� ������
%% ��������� ������
chanParam.channelType = "PHASED_ARRAY_STATIC";    % PHASED_ARRAY_STATIC, PHASED_ARRAY_DYNAMIC
chanParam.numUsers = numUsers;
if (chanParam.channelType == "PHASED_ARRAY_STATIC" || chanParam.typeChannel == "PHASED_ARRAY_DYNAMIC")
    [chanParam.da, chanParam.dp] = loadSteeringVector(numAntenns);  % ��������� � ���� SteeringVector
    chanParam.numDelayBeams = 3;                                    % ���-�� ����������� �������� (����������� ���������� �������)
    chanParam.txAng = {0,90,180,270};
end
%% ��������� ��������� ������������
preambleParamZond.numSC = numSubCarriers;
preambleParamZond.numSTS = numTx;
preambleParamZond.N_FFT = lengthFFT;
preambleParamZond.CyclicPrefixLength = cyclicPrefixLength;
preambleParamZond.NullCarrierIndices = nullCarrierIndices;
%% ��������� ��������� 
preambleParam.numSC = numSubCarriers;
preambleParam.numSTS = numSTS;
preambleParam.N_FFT = lengthFFT;
preambleParam.CyclicPrefixLength = cyclicPrefixLength;
preambleParam.NullCarrierIndices = nullCarrierIndices;
%% ��������� ������� �������������� ��������� �����-�����
confidenceLevel = 0.95;         % ������� �������������
coefConfInterval = 1/15;        % ???  