function [lossSig,chanDelay] = helperApplyMUChannel(sig,prm,spLoss,varargin)
% Apply MIMO channel to input signal
%   Options include:
%       'Scattering': Phased Scattering MIMO channel
%       'MIMO': Comm MIMO channel
%
%   The channel is modeled with a fixed seed so as to keep the same channel
%   realization between sounding and data transmission. In reality, the
%   channel would evolve between the two stages. This evolution is modeled
%   by prepending the preamble signal to the data signal, to prime the
%   channel to a valid state, and then ignoring the preamble portion from
%   the channel output.

%   Copyright 2017-2018 The MathWorks, Inc.

narginchk(3,4);
numUsers = prm.numUsers;
numTx = prm.numTx;
numRx = prm.numRx;
if nargin>3
    % preSig, for data transmission
    preSig = varargin{1}; 
    sigPad = [preSig; zeros(prm.numPadZeros,numTx); ...
              sig; zeros(prm.numPadZeros,numTx)];
else
    % No preSig, for sounding
    preSig = []; 
    sigPad = [sig; zeros(prm.numPadZeros,numTx)];
end
numBytesPerElement = 16;

% Create independent channels per user
chan      = cell(numUsers,1);
chanDelay = zeros(numUsers,1);
lossSig   = cell(numUsers,1);

switch prm.ChanType        
    case 'Scattering'
        % phased.ScatteringMIMOChannel
        %   No motion => static channel.
        
        % Tx & Rx Arrays
        [isTxURA,expFactorTx,isRxURA,expFactorRx] = helperArrayInfo(prm);
        
        %   Specify spacing in direct units (meters)
        if isTxURA % URA
            txarray = phased.URA([expFactorTx,prm.numSTS], ...
                [0.5 0.5]*prm.lambda,'Element', ...
                phased.IsotropicAntennaElement('BackBaffled',false));
        else % ULA
            txarray = phased.ULA('Element', ...
                phased.IsotropicAntennaElement('BackBaffled',false),...
                'NumElements',numTx,'ElementSpacing',0.5*prm.lambda);
        end         
        
        % Create independent channels per user
        for uIdx = 1:numUsers

            if isRxURA(uIdx) % URA
                rxarray = phased.URA([expFactorRx(uIdx),prm.numSTSVec(uIdx)], ...
                    [0.5 0.5]*prm.lambda,'Element', ...
                    phased.IsotropicAntennaElement);
            else % ULA
                if numRx(uIdx)>1
                    rxarray = phased.ULA('Element',phased.IsotropicAntennaElement, ...
                        'NumElements',numRx(uIdx),'ElementSpacing',0.5*prm.lambda);
                else % numRx==1
                    error(message('comm_demos:helperApplyMUChannel:invScatConf'));
                    % only a single antenna, but ScatteringMIMOChannel doesnt accept this!
                    % rxarray = phased.IsotropicAntennaElement;
                end                    
            end

            Ns = 100;          % Number of scatterers

            % Place scatterers randomly in a circle from the center
            % posCtr = (prm.posTx+prm.posRx(:,uIdx))/2;

            % Place scatterers randomly in a sphere around the Rx
            %   similar to the one-ring model
            posCtr = prm.posRx(:,uIdx);
            radCtr = prm.mobileRanges(uIdx)*0.1;
            scatBound = [posCtr(1)-radCtr posCtr(1)+radCtr; ...
                         posCtr(2)-radCtr posCtr(2)+radCtr; ...
                         posCtr(3)-radCtr posCtr(3)+radCtr];
                       
            % Channel
            chan{uIdx} = phased.ScatteringMIMOChannel(...
                'TransmitArray',txarray,...
                'ReceiveArray',rxarray,...
                'PropagationSpeed',prm.cLight,...
                'CarrierFrequency',prm.fc,...
                'SampleRate',prm.chanSRate, ...
                'SimulateDirectPath',false, ...
                'ChannelResponseOutputPort',true, ...
                'TransmitArrayPosition',prm.posTx,...
                'ReceiveArrayPosition',prm.posRx(:,uIdx),...
                'NumScatterers',Ns, ...
                'ScattererPositionBoundary',scatBound, ...
                'SeedSource','Property', ...
                'Seed',uIdx);

            maxBytes = 1e9;
            if numTx*numRx(uIdx)*Ns*(length(sigPad)) ...
                    *numBytesPerElement > maxBytes
                % If requested sizes are too large, process symbol-wise
                fadeSig = complex(zeros(length(sigPad), numRx(uIdx)));
                symLen = prm.FFTLength+prm.CyclicPrefixLength;
                numSymb = ceil(length(sigPad)/symLen);
                for idx = 1:numSymb
                    sIdx = (idx-1)*symLen+(1:symLen).';
                    [tmp,~,tau] = chan{uIdx}(sigPad(sIdx,:));
                    fadeSig(sIdx,:) = tmp;
                end
            else                       
                [fadeSig,~,tau] = chan{uIdx}(sigPad);
            end
            chanDelay(uIdx) = floor(min(tau)*prm.chanSRate);

            % Remove the preamble, if present
            if ~isempty(preSig)
                fadeSig(1:(length(preSig)+prm.numPadZeros),:) = [];
            end

            % Path loss is included in channel
            lossSig{uIdx} = fadeSig;
            
        end
        
    case 'MIMO'

        % Create independent channels per user
        for uIdx = 1:numUsers

            % Using comm.MIMOChannel, with no array information
            chan{uIdx} = comm.MIMOChannel('MaximumDopplerShift',0, ...
                'SpatialCorrelation',false, ...
                'NumTransmitAntennas',numTx, ...
                'NumReceiveAntennas',numRx(uIdx),...
                'RandomStream','mt19937ar with seed', ...
                'Seed',uIdx, ...
                'SampleRate',prm.chanSRate);

            maxBytes = 8e9;
            if numTx*numRx*(length(sigPad))*numBytesPerElement > maxBytes
                % If requested sizes are too large, process symbol-wise
                fadeSig = complex(zeros(length(sigPad), numRx));
                symLen = prm.FFTLength+prm.CyclicPrefixLength;
                numSymb = ceil(length(sigPad)/symLen);
                for idx = 1:numSymb
                    sIdx = (idx-1)*symLen+(1:symLen).';
                    fadeSig(sIdx,:) = chan{uIdx}(sigPad(sIdx,:));
                end
            else
                fadeSig = chan{uIdx}(sigPad);
            end

            % Check derived channel parameters
            chanInfo = info(chan{uIdx});
            chanDelay(uIdx) = chanInfo.ChannelFilterDelay;        

            % Remove the preamble, if present
            if ~isempty(preSig)
                fadeSig(1:(length(preSig)+prm.numPadZeros),:) = [];
            end
            
            % Apply path loss
            lossSig{uIdx} = fadeSig/sqrt(db2pow(spLoss(uIdx)));
            
        end
    otherwise
        error(message('comm_demos:helperApplyMUChannel:invChanType'));
end

end

% [EOF]
