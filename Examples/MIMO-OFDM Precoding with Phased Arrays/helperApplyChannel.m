function [lossSig, chanDelay] = helperApplyChannel(sig, prm, spLoss, varargin)
% Apply MIMO channel to input
%   Options include:
%       WINNER II Channel model:  'WINNER', 
%       Scattering based:  'Scattering', and 'ScatteringFcn'
%       Static-Flat: 'StaticFlat'
%
%   The channel is modelled with a fixed seed so as to keep the same
%   channel realization between sounding and data transmission. In reality,
%   the channel would evolve between the two stages. This channel evolution
%   is modelled by prepending the sounding signal to the data signal, to
%   prime the channel to the same valid state for the data transmission,
%   and then ignoring the preamble portion from the channel output.

%   Copyright 2016-2017 The MathWorks, Inc.

narginchk(3,4);
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
maxBytes = 1e9;

switch prm.ChanType
    case 'WINNER'
        % WINNER II channel
        channel = winnerChannelSetup(prm, length(sigPad));
                
        % Check derived channel parameters
        chanInfo = info(channel);
        chanDelay = chanInfo.ChannelFilterDelay;
        
        if numTx*numRx*chanInfo.NumPaths*(length(sigPad)) ...
                *numBytesPerElement > maxBytes
            % If requested sizes are too large, process symbol-wise
            fadeSig = complex(zeros(length(sigPad), numRx));
            symLen = prm.FFTLength+prm.CyclicPrefixLength;
            channel.ModelConfig.NumTimeSamples = symLen;
            numSymb = ceil(length(sigPad)/symLen);
            for idx = 1:numSymb
                sIdx = (idx-1)*symLen+(1:symLen).';
                tmp = channel(sigPad(sIdx,:));
                fadeSig(sIdx,:) = tmp{1};
            end
        else            
            fadeSig = channel(sigPad);
            fadeSig = fadeSig{1};
        end

        % Remove the preamble, if present
        if ~isempty(preSig)
            fadeSig(1:(length(preSig)+prm.numPadZeros),:) = [];
        end

        % Apply path loss
        lossSig = fadeSig/sqrt(db2pow(spLoss));
        
    case 'Scattering'
        % phased.ScatteringMIMOChannel
        %   No motion => static channel.
        
        % Tx & Rx Arrays
        [isTxURA,expFactorTx,isRxURA,expFactorRx] = helperArrayInfo(prm);
        
        %   Specify spacing in direct units (meters)
        if isTxURA % URA
            txarray = phased.URA([expFactorTx,prm.numSTS], ...
                [0.5 0.5]*prm.lambda,'Element', ...
                phased.IsotropicAntennaElement('BackBaffled',true));
        else % ULA
            txarray = phased.ULA('Element', ...
                phased.IsotropicAntennaElement('BackBaffled', true),...
                'NumElements',numTx,'ElementSpacing',0.5*prm.lambda);
        end         
        if isRxURA % URA
            rxarray = phased.URA([expFactorRx,prm.numSTS], ...
                [0.5 0.5]*prm.lambda,'Element', ...
                phased.IsotropicAntennaElement('BackBaffled',true));
        else % ULA
            rxarray = phased.ULA('Element',phased.IsotropicAntennaElement, ...
                'NumElements',numRx,'ElementSpacing',0.5*prm.lambda);
        end
            
        Ns = 100;          % Number of scatterers
        % Place scatterers randomly in a circle from the center
        posCtr = (prm.posTx+prm.posRx)/2;
        radCtr = prm.mobileRange*0.45;
        scatBound = [posCtr(1)-radCtr posCtr(1)+radCtr; ...
            posCtr(2)-radCtr posCtr(2)+radCtr;     0 0];
        
        % Channel
        channel = phased.ScatteringMIMOChannel(...
            'TransmitArray',txarray,...
            'ReceiveArray',rxarray,...
            'PropagationSpeed',prm.cLight,...
            'CarrierFrequency',prm.fc,...
            'SampleRate',prm.chanSRate, ...
            'SimulateDirectPath',false, ...
            'ChannelResponseOutputPort',true, ...
            'TransmitArrayPosition',prm.posTx,...
            'ReceiveArrayPosition',prm.posRx,...
            'NumScatterers',Ns, ...
            'ScattererPositionBoundary',scatBound, ...
            'SeedSource','Property');
        
        [fadeSig, ~, tau] = channel(sigPad);
        chanDelay = floor(min(tau)*prm.chanSRate);
        
        % Remove the preamble, if present
        if ~isempty(preSig)
            fadeSig(1:(length(preSig)+prm.numPadZeros),:) = [];
        end
            
        % Path loss is included in channel
        lossSig = fadeSig;
        
    case 'ScatteringFcn'
        % scatteringchanmtx with no path loss
        %   Flat, static MIMO fading channel
        
        rng(12345);        % Seed channel so as to get similar effects
        Ns = 100;          % Number of scatterers
        
        % Tx & Rx Array geometry
        [isTxURA,expFactorTx,isRxURA,expFactorRx] = helperArrayInfo(prm);
        %   Specify spacing relative to lambda (meters)
        if isTxURA
            ylim = prm.numSTS/2-0.5;
            zlim = expFactorTx/2-0.5;
            [ypos,zpos] = meshgrid((-ylim:ylim)*0.5/prm.lambda,...
                                   (-zlim:zlim)*0.5/prm.lambda);
            txArrayPos = [zeros(1,numTx);ypos(:).';zpos(:).'];
        else
            txArrayPos = (0:numTx-1)*0.5/prm.lambda;
        end
        if isRxURA
            ylim = prm.numSTS/2-0.5;
            zlim = expFactorRx/2-0.5;
            [ypos,zpos] = meshgrid((-ylim:ylim)*0.5/prm.lambda,...
                                   (-zlim:zlim)*0.5/prm.lambda);
            rxArrayPos = [zeros(1,numRx);ypos(:).';zpos(:).'];
        else
            rxArrayPos = (0:numRx-1)*0.5/prm.lambda;
        end
        
        % Channel
        rChan = scatteringchanmtx(txArrayPos,rxArrayPos,Ns);
        
        fadeSig = complex(zeros(length(sigPad), numRx));
        for i = 1:length(sigPad)
            % Normalize over numTx and numRx
            fadeSig(i, :) = (sigPad(i,:)*rChan)./(numTx*numRx);
        end
        chanDelay = 0;

        % Remove the preamble, if present
        if ~isempty(preSig)
            fadeSig(1:(length(preSig)+prm.numPadZeros),:) = [];
        end
        
        % Apply path loss
        lossSig = fadeSig/sqrt(db2pow(spLoss));
        
    case 'StaticFlat'

        % Using comm.MIMOChannel, with no array information
        rChan = comm.MIMOChannel('MaximumDopplerShift', 0, ...
            'SpatialCorrelation', false, ...
            'NumTransmitAntennas', numTx, ...
            'NumReceiveAntennas', numRx,...
            'SampleRate', prm.chanSRate, ...
            'RandomStream', 'mt19937ar with seed', ...
            'Seed', 21);

        if numTx*numRx*(length(sigPad))*numBytesPerElement > maxBytes
            % If requested sizes are too large, process symbol-wise
            fadeSig = complex(zeros(length(sigPad), numRx));
            symLen = prm.FFTLength+prm.CyclicPrefixLength;
            numSymb = ceil(length(sigPad)/symLen);
            for idx = 1:numSymb
                sIdx = (idx-1)*symLen+(1:symLen).';
                fadeSig(sIdx,:) = rChan(sigPad(sIdx,:));
            end
        else
            fadeSig = rChan(sigPad);
        end
        
        % Check derived channel parameters
        chanInfo = info(rChan);
        chanDelay = chanInfo.ChannelFilterDelay;        
        
        % Remove the preamble, if present
        if ~isempty(preSig)
            fadeSig(1:(length(preSig)+prm.numPadZeros),:) = [];
        end
            
        % Apply path loss
        lossSig = fadeSig/sqrt(db2pow(spLoss));
        
end

end

%-------------------------------------------------------------------------
function channel = winnerChannelSetup(prm, numSamples)
% WINNER II channel model set up for a single user link
%
% Likely scenarios:
%   1:  A1 in building: Indoor office/residential
%   3:  B1 Hotspot: Typical urban microcell
%   10: C1 Metropol: Suburban
%   11: C2 Metropol: Typical urban macro-cell

numUsers = 1; % Extend this for MU-MIMO

% Set up layout parameters for WINNER II channel
[isTxURA,expFactorTx,isRxURA,expFactorRx] = helperArrayInfo(prm);

% Winner supports 2D only, use x/y orientations, no (z) elevation support
%   Specify spacing in direct units (meters)
if isTxURA
    xlim = prm.numSTS/2-0.5;
    ylim = expFactorTx/2-0.5;
    [xpos,ypos] = meshgrid((-xlim:xlim)*0.5*prm.lambda,...
                           (-ylim:ylim)*0.5*prm.lambda);
    txArrayPos = [xpos(:) ypos(:) zeros(prm.numTx,1)];        
    AA = winner2.AntennaArray('Pos', txArrayPos);
else % ULA
    AA = winner2.AntennaArray('ULA', prm.numTx, prm.lambda/2);
end
if isRxURA
    xlim = prm.numSTS/2-0.5;
    ylim = expFactorRx/2-0.5;
    [xpos,ypos] = meshgrid((-xlim:xlim)*0.5*prm.lambda,...
                           (-ylim:ylim)*0.5*prm.lambda);
    rxArrayPos = [xpos(:) ypos(:) zeros(prm.numRx,1)];        
    for i = 1:numUsers
        AA(i+1) = winner2.AntennaArray('Pos', rxArrayPos);
    end
else % ULA   
    for i = 1:numUsers
        AA(i+1) = winner2.AntennaArray('ULA', prm.numRx, prm.lambda/2);
    end
end

MSIdx   = 2:(numUsers+1);
BSIdx   = {1}; 
rndSeed = 59;
cfgLayout = winner2.layoutparset(MSIdx, BSIdx, numUsers, AA, [], rndSeed);
cfgLayout.Stations(1).Pos = prm.posTx; % BS
cfgLayout.Stations(2).Pos = prm.posRx; % MS
cfgLayout.Pairing = [ones(1,numUsers);2:(numUsers+1)]; % One BS for all users
cfgLayout.ScenarioVector = 3; % B1, Hotspot
cfgLayout.PropagConditionVector = 0;  % NLOS, 1 - LOS
for i = 1:numUsers % Randomly set low velocity for each user
    v = rand(3,1) - 0.5; 
    cfgLayout.Stations(i+1).Velocity = 0.01*(v/norm(v, 'fro'));
end

% Set up model parameters for WINNER II channel
cfgModel = winner2.wimparset;
cfgModel.CenterFrequency = prm.fc;
cfgModel.FixedPdpUsed       = 'yes';
cfgModel.FixedAnglesUsed    = 'yes';
cfgModel.IntraClusterDsUsed = 'no';       
cfgModel.RandomSeed         = 29;    % Repeatability 

% The maximum velocity for the users is 1m/s. Set up the SampleDensity
% field to ensure that the sample rate matches the channel bandwidth.
maxMSVelocity = max(cell2mat(cellfun(@(x) norm(x, 'fro'), ...
    {cfgLayout.Stations.Velocity}, 'UniformOutput', false)));
cfgModel.UniformTimeSampling = 'yes';
cfgModel.SampleDensity = round(prm.lambda/2/(maxMSVelocity/prm.chanSRate));
cfgModel.NumTimeSamples = numSamples;

% Create the WINNER II channel System object
channel = comm.WINNER2Channel(cfgModel, cfgLayout);

% Use the wim fcn to get pathDelays
%[H, D] = winner2.wim(cfgModel, cfgLayout);

end

% [EOF]
