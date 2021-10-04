function [channel] = createChannel(obj, prm)

    numTx = obj.main.numTx;
    numUsers = obj.main.numUsers;
    chanType = obj.channel.channelType;

    switch chanType
        case "PHASED_ARRAY_STATIC"
            [da, dp] = loadSteeringVector(numTx);  % Амплитуда и фаза SteeringVector
            channel = CreateChannelByDN_static(numUsers, prm.numDelayBeams, prm.txAng, da, dp); % для статичных углов
            obj.channel.numDelayBeams = prm.numDelayBeams;
            obj.channel.da = da;
            obj.channel.dp = dp;
        case "PHASED_ARRAY_DYNAMIC"
            [da, dp] = loadSteeringVector(numTx);  % Амплитуда и фаза SteeringVector
            channel = CreateChannelByDN(numUsers, numDelayBeams, da, dp); % случайные углы
            obj.channel.numDelayBeams = prm.numDelayBeams;
            obj.channel.da = da;
            obj.channel.dp = dp;
        case "RAYL"
            prm.numTx = obj.main.numTx;
            prm.numRx = obj.main.numRx;
            prm.numSTS = obj.main.numSTS;
            [channel,~,~] = create_chanel("RAYL", prm);
    end

end

