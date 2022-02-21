function [channel] = createChannel(obj)
    %% Получение параметров
    addpath("functions");
    numTx = obj.main.numTx;
    numRxUsers = obj.main.numRxUsers;
    numUsers = obj.main.numUsers;
    chanType = obj.channel.type;

    % Проверка
    if (numTx ~= 12 && numTx ~= 8 && (chanType == "PHASED_ARRAY_STATIC" || chanType == "PHASED_ARRAY_DYNAMIC"))
        str = ['Для канала ' chanType ' numTx дб = 8 или 12'];  
        error(str);
    end
    
    % Заполняем параметры по умолчанию 
    if (~isfield(obj.channel,'sampleRate'))
        obj.channel.sampleRate = 40e6;
    end            
    if (~isfield(obj.channel,'tau'))
        obj.channel.tau = [2 5 7] * (1 / obj.channel.sampleRate);
    end            
    if (~isfield(obj.channel,'pdB'))
        obj.channel.pdB = [-3 -9 -12];
    end              
    sampleRate = obj.channel.sampleRate;
    tau = obj.channel.tau;
    pdB = obj.channel.pdB;    
    
    switch chanType
        case {'PHASED_ARRAY_STATIC', 'PHASED_ARRAY_DYNAMIC'}
            [da, dp] = loadSteeringVector(numTx);  % Амплитуда и фаза SteeringVector
            obj.channel.da = da;
            obj.channel.dp = dp;            
            
            if (chanType == "PHASED_ARRAY_STATIC")
                if (~isfield(obj.channel,'txAng'))
                    obj.channel.txAng = {0,90,180,270};
                end
            end

        case {'RAYL_SPECIAL'}
            if (~isfield(obj.channel,'seed'))
                obj.channel.seed = 95;
            end
            seed = obj.channel.seed;
        case {'SCATTERING_FLAT', 'SCATTERING_FREQ'}
            obj.channel.freqCarr = 40e9;
            obj.channel.nRays = 50;            
            cLight = physconst('LightSpeed');
            obj.channel.lambda = cLight/obj.channel.freqCarr;
            
            freqCarr = obj.channel.freqCarr;
            nRays = obj.channel.nRays; 
            
            antenna = phased.IsotropicAntennaElement('BackBaffled', true);
            arrayTx = phased.UCA('Element', antenna, 'NumElements', numTx);
            posTxElem = getElementPosition(arrayTx);
            arrayRx = cell(numUsers,1);
            posRxElem = cell(numUsers,1);
            for uIdx = 1:numUsers
                if numRxUsers(uIdx) <= 1
                    str = ["Для канала " chanType " нужно numRxUsers > 1"];
                    error(str);
                end
                arrayRx{uIdx} = phased.UCA('Element', antenna, 'NumElements', numRxUsers(uIdx));
                posRxElem{uIdx} = getElementPosition(arrayRx{uIdx})/obj.channel.lambda;
            end
            if (chanType == "SCATTERING_FREQ")
                posTx = [0;0;0];         % BS/Transmit array position, [x;y;z], meter
                maxRange = 1000;         % all MSs within maxRange meters of BS
                mobileRange = randi([1 maxRange], 1, numUsers);
                % Angles specified as [azimuth;elevation], az=[-180 180], el=[-90 90] elevation - угол места
                mobileAngle = [rand(1, numUsers)*360 - 180; rand(1, numUsers)*180 - 90]; % в градусах
                [xRx,yRx,zRx] = sph2cart(deg2rad(mobileAngle(1)), deg2rad(mobileAngle(2)), mobileRange);
                posRx = [xRx; yRx; zRx];
                
                scatBound = cell(numUsers,1);
                for uIdx = 1:numUsers
                    % Place scatterers randomly in a sphere around the Rx
                    %   similar to the one-ring model
                    posCtr = (posTx + posRx(:,uIdx))/2;           
                    radCtr = mobileRange(uIdx)*0.5;
                    scatBound{uIdx} = [posCtr(1)-radCtr posCtr(1)+radCtr; ...
                                        posCtr(2)-radCtr posCtr(2)+radCtr; ...
                                        0 0];
%                                       posCtr(3)-radCtr posCtr(3)+radCtr];
                end
            end
            
    end
    %% Создание канала
    channel = cell(numUsers,1);
    switch chanType
        case 'PHASED_ARRAY_STATIC'
            [~, channel] = createChannelByDnStatic(obj.channel, numRxUsers, numUsers); % для статичных углов
            obj.channel.filter = comm.internal.channel.ChannelFilter('SampleRate', sampleRate, 'PathDelays', tau);
            obj.channel = deleteFields(obj.channel, "seed");
        case 'PHASED_ARRAY_DYNAMIC'
            [~, channel] = createChannelByDn(obj.channel, numRxUsers, numUsers); % случайные углы
            obj.channel.filter = comm.internal.channel.ChannelFilter('SampleRate', sampleRate, 'PathDelays', tau);
            obj.channel = deleteFields(obj.channel, "seed", "txAng");
        case 'STATIC'
            rng(168)
            for uIdx = 1:numUsers
                channel{uIdx} = createStaticChannel(numTx, numRxUsers(uIdx));
            end
            obj.channel = clearStructExcept(obj.channel, "type");
        case 'RAYL'
            for uIdx = 1:numUsers
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
            for uIdx = 1:numUsers
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
        case 'SCATTERING_FLAT'
            rng(142);
            for uIdx = 1:numUsers
                channel{uIdx} = scatteringchanmtx(posTxElem, posRxElem{uIdx}, obj.channel.nRays);
            end
            obj.channel = clearStructExcept(obj.channel, "type", "nRays", "freqCarr", "lambda");
        case 'SCATTERING_FREQ'
            error("Канал SCATTERING_FREQ еще не готов, надо ввести учет задержки");
            for uIdx = 1:numUsers
                channel{uIdx} = phased.ScatteringMIMOChannel(...
                            'TransmitArray',                arrayTx,...
                            'ReceiveArray',                 arrayRx{uIdx},...
                            'PropagationSpeed',             cLight,...
                            'CarrierFrequency',             freqCarr,...
                            'SampleRate',                   sampleRate, ...
                            'SimulateDirectPath',           false, ...
                            'ChannelResponseOutputPort',    true, ...
                            'TransmitArrayPosition',        posTx,...
                            'ReceiveArrayPosition',         posRx(:,uIdx),...
                            'NumScatterers',                nRays, ...
                            'ScattererPositionBoundary',    scatBound{uIdx});
            %                 'SeedSource',                   'Property', ...
            %                 'Seed',                         prm.SEED);
            end
            obj.channel = clearStructExcept(obj.channel, "type", "nRays", "freqCarr", "lambda");
    end

end

