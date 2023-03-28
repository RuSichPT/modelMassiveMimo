clear;clc;close all;
%% Задаем параметры
numTx = 24;
numRx = 4;
numSTS = numRx;
snr = 20;             % SNR в дБ
numExp = 1000;

% Задаем корреляцию
n = 0;
mu = pi/3;
d = 0.5;
arg1 = sqrt(n*n - 4*pi*pi*d*d + 4*pi*1i*n*sin(mu)*d);
arg = imag(arg1);
r = besselj(0,arg)/besseli(0,n);
R = toeplitz([1 r r zeros(1,numTx-3)]);
vec = ones(1,numTx-1)*r;
% R = toeplitz([1 vec]);
R = normColumn(R);

% Задаем связь (coupling)
A = 13.4;
a = exp(-A*d);
Z = toeplitz([1 a a zeros(1,numTx-3)]);
vec1 = ones(1,numTx-1)*a;
% Z = toeplitz([1 vec1]);
Z = normColumn(Z);
%%
% Без корреляции
Hsta = createKroneckerChannels(numTx,numRx,numExp,1,1);
[C, lambda, condH, rankH] = calculateData(Hsta,numSTS,snr,numExp);
% С корреляции
Hsta = createKroneckerChannels(numTx,numRx,numExp,R,1);
[C_r, lambda_r, condH_r, rankH_r] = calculateData(Hsta,numSTS,snr,numExp);
% Со связью
Hsta = createKroneckerChannels(numTx,numRx,numExp,1,Z);
[C_c, lambda_c, condH_c, rankH_c] = calculateData(Hsta,numSTS,snr,numExp);
% Все
Hsta = createKroneckerChannels(numTx,numRx,numExp,R,Z);
[C_r_c, lambda_r_c, condH_r_c, rankH_r_c] = calculateData(Hsta,numSTS,snr,numExp);
% QuaDRiGa
% Hqua = createQuaDRiGa(numRx,numExp);
% Hqua = loadHqua("q_chans_28-Mar-2023_16-23-13.mat");
Hqua = loadHqua("q_chans_28-Mar-2023_16-23-58.mat");
% Hqua = loadHqua("q_chans_28-Mar-2023_16-24-41.mat");
[C_qua, lambda_qua, condH_qua, rankH_qua] = calculateData(Hqua,numSTS,snr,numExp);
%% Графики
figure('Name','CDF');
hold on
[~, statsC] = cdfplot(C(:,1));
disp("mean C: " + statsC.mean);
[~, statsC_r] = cdfplot(C_r(:,1));
disp("mean C_r: " + statsC_r.mean);
[~, statsC_c] = cdfplot(C_c(:,1));
disp("mean C_c: " + statsC_c.mean);
[~, statsC_r_c] = cdfplot(C_r_c(:,1));
disp("mean C_r_c: " + statsC_r_c.mean);
[~, statsC_qua] = cdfplot(C_qua(:,1));
disp("mean C_qua: " + statsC_qua.mean);
legend("C","C_r","C_c","C_r_c","C_qua");
%%
function [C, sigma] = mimoCapacityOne(H, F, snr_dB, numSTS)
    % H - матрица канала размерностью [Nrx Ntx Nch]
    % F - матрица прекодирования
    % snr_dB - в дБ
    snr = 10.^(snr_dB/10);    
    C = zeros(1,length(snr));
    for i = 1:length(snr_dB)
        sigma = svd(H*F); % eig(H*H') = svd(H)^2 
        lambda = sigma(1:numSTS).^2;
        C(i) = 1/numSTS*sum(log2(1+snr(i)*abs(lambda))); % 1/numSTS нормировка по потокам 
    end
end
%%
function [C, lambda, condH, rankH] = calculateData(H,numSTS,snr,numExp)
    F = 1;
    C = zeros(numExp,length(snr));
    lambda = zeros(numExp,1);
    condH = zeros(numExp,1);
    rankH = zeros(numExp,1);
    for i = 1:numExp
        sqH = squeeze(H(:,:,i));
        sqH = sqH/norm(sqH,"fro");
        [C(i,:), sigma] = mimoCapacityOne(sqH, F, snr, numSTS);
        lambda(i) = sum(sigma(1:numSTS).^2);
        condH(i) = cond(sqH);
        rankH(i) = rank(sqH);
    end
end
%%
function Z = normColumn(Z)
    numTx = size(Z);
    for j = 1:numTx
        Z(:,j) = Z(:,j)/sum(Z(:,j),1);
    end
end
%%
function Hqua = loadHqua(name)
    load(name,"H");
    Hqua = permute(H, [2 3 1 4]);
    Hqua = Hqua(:,:,:,2);
end