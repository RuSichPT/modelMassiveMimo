function dispChannel(obj)

    str = [class(obj) ' ' obj.main.precoderType '; '];
    str = [str 'channel: ' obj.channel.type '; '];
    
    if (isfield(obj.channel, 'sampleRate'))
        str = [str 'sampleRate: ' num2str(obj.channel.sampleRate) '; '];
    end    
    if (isfield(obj.channel, 'tau'))
        str = [str 'tau: ' num2str(obj.channel.tau) '; '];
    end    
    if (isfield(obj.channel, 'pdB'))
        str = [str 'pdB: ' num2str(obj.channel.pdB) '; '];
    end    
    if (isfield(obj.channel, 'seed'))
        str = [str 'seed: ' num2str(obj.channel.seed) '; '];
    end    
    if (isfield(obj.channel, 'txAng'))
        strAng = [];
        for i = 1:length(obj.channel.txAng)
            strAng = cat(2,strAng,num2str(obj.channel.txAng{i}),'; ');
        end
        str = [str 'txAng: ' strAng '; '];
    end
    if (isfield(obj.channel, 'freqCarr'))
        str = [str 'freqCarr: ' num2str(obj.channel.freqCarr,'%10.1e\n') '; '];
    end
    if (isfield(obj.channel, 'lambda'))
        str = [str 'lambda: ' num2str(obj.channel.lambda) '; '];
    end 
    if (isfield(obj.channel, 'nRays'))
        str = [str 'nRays: ' num2str(obj.channel.nRays) '; '];
    end
    
    str = [str '\n'];
    
    fprintf(str);
end