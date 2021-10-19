function outputData = passChannel(obj, inputData, channel)

    chanType = obj.channel.channelType;

    switch chanType
        case {'PHASED_ARRAY_STATIC', 'PHASED_ARRAY_DYNAMIC'}
            outputData = toPassChannelMIMO(inputData, channel);
        case {'RAYL', 'RAYL_SPECIAL'}
            outputData = channel(inputData);
        otherwise                  
            outputData = inputData*channel;
    end
        
%     if (typeChannel == "PHASED_ARRAY_STATIC" || typeChannel == "PHASED_ARRAY_DYNAMIC") 
%         toPassChannelMIMO(inputData, channel);
%     elseif (typeChannel == )
%         
%     end
% 
%     if(flag_phased == 1)
%         [Chanel_Zond] = toPassChannelMIMO(preambulaZond, H);
%     else
%         switch flag_chanel
%             case {'RAYL','RIC','RAYL_SPECIAL'}
%                     H.Visualization = 'Impulse and frequency responses';
%                 [Chanel_Zond, H_ist] = H(preambulaZond);                       
%             case 'Scattering'                  
%                 [Chanel_Zond, H_ist,tau] = H(preambulaZond);
%             otherwise                  
%                 Chanel_Zond  = preambulaZond*H;
%         end
%     end

end

