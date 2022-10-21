clear;clc;
addpath("..\functions");

prm.numUsers = 1;                 % Number of users
prm.numSTSVec = 4;%[3 1 2 2];        % Number of independent data streams per user 
prm.numSTS = sum(prm.numSTSVec);  % Must be a power of 2
prm.numTx = prm.numSTS*8;         % Number of BS transmit antennas (power of 2)
prm.numRx = prm.numSTSVec*2;      % Number of receive antennas, per user (any >= numSTSVec)
prm.nRays = 500;             % Number of rays for Frf, Fbb partitioning
prm.fc = 28e9;               % 28 GHz system
prm.cLight = physconst('LightSpeed');
prm.lambda = prm.cLight/prm.fc;
prm.numCarriers = 234; 

numSTS = prm.numSTS;
numTx = prm.numTx;
numRx = prm.numRx;

[isTxURA,expFactorTx,isRxURA,expFactorRx] = helperArrayInfo(prm,true);

txarray = phased.PartitionedArray(...
    'Array',phased.URA([expFactorTx numSTS],0.5*prm.lambda),...
    'SubarraySelection',ones(numSTS,numTx),'SubarraySteering','Custom');

prm.posTxElem = getElementPosition(txarray)/prm.lambda;

% Single-user OMP
%   Spread rays in [az;el]=[-180:180;-90:90] 3D space, equal spacing
%   txang = [-180:360/prm.nRays:180; -90:180/prm.nRays:90];  
txang = [rand(1,prm.nRays)*360-180;rand(1,prm.nRays)*180-90]; % random
At = steervec(prm.posTxElem,txang);
AtExp = complex(zeros(prm.numCarriers,size(At,1),size(At,2)));
for carrIdx = 1:prm.numCarriers
    AtExp(carrIdx,:,:) = At; % same for all sub-carriers
end

H = zeros(numTx,numRx);
for i = 1:numTx
    for j = 1:numRx           
        H(i,j) = (randn(1)+1i*randn(1))/sqrt(2);
    end
end

H = repmat(H,1,1,prm.numCarriers);
H = permute(H,[3 1 2]);

% Orthogonal matching pursuit hybrid weights
[Fbb,Frf] = omphybweights(H,numSTS,numSTS,AtExp);

v = Fbb;    % set the baseband precoder (Fbb)
% Frf is same across subcarriers for flat channels
mFrf = permute(mean(Frf,1),[2 3 1]); 