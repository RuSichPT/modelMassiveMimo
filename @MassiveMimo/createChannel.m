function [channel] = createChannel(obj, prm)

    numTx = obj.main.numTx;
    numRx = obj.main.numRx;
    numSTS = obj.main.numSTS;
    numUsers = obj.main.numUsers;
    chanType = obj.channel.channelType;

    switch chanType
        case 'PHASED_ARRAY_STATIC'
            [da, dp] = loadSteeringVector(numTx);  % Амплитуда и фаза SteeringVector
            channel = CreateChannelByDN_static(numUsers, prm.numDelayBeams, prm.txAng, da, dp); % для статичных углов
            obj.channel.numDelayBeams = prm.numDelayBeams;
            obj.channel.da = da;
            obj.channel.dp = dp;
        case 'PHASED_ARRAY_DYNAMIC'
            [da, dp] = loadSteeringVector(numTx);  % Амплитуда и фаза SteeringVector
            channel = CreateChannelByDN(numUsers, numDelayBeams, da, dp); % случайные углы
            obj.channel.numDelayBeams = prm.numDelayBeams;
            obj.channel.da = da;
            obj.channel.dp = dp;
        case 'RAYL'
            channel = comm.MIMOChannel(...
                        'SampleRate',                       prm.sampleRate, ...
                        'PathDelays',                       prm.tau,        ...
                        'AveragePathGains',                 prm.pdB,        ...
                        'MaximumDopplerShift',              0,              ...
                        'SpatialCorrelationSpecification',  'None',         ... 
                        'NumTransmitAntennas',              numTx,          ...
                        'NumReceiveAntennas',               numRx,          ...
                        'PathGainsOutputPort',              true);
%                 'TransmitCorrelationMatrix', cat(3, eye(2), [1 0.01;0.01 1]),...
%                 'ReceiveCorrelationMatrix',  cat(3, [1 0.1;0.1 1], eye(2)),...
        case 'STATIC'
            rng(168)
            channel = zeros(numTx, numRx);
            for i = 1:numTx
                for j = 1:numRx           
                    channel(i,j) = (randn(1)+1i*randn(1))/sqrt(2);
                end
            end  
    end

end

