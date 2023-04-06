clc;clear;close all;
set(0, 'DefaultAxesFontName', 'Times New Roman');
%% Управление
txang{1} = [-65;0]; txang{2} =[-25;0]; txang{3} = [37;0]; txang{4} = [70;0]; %[azimuth;elevation]
numberOfRows = 16;
numberOfColumns = 16;
%% Параметры
% Системы
cLight = physconst('LightSpeed');
fc = 30e9;                   % Несущая частота
lambda = cLight/fc;         
numUsers = 4;               
numTxRF = numUsers;
numSTSVec = ones(1,numUsers);
% Параметры решетки
numTx = numberOfRows*numberOfColumns;
arraySize = [numberOfRows, numberOfColumns];
elementSpacing = [0.5 0.5]*lambda;
% Плоская(прямоугольная) антенная решетка (URA)
arrayTx = phased.URA('Size', arraySize,'ElementSpacing', elementSpacing, 'Element', phased.IsotropicAntennaElement);
partArrayTx = phased.PartitionedArray('Array',arrayTx,'SubarraySelection',ones(numTxRF,numTx),'SubarraySteering','Custom');
txpos = getElementPosition(partArrayTx)/lambda;
% Геометрия
figure();
viewArray(partArrayTx);
%% Создание канала
[H_users,H] = createLOSchan(numUsers,txpos,txang);
for uIdx = 1:numUsers
    H_users{uIdx} = permute(H_users{uIdx},[3,1,2]);
end
prm.numUsers = numUsers;
prm.numSTSVec = numSTSVec;
prm.numCarriers = 1;
%% Цифровой beamforming
[wpMU, ~] = diagbfweights(H);
wpMU = wpMU(1:numTxRF,:);
figure();
azimuth = -90:90;
elevation = -90:90;
pattern(partArrayTx,fc,azimuth,elevation,'Type','efield','ElementWeights',wpMU','PropagationSpeed',cLight);
title("Цифровая")
%% Гибридный beamforming
[FbbCell, Frf] = helperJSDMTransmitWeights(H_users,prm);
Fbb = diag(cat(1,FbbCell{:}));
figure();
pattern(partArrayTx,fc,azimuth,elevation,'Type','efield','ElementWeights',(Fbb*Frf)','PropagationSpeed',cLight);
title("Гибридная full")
%% Аналоговый beamforming
% MU
wt_MU1 = wpMU(1,:);
wt_MU2 = wpMU(2,:);
wt_MU3 = wpMU(3,:);
wt_MU4 = wpMU(4,:);

% SU
SteerVecTx = phased.SteeringVector('SensorArray',arrayTx, ...
    'PropagationSpeed',cLight);
wt_SU = SteerVecTx(fc,txang{1});

figure();
pattern(arrayTx,fc,azimuth,elevation,'Type','efield','Weights',wt_MU1','PropagationSpeed',cLight);
title("Аналоговая MU 1")

% figure();
% pattern(arrayTx,fc,azimuth,elevation,'Type','efield','Weights',wt_MU2','PropagationSpeed',cLight);
% title("Аналоговая MU 2")
% 
% figure();
% pattern(arrayTx,fc,azimuth,elevation,'Type','efield','Weights',wt_MU3','PropagationSpeed',cLight);
% title("Аналоговая MU 3")
% 
% figure();
% pattern(arrayTx,fc,azimuth,elevation,'Type','efield','Weights',wt_MU4','PropagationSpeed',cLight);
% title("Аналоговая MU 4")

figure();
pattern(arrayTx,fc,azimuth,elevation,'Type','efield','Weights',wt_SU,'PropagationSpeed',cLight);
title("Аналоговая SU")