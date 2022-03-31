clc;clear;close all;
addpath("functions")
set(0, 'DefaultAxesFontName', 'Times New Roman');
%% Параметры системы
% Общие
cLight = physconst('LightSpeed');
fc = 4e9;                   % 4 GHz system
lambda = cLight/fc;
steeringAngle = [30; -20];  %[azimuth; elevation]
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
arrayTx_MU_SU = phased.URA('Size', arraySize,'ElementSpacing', elementSpacing, 'Element', phased.IsotropicAntennaElement);
partArrayTx_MU_SU = phased.PartitionedArray('Array',arrayTx_MU_SU,'SubarraySelection',ones(numTxRF,numTx),'SubarraySteering','Custom');
arrayRx_SU = phased.URA('Size', [numUsers/2 numUsers/2],'ElementSpacing', elementSpacing, 'Element', phased.IsotropicAntennaElement);
txpos_MU_SU = getElementPosition(partArrayTx_MU_SU)/lambda;
rxpos_MU = 0;
rxpos_SU = getElementPosition(arrayRx_SU)/lambda;
% Геометрия
figure();
viewArray(partArrayTx_MU_SU);
%% Создание канала
% MU
[H_MU,~,~,~] = createScatteringChan(numUsers,txpos_MU_SU,rxpos_MU);
% SU
numScatters = 30;
txang = [360*rand(1,numScatters)-180;180*rand(1,numScatters)-90];
rxang = [360*rand(1,numScatters)-180;180*rand(1,numScatters)-90];
g = 1/sqrt(2)*complex(randn(1,numScatters),randn(1,numScatters));
H_SU = scatteringchanmtx(txpos_MU_SU,rxpos_SU,txang,rxang,g);
%% Цифровой beamforming
[wpMU, wcMU] = blkdiagbfweights(H_MU, numSTSVec);
wcMU = diag(cat(1,wcMU{:}));
[wpSU,wcSU] = diagbfweights(H_SU);
wpSU = wpSU(1:numTxRF,:);

figure();
subplot(2,3,1)
pattern(partArrayTx_MU_SU,fc,-180:180,-90:90,'Type','efield','ElementWeights',wpMU','PropagationSpeed',cLight);
title("Цифровая MU")
subplot(2,3,4)
pattern(partArrayTx_MU_SU,fc,-180:180,-90:90,'Type','efield','ElementWeights',wpSU','PropagationSpeed',cLight);
title("Цифровая SU")
%% Гибридный beamforming
prm.numUsers = numUsers;
prm.numSTSVec = numSTSVec;
prm.numCarriers = 1;
Hcell = cell(numUsers,1);
for uIdx = 1:numUsers
    Hcell{uIdx} = permute(H_MU{uIdx},[3,1,2]);
end
[FbbCellMU, FrfMU] = helperJSDMTransmitWeights(Hcell,prm);
FbbMU = diag(cat(1,FbbCellMU{:}));
subplot(2,3,2)
pattern(partArrayTx_MU_SU,fc,-180:180,-90:90,'Type','efield','ElementWeights',(FbbMU*FrfMU)','PropagationSpeed',cLight);
title("Гибридная full MU")

numScatters = 300;
At = steervec(txpos_MU_SU,txang);
[FbbSU,FrfSU] = omphybweights(H_SU,sum(numSTSVec),numTxRF,At);
subplot(2,3,5)
pattern(partArrayTx_MU_SU,fc,-180:180,-90:90,'Type','efield','ElementWeights',(FbbSU*FrfSU)','PropagationSpeed',cLight);
title("Гибридная full SU")
%% Аналоговый beamforming
wtMU = wpMU(1,:);
wrMU = wcMU(:,1);
subplot(2,3,3)
pattern(arrayTx_MU_SU,fc,-180:180,-90:90,'Type','efield','Weights',wtMU','PropagationSpeed',cLight);
title("Аналоговая MU")

wtSU = wpSU(1,:);
wrSU = wcSU(:,1);
subplot(2,3,6)
pattern(arrayTx_MU_SU,fc,-180:180,-90:90,'Type','efield','Weights',wtSU','PropagationSpeed',cLight);
title("Аналоговая SU")