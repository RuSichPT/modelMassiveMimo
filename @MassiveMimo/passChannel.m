function outputData = passChannel(obj, inputData, channel)

    chanType = obj.channel.type;

    switch chanType
        case {'PHASED_ARRAY_DYNAMIC'}
            outputData = toPassChannelMIMO(inputData, channel);
        case {'PHASED_ARRAY_STATIC'}
            channel = permute(channel, [2,1,3]);
            g(1,:,:,:) = channel;
            outputData = step(obj.channel.filter, inputData, g); 
        case {'RAYL', 'RAYL_SPECIAL'}
%             channel.Visualization = 'Impulse and frequency responses';
            outputData = channel(inputData);
        otherwise                  
            outputData = inputData*channel;
    end
        
end

