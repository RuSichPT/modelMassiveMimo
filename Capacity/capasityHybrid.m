clear;close all;clc;
addpath("..\functions");
set(0,'DefaultAxesFontName','Times New Roman');
set(0,'DefaultTextFontName','Times New Roman'); 
flag_chanel = 'STATIC';
SNR = 0:31; % диапазон SNR
prm.numTx = 64; % Кол-во излучающих антен 
prm.numRx = 4; % Кол-во приемных антен
prm.numUsers = prm.numRx;
prm.numSTS = prm.numRx;
prm.numCarriers = 1;
prm.numSTSVec = ones(1,prm.numUsers);
load('..\DataBase/NeuralNetwork/H_I.txt')
load('..\DataBase/NeuralNetwork/H_Q.txt')
load('..\DataBase/NeuralNetwork/F_rf_I.txt')
load('..\DataBase/NeuralNetwork/F_rf_Q.txt')
load('..\DataBase/NeuralNetwork/C_DRL.txt')
Frf_NN = F_rf_I+1i*F_rf_Q;
H_chan = H_I+1i*H_Q;
H_chan = H_chan';
H = permute(H_chan,[3,1,2]);
Hcell = cell(prm.numUsers,1);
for i = 1:prm.numUsers
    Hcell{i} = H(:,:,i);
end
% Multi-user Joint Spatial Division Multiplexing
[~, Frf] = helperJSDMTransmitWeights(Hcell,prm);
Frf = Frf';
H_chan = H_chan';
Heff = H_chan*Frf;
Heff_NN = H_chan*Frf_NN;
indExp = 1;
C_hybrid_mimo = zeros(length(indExp),length(SNR));
C_hybrid_NN = zeros(length(indExp),length(SNR));
C_mimo = zeros(length(indExp),length(SNR));
for indSNR = 1:length(SNR)    
%     C_hybrid_mimo(indExp,indSNR) = mimo_capacity_CU(Heff, SNR(indSNR), prm.numTx);
%     C_hybrid_NN(indExp,indSNR) = mimo_capacity_CU(Heff_NN, SNR(indSNR), prm.numTx);
%     C_mimo(indExp,indSNR) = mimo_capacity_CK(H_chan, SNR(indSNR), prm.numTx);
    C_hybrid_mimo(indExp,indSNR) = mimoCapacity(Heff, SNR(indSNR), prm.numSTS);
    C_hybrid_NN(indExp,indSNR) = mimoCapacity(Heff_NN, SNR(indSNR), prm.numSTS);
    C_mimo(indExp,indSNR) = mimoCapacity(H_chan, SNR(indSNR), prm.numSTS);
end
figure();
plot(SNR,C_hybrid_mimo,'-*k','LineWidth',1.5);
hold on;
plot(SNR,C_hybrid_NN,'k','LineWidth',1.5);
plot(SNR,C_mimo,'--k','LineWidth',1.5);
grid on;
xlim([SNR(1) SNR(end)]);
xlabel('Отношение сигнал/шум, дБ');
ylabel('C, бит/с/Гц');
str1 = ['hybrid mMIMO JSDM ' num2str(prm.numTx) 'x' num2str(prm.numRx)];
str2 = ['hybrid mMIMO NN ' num2str(prm.numTx) 'x' num2str(prm.numRx)];
str3 = ['optimal mMIMO ' num2str(prm.numTx) 'x' num2str(prm.numRx)];
legend(str1,str2,str3,'location','northwest');