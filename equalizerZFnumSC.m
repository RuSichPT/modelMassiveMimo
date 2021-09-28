function [outputData] = equalizerZFnumSC(Y, H_estim)
    % Модель Y = X*H+ksi; 

    % Эквалайзер для каждой поднесущей
    % Y - принятые символы [msc,symb_ofdm,numTx]
    % H_estim - оценка матрицы вида [msc,numTx,numRx]
    % msc - кол-во поднесущих,symb_ofdm - кол-во символов ofdm

%     Instead of multiplying by the inverse, use matrix right division (/) or matrix left division (\). That is:
%     Replace inv(A)*b with A\b - faster 
%     Replace b*inv(A) with b/A - faster 
    
    outputData = zeros(size(Y,1), size(Y,2), size(Y,3));
    for i = 1:size(Y,1)    
        h_estim = squeeze(H_estim(i,:,:));
        inv_H_ZF = h_estim*h_estim';
        outputData(i,:,:) =  squeeze(Y(i,:,:))*h_estim' / inv_H_ZF;
    end
    % Выходные данные в символах IQ
end

