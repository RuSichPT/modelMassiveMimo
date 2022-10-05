function [Y,sigma] = my_awgn(X,snr,varargin)
% X - [поток, numRx]
% varargin{1} - комплексная амплитуда сигнала 
if nargin == 3
    sigma = varargin{1}*10^((-snr)/20); % СКО
    Y =  X+(randn(size(X,1),size(X,2))+ 1i * randn(size(X,1),size(X,2)))*0.707 * sigma;
else
    for i = 1:size(X,2)
        E_tmp(i) = sum(abs(X(:,i)).^2); % Энергия
        P(i) = E_tmp(i)/(size(X,1));% Средняя Мощность 
        A(i) = sqrt(P(i)); % Средние амплитуды
        sigma(i) = A(i)*10^((-snr)/20); % СКО
    end
    sigma = diag(sigma);
    Y =  X+(randn(size(X,1),size(X,2))+ 1i * randn(size(X,1),size(X,2)))*0.707 * sigma;
end
end

