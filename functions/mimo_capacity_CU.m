function C = mimo_capacity_CU(H, SNR_dB, numTx)
% SNR - Б Да
SNR = 10^(SNR_dB/10);
lambdas = eig(H*H');
C = sum(log2(1+SNR*abs(lambdas)/numTx));
end

