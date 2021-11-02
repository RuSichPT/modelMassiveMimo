function invMat = invMatrixNeumannSeries(mat, numIter)

    % mat - квадратная матрица
    % numIter - кол-во итераций 
    % необходимо numIter -> inf
    
    if (numIter <= 0)
        error("Кол-во итерация не может быть <=0")
    end
    
    invMat = 0;
    D = diag(diag(mat));    
    E = triu(mat,1) + tril(mat,-1);
    
    lambdaMax = max(eig((-inv(D)*E)));
    
    % Условие сходимости
    if (abs(lambdaMax) < 1)   
        for i = 0:numIter - 1
            invMat = invMat + ( (-inv(D)*E)^i )*inv(D);
        end
    else
        invMat = inv(D);
%         fprintf("Условие сходимости метода NSA %d > 1 нарушено\n", abs(lambdaMax))
    end 
end