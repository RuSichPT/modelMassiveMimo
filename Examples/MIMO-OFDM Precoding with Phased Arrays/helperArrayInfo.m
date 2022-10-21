function [isTxURA,expFactorTx,isRxURA,expFactorRx] = helperArrayInfo(prm,varargin)
% Return whether Tx and Rx employ URA or not, with other information
%
%   Supports MIMO-OFDM Examples.

%   Copyright 2017 The MathWorks, Inc.

narginchk(1,2);
if nargin==2
    chkFlag = varargin{1};
else
    chkFlag = false;
end

if chkFlag
    % Parameter checks
    %   numSTS
    if (~ismember(prm.numSTS, [1 2 4 8 16 32 64]))
        error(message('comm_demos:helperArrayInfo:invNumSTS'));
    end
    
    %   numSTS and numTx
    if (prm.numSTS > prm.numTx)
        error(message('comm_demos:helperArrayInfo:NumSTSgtNumTx'));
    end

    if (floor(prm.numTx/prm.numSTS) ~= prm.numTx/prm.numSTS)
        error(message('comm_demos:helperArrayInfo:InvExpFactor'));
    end
    
    %   numSTS and numRx
    if any(prm.numRx < prm.numSTSVec)
        error(message('comm_demos:helperArrayInfo:numSTSgtNumRx'));
    end
end

% Transmit end (Tx)
expFactorTx = prm.numTx/prm.numSTS;   

if expFactorTx==1 || prm.numSTS==1 % ULA
    % Use ULA if expFactorTx==1 or if prm.numSTS<2
    isTxURA = false;
    if prm.numTx==1
        % Avoid the phased.ULA error for numElements==1
        error(message('comm_demos:helperArrayInfo:NumTxEq1'));
    end
else % URA
    % Use URA if expFactorTx>1 and numSTS>1
    isTxURA = true;
end

% Receive end (Rx), per user
expFactorRx = prm.numRx./prm.numSTSVec;

isRxURA = zeros(prm.numUsers, 1, 'logical');
for uIdx = 1:prm.numUsers
    if floor(expFactorRx(uIdx))~=expFactorRx(uIdx) || expFactorRx(uIdx)==1 ...
            || prm.numSTSVec(uIdx)==1   % ULA
        % Use ULA if expFactorRx==1 or expFactorRx is non-integer
        isRxURA(uIdx) = false;
    else % URA
        % Use URA if expFactorRx>1 and an integer, and numSTS>1
        isRxURA(uIdx) = true;
    end
end

end
