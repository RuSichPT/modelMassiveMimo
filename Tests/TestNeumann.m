clear;clc;

numTx = 8;
numRx = 4;
k = 0;
numExp = 100;

for exp = 1:numExp 
    H = zeros(numRx, numTx);
    for i = 1:numRx
        for j = 1:numTx           
            H(i,j) = (randn(1)+1i*randn(1))/sqrt(2);
        end
    end
    Gram = H*H';

    invNeim = invMatrixNeumannSeries(Gram, 100);
    
    D = diag(diag(Gram)); 
    if (invNeim == inv(D))
        k = k+1;
        fprintf("Условие сходимости нарушено\n")
    end
end

invNeim = invMatrixNeumannSeries(Gram, 100)

D = diag(diag(Gram));
invNeim2 = invMatrixNeumannSeries2(Gram, 100, inv(D))

inv(Gram)

% Процент несошедшихся матриц
EC = k/numExp*100

