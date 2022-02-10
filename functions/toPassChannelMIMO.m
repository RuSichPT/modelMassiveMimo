function [Y] = toPassChannelMIMO(X, H)
    %% ��������
    % X - ������� ������ ������������ [����� X ���-�� tx ������]
    % H - ��������� ������ ������������ [���-�� tx ������ X ���-�� rx ������ X ���-�� ����������� �����]
    % Y - �������� ������ ������������ [����� X ���-�� rx ������]
    % N_h - ����� ���������� �������������� ��� ���-�� ����������� �����
    % n - ����� ������
    % numRx - ���-�� rx ������
    % X_memory - ����� ������
    
    numRx = size(H,2);
    numTx = size(X,2);  
    N_h = size(H,3);
    n = size(X,1);
    
    X_memory = cell(1, N_h);
    for ii = 1:N_h
        X_memory{ii} = zeros(1, numTx);
    end
    Y = zeros(n, numRx);
    for ii = 1:n
        y = zeros(1, numRx);
        for kk = N_h:-1:2
            X_memory{kk} = X_memory{kk-1};
        end
        X_memory{1} = X(ii,:);
        for jj = 1:N_h
            y = y + X_memory{jj}*permute(H(:,:,jj),[1,2,3]);
        end
        Y(ii,:) = Y(ii,:) + y;
    end

end

