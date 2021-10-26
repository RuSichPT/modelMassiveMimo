clc;clear;close all;
p_dB = 0:15;
M = 8;
K = 4;

SINR_ZF = p_dB*(M-K)/K;
SINR_MF = p_dB*M./(K*(p_dB+1));

C_ZF = K*log2(1 + SINR_ZF);
C_MF = K*log2(1 + SINR_MF);

figure
hold on
plot(p_dB, C_ZF);
grid on
hold on
plot(p_dB, C_MF);
title('Perfect CSI M = 8, K = 4');
grid on;
xlabel('p, dB');
ylabel('C, bits/s/Hz');
legend('ZF','MF')

clear;
p_dB = 20;
K = 10;
M = K:200;
alpha = M/K;

C_TPE = zeros(1,size(M,2));
k = 1;
for i = M(1):M(end)
    SINR_TPE = calcSINR_TPE(i,K);
    C_TPE(k) = sum(log2(1 + SINR_TPE));
    k = k + 1;
end

SINR_ZF = p_dB*(alpha - 1);
SINR_MF = p_dB*alpha/(p_dB + 1);

C_ZF = K*log2(1 + SINR_ZF);
C_MF = K*log2(1 + SINR_MF);


figure
hold on
plot(M, C_ZF);
grid on
hold on
plot(M, C_MF);
hold on
% plot(M, abs(C_TPE));
title('Perfect CSI p = 20 dB, K = 10');
grid on;
xlabel('M');
ylabel('C, bits/s/Hz');
legend('ZF', 'MF')