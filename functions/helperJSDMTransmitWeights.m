function [Fbb,mFrf] = helperJSDMTransmitWeights(H,prm)
% This function helperJSDMTransmitWeights is only in support of
% MassiveMIMOHybridBeamformingExample. It may change in
% a future release.

% JSDM weights formulation for the transmit end
%
%   [Fbb,mFrf] = helperJSDMTransmitWeights(H,prm)
%
%   Supports multi-user, per-subcarrier processing 
%   H:    numUsers cell, numCarriers-by-numTx-by-numRx(uIdx)
%   prm:  parameter structure
%   Fbb:  numUsers cell, numcarriers-by-numSTSVec(uIdx)-by-numSTSVec(uIdx)
%   mFrf: sum(numSTSVec)-by-numTx
%
%   See also omphybweights, blkdiagbfweights.

%   Copyright 2017-2019 The MathWorks, Inc.

% References:
% [1] Adhikary A., Nam J., Ahn J-Y, and Caire G., "Joint Spatial Division
% and Multiplexing - The Large-Scale Array Regime", IEEE Trans. Info.
% Theory, vol. 59, no. 10, pp. 6441-6463, 2013.
% [2] Li Z., Han S., and Molisch A. F., "Hybrid Beamforming Design for
% Millimeter-Wave Multi-User Massive MIMO Downlink", IEEE ICC 2016, Signal
% Processing for Communications Symposium.
% [3] Spencer Q., Swindlehurst A., Haardt M., "Zero-forcing methods for
% downlink spatial multiplexing in multiuser MIMO channels", IEEE Trans.
% Signal Processing, vol. 52, no. 2, pp. 461-471, Feb. 2004.

% Extract parameters
numUsers = prm.numUsers;
numSTSVec = prm.numSTSVec;  % vector, per user values

% Initialization
Fbb = cell(numUsers,1);              % Baseband precoder per user, Vg
    
% Get mFrf or B, based on the full H, for all users (not by group for now)
%   Assumes each user is in a group of its own, G = K.
%   With averaging across subcarriers per user
% in the form of a matrix for all user streams concatenated
Hmean = cell(numUsers,1);
for uIdx = 1:numUsers
    Hmean{uIdx} = mean(permute(H{uIdx},[2 3 1]),3);
end
mFrf = blkdiagbfweights(Hmean,numSTSVec); % Analog precoder for all users, B
Frf = angle(mFrf);

% Assuming receive side does not employ a hybrid architecture
%   Get W
%   Get effective H - as:  (Wgi) Hgi Bg
%   Get Vg: from the svd of Hgi 

% Get Vg: from the svd of hk (did svd within blkdiagbfweights also)
for uIdx = 1:numUsers
    hk = permute(H{uIdx},[3 2 1]);     % numRx-by-numTx-by-numCarriers
    stsIdx = sum(numSTSVec(1:uIdx-1))+(1:numSTSVec(uIdx));

    Vg = complex(zeros(prm.numCarriers,numSTSVec(uIdx),numSTSVec(uIdx))); 
    for i = 1:prm.numCarriers
        % Need Wgi as well, if Rx end adopts hybrid arch
        %   Here use the analog precoder (mFrf) only
        [~,~,Vg(i,:,:)] = svd(hk(:,:,i)*Frf(stsIdx,:).','econ');
    end
    Fbb{uIdx} = Vg;
end
    
% Apply [Bg Vg] to data externally, with mFrf:B and Fbb:Vg
% Fbb is per subcarrier, mFrf is averaged over subcarriers 

end
