function estimH = channelEstimate(obj, rxData, ltfSC, numSTS)
    % Estimate channel from the preamble signal data tones

    [~, nltf, numRx] = size(rxData);
    % nltf should be == numSTS

    % Transmitted pilot mapping sequences
    P = helperGetP(numSTS);

    Puse = P'; % Extract and conjugate the P matrix 

    denom = nltf.*ltfSC;

    estimH = complex(zeros(obj.numSubCarriers,numSTS,numRx));
    for i = 1:numRx
        rxsym = squeeze(rxData(:,(1:nltf),i)); % Symbols per receive antenna
        for j = 1:numSTS
            estimH(:,j,i) = rxsym*Puse(:,j)./denom;
        end
    end

end

