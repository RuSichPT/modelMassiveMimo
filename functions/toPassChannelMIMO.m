function [Y] = toPassChannelMIMO(X, H)
    %% Описание
    % X - входные данные размерностью [поток X кол-во tx антенн]
    % H - канальный тензор размерностью cell{1, кол-во задержанных лучей};
    % cell{1,1} = матрица размерностью. [кол-во tx антенн X кол-во rx антенн]
    % Y - выходные данные размерностью [поток X кол-во rx антенн]
    % N_h - длина импульсной характеристика или кол-во задержанных лучей
    % n - длина потока
    % X_memory - буфер памяти

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

