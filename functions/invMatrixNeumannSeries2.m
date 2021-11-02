function invMat = invMatrixNeumannSeries2(mat, numIter, X)

    % mat - квадратна€ матрица
    % numIter - кол-во итераций
    % X - первое приближение матрицы mat
    % необходимо numIter -> inf
    
    if (numIter <= 0)
        error(" ол-во итераци€ не может быть <=0")
    end
    
    invMat = 0;
        
    tmp = eye(size(mat,1)) - X*mat;   
    lambdaMax = max(eig(tmp));
    
    % ”словие сходимости
    if (abs(lambdaMax) < 1)   
        for i = 0:numIter - 1
            tmp = eye(size(mat,1)) - X*mat; 
            invMat = invMat + (tmp^i)*X;
        end
    else
        invMat = X;
%         fprintf("”словие сходимости метода NSA %d > 1 нарушено\n", abs(lambdaMax))
    end 
end