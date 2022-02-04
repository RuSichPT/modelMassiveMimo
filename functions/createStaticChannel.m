function [channel] = createStaticChannel(numTx,numRx)
    
    % Создает статический канал без замираний    
    channel = zeros(numTx, numRx);
    for i = 1:numTx
        for j = 1:numRx           
            channel(i,j) = (randn(1)+1i*randn(1))/sqrt(2);
        end
    end
end

