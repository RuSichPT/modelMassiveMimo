clear;clc;

numTx = 8;
numRx = 4;
H = zeros(numRx, numTx);
for i = 1:numRx
    for j = 1:numTx           
        H(i,j) = (randn(1)+1i*randn(1))/sqrt(2);
    end
end

Gram = H*H';

He = H;

w = poly(Gram);

invChanTPE = invMatrixCayleyHamilton(Gram, size(Gram,1))

invChan = inv(Gram)

sigma = 1;

SINR = zeros(1,4);
for k = 1:4

    A = zeros(size(w,2));
    B = zeros(size(w,2));
    for m = 0:size(w,2)-1
        for c = 0:size(w,2)-1
            A(c + 1,m + 1) = H(:,k)'*Gram^c*He(:,k)*He(:,k)'*Gram^m*H(:,k);
            B(c + 1,m + 1) = H(:,k)'*Gram^(c + m + 1)*H(:,k);
        end
    end

    SINR(k) = (w*A*w') / (w*B*w' - w*A*w' + sigma^2);

end



