numTx = 8;
numRx = 4;

H = zeros(numTx, numRx);
for i = 1:numTx
    for j = 1:numRx           
        H(i,j) = (randn(1)+1i*randn(1))/sqrt(2);                            
    end
end

% Сингулярные числа прямоугольной матрицы X размерностью M×N
% являются корнем квадратным от собственных чисел квадратной матрицы X'*X размерностью N×N
svd(H)
R = H'*H;
sqrt(eig(R))
