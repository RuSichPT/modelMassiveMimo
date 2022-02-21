function pilots = helperGenPilots(numDataSymbols,numTx)
% Generate pilots for examples
%
%   Assume 8 pilot tones per OFDM symbol.
%   Repeats pilots across tones and antennas, different over symbols.

%   Copyright 2016 The MathWorks, Inc.

% Create pilots per symbol
pnseq = comm.PNSequence(...
        'Polynomial',[1 0 0 0 1 0 0 1],...
        'SamplesPerFrame', numDataSymbols,...
        'InitialConditions',[1 1 1 1 1 1 1]);
pilot = pnseq(); 

% Expand to all pilot tones
pilots1 = repmat(pilot, 1, 8)';

pilots1 = 2*double(pilots1<1)-1;        % Unipolar to bipolar
pilots1([4 7],:) = -1*pilots1([4 7],:); % Invert fixed tone pilots

% Multi-antenna pilots: replicate over all antennas
pilots = repmat(pilots1,[1, 1, numTx]);

% [EOF]
