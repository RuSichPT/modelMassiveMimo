function [preamble, ltfSC] = generatePreamble(obj, numSTS, varargin)
    % Generate the Preamble signal for channel estimation.

    numSubCarr = obj.ofdm.numSubCarriers;
    lenFFT = obj.ofdm.lengthFFT;
    cycPrefLen = obj.ofdm.cyclicPrefixLength;
    nullCarrInd = obj.ofdm.nullCarrierIndices;

    if (nargin > 2)
        v = varargin{1};
    else
        v = complex(zeros(numSubCarr,numSTS,numSTS));
        a = eye(numSTS);
        for i = 1:numSubCarr
            v(i,:,:) = a;
        end
    end
    Nltf = numSTS; % number of preamble symbols

    % Frequency subcarrier tones
    x = randi([0 1],numSubCarr,1);
    ltfSC = pskmod(x,2);

    P = helperGetP(numSTS);    
    Pred = P;

    % Define LTF(Long training field) and output variable sizes
    symLen = lenFFT + cycPrefLen;

    % Generate and modulate each LTF symbol
    for i = 1:Nltf  
        ltfTx = ltfSC*Pred(:, i).';
        for j = 1:numSubCarr
            Q = squeeze(v(j,:,:));
            ltf(j,:) = ltfTx(j,:)*Q;       
        end
        % OFDM modulation
        tmp = ofdmmod(reshape(ltf, [numSubCarr,1,size(ltf,2)]), lenFFT, cycPrefLen, nullCarrInd);

        preamble((i-1)*symLen+(1:symLen),:) = tmp;
    end
end


