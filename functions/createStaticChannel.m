function H = createStaticChannel(numTx,numRx)
    H = zeros(numTx,numRx);
    for i = 1:numTx
        for j = 1:numRx
            H(i,j) = (randn(1)+1i*randn(1))/sqrt(2);
        end
    end
end