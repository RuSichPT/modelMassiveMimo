function [y,CSI] = helperMIMOEqualize(x,chanEst)
% Zero-forcing MIMO Equalizer for examples.

% Copyright 2016 The MathWorks, Inc.

[numSC,numSTS,numRx] = size(chanEst);
numSym = size(x,2);
y = complex(zeros(numSC,numSym,numSTS));
CSI = zeros(numSC,numSTS);
for idx = 1:numSC
    H = reshape((chanEst(idx,:,:)),numSTS,numRx);
    invH = inv(H*H');
    CSI(idx, :)  = 1./real(diag(invH));
    y(idx,:,1:numSTS) = reshape(x(idx,:,:),numSym,numRx) * H' * invH;  %#ok<MINV>
end    

% [EOF]
