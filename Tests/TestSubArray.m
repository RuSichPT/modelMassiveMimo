clear; clc;
numTx = 8;
numSTS = 4;
numRF = numSTS;

dataOFDMbb = randi([0 9], 1, numSTS);
Frf = randi([0 9], numSTS, numTx);

subNumTx = numTx/numRF;
subNumSTS = numSTS/numRF;
tmpFrf = cell(1,numRF);
for i = 1:numRF
    tmpFrf{i} = Frf(1+(i-1)*subNumSTS:i*subNumSTS, 1+(i-1)*subNumTx:i*subNumTx);
end
newFrf = blkdiag(tmpFrf{:});
dataOFDMrf = dataOFDMbb*newFrf;

dataOFDMrf1 = dataOFDMbb*Frf;

Frf
newFrf