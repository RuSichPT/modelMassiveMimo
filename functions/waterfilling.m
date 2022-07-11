function gammas = waterfilling(Mt, SNR_dB, H_chan)
% Mt - кол-во передающих антенн 
% SNR_dB - в дБ
% H_chan - канальная матрица

SNR = 10^(SNR_dB/10);
r = rank(H_chan);
H_sq = H_chan*H_chan';
lambdas = eig(H_sq) ;
lambdas = sort(lambdas,'descend');
p = 1;
gammas = zeros(r,1);
flag = 1;
while (flag == 1)
    lambdas_r_p_1 = lambdas(1:(r-p+1));
    inv_lambdas = 1./lambdas_r_p_1;
    inv_lambdas_sum = sum(inv_lambdas);
    mu = ( Mt / (r - p + 1) ) * ( 1 + (1/SNR) * inv_lambdas_sum);
    for idx = 1:length(lambdas_r_p_1)
        gammas(idx) = mu - (Mt/(SNR*lambdas_r_p_1(idx)));
    end
    if(gammas(r-p+1) < 0) % обнуление отрицательных чисел
        gammas(r-p+1) = 0; 
        p = p + 1;
    else
        flag = 0;
    end
end
end

