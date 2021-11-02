function invMat = invMatrixNeumannSeries(mat, numIter)

    % mat - ���������� �������
    % numIter - ���-�� �������� 
    % ���������� numIter -> inf
    
    if (numIter <= 0)
        error("���-�� �������� �� ����� ���� <=0")
    end
    
    invMat = 0;
    D = diag(diag(mat));    
    E = triu(mat,1) + tril(mat,-1);
    
    lambdaMax = max(eig((-inv(D)*E)));
    
    % ������� ����������
    if (abs(lambdaMax) < 1)   
        for i = 0:numIter - 1
            invMat = invMat + ( (-inv(D)*E)^i )*inv(D);
        end
    else
        invMat = inv(D);
%         fprintf("������� ���������� ������ NSA %d > 1 ��������\n", abs(lambdaMax))
    end 
end