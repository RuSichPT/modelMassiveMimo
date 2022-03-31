clc;clear;close all;
addpath("functions")
set(0, 'DefaultAxesFontName', 'Times New Roman');
%% Управление

%% Параметры
% Системы
cLight = physconst('LightSpeed');
fc = 4e9;                   % Несущая частота
lambda = cLight/fc;         
numUsers = 4;               
numTxRF = numUsers;
numSTSVec = ones(1,numUsers);
% Параметры решетки
numberOfRows = 8;
numberOfColumns = 16;
numTx = numberOfRows*numberOfColumns;
arraySize = [numberOfRows, numberOfColumns];
elementSpacing = [0.5 0.5]*lambda;
% Плоская(прямоугольная) антенная решетка (URA)
arrayTx = phased.URA('Size', arraySize,'ElementSpacing', elementSpacing, 'Element', phased.IsotropicAntennaElement);
partArrayTx = phased.PartitionedArray('Array',arrayTx,'SubarraySelection',ones(numTxRF,numTx),'SubarraySteering','Custom');
arrayRx_SU = phased.URA('Size', [numUsers/2 numUsers/2],'ElementSpacing', elementSpacing, 'Element', phased.IsotropicAntennaElement);
txpos = getElementPosition(partArrayTx)/lambda;
% Геометрия
figure();
viewArray(partArrayTx);
%% Создание канала
SNR_DB = 0;
txang{1} = [0;25]; txang{2} =[45;25]; txang{3} = [90;25]; txang{4} = [135;25]; %[azimuth;elevation]
[H_MU,H_SU] = createLOSchan(numUsers,txpos,txang);
H_MU_est = cell(numUsers,1);
for uIdx = 1:numUsers
    H_MU_est{uIdx}  = awgn(H_MU{uIdx},SNR_DB,'measured');
end
%% Цифровой beamforming
[wpMU, wcMU] = blkdiagbfweights(H_MU_est, numSTSVec);
wcMU = diag(cat(1,wcMU{:}));

figure();
pattern(partArrayTx,fc,-180:180,-90:90,'Type','efield','ElementWeights',wpMU','PropagationSpeed',cLight);
title("Цифровая MU")

% [wpSU,wcSU] = diagbfweights(H_SU);
% wpSU = wpSU(1:numTxRF,:);
% figure();
% pattern(partArrayTx,fc,-180:180,-90:90,'Type','efield','ElementWeights',wpSU','PropagationSpeed',cLight);
% title("Цифровая SU")
%% Гибридный beamforming
prm.numUsers = numUsers;
prm.numSTSVec = numSTSVec;
prm.numCarriers = 1;
Hcell = cell(numUsers,1);
for uIdx = 1:numUsers
    Hcell{uIdx} = permute(H_MU_est{uIdx},[3,1,2]);
end
[FbbCellMU, FrfMU] = helperJSDMTransmitWeights(Hcell,prm);
FbbMU = diag(cat(1,FbbCellMU{:}));
figure();
pattern(partArrayTx,fc,-180:180,-90:90,'Type','efield','ElementWeights',(FbbMU*FrfMU)','PropagationSpeed',cLight);
title("Гибридная full MU")

% numScatters = 300;
% txangSU = cat(2,txang{:});
% At = steervec(txpos,txangSU);
% [FbbSU,FrfSU] = omphybweights(H_SU,sum(numSTSVec),numTxRF,At);
% figure();
% pattern(partArrayTx,fc,-180:180,-90:90,'Type','efield','ElementWeights',(FbbSU*FrfSU)','PropagationSpeed',cLight);
% title("Гибридная full SU")
%% Аналоговый beamforming
wtMU = wpMU(1,:);
wrMU = wcMU(:,1);

figure();
pattern(arrayTx,fc,-180:180,-90:90,'Type','efield','Weights',wtMU','PropagationSpeed',cLight);
title("Аналоговая MU")

% wtSU = wpSU(1,:);
% wrSU = wcSU(:,1);
% figure();
% pattern(arrayTx,fc,-180:180,-90:90,'Type','efield','Weights',wtSU','PropagationSpeed',cLight);
% title("Аналоговая SU")