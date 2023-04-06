clear;close all;clc;
flag_chanel = 'STATIC';
Exp = 100;% Кол-во опытов
SNR = 0:21; % диапазон SNR
for indExp = 1:Exp
    prm1.numTx = 8; % Кол-во излучающих антен 
    prm1.numRx = 4; % Кол-во приемных антен
    prm1.numSTS = prm1.numTx;
    [H_chan_8x4,H_siso,~] = create_chanel(flag_chanel,prm1);
    prm2.numTx = 12; % Кол-во излучающих антен 
    prm2.numRx = 4; % Кол-во приемных антен
    prm2.numSTS = prm2.numTx;
    [H_chan_12x4,~,~] = create_chanel(flag_chanel,prm2);
    for indSNR = 1:length(SNR)
        C_mimo_CU_8x4(indExp,indSNR) = mimo_capacity_CU(H_chan_8x4, SNR(indSNR), prm1.numTx);        
        C_mimo_CK_8x4(indExp,indSNR) = mimo_capacity_CK(H_chan_8x4, SNR(indSNR), prm1.numTx);
        C_mimo_CU_12x4(indExp,indSNR) = mimo_capacity_CU(H_chan_12x4, SNR(indSNR), prm2.numTx);        
        C_mimo_CK_12x4(indExp,indSNR) = mimo_capacity_CK(H_chan_12x4, SNR(indSNR), prm2.numTx);
        C_siso(indExp,indSNR) = siso_capacity(H_siso,SNR(indSNR));
    end
    disp(indExp);
end
% set(0,'DefaultAxesFontSize',12,'DefaultAxesFontName','Times New Roman');
% set(0,'DefaultTextFontSize',12,'DefaultTextFontName','Times New Roman'); 
set(0,'DefaultAxesFontName','Times New Roman');
set(0,'DefaultTextFontName','Times New Roman'); 
figure();
plot(SNR,mean(C_mimo_CU_8x4,1),'k','LineWidth',1.5);
hold on;
plot(SNR,mean(C_mimo_CK_8x4,1),'--k','LineWidth',1.5);
plot(SNR,mean(C_mimo_CU_12x4,1),'ok','LineWidth',1);
plot(SNR,mean(C_mimo_CK_12x4,1),'xk','LineWidth',1);
plot(SNR,mean(C_siso,1),'-.k','LineWidth',1.5);
grid on;
xlim([0 SNR(end)]);
xlabel('Отношение сигнал/шум, дБ');
ylabel('C, бит/с/Гц');
str1 = 'MIMO 8x4 CU';
str2 = 'MIMO 8x4 CK';
str3 = 'MIMO 12x4 CU';
str4 = 'MIMO 12x4 CK';
legend(str1,str2,str3,str4,'SISO','location','northwest');