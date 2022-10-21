clear;clc;
addpath("..\functions");

numTx = 8;
numRx = 4;
k = 0;
numExp = 1000;

for exp = 1:numExp 
    H = zeros(numRx, numTx);
    for i = 1:numRx
        for j = 1:numTx           
            H(i,j) = (randn(1)+1i*randn(1))/sqrt(2);
        end
    end
    Gram = H*H';

    invNewton = invMatrixNewton(Gram, 100);
    D = diag(diag(Gram)); 
    if (invNewton == inv(D))
        k = k+1;
        fprintf("Условие сходимости нарушено\n")
    end
end

invNewton = invMatrixNewton(Gram, 100)

inv(Gram)

% Процент несошедшихся матриц
EC = k/numExp*100