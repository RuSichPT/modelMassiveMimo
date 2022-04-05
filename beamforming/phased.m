clear;clc;close all;
fc = 4e9;                   % 4 GHz system
cLight = physconst('LightSpeed');
steeringAngle = [30; -20];  %[azimuth; elevation]
% ѕараметры решетки
NumberOfRows = 5;
NumberOfColumns = 5;
numTx = NumberOfRows*NumberOfColumns;
lambda = cLight/fc;
Size = [NumberOfRows,NumberOfColumns];
ElementSpacing = [0.5 0.5]*lambda;
% ѕлоска€(пр€моугольна€) антенна€ решетка
% Uniform Rectangular array (URA)
arrayTx = phased.URA(Size,ElementSpacing, ... 
    'Element',phased.IsotropicAntennaElement);
% √еометри€
figure();
viewArray(arrayTx);

% ”правл€ющий вектор
% ”правл€ющий вектор представл€ет собой набор фазовых задержек, испытываемых плоской волной,
% оцениваемых на наборе элементов решетки (антенн). (google)
SteerVecTx = phased.SteeringVector('SensorArray',arrayTx, ...
    'PropagationSpeed',cLight);

% √енерируем веса. (аналогова€ часть) 
wT = SteerVecTx(fc,steeringAngle);

% ƒиаграмма направленности
figure();
pattern(arrayTx,fc,'PropagationSpeed',cLight,'Weights',wT);
figure();
patternAzimuth(arrayTx,fc,-20,'PropagationSpeed',cLight,'Weights',wT);
figure();
patternElevation(arrayTx,fc,30,'PropagationSpeed',cLight,'Weights',wT);