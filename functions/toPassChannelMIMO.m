function [Y] = toPassChannelMIMO(X, H)
    %% Описание
    % X - входные данные размерностью [поток X кол-во tx антенн]
    % H - канальный тензор размерностью [кол-во tx антенн X кол-во rx антенн X кол-во задержанных лучей]
    % Y - выходные данные размерностью [поток X кол-во rx антенн]
    % N_h - длина импульсной характеристика или кол-во задержанных лучей
    % n - длина потока
    % numRx - кол-во rx антенн
    % X_memory - буфер памяти
    
    numRx = size(H,1);
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

