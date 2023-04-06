function SINR_TPE = calcSINR_TPE(numTx, numRx)

    H = zeros(numRx, numTx);
    for i = 1:numRx
        for j = 1:numTx           
            H(i,j) = (randn(1)+1i*randn(1))/sqrt(2);
        end
    end

    Gram = H*H';

    He = H;

    w = poly(Gram);
    sigma = 1;

    J = size(w,2);    

    SINR_TPE = zeros(1,4);
    for k = 1:4

        A = zeros(J);    
        B = zeros(J);

        for m = 0:J - 1
            for c = 0:J - 1
                A(c + 1,m + 1) = H(:,k)'*Gram^c*He(:,k)*He(:,k)'*Gram^m*H(:,k);
                B(c + 1,m + 1) = H(:,k)'*Gram^(c + m + 1)*H(:,k);
            end
        end
        SINR_TPE(k) = (w*A*w') / (w*B*w' - w*A*w' + sigma^2);
    end
end

