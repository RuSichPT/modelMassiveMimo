function C = mimoCapacity(H, SNR_dB, numSTS)
% SNR - в дБ
SNR = 10^(SNR_dB/10);
lambdas = eig(H*H');
lambdas = flip(lambdas);
lambdas = lambdas(1:numSTS);
C = sum(log2(1+SNR*abs(lambdas)));
end