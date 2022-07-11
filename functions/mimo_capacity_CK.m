function C = mimo_capacity_CK(H, SNR_dB, numTx)
% SNR - в дБ
SNR = 10^(SNR_dB/10);
lambdas = eig(H*H');
lambdas = sort(lambdas,'descend');
gammas = waterfilling(numTx, SNR_dB, H);
difSize = length(lambdas) - length(gammas);
gammas = cat(1,gammas,zeros(difSize,1));
C = sum(log2(1+SNR*abs(lambdas).*gammas/numTx));
end
