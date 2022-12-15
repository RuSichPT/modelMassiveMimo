function simulate1(obj,numChannels)       
    checkChannel(obj);
    snr = obj.sim.snr;
    minNumErrs = obj.sim.minNumErrs;
    maxNumSimulation = obj.sim.maxNumSimulation;
    maxNumZeroBER = obj.sim.maxNumZeroBER;
    numZeroBER = 0;
    
    ber = zeros(obj.main.numSTS, length(snr));
    capacity = zeros(obj.main.numUsers, length(snr));
    
    numUsers = obj.main.numUsers;
    numSTS = obj.main.numSTS;
  
    for indSNR = 1:length(snr)
        if (numZeroBER < maxNumZeroBER)
            berChan = zeros(numSTS,numChannels);
            capacityChan = zeros(numUsers,numChannels);
            numSimChan = zeros(1,numChannels);

            for indChan = 1:numChannels
                anglesTx = getRandomCellAngs(obj.main.numUsers);
                classChannel = class(obj.downChannel);
                if classChannel == "LOSSpecialChannelIzo"
                    los = LOSSpecialChannelIzo('sysconf',obj.main,'anglesTx',anglesTx);
                else
                    los = LOSSpecialChannelCust('sysconf',obj.main,'anglesTx',anglesTx);
                end
                obj.setChannel(los);
                [berChan(:,indChan),capacityChan(:,indChan),numSimChan(indChan)]...
                    = calcIter(obj,snr(indSNR),minNumErrs,maxNumSimulation);
                str = ['Complete channel = ' num2str(indChan) ', angles = ' num2str(cat(2,anglesTx{:})) newline];
                fprintf(str);
            end
            berIter = mean(berChan,2);
            capacityIter = mean(capacityChan,2);
            numSim = mean(numSimChan);
            ber(:,indSNR) = berIter;
            capacity(:,indSNR) = capacityIter;
            
            if (ber == 0)
                numZeroBER = numZeroBER + 1;
            end 
            str = ['Complete SNR = ' num2str(snr(indSNR)) ' dB, simulations = ' num2str(numSim) newline];
            fprintf(str);
        end
    end
    str = ['Complete ' obj.precoderType '\n'];
    fprintf(str);
        
    obj.sim = obj.sim.setBer(ber);
    obj.sim = obj.sim.setCapacity(capacity);
end

function checkChannel(obj)
    if ~isscalar(obj.downChannel)
        error('Канал не найден! Установите канал!');
    end
    
    if obj.downChannel.sysconf.numTx ~= obj.main.numTx
        error('Количество numTx в модели и в канале не совпадает');
    end
    
    if obj.downChannel.sysconf.numRx ~= obj.main.numRx
        error('Количество numRx в модели и в канале не совпадает');
    end
    
    if obj.downChannel.sysconf.numRxUsers ~= obj.main.numRxUsers
        error('Количество numRxUsers в модели и в канале не совпадает');
    end
    
    if obj.downChannel.sysconf.numUsers ~= obj.main.numUsers
        error('Количество numRxUsers в модели и в канале не совпадает');
    end
    
    if isprop(obj.downChannel,'anglesTx')
        if obj.main.numUsers ~= length(obj.downChannel.anglesTx)
            error('В канале количество numUsers не совпадает c length(anglesTx)');
        end
    end
end
function C = mimoCapacitySINR(SINR_dB)
    % SINR - в дБ
    SINR = 10^(SINR_dB/10);

    C = log2(1+SINR);
end

function [ber,capacity,numSim] = calcIter(obj,snr,minNumErrs,maxNumSimulation)   
    coefConfInt = obj.sim.coefConfInterval;
    numUsers = obj.main.numUsers;
    indSim = 0;
    allNumErrors = 0;
    allNumBits = 0; 
    condition = 1;
    capacityTmp = zeros(maxNumSimulation,numUsers);
    while ( condition && (indSim < maxNumSimulation) )
        indSim = indSim + 1;
        % BER
        [numErrors,numBits,SINR_dB] = obj.simulateOneSNR(snr);

        allNumErrors = allNumErrors + numErrors;
        allNumBits = allNumBits + numBits;

        [berconf, lenConfInterval] = obj.sim.calculateBER(allNumErrors,allNumBits,obj.main.numSTS);
        maxConfidenceInterval = berconf * coefConfInt;

        condition = max(((lenConfInterval > maxConfidenceInterval)|(numErrors < minNumErrs)));

        % Capacity
        for uIdx = 1:numUsers
            capacityTmp(indSim,uIdx) = mimoCapacitySINR(SINR_dB(uIdx));
        end
    end
    ber = berconf;
    capacity = mean(capacityTmp,1);
    numSim = indSim;
end
function angCell = getRandomCellAngs(numUsers)
    angCell = cell(numUsers,1);
    for i = 1:numUsers
        angCell{i} = randi(121) - 61;
    end
end