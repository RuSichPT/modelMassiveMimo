function Hk = createKroneckerChannels(numTx,numRx,numChan,R,Z)
    addpath("../functions");
    Hk = zeros(numRx,numTx,numChan);
    for k = 1:numChan
        H = createStaticChannel(numTx,numRx);
        H = H.';
        Hk(:,:,k) = H*sqrt(R)*Z;
    end
end