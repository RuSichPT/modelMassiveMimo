function [preamble, ltfSC] = generatePreamble(obj, numSTS, varargin)
% Generate the Preamble signal for channel estimation.

if (nargin > 2)
    v = varargin{1};
else
    v = complex(zeros(obj.numSubCarriers,numSTS,numSTS));
    a = eye(numSTS);
    for i = 1:obj.numSubCarriers
        v(i,:,:) = a;
    end
end
Nltf = numSTS; % number of preamble symbols

% Frequency subcarrier tones
x = randi([0 1],obj.numSubCarriers,1);
ltfSC = pskmod(x,2);

P = helperGetP(numSTS);    
Pred = P;

% Define LTF(Long training field) and output variable sizes
symLen = obj.lengthFFT + obj.cyclicPrefixLength;

% Generate and modulate each LTF symbol
for i = 1:Nltf  
    ltfTx = ltfSC*Pred(:, i).';
    for j = 1:obj.numSubCarriers
        Q = squeeze(v(j,:,:));
        ltf(j,:) = ltfTx(j,:)*Q;       
    end
    % OFDM modulation
    tmp = ofdmmod(reshape(ltf, [obj.numSubCarriers,1,size(ltf,2)]), ...
        obj.lengthFFT, obj.cyclicPrefixLength,obj.nullCarrierIndices);

    preamble((i-1)*symLen+(1:symLen),:) = tmp;
end


