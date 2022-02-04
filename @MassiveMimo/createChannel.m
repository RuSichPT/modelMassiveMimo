function [channel] = createChannel(obj)
    %% ��������� ����������
    addpath("functions");
    numTx = obj.main.numTx;
    numRxUsers = obj.main.numRxUsers;
    numUsers = obj.main.numUsers;
    chanType = obj.channel.type;

    % ��������
    if (numTx ~= 12 && numTx ~= 8 && (chanType == "PHASED_ARRAY_STATIC" || chanType == "PHASED_ARRAY_DYNAMIC"))
        str = ['��� ������ ' chanType ' numTx �� = 8 ��� 12'];  
        error(str);
    end   
    
    % ��������� ���������
    switch chanType
        case {'PHASED_ARRAY_STATIC', 'PHASED_ARRAY_DYNAMIC'}
            [da, dp] = loadSteeringVector(numTx);  % ��������� � ���� SteeringVector
            obj.channel.da = da;
            obj.channel.dp = dp;            
            if (isfield('obj.channel.numDelayBeams','var') == 0)
                obj.channel.numDelayBeams = 3;
            end
            numDelayBeams = obj.channel.numDelayBeams;
            
            if (chanType == "PHASED_ARRAY_STATIC")
                if (isfield('obj.channel.txAng','var') == 0)
                    obj.channel.txAng = {0,90,180,270};
                end
                txAng = obj.channel.txAng;
            end

        case {'RAYL', 'RAYL_SPECIAL'}
            if (isfield(obj.channel,'sampleRate') == 0)
                obj.channel.sampleRate = 40e6;
            end            
            if (isfield(obj.channel,'tau') == 0)
                obj.channel.tau = [2 5 7] * (1 / obj.channel.sampleRate);
            end            
            if (isfield(obj.channel,'pdB') == 0)
                obj.channel.pdB = [-3 -9 -12];
            end              
            sampleRate = obj.channel.sampleRate;
            tau = obj.channel.tau;
            pdB = obj.channel.pdB;
            if (chanType == "RAYL_SPECIAL")
                if (isfield(obj.channel,'seed') == 0)
                    obj.channel.seed = 95;
                end
                seed = obj.channel.seed;
            end            
    end
    %% �������� ������
    channel = cell(obj.main.numUsers,1);
    switch chanType
        case 'PHASED_ARRAY_STATIC'
            channel = CreateChannelByDN_static(numUsers, numDelayBeams, txAng, da, dp); % ��� ��������� �����
            obj.channel = clearStructExcept(obj.channel, "type","numUsers", "numDelayBeams", "txAng", "da", "dp");
        case 'PHASED_ARRAY_DYNAMIC'
            channel = CreateChannelByDN(numUsers, numDelayBeams, da, dp); % ��������� ����
            obj.channel = clearStructExcept(obj.channel, "type","numUsers", "numDelayBeams", "da", "dp");
        case 'STATIC'
            rng(168)
            for uIdx = 1:obj.main.numUsers
                channel{uIdx} = createStaticChannel(numTx, numRxUsers(uIdx));
            end
            obj.channel = clearStructExcept(obj.channel,"type");
        case 'RAYL'
            for uIdx = 1:obj.main.numUsers
                channel{uIdx} = comm.MIMOChannel(...
                            'SampleRate',                       sampleRate,                 ...
                            'PathDelays',                       tau,                        ...
                            'AveragePathGains',                 pdB,                        ...
                            'MaximumDopplerShift',              0,                          ...
                            'SpatialCorrelationSpecification',  'None',                     ... 
                            'NumTransmitAntennas',              numTx,                      ...
                            'NumReceiveAntennas',               numRxUsers(uIdx),           ...
                            'PathGainsOutputPort',              true);
    %                         'TransmitCorrelationMatrix', cat(3, eye(2), [1 0.01;0.01 1]),   ...
    %                         'ReceiveCorrelationMatrix',  cat(3, [1 0.1;0.1 1], eye(2)),     ...
            end
            obj.channel = clearStructExcept(obj.channel, "type", "sampleRate", "tau", "pdB");
        case 'RAYL_SPECIAL'
            for uIdx = 1:obj.main.numUsers
                channel{uIdx} = comm.MIMOChannel(...
                            'SampleRate',                       sampleRate,             ...
                            'PathDelays',                       tau,                    ...
                            'AveragePathGains',                 pdB,                    ...
                            'MaximumDopplerShift',              0,                      ...
                            'SpatialCorrelationSpecification',  'None',                 ... 
                            'NumTransmitAntennas',              numTx,                  ...
                            'NumReceiveAntennas',               numRxUsers(uIdx),       ...
                            'RandomStream',                     'mt19937ar with seed',  ...
                            'Seed',                             seed,                   ... 
                            'PathGainsOutputPort',              true);
                seed = seed + 1;
            end
            obj.channel = clearStructExcept(obj.channel, "type","sampleRate", "tau", "pdB", "seed");
    end

end

