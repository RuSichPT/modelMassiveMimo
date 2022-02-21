function outputData = passChannel(obj, inputData, channel)

    chanType = obj.channel.type;
    numTx = obj.main.numTx;
    numRx = size(channel,2);

    switch chanType
        case {'PHASED_ARRAY_STATIC', 'PHASED_ARRAY_DYNAMIC'}
            numPath = length(obj.channel.tau);
            channel = permute(channel, [2,1,3]);
            g = reshape(channel, [], numRx, numTx, numPath);
            outputData = step(obj.channel.filter, inputData, g); 
        case {'RAYL', 'RAYL_SPECIAL', 'SCATTERING_FREQ'}
%             channel.Visualization = 'Impulse and frequency responses';
            outputData = channel(inputData);
        otherwise                  
            outputData = inputData*channel;
    end
        
end

