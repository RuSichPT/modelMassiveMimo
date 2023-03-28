function C = mimoCapacity(H, snr_dB)
    % H - матрица канала размерностью [Nrx Ntx]
    % F - матрица прекодирования
    % snr_dB - в дБ
    snr = 10.^(snr_dB/10);
    numRx = size(H,1);
    
    C = zeros(1,length(snr));
    for i = 1:length(snr_dB)
        C(i) = 1/numRx * log2(det(eye(numRx) + snr(i)*(H*H'))); 
    end
end