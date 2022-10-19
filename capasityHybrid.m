clear;close all;clc;
addpath("functions");
set(0,'DefaultAxesFontName','Times New Roman');
set(0,'DefaultTextFontName','Times New Roman'); 
flag_chanel = 'STATIC';
SNR = 0:31; % диапазон SNR
prm.numTx = 8; % Кол-во излучающих антен 
prm.numRx = 4; % Кол-во приемных антен
prm.numUsers = prm.numRx;
prm.numSTS = prm.numRx;
prm.numCarriers = 1;
prm.numSTSVec = ones(1,prm.numUsers);
[H_chan,H_siso,~] = create_chanel(flag_chanel,prm);
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
indExp = 1;
C_hybrid_mimo = zeros(length(indExp),length(SNR));
C_mimo = zeros(length(indExp),length(SNR));
C_siso = zeros(length(indExp),length(SNR));
for indSNR = 1:length(SNR)    
%     C_mimo_CU(indExp,indSNR) = mimo_capacity_CU(H_chan, indSNR, prm.numTx);        
%     C_mimo_CK(indExp,indSNR) = mimo_capacity_CK(H_chan, indSNR, prm.numTx);
    C_hybrid_mimo(indExp,indSNR) = mimoCapacity(Heff, indSNR, prm.numSTS);
    C_mimo(indExp,indSNR) = mimoCapacity(H_chan, indSNR, prm.numSTS);
    C_siso(indExp,indSNR) = siso_capacity(H_siso,indSNR);
end
figure();
plot(SNR,mean(C_hybrid_mimo,1),'-*k','LineWidth',1.5);
% plot(SNR,mean(C_mimo_CU,1),'k','LineWidth',1.5);
hold on;
plot(SNR,mean(C_mimo,1),'--k','LineWidth',1.5);
% plot(SNR,mean(C_mimo_CK,1),'--k','LineWidth',1.5);
plot(SNR,mean(C_siso,1),'-.k','LineWidth',1.5);
grid on;
xlim([0 SNR(end)]);
xlabel('Отношение сигнал/шум, дБ');
ylabel('C, бит/с/Гц');
str1 = ['hybrid mMIMO JSDM ' num2str(prm.numTx) 'x' num2str(prm.numRx)];
str2 = ['optimal mMIMO ' num2str(prm.numTx) 'x' num2str(prm.numRx)];
% str2 = ['mMIMO ' num2str(prm.numTx) 'x' num2str(prm.numRx) ' CU'];
% str3 = ['mMIMO ' num2str(prm.numTx) 'x' num2str(prm.numRx) ' CK'];
legend(str1,str2,'SISO','location','northwest');

% C_hybrid_mimo = C_hybrid_mimo';
% save('DataBase/Capacity/data.txt','C_hybrid_mimo','-ascii');