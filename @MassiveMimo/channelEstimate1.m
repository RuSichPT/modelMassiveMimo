function estimH = channelEstimate1(obj, rxData, ltfSC, numSTS)
    % Estimate channel from the preamble signal data tones

    numSubCarr = obj.ofdm.numSubCarriers;
    
    [~, nltf, numRx] = size(rxData);
    % nltf should be == numSTS

    % Transmitted pilot mapping sequences
    P = helperGetP(numSTS);

    Puse = P'; % Extract and conjugate the P matrix 

    denom = nltf.*ltfSC;

    estimH = complex(zeros(numSubCarr, numSTS, numRx));
    for i = 1:numRx
        rxsym = squeeze(rxData(:,(1:nltf),i)); % Symbols per receive antenna
        for j = 1:numSTS
            estimH(:,j,i) = rxsym./denom(:,j);
        end
    end

end

