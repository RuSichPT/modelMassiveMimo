function invMat = invMatrixCayleyHamilton(mat, sizeMat)

    % mat - ���������� �������
    % sizeMat - ������ �������, (����� � �����), ����� ������� ����������
    % ���������� sizeMat = size(mat)
       
    cpoly = poly(mat);

    invMat = 0;
    for i = 0:sizeMat-1
       invMat = invMat + cpoly(sizeMat - i)*mat^(i);
    end
    
    invMat =( (-1)^(sizeMat - 1)/det(mat) )*invMat;
    
end

