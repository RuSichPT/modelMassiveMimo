function y = helperGenPreamble(prm, varargin)
% Generate the Preamble signal for channel estimation.
%
%   y = helperGenPreamble(prm)
%   y = helperGenPreamble(prm, v)
%       with no numTx mapping.

% Copyright 2016-2017 The MathWorks, Inc.

narginchk(1,2);

numSTS = prm.numSTS;
if nargin>1
    v = varargin{1};
else
    v = complex(zeros(prm.numCarriers,numSTS,numSTS));
    a = eye(numSTS);
    for i = 1:prm.numCarriers
        v(i,:,:) = a;
    end
end

P = helperGetP(numSTS);
Nltf = numSTS; % number of preamble symbols

% Frequency subcarrier tones
ltfLeft = [1; 1;-1;-1; 1; 1;-1; 1; -1; 1; 1; 1; ...
            1; 1; 1;-1; -1; 1; 1;-1; 1;-1; 1; 1; 1; 1;];
ltfRight = [1; -1;-1; 1; 1; -1; 1;-1; 1; -1;-1;-1;-1; ...
            -1; 1; 1;-1; -1; 1;-1; 1; -1; 1; 1; 1; 1];   

ltfSC = [zeros(7,1); ltfLeft; 1; ltfRight;-1;-1;-1; 1; 1;-1; 1; ...
        -1; 1; 1;-1; ltfLeft; 1; ltfRight; 1;-1; 1;-1; 0; ...
        1;-1;-1; 1; ltfLeft; 1; ltfRight;-1;-1;-1; 1; 1;-1; 1; ...
        -1; 1; 1;-1; ltfLeft; 1; ltfRight; zeros(6,1)];
    
Pred = P(1:numSTS,1:numSTS);
R = repmat(Pred(1,1:numSTS),numSTS,1); 

% Define LTF and output variable sizes
numST = prm.numCarriers + numel(prm.PilotCarrierIndices);
normFac = prm.FFTLength/sqrt(numSTS*numST);
ltfTx = complex(zeros(prm.FFTLength,numSTS));
symLen = prm.FFTLength+prm.CyclicPrefixLength;

% Generate and modulate each LTF symbol
y = complex(zeros(symLen*Nltf,numSTS));
for i = 1:Nltf
    
    % Map data and pilot subcarriers and apply P and R mapping matrices
    ltfTx(prm.CarriersLocations,:) = bsxfun(@times, ...
        ltfSC(prm.CarriersLocations),Pred(:, i).');
    ltfTx(prm.PilotCarrierIndices,:) = bsxfun(@times, ...
        ltfSC(prm.PilotCarrierIndices),R(:, i).');
    
    for carrIdx = 1:prm.numCarriers
        Q = squeeze(v(carrIdx,:,:));
        normQ = Q * sqrt(numSTS)/norm(Q, 'fro');

        ltfTx(prm.CarriersLocations(carrIdx),:) = ltfTx(prm.CarriersLocations(carrIdx),:) ...
            * normQ;
    end
    
    % OFDM modulation
    tmp = ofdmmod(reshape(ltfTx, [prm.FFTLength,1,numSTS]), ...
        prm.FFTLength, prm.CyclicPrefixLength);
    y((i-1)*symLen+(1:symLen),:) = tmp*normFac;
end

% [EOF]
