function [H,H_siso,H_STS] = create_chanel(flag_my_chanel,prm)
    switch flag_my_chanel
        case 'STATIC'
            rng(167)
            for i= 1:prm.numTx
                for j = 1:prm.numRx           
                    H(i,j) = (randn(1)+1i*randn(1))/sqrt(2);
                end
            end 
            H_siso = (randn(1)+1i*randn(1))/sqrt(2);
            rng(167)
            for i= 1:prm.numSTS
                for j = 1:prm.numSTS           
                    H_STS(i,j) = (randn(1)+1i*randn(1))/sqrt(2);
                end
            end 
        case 'AWGN'        
            H = eye(prm.numTx,prm.numRx);
            H_STS = eye(prm.numSTS,prm.numSTS);
            H_siso = 1;
%         case 'BAD'
%             H = zeros(prm.numTx,prm.numRx);
%             H(1,1) = 1.1 - i*1;
%             H(1,2) = 1 - i*1;
%             H(2,1) = -1 - i*1;        
%             H(2,2) = -1 - i*1;
        case 'RAYL' 
            H = comm.MIMOChannel(...
                'SampleRate',                       prm.sampleRate,...
                'PathDelays',                       prm.tau,...
                'AveragePathGains',                 prm.pdB,...
                'MaximumDopplerShift',              0,...
                'SpatialCorrelationSpecification',  'None',... 
                'NumTransmitAntennas',              prm.numTx,...
                'NumReceiveAntennas',               prm.numRx,...
                'PathGainsOutputPort',              true);
%                 'TransmitCorrelationMatrix', cat(3, eye(2), [1 0.01;0.01 1]),...
%                 'ReceiveCorrelationMatrix',  cat(3, [1 0.1;0.1 1], eye(2)),...

            H_siso =  comm.RayleighChannel(...
                'SampleRate',                       prm.sampleRate, ...
                'PathDelays',                       prm.tau, ...
                'AveragePathGains',                 prm.pdB,...
                'MaximumDopplerShift',              0,...
                'PathGainsOutputPort',              true);
            
            H_STS = comm.MIMOChannel(...
                'SampleRate',                       prm.sampleRate,...
                'PathDelays',                       prm.tau,...
                'AveragePathGains',                 prm.pdB,...
                'MaximumDopplerShift',              0,...
                'SpatialCorrelationSpecification', 'None',... 
                'NumTransmitAntennas',              prm.numSTS,...
                'NumReceiveAntennas',               prm.numSTS,...
                'PathGainsOutputPort',              true);
        case 'RIC'
            H = comm.MIMOChannel(...
                'SampleRate',                prm.sampleRate,...
                'PathDelays',                prm.tau,...
                'AveragePathGains',          prm.pdB,...
                'FadingDistribution',        'Rician',...
                'KFactor',                   prm.KFactor,...
                'DirectPathDopplerShift',    zeros(1,length(prm.KFactor)),...
                'DirectPathInitialPhase',    zeros(1,length(prm.KFactor)),...
                'MaximumDopplerShift',       0,...
                'SpatialCorrelationSpecification', 'None',... 
                'NumTransmitAntennas',prm.numTx,...
                'NumReceiveAntennas',prm.numRx,...
                'PathGainsOutputPort', true);
            
            H_siso =  comm.RicianChannel(...
                'SampleRate',               prm.sampleRate, ...
                'PathDelays',               prm.tau, ...
                'AveragePathGains',         prm.pdB,...
                'KFactor',                   prm.KFactor,...
                'MaximumDopplerShift',      0,...
                'PathGainsOutputPort',true);
            H_STS = comm.MIMOChannel(...
                'SampleRate',                prm.sampleRate,...
                'PathDelays',                prm.tau,...
                'AveragePathGains',          prm.pdB,...
                'FadingDistribution',        'Rician',...
                'KFactor',                   prm.KFactor,...
                'DirectPathDopplerShift',    zeros(1,length(prm.KFactor)),...
                'DirectPathInitialPhase',    zeros(1,length(prm.KFactor)),...
                'MaximumDopplerShift',       0,...
                'SpatialCorrelationSpecification', 'None',... 
                'NumTransmitAntennas',prm.numSTS,...
                'NumReceiveAntennas',prm.numSTS,...
                'PathGainsOutputPort', true);
        case 'RAYL_SPECIAL'
            H = comm.MIMOChannel(...
                'SampleRate',                prm.sampleRate,...
                'PathDelays',                prm.tau,...
                'AveragePathGains',          prm.pdB,...
                'MaximumDopplerShift',       0,...
                'SpatialCorrelationSpecification', 'None',... 
                'NumTransmitAntennas',prm.numTx,...
                'NumReceiveAntennas',prm.numRx,...
                'RandomStream',             'mt19937ar with seed', ...
                'Seed',prm.SEED,... 
                'PathGainsOutputPort', true);
            
            H_siso =  comm.RayleighChannel(...
                'SampleRate',               prm.sampleRate, ...
                'PathDelays',               prm.tau, ...
                'AveragePathGains',         prm.pdB,...
                'MaximumDopplerShift',      0,...
                'RandomStream',             'mt19937ar with seed', ...
                'Seed',prm.SEED,... 
                'PathGainsOutputPort',true);
            H_STS = comm.MIMOChannel(...
                'SampleRate',                prm.sampleRate,...
                'PathDelays',                prm.tau,...
                'AveragePathGains',          prm.pdB,...
                'MaximumDopplerShift',       0,...
                'SpatialCorrelationSpecification', 'None',... 
                'NumTransmitAntennas',prm.numSTS,...
                'NumReceiveAntennas',prm.numSTS,...
                'RandomStream',             'mt19937ar with seed', ...
                'Seed',prm.SEED,... 
                'PathGainsOutputPort', true);
        case 'Scattering'
            % phased.ScatteringMIMOChannel
            %   No motion => static channel.

            % Place scatterers randomly in a circle from the center
            posCtr = (prm.posTx+prm.posRx)/2;           
            radCtr = prm.mobileRange*0.5;
            scatBound = [posCtr(1)-radCtr posCtr(1)+radCtr; ...
                         posCtr(2)-radCtr posCtr(2)+radCtr; ...
                          0 0];
            % Channel
            H = phased.ScatteringMIMOChannel(...
                'TransmitArray',                prm.arrayTx,...
                'ReceiveArray',                 prm.arrayRx,...
                'PropagationSpeed',             prm.cLight,...
                'CarrierFrequency',             prm.fc,...
                'SampleRate',                   prm.sampleRate, ...
                'SimulateDirectPath',           false, ...
                'ChannelResponseOutputPort',    true, ...
                'TransmitArrayPosition',        prm.posTx,...
                'ReceiveArrayPosition',         prm.posRx,...
                'NumScatterers',                prm.nRays, ...
                'ScattererPositionBoundary',    scatBound);
%                 'SeedSource',                   'Property', ...
%                 'Seed',                         prm.SEED);
            H_siso = 1;
            H_STS = phased.ScatteringMIMOChannel(...
                'TransmitArray',                prm.arrayTx_M,...
                'ReceiveArray',                 prm.arrayRx_M,...
                'PropagationSpeed',             prm.cLight,...
                'CarrierFrequency',             prm.fc_M,...
                'SampleRate',                   prm.sampleRate, ...
                'SimulateDirectPath',           false, ...
                'ChannelResponseOutputPort',    true, ...
                'TransmitArrayPosition',        prm.posTx,...
                'ReceiveArrayPosition',         prm.posRx,...
                'NumScatterers',                prm.nRays, ...
                'ScattererPositionBoundary',    scatBound);
%                 'SeedSource',                   'Property', ...
%                 'Seed',                         prm.SEED);        
        case 'ScatteringFlat'
            rng(214)
            H = scatteringchanmtx(prm.posTxElem,prm.posRxElem,prm.nRays);
            rng(214)
            H_STS = scatteringchanmtx(prm.posTxElem_M,prm.posRxElem_M,prm.nRays);
            H_siso = 1;
            
        case 'ScatteringMU'
            for uIdx = 1:prm.numUsers
                % Place scatterers randomly in a sphere around the Rx
                %   similar to the one-ring model
                posCtr = prm.posRx(:,uIdx);
                radCtr = prm.mobileRanges(uIdx)*0.1;
                scatBound = [posCtr(1)-radCtr posCtr(1)+radCtr; ...
                             posCtr(2)-radCtr posCtr(2)+radCtr; ...
                             posCtr(3)-radCtr posCtr(3)+radCtr];
                % Channel
                H{uIdx} = phased.ScatteringMIMOChannel(...
                    'TransmitArray',                prm.arrayTx,...
                    'ReceiveArray',                 prm.arrayRx,...
                    'PropagationSpeed',             prm.cLight,...
                    'CarrierFrequency',             prm.fc,...
                    'SampleRate',                   prm.sampleRate, ...
                    'SimulateDirectPath',           false, ...
                    'ChannelResponseOutputPort',    true, ...
                    'TransmitArrayPosition',        prm.posTx,...
                    'ReceiveArrayPosition',         prm.posRx(:,uIdx),...
                    'NumScatterers',                prm.nRays, ...
                    'ScattererPositionBoundary',    scatBound);
    %                 'SeedSource',                   'Property', ...
    %                 'Seed',                         prm.SEED);
    
                H_STS{uIdx} = phased.ScatteringMIMOChannel(...
                    'TransmitArray',                prm.arrayTx_M,...
                    'ReceiveArray',                 prm.arrayRx_M,...
                    'PropagationSpeed',             prm.cLight,...
                    'CarrierFrequency',             prm.fc,...
                    'SampleRate',                   prm.sampleRate, ...
                    'SimulateDirectPath',           false, ...
                    'ChannelResponseOutputPort',    true, ...
                    'TransmitArrayPosition',        prm.posTx,...
                    'ReceiveArrayPosition',         prm.posRx(:,uIdx),...
                    'NumScatterers',                prm.nRays, ...
                    'ScattererPositionBoundary',    scatBound);
    %                 'SeedSource',                   'Property', ...
    %                 'Seed',                         prm.SEED);  

                H_siso = 1;
            end
            
        case 'ScatteringFlatMU'
            rng(214)
            H = [];
            H_STS = [];
            H_siso = 1;
            for uIdx = 1:prm.numUsers
                h = scatteringchanmtx(prm.posTxElem,prm.posRxElem,prm.nRays);
                H = [H h];
                h_STS = scatteringchanmtx(prm.posTxElem_M,prm.posRxElem_M,prm.nRays);
                H_STS = [H_STS h_STS];
            end            
    end
end    


