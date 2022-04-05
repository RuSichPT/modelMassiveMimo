clear;clc;close all;
fc = 4e9;                   % 4 GHz system
cLight = physconst('LightSpeed');
steeringAngle = [30; -20];  %[azimuth; elevation]
% ��������� �������
NumberOfRows = 5;
NumberOfColumns = 5;
numTx = NumberOfRows*NumberOfColumns;
lambda = cLight/fc;
Size = [NumberOfRows,NumberOfColumns];
ElementSpacing = [0.5 0.5]*lambda;
% �������(�������������) �������� �������
% Uniform Rectangular array (URA)
arrayTx = phased.URA(Size,ElementSpacing, ... 
    'Element',phased.IsotropicAntennaElement);
% ���������
figure();
viewArray(arrayTx);

% ����������� ������
% ����������� ������ ������������ ����� ����� ������� ��������, ������������ ������� ������,
% ����������� �� ������ ��������� ������� (������). (google)
SteerVecTx = phased.SteeringVector('SensorArray',arrayTx, ...
    'PropagationSpeed',cLight);

% ���������� ����. (���������� �����) 
wT = SteerVecTx(fc,steeringAngle);

% ��������� ��������������
figure();
pattern(arrayTx,fc,'PropagationSpeed',cLight,'Weights',wT);
figure();
patternAzimuth(arrayTx,fc,-20,'PropagationSpeed',cLight,'Weights',wT);
figure();
patternElevation(arrayTx,fc,30,'PropagationSpeed',cLight,'Weights',wT);