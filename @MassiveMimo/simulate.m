function simulate(obj)         
    snr = obj.sim.snr;
    minNumErrs = obj.sim.minNumErrs;
    maxNumSimulation = obj.sim.maxNumSimulation;
    maxNumZeroBER = obj.sim.maxNumZeroBER;
    numZeroBER = 0;
    
    ber = zeros(obj.main.numSTS, length(snr));
    capacity = zeros(obj.main.numUsers, length(snr));
    
    for indSNR = 1:length(snr)
        if (numZeroBER < maxNumZeroBER) 
            [berIter,capacityIter,numSim] = calcIter(obj,snr(indSNR),minNumErrs,maxNumSimulation);
            ber(:,indSNR) = berIter;
            capacity(:,indSNR) = capacityIter;

            if (ber == 0)
                numZeroBER = numZeroBER + 1;
            end 
            
            fprintf('Complete SNR = %d dB, simulations = %d \n', snr(indSNR), numSim);
        end
    end
    str = ['Complete ' obj.precoderType '\n'];
    fprintf(str);
    
    obj.sim = obj.sim.setBer(ber);
    obj.sim = obj.sim.setCapacity(capacity);
end

function C = mimoCapacitySINR(SINR_dB)
    % SINR - Б Да
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