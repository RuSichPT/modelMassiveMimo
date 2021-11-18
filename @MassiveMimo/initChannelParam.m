function initChannelParam(obj, varargin)
    if (nargin > 1)
        channel = varargin{1};            
        obj.channel.type = channel.type;
        switch channel.type
            case {'PHASED_ARRAY_STATIC', 'PHASED_ARRAY_DYNAMIC'}
                obj.channel.numDelayBeams = channel.numDelayBeams;       
                obj.channel.txAng = channel.txAng;
            case 'RAYL'
                obj.channel.sampleRate = channel.sampleRate;
                obj.channel.tau = channel.tau;
                obj.channel.pdB = channel.pdB;
            case 'RAYL_SPECIAL'
                obj.channel.sampleRate = channel.sampleRate;
                obj.channel.tau = channel.tau;
                obj.channel.pdB = channel.pdB;
                obj.channel.seed = channel.seed;
        end           
    else % По умолчанию
        obj.channel.type = 'RAYL_SPECIAL';
        obj.channel.sampleRate = 40e6;
        obj.channel.tau = [2 5 7] * (1 / obj.channel.sampleRate);
        obj.channel.pdB = [-3 -9 -12];
        obj.channel.seed = 95;

    end    
end

