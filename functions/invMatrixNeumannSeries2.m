function invMat = invMatrixNeumannSeries2(mat, numIter, X)

    % mat - ���������� �������
    % numIter - ���-�� ��������
    % X - ������ ����������� ������� mat
    % ���������� numIter -> inf
    
    if (numIter <= 0)
        error("���-�� �������� �� ����� ���� <=0")
    end
    
    invMat = 0;
        
    tmp = eye(size(mat,1)) - X*mat;   
    lambdaMax = max(eig(tmp));
    
    % ������� ����������
    if (abs(lambdaMax) < 1)   
        for i = 0:numIter - 1
            tmp = eye(size(mat,1)) - X*mat; 
            invMat = invMat + (tmp^i)*X;
        end
    else
        invMat = X;
%         fprintf("������� ���������� ������ NSA %d > 1 ��������\n", abs(lambdaMax))
    end 
end