clear;clc;
numTx = 8;
numRx = 4;
H = zeros(numTx, numRx);
for i = 1:numTx
    for j = 1:numRx           
        H(i,j) = (randn(1)+1i*randn(1))/sqrt(2);
    end
end

[U,S,V] = svd(H);
sigma = diag(S);
cond(H)
sigma(1)/sigma(end)

A = [-1 0 1 2;
    -1 1 0 -1;
    0 -1 1 3;
    0 1 -1 -3;
    1 -1 0 1;
    1 0 -1 -2];

pinvA1 = pinv(A);
sigma = svd(A)
[U,S,V] = svd(A);
pinvA2 = V*pinv(S)*U';
S1 = pinv(S);
pinvA3 = V(:,1:2)*S1(1:2,1:2)*U(:,1:2)';
pinvA4 = A.'*pinv(A*A.');
cond(A)
cond(A*A.')
