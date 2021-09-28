function [Y] = toPassChannelMIMO(X, H)
    %% ��������
    % X - ������� ������ ������������ [����� X ���-�� tx ������]
    % H - ��������� ������ ������������ cell{1, ���-�� ����������� �����};
    % cell{1,1} = ������� ������������. [���-�� tx ������ X ���-�� rx ������]
    % Y - �������� ������ ������������ [����� X ���-�� rx ������]
    % N_h - ����� ���������� �������������� ��� ���-�� ����������� �����
    % n - ����� ������
    % X_memory - ����� ������

    N_h = length(H);
    n = size(X,1);
    X_memory = cell(size(H,1), size(H,2));
    for ii = 1:N_h
        X_memory{ii} = zeros(1, size(X,2));
    end
    Y = zeros(size(X,1), size(H{1,1},2));
    for ii = 1:n
        y = zeros(1, size(Y,2));
        for kk = N_h:-1:2
            X_memory{kk} = X_memory{kk-1};
        end
        X_memory{1} = X(ii,:);
        for jj = 1:N_h
            y = y + X_memory{jj}*H{jj};
        end
        Y(ii,:) = Y(ii,:) + y;
    end

end

