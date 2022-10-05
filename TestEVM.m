clc; clear;addpath("functions");
%%
numBits = 1e6; % Чем больше бит, тем точнее snr
data = randi([0 15],numBits,1);
refSym = qammod(data,32);

evm = comm.EVM('Normalization', 'Average reference signal power');
evm1 = comm.EVM('Normalization', 'Average constellation power');
evm2 = comm.EVM('Normalization', 'Peak constellation power');

snr = 20;
rxSym = awgn(refSym,snr,'measured');

[rmsEVM] = evm(refSym,rxSym)
[rmsEVM1] = evm1(refSym,rxSym)
[rmsEVM2] = evm2(refSym,rxSym)
EVM3 = (rxSym - refSym)/rms(refSym);
rmsEVM3 = rms(EVM3)*100
%%
Pavg = sum(abs(refSym.*refSym))/size(refSym,1);% Средняя Мощность 
A = sqrt(Pavg); % Средние амплитуды
sigma = A*10^((-snr)/20); % СКО
snr1 = 20*log10(A/sigma);

A1 = rms(refSym);
sigma1 = rms(rxSym - refSym);

snr
snr2 = 20*log10(A1/sigma1)
disp('SNR похожи')