function [y,ltfSC] = My_helperGenPreamble(prm,varargin)
% Generate the Preamble signal for channel estimation.

if nargin>1
    v = varargin{1};
else
    v = complex(zeros(prm.numSC,prm.numSTS,prm.numSTS));
    a = eye(prm.numSTS);
    for i = 1:prm.numSC
        v(i,:,:) = a;
    end
end
Nltf = prm.numSTS; % number of preamble symbols

% Frequency subcarrier tones
x = randi([0 1],prm.numSC,1);
ltfSC = pskmod(x,2);

P = helperGetP(prm.numSTS);    
Pred = P;

% Define LTF(Long training field) and output variable sizes
symLen = prm.N_FFT+prm.CyclicPrefixLength;

% Generate and modulate each LTF symbol
for i = 1:Nltf  
    ltfTx = ltfSC*Pred(:, i).';
    for j = 1:prm.numSC
        Q = squeeze(v(j,:,:));
        ltf(j,:) = ltfTx(j,:)*Q;       
    end
    % OFDM modulation
    tmp = ofdmmod(reshape(ltf, [prm.numSC,1,size(ltf,2)]), ...
        prm.N_FFT, prm.CyclicPrefixLength,prm.NullCarrierIndices);

    y((i-1)*symLen+(1:symLen),:) = tmp;
end
