clear;close all;clc;
addpath("functions");
flag_chanel = 'STATIC';
Exp = 100;% Кол-во опытов
SNR = 0:21; % диапазон SNR
for indExp = 1:Exp
    prm.numTx = 4; % Кол-во излучающих антен 
    prm.numRx = 4; % Кол-во приемных антен
    prm.numSTS = prm.numTx;
    [H_chan_4x4,H_siso,~] = create_chanel(flag_chanel,prm);
    for indSNR = 1:length(SNR)
        C_mimo_CU(indExp,indSNR) = mimo_capacity_CU(H_chan_4x4, SNR(indSNR), prm.numTx);        
        C_mimo_CK(indExp,indSNR) = mimo_capacity_CK(H_chan_4x4, SNR(indSNR), prm.numTx);
        C_siso(indExp,indSNR) = siso_capacity(H_siso,indSNR);
    end
    disp(indExp);
end
% set(0,'DefaultAxesFontSize',12,'DefaultAxesFontName','Times New Roman');
% set(0,'DefaultTextFontSize',12,'DefaultTextFontName','Times New Roman'); 
set(0,'DefaultAxesFontName','Times New Roman');
set(0,'DefaultTextFontName','Times New Roman'); 
figure();
plot(SNR,mean(C_mimo_CU,1),'k','LineWidth',1.5);
hold on;
plot(SNR,mean(C_mimo_CK,1),'--k','LineWidth',1.5);
plot(SNR,mean(C_siso,1),'-.k','LineWidth',1.5);
grid on;
xlim([0 SNR(end)]);
xlabel('Отношение сигнал/шум, дБ');
ylabel('C, бит/с/Гц');
str1 = 'MIMO 4x4 CU';
str2 = 'MIMO 4x4 CK';
legend(str1,str2,'SISO','location','northwest');