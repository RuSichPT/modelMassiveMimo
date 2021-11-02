function invMat = invMatrixNewton(mat, numIter)

    % mat - ���������� �������
    % numIter - ���-�� �������� 
    % ���������� numIter -> inf
    
    if (numIter <= 0)
        error("���-�� �������� �� ����� ���� <=0")
    end
        
    numIter = numIter + 1;
    invMatIter = cell(1, numIter);
    invMatIter{1} = invMatrixNeumannSeries(mat, 1);

    % ������� ����������
    if (norm(eye(size(mat,1)) - mat*invMatIter{1}) < 1)
        for i = 2:numIter
            invMatIter{i} = invMatIter{i - 1}*(2*eye(size(mat,1)) - mat*invMatIter{i - 1});
        end
        invMat = invMatIter{end};
    else
        invMat = invMatIter{1};
%         fprintf("������� ���������� ������ NI %d > 1 ��������\n", norm(eye(size(mat,1)) - mat*invMatIter{1}))
    end  
end