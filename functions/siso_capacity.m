function C = siso_capacity(h, SNR_dB)
% SNR - Б Да
SNR = 10^(SNR_dB/10);
C = log2(1 + SNR*(abs(h)^2));
end

