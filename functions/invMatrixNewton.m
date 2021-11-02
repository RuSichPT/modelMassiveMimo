function invMat = invMatrixNewton(mat, numIter)

    % mat - квадратная матрица
    % numIter - кол-во итераций 
    % необходимо numIter -> inf
    
    if (numIter <= 0)
        error("Кол-во итерация не может быть <=0")
    end
        
    numIter = numIter + 1;
    invMatIter = cell(1, numIter);
    invMatIter{1} = invMatrixNeumannSeries(mat, 1);

    % Условие сходимости
    if (norm(eye(size(mat,1)) - mat*invMatIter{1}) < 1)
        for i = 2:numIter
            invMatIter{i} = invMatIter{i - 1}*(2*eye(size(mat,1)) - mat*invMatIter{i - 1});
        end
        invMat = invMatIter{end};
    else
        invMat = invMatIter{1};
%         fprintf("Условие сходимости метода NI %d > 1 нарушено\n", norm(eye(size(mat,1)) - mat*invMatIter{1}))
    end  
end